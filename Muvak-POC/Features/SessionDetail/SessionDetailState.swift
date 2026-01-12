import Foundation

struct SessionDetailState: Equatable {
    // MARK: - Session Data
    var session: Session?
    var performance: SessionPerformance?
    var experience: SessionExperience?

    // MARK: - Loading States
    var isLoading: Bool = false
    var errorMessage: String?

    // MARK: - Player State
    var isPlaying: Bool = false
    var elapsedTime: TimeInterval = 0

    // MARK: - Action Button States
    var isBookmarked: Bool = false
    var isDownloaded: Bool = false
    var isLiked: Bool = false
    var isDisliked: Bool = false

    // MARK: - Computed Properties

    var formattedElapsedTime: String {
        let minutes = Int(elapsedTime) / 60
        let seconds = Int(elapsedTime) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var formattedTotalDuration: String {
        guard let session = session else { return "--:--" }
        let minutes = Int(session.totalDuration) / 60
        let seconds = Int(session.totalDuration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var hasError: Bool { errorMessage != nil }
}
