import Foundation
import SwiftData
import TutorCore

@Model
public final class FlashcardReview {
    public var id: UUID = UUID()
    public var rating: Int = ReviewRating.good.rawValue
    public var reviewedAt: Date = Date()
    public var responseTimeMs: Int = 0

    public var flashcard: Flashcard?

    public init(rating: ReviewRating, responseTimeMs: Int = 0) {
        self.id = UUID()
        self.rating = rating.rawValue
        self.reviewedAt = Date()
        self.responseTimeMs = responseTimeMs
    }

    public var reviewRating: ReviewRating {
        ReviewRating(rawValue: rating) ?? .good
    }
}
