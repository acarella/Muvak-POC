import XCTest
import Combine
@testable import Muvak_POC

final class SessionDetailReducerTests: XCTestCase {

    // MARK: - Lifecycle Tests

    func testViewAppeared_SetsLoadingState() {
        var state = SessionDetailState()
        let dependencies = SessionDetailDependencies.mock

        let effect = sessionDetailReducer(
            state: &state,
            action: .viewAppeared(sessionId: "session-001"),
            dependencies: dependencies
        )

        XCTAssertTrue(state.isLoading)
        XCTAssertNil(state.errorMessage)
        XCTAssertNotNil(effect, "Should return effect for data loading")
    }

    func testViewDisappeared_StopsPlayback() {
        var state = SessionDetailState()
        state.isPlaying = true
        let dependencies = SessionDetailDependencies.mock

        let effect = sessionDetailReducer(
            state: &state,
            action: .viewDisappeared,
            dependencies: dependencies
        )

        XCTAssertFalse(state.isPlaying)
        XCTAssertNil(effect)
    }

    // MARK: - Data Loading Tests

    func testSessionLoaded_Success_UpdatesState() {
        var state = SessionDetailState(isLoading: true)
        let dependencies = SessionDetailDependencies.mock
        let mockSession = Session.mockRelaxSession

        let effect = sessionDetailReducer(
            state: &state,
            action: .sessionLoaded(.success(mockSession)),
            dependencies: dependencies
        )

        XCTAssertFalse(state.isLoading)
        XCTAssertEqual(state.session, mockSession)
        XCTAssertNil(state.errorMessage)
        XCTAssertNil(effect)
    }

    func testSessionLoaded_Failure_SetsError() {
        var state = SessionDetailState(isLoading: true)
        let dependencies = SessionDetailDependencies.mock
        let error = EquatableError(message: "Network error")

        let effect = sessionDetailReducer(
            state: &state,
            action: .sessionLoaded(.failure(error)),
            dependencies: dependencies
        )

        XCTAssertFalse(state.isLoading)
        XCTAssertNil(state.session)
        XCTAssertEqual(state.errorMessage, "Network error")
        XCTAssertNil(effect)
    }

    func testPerformanceLoaded_Success_UpdatesState() {
        var state = SessionDetailState()
        let dependencies = SessionDetailDependencies.mock
        let mockPerformance = SessionPerformance.mockPerformance

        let effect = sessionDetailReducer(
            state: &state,
            action: .performanceLoaded(.success(mockPerformance)),
            dependencies: dependencies
        )

        XCTAssertEqual(state.performance, mockPerformance)
        XCTAssertNil(effect)
    }

    func testExperienceLoaded_Success_UpdatesState() {
        var state = SessionDetailState()
        let dependencies = SessionDetailDependencies.mock
        let mockExperience = SessionExperience.mockExperience

        let effect = sessionDetailReducer(
            state: &state,
            action: .experienceLoaded(.success(mockExperience)),
            dependencies: dependencies
        )

        XCTAssertEqual(state.experience, mockExperience)
        XCTAssertNil(effect)
    }

    // MARK: - Player Control Tests

    func testPlayPauseTapped_TogglesPlayState() {
        var state = SessionDetailState()
        state.isPlaying = false
        let dependencies = SessionDetailDependencies.mock

        let effect = sessionDetailReducer(
            state: &state,
            action: .playPauseTapped,
            dependencies: dependencies
        )

        XCTAssertTrue(state.isPlaying)
        XCTAssertNotNil(effect, "Should return timer effect when starting playback")
    }

    func testPlayPauseTapped_PauseStopsTimer() {
        var state = SessionDetailState()
        state.isPlaying = true
        let dependencies = SessionDetailDependencies.mock

        let effect = sessionDetailReducer(
            state: &state,
            action: .playPauseTapped,
            dependencies: dependencies
        )

        XCTAssertFalse(state.isPlaying)
        XCTAssertNil(effect, "Should not return effect when pausing")
    }

    func testTimerTicked_IncrementsElapsedTime() {
        var state = SessionDetailState()
        state.isPlaying = true
        state.elapsedTime = 150
        state.session = Session.mockRelaxSession
        let dependencies = SessionDetailDependencies.mock

        let effect = sessionDetailReducer(
            state: &state,
            action: .timerTicked,
            dependencies: dependencies
        )

        XCTAssertEqual(state.elapsedTime, 151)
        XCTAssertNil(effect)
    }

    func testTimerTicked_WhenNotPlaying_DoesNotIncrement() {
        var state = SessionDetailState()
        state.isPlaying = false
        state.elapsedTime = 150
        let dependencies = SessionDetailDependencies.mock

        let effect = sessionDetailReducer(
            state: &state,
            action: .timerTicked,
            dependencies: dependencies
        )

        XCTAssertEqual(state.elapsedTime, 150)
        XCTAssertNil(effect)
    }

