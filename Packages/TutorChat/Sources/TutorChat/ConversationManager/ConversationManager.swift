import Foundation
import TutorCore

/// Manages chat conversations and message history
@Observable
public final class ConversationManager {
    public private(set) var messages: [(role: MessageRole, content: String)] = []
    public private(set) var isLoading: Bool = false
    public var conversationID: UUID?
    public var workspaceID: UUID?

    private let aiService: AIService

    public init(aiService: AIService) {
        self.aiService = aiService
    }

    /// Send a message and get an AI response
    public func send(_ message: String, context: String? = nil) async throws -> String {
        messages.append((role: .user, content: message))
        isLoading = true
        defer { isLoading = false }

        let response = try await aiService.chat(messages: messages, context: context)
        messages.append((role: .assistant, content: response))
        return response
    }

    /// Clear conversation history
    public func clear() {
        messages.removeAll()
    }

    /// Load messages from persisted conversation
    public func load(messages: [(role: MessageRole, content: String)]) {
        self.messages = messages
    }
}
