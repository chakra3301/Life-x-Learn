import Testing
@testable import TutorCore
@testable import TutorLearning
@testable import TutorGamification

@Suite("Core Tests")
struct CoreTests {
    @Test("Level calculation works correctly")
    func levelCalculation() {
        #expect(LevelSystem.level(for: 0) == 1)
        #expect(LevelSystem.level(for: 100) == 2)
        #expect(LevelSystem.level(for: 250) == 3)
        #expect(LevelSystem.level(for: 99) == 1)
    }

    @Test("XP progress within level")
    func xpProgress() {
        let progress = LevelSystem.progress(for: 50)
        #expect(progress > 0.0 && progress < 1.0)
    }
}

@Suite("Gamification Tests")
struct GamificationTests {
    @Test("Streak calculation")
    func streakCalc() {
        let tracker = StreakTracker()
        let today = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        let twoDaysAgo = Calendar.current.date(byAdding: .day, value: -2, to: today)!

        let result = tracker.calculateStreak(activeDates: [today, yesterday, twoDaysAgo])
        #expect(result.current == 3)
        #expect(result.longest == 3)
    }

    @Test("XP engine awards correct base XP")
    func xpAwards() {
        let engine = XPEngine()
        let flashcardXP = engine.calculateXP(for: .flashcardReview)
        #expect(flashcardXP == LevelSystem.flashcardReviewXP)

        let perfectQuizXP = engine.calculateXP(for: .quizCompletion(perfect: true))
        #expect(perfectQuizXP == LevelSystem.quizCompletionXP + LevelSystem.perfectQuizBonusXP)
    }
}
