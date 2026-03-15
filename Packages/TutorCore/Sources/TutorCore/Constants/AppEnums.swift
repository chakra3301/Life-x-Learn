import Foundation

// MARK: - App Mode

public enum AppMode: String, Codable, Sendable, CaseIterable {
    case student
    case life
}

// MARK: - Tutor Personality

public enum TutorTone: String, Codable, Sendable, CaseIterable {
    case friendly
    case academic
    case socratic
    case casual
    case strict
}

// MARK: - Theme

public enum ThemeType: String, Codable, Sendable, CaseIterable {
    case minimal
    case rich
    case lockedIn
    case cozy
}

public enum ColorSchemePreference: String, Codable, Sendable, CaseIterable {
    case light
    case dark
    case system
}

// MARK: - Review Frequency

public enum ReviewFrequency: String, Codable, Sendable, CaseIterable {
    case weekly
    case monthly
}

// MARK: - Workspace

public enum WorkspaceType: String, Codable, Sendable, CaseIterable {
    case semester
    case classType
    case year
    case subject
    case project
    case goal
    case general
    case custom
}

// MARK: - Knowledge

public enum SourceType: String, Codable, Sendable, CaseIterable {
    case pdf
    case image
    case audio
    case video
    case webLink
    case document
    case note
    case handwritten
    case slides
}

public enum ProcessingStatus: String, Codable, Sendable, CaseIterable {
    case pending
    case processing
    case completed
    case failed
}

// MARK: - Flashcards

public enum CardState: String, Codable, Sendable, CaseIterable {
    case new
    case learning
    case review
    case relearning
}

public enum ReviewRating: Int, Codable, Sendable, CaseIterable {
    case again = 1
    case hard = 2
    case good = 3
    case easy = 4
}

// MARK: - Quizzes

public enum QuizType: String, Codable, Sendable, CaseIterable {
    case multipleChoice
    case shortAnswer
    case essay
    case fillInBlank
    case mixed
}

// MARK: - Writing

public enum WritingType: String, Codable, Sendable, CaseIterable {
    case essay
    case paragraph
}

// MARK: - Journal

public enum JournalType: String, Codable, Sendable, CaseIterable {
    case reflection
    case general
    case aiPrompted
}

// MARK: - Chat

public enum MessageRole: String, Codable, Sendable, CaseIterable {
    case user
    case assistant
    case system
}

// MARK: - AI

public enum AITarget: String, Codable, Sendable {
    case local
    case cloud
}

// MARK: - Grade Categories

public enum GradeCategory: String, Codable, Sendable, CaseIterable {
    case homework
    case exam
    case quiz
    case project
    case participation
    case essay
    case lab
    case other
}
