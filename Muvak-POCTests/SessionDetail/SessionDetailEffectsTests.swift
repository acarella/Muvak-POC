import XCTest
import Combine
@testable import Muvak_POC

final class SessionDetailEffectsTests: XCTestCase {
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        cancellables = Set<AnyCancellable>()
    }

    override func tearDown() {
        cancellables = nil
        super.tearDown()
    }

    func testViewAppeared_EmitsSessionLoadedSuccess() {
        let expectation = expectation(description: "Session loaded")
        var state = SessionDetailState()
        let dependencies = SessionDetailDependencies.mock

        let effect = sessionDetailReducer(
            state: &state,
            action: .viewAppeared(sessionId: "session-001"),
            dependencies: dependencies
        )

        var receivedActions: [SessionDetailAction] = []

        effect?
            .sink { action in
                receivedActions.append(action)
                if case .sessionLoaded(.success) = action {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 2.0)

        XCTAssertTrue(receivedActions.contains { action in
            if case .sessionLoaded(.success) = action { return true }
            return false
        })
    }

    func testViewAppeared_EmitsPerformanceLoaded() {
        let expectation = expectation(description: "Performance loaded")
        var state = SessionDetailState()
        let dependencies = SessionDetailDependencies.mock

        let effect = sessionDetailReducer(
            state: &state,
            action: .viewAppeared(sessionId: "session-001"),
            dependencies: dependencies
        )

        var receivedActions: [SessionDetailAction] = []

        effect?
            .sink { action in
                receivedActions.append(action)
                if case .performanceLoaded(.success) = action {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 2.0)

        XCTAssertTrue(receivedActions.contains { action in
            if case .performanceLoaded(.success) = action { return true }
            return false
        })
    }

    func testViewAppeared_EmitsExperienceLoaded() {
        let expectation = expectation(description: "Experience loaded")
        var state = SessionDetailState()
        let dependencies = SessionDetailDependencies.mock

        let effect = sessionDetailReducer(
            state: &state,
            action: .viewAppeared(sessionId: "session-001"),
            dependencies: dependencies
        )

        var receivedActions: [SessionDetailAction] = []

        effect?
            .sink { action in
                receivedActions.append(action)
                if case .experienceLoaded(.success) = action {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 2.0)

        XCTAssertTrue(receivedActions.contains { action in
            if case .experienceLoaded(.success) = action { return true }
            return false
        })
    }

    func testViewAppeared_WithError_EmitsFailure() {
        let expectation = expectation(description: "Error emitted")
        var state = SessionDetailState()
        let mockError = NSError(domain: "test", code: 1, userInfo: [NSLocalizedDescriptionKey: "Network error"])
        let dependencies = SessionDetailDependencies(
            sessionService: .mockWithError(mockError),
            timerService: .mock,
            dateGenerator: { Date() },
            uuid: { UUID() }
        )

        let effect = sessionDetailReducer(
            state: &state,
            action: .viewAppeared(sessionId: "session-001"),
            dependencies: dependencies
        )

        effect?
            .sink { action in
                if case .sessionLoaded(.failure) = action {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 2.0)
    }
}
