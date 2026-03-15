import Foundation

// MARK: - Repository Protocols

/// Base protocol for all repositories
public protocol Repository: Sendable {
    associatedtype Entity

    func fetchAll() async throws -> [Entity]
    func fetch(by id: UUID) async throws -> Entity?
    func save(_ entity: Entity) async throws
    func delete(_ entity: Entity) async throws
}

/// Protocol for AI services (local and cloud)
public protocol AIService: Sendable {
    func summarize(text: String) async throws -> String
    func generateFlashcards(from text: String, count: Int) async throws -> [(front: String, back: String)]
    func generateQuiz(from text: String, type: QuizType, questionCount: Int) async throws -> [(question: String, answer: String, options: [String]?)]
    func chat(messages: [(role: MessageRole, content: String)], context: String?) async throws -> String
    func categorize(text: String) async throws -> [String]
    func gradeWriting(prompt: String, response: String, exerciseType: WritingType) async throws -> (score: Double, feedback: String)
}

/// Protocol for file importing
public protocol FileImporter: Sendable {
    var supportedTypes: [SourceType] { get }
    func canImport(url: URL) -> Bool
    func extractText(from url: URL) async throws -> String
    func extractMetadata(from url: URL) async throws -> [String: Any]
}

/// Protocol for knowledge search
public protocol KnowledgeSearchable: Sendable {
    func search(query: String, limit: Int) async throws -> [SearchResult]
}

public struct SearchResult: Sendable {
    public let id: UUID
    public let title: String
    public let snippet: String
    public let relevanceScore: Double

    public init(id: UUID, title: String, snippet: String, relevanceScore: Double) {
        self.id = id
        self.title = title
        self.snippet = snippet
        self.relevanceScore = relevanceScore
    }
}
