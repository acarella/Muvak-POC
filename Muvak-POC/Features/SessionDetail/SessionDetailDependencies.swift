import Foundation
import Combine

// MARK: - Witness Types

struct SessionService {
    var fetchSession: (String) -> AnyPublisher<Session, Error>
    var fetchPerformance: (String) -> AnyPublisher<SessionPerformance, Error>
    var fetchExperience: (String) -> AnyPublisher<SessionExperience, Error>
}

struct TimerService {
    var startTimer: (TimeInterval) -> AnyPublisher<Date, Never>
    var stopTimer: () -> Void
}

// MARK: - Dependencies Container

struct SessionDetailDependencies {
    var sessionService: SessionService
    var timerService: TimerService
    var dateGenerator: () -> Date
    var uuid: () -> UUID

    // MARK: - Live Implementation

    static let live = SessionDetailDependencies(
        sessionService: .live,
        timerService: .live,
        dateGenerator: Date.init,
        uuid: UUID.init
    )

    // MARK: - Mock Implementation

    static let mock = SessionDetailDependencies(
        sessionService: .mock,
        timerService: .mock,
        dateGenerator: { Date(timeIntervalSince1970: 1715875200) },
        uuid: { UUID(uuidString: "00000000-0000-0000-0000-000000000000")! }
    )
}

// MARK: - SessionService Implementations

extension SessionService {
    static let live = SessionService(
        fetchSession: { _ in
            Just(Session.mockRelaxSession)
                .setFailureType(to: Error.self)
                .delay(for: .milliseconds(500), scheduler: DispatchQueue.main)
                .eraseToAnyPublisher()
        },
        fetchPerformance: { _ in
            Just(SessionPerformance.mockPerformance)
                .setFailureType(to: Error.self)
                .delay(for: .milliseconds(300), scheduler: DispatchQueue.main)
                .eraseToAnyPublisher()
        },
        fetchExperience: { _ in
            Just(SessionExperience.mockExperience)
                .setFailureType(to: Error.self)
                .delay(for: .milliseconds(300), scheduler: DispatchQueue.main)
                .eraseToAnyPublisher()
        }
    )

    static let mock = SessionService(
        fetchSession: { _ in
            Just(Session.mockRelaxSession)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        },
        fetchPerformance: { _ in
            Just(SessionPerformance.mockPerformance)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        },
        fetchExperience: { _ in
            Just(SessionExperience.mockExperience)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
    )

    static func mockWithError(_ error: Error) -> SessionService {
        SessionService(
            fetchSession: { _ in
                Fail(error: error).eraseToAnyPublisher()
            },
            fetchPerformance: { _ in
                Fail(error: error).eraseToAnyPublisher()
            },
            fetchExperience: { _ in
                Fail(error: error).eraseToAnyPublisher()
            }
        )
    }
}

// MARK: - TimerService Implementations

extension TimerService {
    static let live = TimerService(
        startTimer: { interval in
            Timer.publish(every: interval, on: .main, in: .common)
                .autoconnect()
                .eraseToAnyPublisher()
        },
        stopTimer: {}
    )

    static let mock = TimerService(
        startTimer: { _ in
            Empty<Date, Never>().eraseToAnyPublisher()
        },
        stopTimer: {}
    )
}
