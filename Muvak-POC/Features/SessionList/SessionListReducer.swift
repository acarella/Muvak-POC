import Foundation
import Combine

func sessionListReducer(
    state: inout SessionListState,
    action: SessionListAction,
    dependencies: SessionListDependencies
) -> AnyPublisher<SessionListAction, Never>? {
    switch action {
    case .viewAppeared:
        guard state.sessions.isEmpty else { return nil }

        state.isLoading = true
        state.errorMessage = nil

        return dependencies.sessionService
            .fetchSessions()
            .map { SessionListAction.sessionsLoaded(.success($0)) }
            .catch { Just(SessionListAction.sessionsLoaded(.failure(EquatableError($0)))) }
            .eraseToAnyPublisher()

    case .sessionsLoaded(.success(let sessions)):
        state.isLoading = false
        state.sessions = sessions
        return nil

    case .sessionsLoaded(.failure(let error)):
        state.isLoading = false
        state.errorMessage = error.localizedDescription
        return nil

    case .sessionTapped:
        return nil
    }
}
