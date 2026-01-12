import XCTest
import Combine
@testable import Muvak_POC

@MainActor
final class SessionDetailStoreTests: XCTestCase {
    private var cancellables: Set<AnyCancellable>!

    override func setUp() async throws {
        try await super.setUp()
        cancellables = []
    }

    override func tearDown() async throws {
        cancellables = nil
        try await super.tearDown()
    }

    func testViewAppeared_LoadsDataSuccessfully() async throws {
        let expectation = expectation(description: "Data loaded")
        expectation.assertForOverFulfill = false

        let store = SessionDetailStore(
            initialState: SessionDetailState(),
            dependencies: .mock
        )

        store.$state
            .dropFirst()
            .sink { state in
                if state.session != nil && !state.isLoading {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        store.send(.viewAppeared(sessionId: "session-001"))

        await fulfillment(of: [expectation], timeout: 2.0)

        XCTAssertNotNil(store.state.session)
        XCTAssertFalse(store.state.isLoading)
        XCTAssertNil(store.state.errorMessage)
    }

    func testPlayPause_TogglesState() async throws {
        var initialState = SessionDetailState()
        initialState.session = Session.mockRelaxSession

        let store = SessionDetailStore(
            initialState: initialState,
            dependencies: .mock
        )

        XCTAssertFalse(store.state.isPlaying)

        store.send(.playPauseTapped)
        XCTAssertTrue(store.state.isPlaying)

        store.send(.playPauseTapped)
        XCTAssertFalse(store.state.isPlaying)
    }

    func testActionButtons_ToggleIndependently() async throws {
        let store = SessionDetailStore(
            initialState: SessionDetailState(),
            dependencies: .mock
        )

        store.send(.bookmarkTapped)
        XCTAssertTrue(store.state.isBookmarked)

        store.send(.downloadTapped)
        XCTAssertTrue(store.state.isDownloaded)
        XCTAssertTrue(store.state.isBookmarked)

        store.send(.likeTapped)
        XCTAssertTrue(store.state.isLiked)

        store.send(.dislikeTapped)
        XCTAssertTrue(store.state.isDisliked)
        XCTAssertFalse(store.state.isLiked)
    }

    func testMultipleActions_MaintainsConsistentState() async throws {
        var initialState = SessionDetailState()
        initialState.session = Session.mockRelaxSession

        let store = SessionDetailStore(
            initialState: initialState,
            dependencies: .mock
        )

        store.send(.playPauseTapped)
        store.send(.bookmarkTapped)
        store.send(.downloadTapped)
        store.send(.likeTapped)
        store.send(.skipTapped)

        XCTAssertTrue(store.state.isPlaying)
        XCTAssertTrue(store.state.isBookmarked)
        XCTAssertTrue(store.state.isDownloaded)
        XCTAssertTrue(store.state.isLiked)
        XCTAssertEqual(store.state.elapsedTime, 15)
    }

    func testEndSession_StopsPlayback() async throws {
        var initialState = SessionDetailState()
        initialState.session = Session.mockRelaxSession
        initialState.isPlaying = true
        initialState.elapsedTime = 100

        let store = SessionDetailStore(
            initialState: initialState,
            dependencies: .mock
        )

        store.send(.endSessionTapped)

        XCTAssertFalse(store.state.isPlaying)
    }

    func testRepeat_ResetsElapsedTime() async throws {
        var initialState = SessionDetailState()
        initialState.session = Session.mockRelaxSession
        initialState.elapsedTime = 300

        let store = SessionDetailStore(
            initialState: initialState,
            dependencies: .mock
        )

        store.send(.repeatTapped)

        XCTAssertEqual(store.state.elapsedTime, 0)
    }

    func testSkip_AdvancesTime() async throws {
        var initialState = SessionDetailState()
        initialState.session = Session.mockRelaxSession
        initialState.elapsedTime = 100

        let store = SessionDetailStore(
            initialState: initialState,
            dependencies: .mock
        )

        store.send(.skipTapped)

        XCTAssertEqual(store.state.elapsedTime, 115)
    }
}
