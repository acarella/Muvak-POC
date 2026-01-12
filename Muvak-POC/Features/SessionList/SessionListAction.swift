import Foundation

enum SessionListAction: Equatable {
    case viewAppeared
    case sessionsLoaded(Result<[Session], EquatableError>)
    case sessionTapped(Session)
}
