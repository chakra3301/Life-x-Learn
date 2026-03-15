import Foundation
import TutorCore

/// Local AI service using Apple Foundation Models (on-device)
/// Falls back to basic text processing when Foundation Models unavailable
public final class LocalAIService: AIService, @unchecked Sendable {

    public init() {}

    // MARK: - AIService

    public func summarize(text: String) async throws -> String {
        #if canImport(FoundationModels)
        if #available(macOS 26.0, iOS 26.0, *) {
            return try await summarizeWithFoundationModels(text: text)
        }
        #endif
        return extractiveSummary(text: text)
    }

    public func generateFlashcards(from text: String, count: Int) async throws -> [(front: String, back: String)] {
        #if canImport(FoundationModels)
        if #available(macOS 26.0, iOS 26.0, *) {
            return try await generateFlashcardsWithFoundationModels(text: text, count: count)
        }
        #endif
        return basicFlashcardExtraction(text: text, count: count)
    }

    public func generateQuiz(from text: String, type: QuizType, questionCount: Int) async throws -> [(question: String, answer: String, options: [String]?)] {
        #if canImport(FoundationModels)
        if #available(macOS 26.0, iOS 26.0, *) {
            return try await generateQuizWithFoundationModels(text: text, type: type, count: questionCount)
        }
        #endif
        return []
    }

    public func chat(messages: [(role: MessageRole, content: String)], context: String?) async throws -> String {
        #if canImport(FoundationModels)
        if #available(macOS 26.0, iOS 26.0, *) {
            return try await chatWithFoundationModels(messages: messages, context: context)
        }
        #endif
        return "AI chat requires iOS 26+ or macOS 26+ for on-device processing, or an internet connection for cloud AI."
    }

    public func categorize(text: String) async throws -> [String] {
        #if canImport(FoundationModels)
        if #available(macOS 26.0, iOS 26.0, *) {
            return try await categorizeWithFoundationModels(text: text)
        }
        #endif
        return basicCategorization(text: text)
    }

    public func gradeWriting(prompt: String, response: String, exerciseType: WritingType) async throws -> (score: Double, feedback: String) {
        // Writing grading is complex — prefer cloud, but provide basic feedback locally
        return (score: 0.0, feedback: "Detailed writing feedback requires cloud AI. Please ensure you have an internet connection.")
    }

    // MARK: - Fallback Implementations

    private func extractiveSummary(text: String, maxSentences: Int = 3) -> String {
        let sentences = text.components(separatedBy: ". ")
        let selected = Array(sentences.prefix(maxSentences))
        return selected.joined(separator: ". ") + (selected.count < sentences.count ? "." : "")
    }

    private func basicFlashcardExtraction(text: String, count: Int) -> [(front: String, back: String)] {
        // Basic extraction: split into paragraphs, create Q&A pairs
        let paragraphs = text.components(separatedBy: "\n\n").filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        return paragraphs.prefix(count).map { paragraph in
            let trimmed = paragraph.trimmingCharacters(in: .whitespacesAndNewlines)
            let firstSentence = trimmed.components(separatedBy: ". ").first ?? trimmed
            return (front: "What is described here: \(firstSentence)?", back: trimmed)
        }
    }

    private func basicCategorization(text: String) -> [String] {
        // Keyword-based fallback categorization
        let categories: [(String, [String])] = [
            ("Science", ["experiment", "hypothesis", "cell", "atom", "molecule", "physics", "chemistry", "biology"]),
            ("Mathematics", ["equation", "formula", "theorem", "calculate", "algebra", "geometry", "calculus"]),
            ("History", ["century", "war", "empire", "revolution", "ancient", "civilization", "historical"]),
            ("Literature", ["novel", "poem", "author", "character", "narrative", "literary", "fiction"]),
            ("Technology", ["software", "algorithm", "computer", "programming", "digital", "code", "data"]),
            ("Language", ["grammar", "vocabulary", "conjugation", "syntax", "linguistic", "translation"]),
        ]

        let lowerText = text.lowercased()
        return categories
            .filter { (_, keywords) in keywords.contains { lowerText.contains($0) } }
            .map(\.0)
    }
}

// MARK: - Foundation Models Integration (Conditional)

