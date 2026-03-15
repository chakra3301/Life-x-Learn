import Foundation
import TutorCore

/// Cloud AI service using Claude API for complex tasks
public final class CloudAIService: AIService, @unchecked Sendable {
    private let apiKey: String
    private let model: String
    private let baseURL = URL(string: "https://api.anthropic.com/v1/messages")!

    public init(apiKey: String, model: String = "claude-sonnet-4-20250514") {
        self.apiKey = apiKey
        self.model = model
    }

    // MARK: - AIService

    public func summarize(text: String) async throws -> String {
        let response = try await sendMessage(
            system: "You are a concise summarizer. Provide clear, accurate summaries.",
            userMessage: "Summarize the following text in 2-3 paragraphs:\n\n\(text)"
        )
        return response
    }

    public func generateFlashcards(from text: String, count: Int) async throws -> [(front: String, back: String)] {
        let response = try await sendMessage(
            system: PromptTemplates.flashcardSystem,
            userMessage: "Generate exactly \(count) flashcards from this text:\n\n\(text)\n\nReturn as JSON array: [{\"front\": \"...\", \"back\": \"...\"}]"
        )
        return try parseFlashcardJSON(response)
    }

    public func generateQuiz(from text: String, type: QuizType, questionCount: Int) async throws -> [(question: String, answer: String, options: [String]?)] {
        let typeDescription = switch type {
        case .multipleChoice: "multiple choice with exactly 4 options"
        case .shortAnswer: "short answer (1-2 sentences)"
        case .essay: "essay (open-ended, thought-provoking)"
        case .fillInBlank: "fill in the blank"
        case .mixed: "a mix of multiple choice, short answer, and fill in the blank"
        }

        let response = try await sendMessage(
            system: PromptTemplates.quizSystem,
            userMessage: """
            Generate \(questionCount) \(typeDescription) questions from this text:

            \(text)

            Return as JSON array: [{"question": "...", "answer": "...", "options": ["a", "b", "c", "d"] or null}]
            """
        )
        return try parseQuizJSON(response)
    }

    public func chat(messages: [(role: MessageRole, content: String)], context: String?) async throws -> String {
        var systemPrompt = PromptTemplates.chatSystem
        if let context {
            systemPrompt += "\n\nRelevant context from the user's knowledge base:\n\(context)"
        }

        let apiMessages = messages.map { msg -> [String: String] in
            ["role": msg.role == .user ? "user" : "assistant", "content": msg.content]
        }

        return try await sendMessages(system: systemPrompt, messages: apiMessages)
    }

    public func categorize(text: String) async throws -> [String] {
        let response = try await sendMessage(
            system: "Return only category names, comma-separated. Choose from: Science, Mathematics, History, Literature, Technology, Language, Art, Music, Philosophy, Psychology, Business, Health, Law, Engineering, Social Studies",
            userMessage: "Categorize this text:\n\n\(text)"
        )
        return response.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
    }

    public func gradeWriting(prompt: String, response: String, exerciseType: WritingType) async throws -> (score: Double, feedback: String) {
        let gradeResponse = try await sendMessage(
            system: PromptTemplates.writingGradingSystem(type: exerciseType),
            userMessage: """
            Writing Prompt: \(prompt)

            Student's Response:
            \(response)

            Provide your assessment as JSON: {"score": 0.0-1.0, "feedback": "detailed feedback"}
            """
        )
        return try parseGradeJSON(gradeResponse)
    }

    // MARK: - API Communication

    private func sendMessage(system: String, userMessage: String) async throws -> String {
        try await sendMessages(system: system, messages: [["role": "user", "content": userMessage]])
    }

    private func sendMessages(system: String, messages: [[String: String]]) async throws -> String {
        let body: [String: Any] = [
            "model": model,
            "max_tokens": 4096,
            "system": system,
            "messages": messages
        ]

        var request = URLRequest(url: baseURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "content-type")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
            throw CloudAIError.apiError(statusCode: statusCode, body: String(data: data, encoding: .utf8) ?? "")
        }

        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard let content = json?["content"] as? [[String: Any]],
              let text = content.first?["text"] as? String else {
            throw CloudAIError.invalidResponse
        }

        return text
    }

    // MARK: - JSON Parsing

    private func parseFlashcardJSON(_ text: String) throws -> [(front: String, back: String)] {
        guard let jsonStart = text.firstIndex(of: "["),
              let jsonEnd = text.lastIndex(of: "]") else {
            return []
        }
        let jsonString = String(text[jsonStart...jsonEnd])
        guard let data = jsonString.data(using: .utf8) else { return [] }

        struct FC: Decodable { let front: String; let back: String }
        let cards = try JSONDecoder().decode([FC].self, from: data)
        return cards.map { ($0.front, $0.back) }
    }

    private func parseQuizJSON(_ text: String) throws -> [(question: String, answer: String, options: [String]?)] {
        guard let jsonStart = text.firstIndex(of: "["),
              let jsonEnd = text.lastIndex(of: "]") else {
            return []
        }
        let jsonString = String(text[jsonStart...jsonEnd])
        guard let data = jsonString.data(using: .utf8) else { return [] }

        struct QQ: Decodable { let question: String; let answer: String; let options: [String]? }
        let questions = try JSONDecoder().decode([QQ].self, from: data)
        return questions.map { ($0.question, $0.answer, $0.options) }
    }

    private func parseGradeJSON(_ text: String) throws -> (score: Double, feedback: String) {
        guard let jsonStart = text.firstIndex(of: "{"),
              let jsonEnd = text.lastIndex(of: "}") else {
            return (0.0, text)
        }
        let jsonString = String(text[jsonStart...jsonEnd])
        guard let data = jsonString.data(using: .utf8) else { return (0.0, text) }

        struct Grade: Decodable { let score: Double; let feedback: String }
        let grade = try JSONDecoder().decode(Grade.self, from: data)
        return (grade.score, grade.feedback)
    }
}

// MARK: - Errors

public enum CloudAIError: Error, LocalizedError {
    case apiError(statusCode: Int, body: String)
    case invalidResponse
    case noAPIKey

    public var errorDescription: String? {
        switch self {
        case .apiError(let code, _): return "API error (status \(code))"
        case .invalidResponse: return "Invalid response from AI service"
        case .noAPIKey: return "No API key configured"
        }
    }
}
