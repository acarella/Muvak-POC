import XCTest
import Combine
@testable import Muvak_POC

final class SessionListReducerTests: XCTestCase {

    func testViewAppeared_SetsLoadingState() {
        var state = SessionListState()
        let dependencies = SessionListDependencies.mock

        let effect = sessionListReducer(
            state: &state,
            action: .viewAppeared,
            dependencies: dependencies
        )

        XCTAssertTrue(state.isLoading)
        XCTAssertNil(state.errorMessage)
        XCTAssertNotNil(effect)
    }

    func testViewAppeared_WhenAlreadyLoaded_DoesNotReload() {
        var state = SessionListState()
        state.sessions = [Session.mockRelaxSession]
        let dependencies = SessionListDependencies.mock

        let effect = sessionListReducer(
            state: &state,
            action: .viewAppeared,
            dependencies: dependencies
        )

        XCTAssertFalse(state.isLoading)
        XCTAssertNil(effect)
    }

    func testSessionsLoaded_Success_UpdatesState() {
        var state = SessionListState(isLoading: true)
        let dependencies = SessionListDependencies.mock
        let sessions = [Session.mockRelaxSession, Session.mockFocusSession]

        let effect = sessionListReducer(
            state: &state,
            action: .sessionsLoaded(.success(sessions)),
            dependencies: dependencies
        )

        XCTAssertFalse(state.isLoading)
        XCTAssertEqual(state.sessions.count, 2)
        XCTAssertNil(state.errorMessage)
        XCTAssertNil(effect)
    }

    func testSessionsLoaded_Failure_SetsError() {
        var state = SessionListState(isLoading: true)
        let dependencies = SessionListDependencies.mock
        let error = EquatableError(message: "Failed to load")

        let effect = sessionListReducer(
            state: &state,
            action: .sessionsLoaded(.failure(error)),
            dependencies: dependencies
        )

        XCTAssertFalse(state.isLoading)
        XCTAssertTrue(state.sessions.isEmpty)
        XCTAssertEqual(state.errorMessage, "Failed to load")
        XCTAssertNil(effect)
    }

    func testSessionTapped_DoesNotChangeState() {
        var state = SessionListState()
        state.sessions = [Session.mockRelaxSession]
        let dependencies = SessionListDependencies.mock

        let effect = sessionListReducer(
            state: &state,
            action: .sessionTapped(Session.mockRelaxSession),
            dependencies: dependencies
        )

        XCTAssertEqual(state.sessions.count, 1)
        XCTAssertNil(effect)
    }
}

@MainActor
final class SessionListStoreTests: XCTestCase {
    private var cancellables: Set<AnyCancellable>!

    override func setUp() async throws {
        try await super.setUp()
        cancellables = []
    }

    override func tearDown() async throws {
        cancellables = nil
        try await super.tearDown()
    }

    func testViewAppeared_LoadsSessionsSuccessfully() async throws {
        let expectation = expectation(description: "Sessions loaded")
        expectation.assertForOverFulfill = false

        let store = SessionListStore(
            initialState: SessionListState(),
            dependencies: .mock
        )

        store.$state
            .dropFirst()
            .sink { state in
                if !state.sessions.isEmpty && !state.isLoading {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        store.send(.viewAppeared)

        await fulfillment(of: [expectation], timeout: 2.0)

        XCTAssertEqual(store.state.sessions.count, 3)
        XCTAssertFalse(store.state.isLoading)
        XCTAssertNil(store.state.errorMessage)
    }

    func testViewAppeared_WhenAlreadyLoaded_DoesNotReload() async throws {
        var initialState = SessionListState()
        initialState.sessions = [Session.mockRelaxSession]

        let store = SessionListStore(
            initialState: initialState,
            dependencies: .mock
        )

        store.send(.viewAppeared)

        XCTAssertEqual(store.state.sessions.count, 1)
        XCTAssertFalse(store.state.isLoading)
    }

    func testErrorState() async throws {
        let expectation = expectation(description: "Error received")
        expectation.assertForOverFulfill = false

        let mockError = NSError(domain: "test", code: 1, userInfo: [NSLocalizedDescriptionKey: "Network error"])

        let store = SessionListStore(
            initialState: SessionListState(),
            dependencies: SessionListDependencies(
                sessionService: .mockWithError(mockError)
            )
        )

        store.$state
            .dropFirst()
            .sink { state in
                if state.errorMessage != nil {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        store.send(.viewAppeared)

        await fulfillment(of: [expectation], timeout: 2.0)

        XCTAssertNotNil(store.state.errorMessage)
        XCTAssertFalse(store.state.isLoading)
    }
}
