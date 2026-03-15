import Foundation
import TutorCore

/// Free Spaced Repetition Scheduler (FSRS) implementation
/// Based on the FSRS-5 algorithm used by modern Anki
/// See: https://github.com/open-spaced-repetition/fsrs4anki
public struct FSRSEngine: Sendable {
    // MARK: - Parameters

    /// Default FSRS parameters (empirically optimized)
    public struct Parameters: Sendable {
        public let requestRetention: Double   // Target retention rate
        public let maximumInterval: Int       // Max days between reviews
        public let w: [Double]               // Model weights

        public static let defaults = Parameters(
            requestRetention: 0.9,
            maximumInterval: 36500,
            w: [
                0.4072, 1.1829, 3.1262, 15.4722,   // Initial stability for each rating
                7.2102, 0.5316, 1.0651, 0.0589,     // Difficulty parameters
                1.5330, 0.1544, 1.0347, 1.9395,     // Stability parameters
                0.1093, 0.2963, 2.2690, 0.2272,     // Recall parameters
                2.8755, 0.0000, 0.0000               // Additional parameters
            ]
        )

        public init(requestRetention: Double = 0.9, maximumInterval: Int = 36500, w: [Double]? = nil) {
            self.requestRetention = requestRetention
            self.maximumInterval = maximumInterval
            self.w = w ?? Parameters.defaults.w
        }
    }

    /// Card state for FSRS calculations
    public struct CardState: Sendable {
        public var difficulty: Double
        public var stability: Double
        public var state: TutorCore.CardState
        public var lastReview: Date?
        public var reviewCount: Int
        public var lapseCount: Int

        public init(
            difficulty: Double = 0.3,
            stability: Double = 0.0,
            state: TutorCore.CardState = .new,
            lastReview: Date? = nil,
            reviewCount: Int = 0,
            lapseCount: Int = 0
        ) {
            self.difficulty = difficulty
            self.stability = stability
            self.state = state
            self.lastReview = lastReview
            self.reviewCount = reviewCount
            self.lapseCount = lapseCount
        }
    }

    /// Result of reviewing a card
    public struct ReviewResult: Sendable {
        public let newDifficulty: Double
        public let newStability: Double
        public let newState: TutorCore.CardState
        public let nextReviewDate: Date
        public let interval: Int  // days
    }

    private let params: Parameters

    public init(params: Parameters = .defaults) {
        self.params = params
    }

    // MARK: - Review

    /// Process a review and return the updated card state
    public func review(card: CardState, rating: ReviewRating, now: Date = Date()) -> ReviewResult {
        switch card.state {
        case .new:
            return reviewNew(rating: rating, now: now)
        case .learning, .relearning:
            return reviewLearning(card: card, rating: rating, now: now)
        case .review:
            return reviewReview(card: card, rating: rating, now: now)
        }
    }

    /// Get scheduled intervals for all possible ratings
    public func scheduleOptions(card: CardState, now: Date = Date()) -> [(rating: ReviewRating, interval: Int, date: Date)] {
        ReviewRating.allCases.map { rating in
            let result = review(card: card, rating: rating, now: now)
            return (rating: rating, interval: result.interval, date: result.nextReviewDate)
        }
    }

    // MARK: - New Cards

    private func reviewNew(rating: ReviewRating, now: Date) -> ReviewResult {
        let initialStability = initialStability(for: rating)
        let initialDifficulty = initialDifficulty(for: rating)

        let interval: Int
        let newState: TutorCore.CardState

        switch rating {
        case .again:
            interval = 1  // 1 minute (show again soon)
            newState = .learning
        case .hard:
            interval = 1
            newState = .learning
        case .good:
            interval = max(1, Int(initialStability))
            newState = .review
        case .easy:
            interval = max(1, Int(initialStability * 1.3))
            newState = .review
        }

        let clampedInterval = min(interval, params.maximumInterval)

        return ReviewResult(
            newDifficulty: clamp(initialDifficulty, 0.0, 1.0),
            newStability: initialStability,
            newState: newState,
            nextReviewDate: Calendar.current.date(byAdding: .day, value: clampedInterval, to: now) ?? now,
            interval: clampedInterval
        )
    }

    // MARK: - Learning Cards

