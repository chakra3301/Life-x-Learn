import Foundation
import SwiftData
import TutorCore

@Model
public final class QuizQuestion {
    public var id: UUID = UUID()
    public var questionText: String = ""
    public var questionType: String = QuizType.multipleChoice.rawValue
    public var correctAnswer: String = ""
    public var optionsJSON: String?
    public var userAnswer: String?
    public var isCorrect: Bool?
    public var points: Int = 1
    public var aiFeedback: String?
    public var sortOrder: Int = 0

    public var quiz: Quiz?

    public init(questionText: String, correctAnswer: String, type: QuizType = .multipleChoice) {
        self.id = UUID()
        self.questionText = questionText
        self.correctAnswer = correctAnswer
        self.questionType = type.rawValue
    }

    /// Decode multiple choice options from JSON
    public var options: [String] {
        get {
            guard let json = optionsJSON,
                  let data = json.data(using: .utf8),
                  let decoded = try? JSONDecoder().decode([String].self, from: data)
            else { return [] }
            return decoded
        }
        set {
            if let data = try? JSONEncoder().encode(newValue),
               let json = String(data: data, encoding: .utf8) {
                optionsJSON = json
            }
        }
    }
}
