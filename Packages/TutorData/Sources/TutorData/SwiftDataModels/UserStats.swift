import Foundation
import SwiftData

@Model
public final class UserStats {
    public var id: UUID = UUID()
    public var totalXP: Int = 0
    public var currentLevel: Int = 1
    public var currentStreak: Int = 0
    public var longestStreak: Int = 0
    public var lastActiveDate: Date?
    public var totalStudyMinutes: Int = 0
    public var totalCardsReviewed: Int = 0
    public var totalQuizzesCompleted: Int = 0

    public var user: UserProfile?

    @Relationship(deleteRule: .cascade, inverse: \DailyActivity.stats)
    public var dailyActivities: [DailyActivity]?

    public init() {
        self.id = UUID()
    }
}

@Model
public final class DailyActivity {
    public var id: UUID = UUID()
    public var date: Date = Date()
    public var xpEarned: Int = 0
    public var studyMinutes: Int = 0
    public var cardsReviewed: Int = 0
    public var quizzesCompleted: Int = 0
    public var lessonsCompleted: Int = 0

    public var stats: UserStats?

    public init(date: Date = Date()) {
        self.id = UUID()
        self.date = date
    }
}
