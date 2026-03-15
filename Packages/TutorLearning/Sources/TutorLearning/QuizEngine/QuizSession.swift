import Foundation
import TutorCore

/// Manages a quiz-taking session
@Observable
public final class QuizSession {
    public private(set) var questions: [QuizSessionQuestion]
    public private(set) var currentIndex: Int = 0
    public private(set) var isComplete: Bool = false
    public private(set) var startTime: Date

    public init(questions: [QuizSessionQuestion]) {
        self.questions = questions
        self.startTime = Date()
    }

    // MARK: - Navigation

    public var currentQuestion: QuizSessionQuestion? {
        guard currentIndex < questions.count else { return nil }
        return questions[currentIndex]
    }

    public var totalQuestions: Int { questions.count }

    public var answeredCount: Int {
        questions.filter { $0.userAnswer != nil }.count
    }

    public var progress: Double {
        guard !questions.isEmpty else { return 1.0 }
        return Double(answeredCount) / Double(questions.count)
    }

    // MARK: - Actions

    public func answer(_ answer: String) {
        guard currentIndex < questions.count else { return }
        questions[currentIndex].userAnswer = answer
        questions[currentIndex].isCorrect = checkAnswer(
            userAnswer: answer,
            correctAnswer: questions[currentIndex].correctAnswer,
            type: questions[currentIndex].type
        )
    }

    public func next() {
        guard currentIndex < questions.count - 1 else {
            isComplete = true
            return
        }
        currentIndex += 1
    }

    public func previous() {
        guard currentIndex > 0 else { return }
        currentIndex -= 1
    }

    public func submit() {
        isComplete = true
    }

    // MARK: - Scoring

    public var score: Double {
        let correct = questions.filter { $0.isCorrect == true }.count
        return Double(correct)
    }

    public var totalPoints: Int {
        questions.reduce(0) { $0 + $1.points }
    }

    public var scorePercentage: Double {
        guard !questions.isEmpty else { return 0 }
        return (score / Double(totalPoints)) * 100
    }

    public var isPerfect: Bool {
        scorePercentage == 100
    }

    public var duration: TimeInterval {
        Date().timeIntervalSince(startTime)
    }

    // MARK: - Answer Checking

    private func checkAnswer(userAnswer: String, correctAnswer: String, type: QuizType) -> Bool {
        switch type {
        case .multipleChoice:
            return userAnswer.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) ==
                   correctAnswer.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        case .shortAnswer:
            // Fuzzy matching for short answers
            let normalized1 = userAnswer.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
            let normalized2 = correctAnswer.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
            return normalized1 == normalized2 || normalized2.contains(normalized1) || normalized1.contains(normalized2)
        case .fillInBlank:
            return userAnswer.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) ==
                   correctAnswer.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        case .essay, .mixed:
            // Essays are graded by AI, not auto-checked
            return false
        }
    }
}

// MARK: - Supporting Types

public struct QuizSessionQuestion: Identifiable, Sendable {
    public let id: UUID
    public let questionText: String
    public let type: QuizType
    public let correctAnswer: String
    public let options: [String]?
    public let points: Int
    public var userAnswer: String?
    public var isCorrect: Bool?
    public var aiFeedback: String?

    public init(
        id: UUID = UUID(),
        questionText: String,
        type: QuizType,
        correctAnswer: String,
        options: [String]? = nil,
        points: Int = 1
    ) {
        self.id = id
        self.questionText = questionText
        self.type = type
        self.correctAnswer = correctAnswer
        self.options = options
        self.points = points
    }
}
