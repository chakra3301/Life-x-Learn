import Foundation
import TutorCore

/// Manages XP awards and level calculations
public struct XPEngine: Sendable {

    public init() {}

    /// Award XP for completing an activity
    public func calculateXP(for activity: XPActivity, streakDays: Int = 0) -> Int {
        var xp = activity.baseXP

        // Streak bonus: +10% per streak day (capped at 100%)
        if streakDays > 0 {
            let streakMultiplier = min(2.0, 1.0 + Double(streakDays) * 0.1)
            xp = Int(Double(xp) * streakMultiplier)
        }

        return xp
    }

    /// Check if a level up occurred
    public func checkLevelUp(previousXP: Int, newXP: Int) -> LevelUpResult? {
        let previousLevel = LevelSystem.level(for: previousXP)
        let newLevel = LevelSystem.level(for: newXP)

        guard newLevel > previousLevel else { return nil }

        return LevelUpResult(
            previousLevel: previousLevel,
            newLevel: newLevel,
            totalXP: newXP
        )
    }
}

// MARK: - Supporting Types

public enum XPActivity: Sendable {
    case flashcardReview
    case quizCompletion(perfect: Bool)
    case dailyLesson
    case uploadContent
    case journalEntry
    case writingExercise

    public var baseXP: Int {
        switch self {
        case .flashcardReview: return LevelSystem.flashcardReviewXP
        case .quizCompletion(let perfect):
            return LevelSystem.quizCompletionXP + (perfect ? LevelSystem.perfectQuizBonusXP : 0)
        case .dailyLesson: return LevelSystem.dailyLessonXP
        case .uploadContent: return LevelSystem.uploadContentXP
        case .journalEntry: return LevelSystem.journalEntryXP
        case .writingExercise: return LevelSystem.writingExerciseXP
        }
    }
}

public struct LevelUpResult: Sendable {
    public let previousLevel: Int
    public let newLevel: Int
    public let totalXP: Int
}
