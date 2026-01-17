import Foundation

// MARK: - Session

struct Session: Equatable, Identifiable, Hashable {
    let id: String
    let title: String
    let type: SessionType
    let tags: [String]
    let rating: Double
    let totalDuration: TimeInterval
    let imageURL: String?
    let description: String

    enum SessionType: String, Equatable, Hashable {
        case relax = "Relax"
        case focus = "Focus"
        case sleep = "Sleep"
        case energy = "Energy"
    }
}

// MARK: - SessionPerformance

struct SessionPerformance: Equatable {
    let todayMinutes: Int
    let targetMinutes: Int
    let weeklyProgress: [DayProgress]
    let date: Date

    struct DayProgress: Equatable, Identifiable {
        let id: String
        let dayLetter: String
        let isCompleted: Bool
    }

    var progressPercentage: Double {
        guard targetMinutes > 0 else { return 0 }
        return min(Double(todayMinutes) / Double(targetMinutes), 1.0)
    }
}

// MARK: - SessionExperience

struct SessionExperience: Equatable {
    let level: ExperienceLevel
    let minutesToNextLevel: Int
    let description: String

    enum ExperienceLevel: String, Equatable {
        case beginner = "Beginner"
        case intermediate = "Intermediate"
        case advanced = "Advanced"
        case expert = "Expert"
    }
}

// MARK: - Equatable Error Wrapper

struct EquatableError: Error, Equatable {
    let message: String
    let code: Int

    init(_ error: Error) {
        self.message = error.localizedDescription
        self.code = (error as NSError).code
    }

    init(message: String, code: Int = 0) {
        self.message = message
        self.code = code
    }

    var localizedDescription: String { message }

    static func == (lhs: EquatableError, rhs: EquatableError) -> Bool {
        lhs.message == rhs.message && lhs.code == rhs.code
    }
}

// MARK: - Mock Data

extension Session {
    static let mockRelaxSession = Session(
        id: "session-001",
        title: "Relax Session",
        type: .relax,
        tags: ["Relax", "Long Session", "Sparse", "4.8"],
        rating: 4.8,
        totalDuration: 900,
        imageURL: nil,
        description: "A calming session designed to help you unwind and find inner peace."
    )

    static let mockFocusSession = Session(
        id: "session-002",
        title: "Focus Session",
        type: .focus,
        tags: ["Focus", "Short Session", "Intense"],
        rating: 4.5,
        totalDuration: 600,
        imageURL: nil,
        description: "Enhance your concentration and mental clarity."
    )

    static let mockCalmingSession = Session(
        id: "session-003",
        title: "Calming Session",
        type: .sleep,
        tags: ["Calm", "Gentle", "Evening"],
        rating: 4.9,
        totalDuration: 1200,
        imageURL: nil,
        description: "A gentle session to quiet your mind and prepare for restful sleep."
    )
}

extension SessionPerformance {
    static let mockPerformance = SessionPerformance(
        todayMinutes: 9,
        targetMinutes: 15,
        weeklyProgress: [
            DayProgress(id: "1", dayLetter: "S", isCompleted: true),
            DayProgress(id: "2", dayLetter: "M", isCompleted: true),
            DayProgress(id: "3", dayLetter: "T", isCompleted: true),
            DayProgress(id: "4", dayLetter: "W", isCompleted: true),
            DayProgress(id: "5", dayLetter: "T", isCompleted: true),
            DayProgress(id: "6", dayLetter: "F", isCompleted: true),
            DayProgress(id: "7", dayLetter: "S", isCompleted: true)
        ],
        date: Date(timeIntervalSince1970: 1715875200)
    )
}

extension SessionExperience {
    static let mockExperience = SessionExperience(
        level: .beginner,
        minutesToNextLevel: 45,
        description: "Practice 15 minutes daily for the next 2 weeks to level up your skill"
    )
}
