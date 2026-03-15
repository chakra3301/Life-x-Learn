import Foundation
import TutorCore

/// Central AI routing engine that decides whether to use local or cloud AI
/// and manages context injection from the user's knowledge base.
public actor AIOrchestrator {
    private let localService: AIService
    private let cloudService: AIService?
    private let contextProvider: KnowledgeContextProvider?

    public init(
        localService: AIService,
        cloudService: AIService? = nil,
        contextProvider: KnowledgeContextProvider? = nil
    ) {
        self.localService = localService
        self.cloudService = cloudService
        self.contextProvider = contextProvider
    }

    // MARK: - Task Routing

    /// Determines which AI to use based on the task complexity
    public func route(_ task: AITask) -> AITarget {
        switch task {
        case .summarize, .categorize, .flashcardsBasic, .chatSimple, .journalPrompt:
            return .local
        case .essayGrade, .quizComplex, .studyPlan, .extendedLearning,
             .bookClub, .gradePrediction, .goalPlan, .writingFeedback:
            return cloudService != nil ? .cloud : .local
        }
    }

    // MARK: - Summarization

    public func summarize(text: String) async throws -> String {
        let target = route(.summarize)
        let service = target == .cloud ? (cloudService ?? localService) : localService
        return try await service.summarize(text: text)
    }

    // MARK: - Flashcard Generation

    public func generateFlashcards(
        from text: String,
        count: Int = 10,
        useExtendedLearning: Bool = false
    ) async throws -> [(front: String, back: String)] {
        let task: AITask = useExtendedLearning ? .extendedLearning : .flashcardsBasic
        let target = route(task)
        let service = target == .cloud ? (cloudService ?? localService) : localService

        var contextualText = text
        if useExtendedLearning, let context = try await contextProvider?.relatedContext(for: text) {
            contextualText += "\n\nAdditional context:\n\(context)"
        }

        return try await service.generateFlashcards(from: contextualText, count: count)
    }

    // MARK: - Quiz Generation

    public func generateQuiz(
        from text: String,
        type: QuizType = .multipleChoice,
        questionCount: Int = 10,
        useExtendedLearning: Bool = false
    ) async throws -> [(question: String, answer: String, options: [String]?)] {
        let task: AITask = useExtendedLearning ? .quizComplex : .flashcardsBasic
        let target = route(task)
        let service = target == .cloud ? (cloudService ?? localService) : localService
        return try await service.generateQuiz(from: text, type: type, questionCount: questionCount)
    }

    // MARK: - Chat

    public func chat(
        messages: [(role: MessageRole, content: String)],
        workspaceContext: String? = nil
    ) async throws -> String {
        // Determine complexity from message length and content
        let lastMessage = messages.last?.content ?? ""
        let isComplex = lastMessage.count > 500 || lastMessage.contains("explain in detail")
        let task: AITask = isComplex ? .extendedLearning : .chatSimple
        let target = route(task)
        let service = target == .cloud ? (cloudService ?? localService) : localService

        // Inject relevant knowledge context
        var context = workspaceContext
        if context == nil, let relevantContext = try await contextProvider?.relatedContext(for: lastMessage) {
            context = relevantContext
        }

        return try await service.chat(messages: messages, context: context)
    }

    // MARK: - Writing Practice

    public func gradeWriting(
        prompt: String,
        response: String,
        exerciseType: WritingType
    ) async throws -> (score: Double, feedback: String) {
        let target = route(.writingFeedback)
        let service = target == .cloud ? (cloudService ?? localService) : localService
        return try await service.gradeWriting(prompt: prompt, response: response, exerciseType: exerciseType)
    }

    // MARK: - Categorization

    public func categorize(text: String) async throws -> [String] {
        return try await localService.categorize(text: text)
    }

    // MARK: - Connectivity

    public var isCloudAvailable: Bool {
        cloudService != nil
    }
}

// MARK: - Task Types

public enum AITask: Sendable {
    // Local tasks
    case summarize
    case categorize
    case flashcardsBasic
    case chatSimple
    case journalPrompt

    // Cloud tasks
    case essayGrade
    case quizComplex
    case studyPlan
    case extendedLearning
    case bookClub
    case gradePrediction
    case goalPlan
    case writingFeedback
}

// MARK: - Knowledge Context Provider

/// Provides relevant context from the user's knowledge base for AI calls
public protocol KnowledgeContextProvider: Sendable {
    func relatedContext(for query: String) async throws -> String?
}