#if canImport(FoundationModels)
import FoundationModels

@available(macOS 26.0, iOS 26.0, *)
extension LocalAIService {
    private func summarizeWithFoundationModels(text: String) async throws -> String {
        let session = LanguageModelSession()
        let prompt = """
        Summarize the following text concisely in 2-3 sentences, capturing the key points:

        \(text)
        """
        let response = try await session.respond(to: prompt)
        return response.content
    }

    private func generateFlashcardsWithFoundationModels(text: String, count: Int) async throws -> [(front: String, back: String)] {
        let session = LanguageModelSession()
        let prompt = """
        Generate exactly \(count) flashcards from the following text. Each flashcard should have a clear question on the front and a concise, accurate answer on the back.

        Format each flashcard as:
        Q: [question]
        A: [answer]

        Text:
        \(text)
        """
        let response = try await session.respond(to: prompt)
        return parseFlashcards(from: response.content)
    }

    private func generateQuizWithFoundationModels(text: String, type: QuizType, count: Int) async throws -> [(question: String, answer: String, options: [String]?)] {
        let session = LanguageModelSession()
        let typeDesc = switch type {
        case .multipleChoice: "multiple choice with 4 options (mark correct with *)"
        case .shortAnswer: "short answer"
        case .essay: "essay"
        case .fillInBlank: "fill in the blank (use ___ for blanks)"
        case .mixed: "mixed (variety of types)"
        }

        let prompt = """
        Generate \(count) \(typeDesc) questions from this text:

        \(text)
        """
        let response = try await session.respond(to: prompt)
        return parseQuiz(from: response.content, type: type)
    }

    private func chatWithFoundationModels(messages: [(role: MessageRole, content: String)], context: String?) async throws -> String {
        let session = LanguageModelSession()

        var fullPrompt = ""
        if let context {
            fullPrompt += "Context from the user's knowledge base:\n\(context)\n\n"
        }
        fullPrompt += "Conversation:\n"
        for msg in messages {
            let role = msg.role == .user ? "User" : "Assistant"
            fullPrompt += "\(role): \(msg.content)\n"
        }
        fullPrompt += "Assistant:"

        let response = try await session.respond(to: fullPrompt)
        return response.content
    }

    private func categorizeWithFoundationModels(text: String) async throws -> [String] {
        let session = LanguageModelSession()
        let prompt = """
        Categorize the following text into 1-3 subject areas. Return only the category names, separated by commas.

        Categories to choose from: Science, Mathematics, History, Literature, Technology, Language, Art, Music, Philosophy, Psychology, Business, Health, Law, Engineering, Social Studies, Other

        Text:
        \(text)
        """
        let response = try await session.respond(to: prompt)
        return response.content
            .components(separatedBy: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }
}
#endif

// MARK: - Parsing Helpers

extension LocalAIService {
    func parseFlashcards(from text: String) -> [(front: String, back: String)] {
        var cards: [(front: String, back: String)] = []
        let lines = text.components(separatedBy: "\n")
        var currentQuestion: String?

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix("Q:") || trimmed.hasPrefix("Q :") {
                currentQuestion = String(trimmed.dropFirst(2)).trimmingCharacters(in: .whitespaces)
            } else if (trimmed.hasPrefix("A:") || trimmed.hasPrefix("A :")), let question = currentQuestion {
                let answer = String(trimmed.dropFirst(2)).trimmingCharacters(in: .whitespaces)
                cards.append((front: question, back: answer))
                currentQuestion = nil
            }
        }

        return cards
    }

    func parseQuiz(from text: String, type: QuizType) -> [(question: String, answer: String, options: [String]?)] {
        // Basic parsing — will be refined with structured output in production
        let sections = text.components(separatedBy: "\n\n")
        return sections.compactMap { section in
            let lines = section.components(separatedBy: "\n").map { $0.trimmingCharacters(in: .whitespaces) }
            guard let firstLine = lines.first, !firstLine.isEmpty else { return nil }
            let question = firstLine
            let answer = lines.count > 1 ? lines.last ?? "" : ""
            let options = type == .multipleChoice ? Array(lines.dropFirst().dropLast()) : nil
            return (question: question, answer: answer, options: options)
        }
    }
}
