import Foundation
import Combine

func sessionDetailReducer(
    state: inout SessionDetailState,
    action: SessionDetailAction,
    dependencies: SessionDetailDependencies
) -> AnyPublisher<SessionDetailAction, Never>? {
    switch action {

    // MARK: - Lifecycle

    case .viewAppeared(let sessionId):
        state.isLoading = true
        state.errorMessage = nil

        let sessionEffect = dependencies.sessionService
            .fetchSession(sessionId)
            .map { SessionDetailAction.sessionLoaded(.success($0)) }
            .catch { Just(SessionDetailAction.sessionLoaded(.failure(EquatableError($0)))) }

        let performanceEffect = dependencies.sessionService
            .fetchPerformance(sessionId)
            .map { SessionDetailAction.performanceLoaded(.success($0)) }
            .catch { Just(SessionDetailAction.performanceLoaded(.failure(EquatableError($0)))) }

        let experienceEffect = dependencies.sessionService
            .fetchExperience(sessionId)
            .map { SessionDetailAction.experienceLoaded(.success($0)) }
            .catch { Just(SessionDetailAction.experienceLoaded(.failure(EquatableError($0)))) }

        return Publishers.Merge3(sessionEffect, performanceEffect, experienceEffect)
            .eraseToAnyPublisher()

    case .viewDisappeared:
        state.isPlaying = false
        dependencies.timerService.stopTimer()
        return nil

    // MARK: - Data Loading Responses

    case .sessionLoaded(.success(let session)):
        state.session = session
        state.isLoading = false
        return nil

    case .sessionLoaded(.failure(let error)):
        state.isLoading = false
        state.errorMessage = error.localizedDescription
        return nil

    case .performanceLoaded(.success(let performance)):
        state.performance = performance
        return nil

    case .performanceLoaded(.failure):
        return nil

    case .experienceLoaded(.success(let experience)):
        state.experience = experience
        return nil

    case .experienceLoaded(.failure):
        return nil

    // MARK: - Player Controls

    case .playPauseTapped:
        state.isPlaying.toggle()

        if state.isPlaying {
            return dependencies.timerService
                .startTimer(1.0)
                .map { _ in SessionDetailAction.timerTicked }
                .eraseToAnyPublisher()
        } else {
            dependencies.timerService.stopTimer()
            return nil
        }

    case .timerTicked:
        guard state.isPlaying else { return nil }

        if let session = state.session, state.elapsedTime >= session.totalDuration {
            state.isPlaying = false
            state.elapsedTime = session.totalDuration
            dependencies.timerService.stopTimer()
            return nil
        }

        state.elapsedTime += 1
        return nil

    case .repeatTapped:
        state.elapsedTime = 0
        return nil

    case .skipTapped:
        if let session = state.session {
            state.elapsedTime = min(state.elapsedTime + 15, session.totalDuration)
        }
        return nil

    // MARK: - Action Buttons

    case .bookmarkTapped:
        state.isBookmarked.toggle()
        return nil

    case .downloadTapped:
        state.isDownloaded.toggle()
        return nil

    case .likeTapped:
        state.isLiked.toggle()
        if state.isLiked {
            state.isDisliked = false
        }
        return nil

    case .dislikeTapped:
        state.isDisliked.toggle()
        if state.isDisliked {
            state.isLiked = false
        }
        return nil

    // MARK: - Placeholder Actions

    case .volumeTapped, .fullscreenTapped, .moreOptionsTapped:
        return nil

    // MARK: - Navigation

    case .backButtonTapped, .endSessionTapped, .searchTapped, .menuTapped:
        if state.isPlaying {
            state.isPlaying = false
            dependencies.timerService.stopTimer()
        }
        return nil
    }
}
