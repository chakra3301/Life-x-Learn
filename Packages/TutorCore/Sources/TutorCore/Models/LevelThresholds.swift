import Foundation

/// Defines XP thresholds for each level and related gamification constants
public enum LevelSystem {
    /// XP required to reach each level (index = level number)
    /// Level 1: 0 XP, Level 2: 100 XP, etc.
    public static let thresholds: [Int] = [
        0,      // Level 1
        100,    // Level 2
        250,    // Level 3
        500,    // Level 4
        850,    // Level 5
        1300,   // Level 6
        1900,   // Level 7
        2600,   // Level 8
        3500,   // Level 9
        4600,   // Level 10
        5900,   // Level 11
        7500,   // Level 12
        9400,   // Level 13
        11600,  // Level 14
        14200,  // Level 15
        17200,  // Level 16
        20700,  // Level 17
        24700,  // Level 18
        29300,  // Level 19
        34500,  // Level 20
    ]

    /// Maximum level currently supported
    public static let maxLevel = thresholds.count

    /// Calculate level from total XP
    public static func level(for xp: Int) -> Int {
        for i in stride(from: thresholds.count - 1, through: 0, by: -1) {
            if xp >= thresholds[i] {
                return i + 1
            }
        }
        return 1
    }

    /// XP progress within current level (0.0 to 1.0)
    public static func progress(for xp: Int) -> Double {
        let currentLevel = level(for: xp)
        guard currentLevel < maxLevel else { return 1.0 }
        let currentThreshold = thresholds[currentLevel - 1]
        let nextThreshold = thresholds[currentLevel]
        let progressXP = xp - currentThreshold
        let requiredXP = nextThreshold - currentThreshold
        return Double(progressXP) / Double(requiredXP)
    }

    // MARK: - XP Awards

    public static let flashcardReviewXP = 5
    public static let quizCompletionXP = 20
    public static let perfectQuizBonusXP = 15
    public static let dailyLessonXP = 25
    public static let uploadContentXP = 10
    public static let journalEntryXP = 10
    public static let writingExerciseXP = 30
    public static let streakBonusXP = 10  // per day of streak
}
