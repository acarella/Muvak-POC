import Foundation

enum SessionDetailAction: Equatable {
    // MARK: - Lifecycle
    case viewAppeared(sessionId: String)
    case viewDisappeared

    // MARK: - Data Loading Responses
    case sessionLoaded(Result<Session, EquatableError>)
    case performanceLoaded(Result<SessionPerformance, EquatableError>)
    case experienceLoaded(Result<SessionExperience, EquatableError>)

    // MARK: - Player Controls
    case playPauseTapped
    case timerTicked
    case repeatTapped
    case skipTapped

    // MARK: - Action Buttons
    case bookmarkTapped
    case downloadTapped
    case likeTapped
    case dislikeTapped

    // MARK: - Placeholder Actions
    case volumeTapped
    case fullscreenTapped
    case moreOptionsTapped

    // MARK: - Navigation
    case backButtonTapped
    case endSessionTapped
    case searchTapped
    case menuTapped
}
