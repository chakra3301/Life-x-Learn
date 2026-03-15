import Foundation
import SwiftData
import TutorCore

@Model
public final class Conversation {
    public var id: UUID = UUID()
    public var title: String = ""
    public var createdAt: Date = Date()
    public var lastMessageAt: Date?
    public var workspaceID: UUID?

    @Relationship(deleteRule: .cascade, inverse: \ChatMessage.conversation)
    public var messages: [ChatMessage]?

    public init(title: String = "New Chat") {
        self.id = UUID()
        self.title = title
        self.createdAt = Date()
    }

    /// Sorted messages by timestamp
    public var sortedMessages: [ChatMessage] {
        (messages ?? []).sorted { $0.timestamp < $1.timestamp }
    }
}

@Model
public final class ChatMessage {
    public var id: UUID = UUID()
    public var role: String = MessageRole.user.rawValue
    public var content: String = ""
    public var timestamp: Date = Date()

    public var conversation: Conversation?

    public init(role: MessageRole, content: String) {
        self.id = UUID()
        self.role = role.rawValue
        self.content = content
        self.timestamp = Date()
    }

    public var messageRole: MessageRole {
        get { MessageRole(rawValue: role) ?? .user }
        set { role = newValue.rawValue }
    }
}