    private func reviewLearning(card: CardState, rating: ReviewRating, now: Date) -> ReviewResult {
        let difficulty = nextDifficulty(current: card.difficulty, rating: rating)
        let stability: Double

        switch rating {
        case .again:
            stability = max(0.1, card.stability * 0.5)
        case .hard:
            stability = max(0.1, card.stability * 0.8)
        case .good:
            stability = initialStability(for: rating)
        case .easy:
            stability = initialStability(for: rating) * 1.3
        }

        let interval: Int
        let newState: TutorCore.CardState

        switch rating {
        case .again:
            interval = 0  // Show again in this session
            newState = .relearning
        case .hard:
            interval = 1
            newState = .learning
        case .good:
            interval = max(1, Int(stability))
            newState = .review
        case .easy:
            interval = max(1, Int(stability * 1.3))
            newState = .review
        }

        let clampedInterval = min(interval, params.maximumInterval)

        return ReviewResult(
            newDifficulty: clamp(difficulty, 0.0, 1.0),
            newStability: stability,
            newState: newState,
            nextReviewDate: Calendar.current.date(byAdding: .day, value: clampedInterval, to: now) ?? now,
            interval: clampedInterval
        )
    }

    // MARK: - Review Cards

    private func reviewReview(card: CardState, rating: ReviewRating, now: Date) -> ReviewResult {
        let elapsedDays = daysBetween(card.lastReview ?? now, now)
        let retrievability = forgettingCurve(elapsedDays: Double(elapsedDays), stability: card.stability)
        let difficulty = nextDifficulty(current: card.difficulty, rating: rating)

        let stability: Double
        let newState: TutorCore.CardState

        switch rating {
        case .again:
            stability = max(0.1, card.stability * params.w[11])
            newState = .relearning
        case .hard:
            let hardFactor = params.w[15]
            stability = card.stability * (1 + hardFactor * (1 - card.difficulty) * pow(card.stability, -params.w[12]) * (exp((1 - retrievability) * params.w[13]) - 1))
            newState = .review
        case .good:
            let goodFactor = 1.0
            stability = card.stability * (1 + goodFactor * (1 - card.difficulty) * pow(card.stability, -params.w[12]) * (exp((1 - retrievability) * params.w[13]) - 1))
            newState = .review
        case .easy:
            let easyFactor = params.w[16]
            stability = card.stability * (1 + easyFactor * (1 - card.difficulty) * pow(card.stability, -params.w[12]) * (exp((1 - retrievability) * params.w[13]) - 1))
            newState = .review
        }

        let interval = nextInterval(stability: stability)
        let clampedInterval = min(max(1, interval), params.maximumInterval)

        return ReviewResult(
            newDifficulty: clamp(difficulty, 0.0, 1.0),
            newStability: stability,
            newState: newState,
            nextReviewDate: Calendar.current.date(byAdding: .day, value: clampedInterval, to: now) ?? now,
            interval: clampedInterval
        )
    }

    // MARK: - Core Functions

    private func initialStability(for rating: ReviewRating) -> Double {
        params.w[rating.rawValue - 1]
    }

    private func initialDifficulty(for rating: ReviewRating) -> Double {
        let d0 = params.w[4]
        let d = d0 - exp(params.w[5] * Double(rating.rawValue - 1)) + 1
        return clamp(d / 10.0, 0.0, 1.0)
    }

    private func nextDifficulty(current: Double, rating: ReviewRating) -> Double {
        let delta = -(params.w[6] * (Double(rating.rawValue) - 3.0))
        let newD = current + delta * (1 - current) * 0.5
        return clamp(newD, 0.0, 1.0)
    }

    private func forgettingCurve(elapsedDays: Double, stability: Double) -> Double {
        guard stability > 0 else { return 0 }
        return pow(1 + elapsedDays / (9 * stability), -1)
    }

    private func nextInterval(stability: Double) -> Int {
        guard stability > 0 else { return 1 }
        let interval = 9 * stability * (1 / params.requestRetention - 1)
        return max(1, Int(round(interval)))
    }

    // MARK: - Helpers

    private func daysBetween(_ start: Date, _ end: Date) -> Int {
        max(0, Calendar.current.dateComponents([.day], from: start, to: end).day ?? 0)
    }

    private func clamp(_ value: Double, _ min: Double, _ max: Double) -> Double {
        Swift.min(Swift.max(value, min), max)
    }
}