    func testTimerTicked_AtEnd_StopsPlayback() {
        var state = SessionDetailState()
        state.isPlaying = true
        state.session = Session.mockRelaxSession
        state.elapsedTime = Session.mockRelaxSession.totalDuration
        let dependencies = SessionDetailDependencies.mock

        let effect = sessionDetailReducer(
            state: &state,
            action: .timerTicked,
            dependencies: dependencies
        )

        XCTAssertFalse(state.isPlaying)
        XCTAssertEqual(state.elapsedTime, Session.mockRelaxSession.totalDuration)
        XCTAssertNil(effect)
    }

    func testRepeatTapped_ResetsElapsedTime() {
        var state = SessionDetailState()
        state.elapsedTime = 300
        let dependencies = SessionDetailDependencies.mock

        let effect = sessionDetailReducer(
            state: &state,
            action: .repeatTapped,
            dependencies: dependencies
        )

        XCTAssertEqual(state.elapsedTime, 0)
        XCTAssertNil(effect)
    }

    func testSkipTapped_SkipsForward15Seconds() {
        var state = SessionDetailState()
        state.session = Session.mockRelaxSession
        state.elapsedTime = 100
        let dependencies = SessionDetailDependencies.mock

        let effect = sessionDetailReducer(
            state: &state,
            action: .skipTapped,
            dependencies: dependencies
        )

        XCTAssertEqual(state.elapsedTime, 115)
        XCTAssertNil(effect)
    }

    func testSkipTapped_DoesNotExceedDuration() {
        var state = SessionDetailState()
        state.session = Session.mockRelaxSession
        state.elapsedTime = 895
        let dependencies = SessionDetailDependencies.mock

        let effect = sessionDetailReducer(
            state: &state,
            action: .skipTapped,
            dependencies: dependencies
        )

        XCTAssertEqual(state.elapsedTime, 900)
        XCTAssertNil(effect)
    }

    // MARK: - Action Button Tests

    func testBookmarkTapped_TogglesBookmark() {
        var state = SessionDetailState()
        state.isBookmarked = false
        let dependencies = SessionDetailDependencies.mock

        _ = sessionDetailReducer(
            state: &state,
            action: .bookmarkTapped,
            dependencies: dependencies
        )

        XCTAssertTrue(state.isBookmarked)

        _ = sessionDetailReducer(
            state: &state,
            action: .bookmarkTapped,
            dependencies: dependencies
        )

        XCTAssertFalse(state.isBookmarked)
    }

    func testDownloadTapped_TogglesDownload() {
        var state = SessionDetailState()
        state.isDownloaded = false
        let dependencies = SessionDetailDependencies.mock

        _ = sessionDetailReducer(
            state: &state,
            action: .downloadTapped,
            dependencies: dependencies
        )

        XCTAssertTrue(state.isDownloaded)
    }

    func testLikeTapped_TogglesLikeAndClearsDislike() {
        var state = SessionDetailState()
        state.isDisliked = true
        state.isLiked = false
        let dependencies = SessionDetailDependencies.mock

        _ = sessionDetailReducer(
            state: &state,
            action: .likeTapped,
            dependencies: dependencies
        )

        XCTAssertTrue(state.isLiked)
        XCTAssertFalse(state.isDisliked, "Dislike should be cleared when liking")
    }

    func testDislikeTapped_TogglesDislikeAndClearsLike() {
        var state = SessionDetailState()
        state.isLiked = true
        state.isDisliked = false
        let dependencies = SessionDetailDependencies.mock

        _ = sessionDetailReducer(
            state: &state,
            action: .dislikeTapped,
            dependencies: dependencies
        )

        XCTAssertTrue(state.isDisliked)
        XCTAssertFalse(state.isLiked, "Like should be cleared when disliking")
    }

    // MARK: - Navigation Tests

    func testEndSessionTapped_StopsPlaybackIfPlaying() {
        var state = SessionDetailState()
        state.isPlaying = true
        let dependencies = SessionDetailDependencies.mock

        let effect = sessionDetailReducer(
            state: &state,
            action: .endSessionTapped,
            dependencies: dependencies
        )

        XCTAssertFalse(state.isPlaying)
        XCTAssertNil(effect)
    }

    // MARK: - Computed Property Tests

    func testFormattedElapsedTime() {
        var state = SessionDetailState()
        state.elapsedTime = 150

        XCTAssertEqual(state.formattedElapsedTime, "02:30")
    }

    func testFormattedTotalDuration() {
        var state = SessionDetailState()
        state.session = Session.mockRelaxSession

        XCTAssertEqual(state.formattedTotalDuration, "15:00")
    }

    func testFormattedTotalDuration_NoSession() {
        let state = SessionDetailState()

        XCTAssertEqual(state.formattedTotalDuration, "--:--")
    }
}
