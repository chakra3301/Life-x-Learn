import Foundation
import TutorCore

/// Manages a single flashcard review session
@Observable
public final class FlashcardReviewSession {
    public private(set) var cards: [ReviewableCard]
    public private(set) var currentIndex: Int = 0
    public private(set) var completedCount: Int = 0
    public private(set) var correctCount: Int = 0
    public private(set) var sessionStartTime: Date
    public private(set) var isComplete: Bool = false

    private let fsrs = FSRSEngine()

    public init(cards: [ReviewableCard]) {
        self.cards = cards
        self.sessionStartTime = Date()
    }

    /// The current card to review
    public var currentCard: ReviewableCard? {
        guard currentIndex < cards.count else { return nil }
        return cards[currentIndex]
    }

    /// Total number of cards in this session
    public var totalCards: Int { cards.count }

    /// Progress through the session (0.0 to 1.0)
    public var progress: Double {
        guard !cards.isEmpty else { return 1.0 }
        return Double(completedCount) / Double(cards.count)
    }

    /// Accuracy percentage
    public var accuracy: Double {
        guard completedCount > 0 else { return 0 }
        return Double(correctCount) / Double(completedCount) * 100
    }

    /// Total session duration
    public var duration: TimeInterval {
        Date().timeIntervalSince(sessionStartTime)
    }

    /// Process a rating for the current card
    public func rate(_ rating: ReviewRating) -> ReviewResult? {
        guard currentIndex < cards.count else { return nil }

        let card = cards[currentIndex]
        let cardState = FSRSEngine.CardState(
            difficulty: card.difficulty,
            stability: card.stability,
            state: card.state,
            lastReview: card.lastReviewDate,
            reviewCount: card.reviewCount,
            lapseCount: card.lapseCount
        )

        let result = fsrs.review(card: cardState, rating: rating)

        completedCount += 1
        if rating != .again {
            correctCount += 1
        }

        // If rated "again", put the card back in the queue
        if rating == .again {
            var failedCard = card
            failedCard.difficulty = result.newDifficulty
            failedCard.stability = result.newStability
            failedCard.state = result.newState
            cards.append(failedCard)
        }

        currentIndex += 1

        if currentIndex >= cards.count {
            isComplete = true
        }

        return ReviewResult(
            cardID: card.id,
            rating: rating,
            newDifficulty: result.newDifficulty,
            newStability: result.newStability,
            newState: result.newState,
            nextReviewDate: result.nextReviewDate,
            interval: result.interval
        )
    }

    /// Skip the current card
    public func skip() {
        guard currentIndex < cards.count else { return }
        currentIndex += 1
        if currentIndex >= cards.count {
            isComplete = true
        }
    }
}

// MARK: - Supporting Types

public struct ReviewableCard: Identifiable, Sendable {
    public let id: UUID
    public let front: String
    public let back: String
    public var difficulty: Double
    public var stability: Double
    public var state: CardState
    public var lastReviewDate: Date?
    public var reviewCount: Int
    public var lapseCount: Int

    public init(
        id: UUID,
        front: String,
        back: String,
        difficulty: Double = 0.3,
        stability: Double = 0.0,
        state: CardState = .new,
        lastReviewDate: Date? = nil,
        reviewCount: Int = 0,
        lapseCount: Int = 0
    ) {
        self.id = id
        self.front = front
        self.back = back
        self.difficulty = difficulty
        self.stability = stability
        self.state = state
        self.lastReviewDate = lastReviewDate
        self.reviewCount = reviewCount
        self.lapseCount = lapseCount
    }
}

public struct ReviewResult: Sendable {
    public let cardID: UUID
    public let rating: ReviewRating
    public let newDifficulty: Double
    public let newStability: Double
    public let newState: CardState
    public let nextReviewDate: Date
    public let interval: Int
}
