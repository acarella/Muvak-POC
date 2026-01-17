import Foundation
import Combine

struct SessionListDependencies {
    var sessionService: SessionListService

    static let live = SessionListDependencies(
        sessionService: .live
    )

    static let mock = SessionListDependencies(
        sessionService: .mock
    )
}

struct SessionListService {
    var fetchSessions: () -> AnyPublisher<[Session], Error>
}

extension SessionListService {
    static let live = SessionListService(
        fetchSessions: {
            Just([Session.mockRelaxSession, Session.mockFocusSession, Session.mockCalmingSession])
                .setFailureType(to: Error.self)
                .delay(for: .milliseconds(500), scheduler: DispatchQueue.main)
                .eraseToAnyPublisher()
        }
    )

    static let mock = SessionListService(
        fetchSessions: {
            Just([Session.mockRelaxSession, Session.mockFocusSession, Session.mockCalmingSession])
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
    )

    static func mockWithError(_ error: Error) -> SessionListService {
        SessionListService(
            fetchSessions: {
                Fail(error: error).eraseToAnyPublisher()
            }
        )
    }
}
