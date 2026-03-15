import Foundation
import SwiftData
import TutorCore

@Model
public final class Quiz {
    public var id: UUID = UUID()
    public var title: String = ""
    public var quizType: String = QuizType.multipleChoice.rawValue
    public var createdAt: Date = Date()
    public var completedAt: Date?
    public var score: Double?
    public var totalPoints: Int = 0
    public var useExtendedLearning: Bool = false

    @Relationship(deleteRule: .cascade, inverse: \QuizQuestion.quiz)
    public var questions: [QuizQuestion]?

    public var sourceItems: [KnowledgeItem]?

    public init(title: String, type: QuizType = .multipleChoice) {
        self.id = UUID()
        self.title = title
        self.quizType = type.rawValue
        self.createdAt = Date()
    }

    public var type: QuizType {
        get { QuizType(rawValue: quizType) ?? .multipleChoice }
        set { quizType = newValue.rawValue }
    }

    public var isCompleted: Bool {
        completedAt != nil
    }

    public var scorePercentage: Double? {
        guard let score, totalPoints > 0 else { return nil }
        return (score / Double(totalPoints)) * 100
    }
}
