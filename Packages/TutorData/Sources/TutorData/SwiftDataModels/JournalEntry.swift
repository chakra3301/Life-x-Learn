import Foundation
import SwiftData
import TutorCore

@Model
public final class JournalEntry {
    public var id: UUID = UUID()
    public var content: String = ""
    public var entryType: String = JournalType.general.rawValue
    public var mood: String?
    public var aiPrompt: String?
    public var createdAt: Date = Date()
    public var isPrivate: Bool = true

    public var user: UserProfile?

    public init(content: String = "", type: JournalType = .general) {
        self.id = UUID()
        self.content = content
        self.entryType = type.rawValue
        self.createdAt = Date()
        self.isPrivate = true
    }

    public var type: JournalType {
        get { JournalType(rawValue: entryType) ?? .general }
        set { entryType = newValue.rawValue }
    }
}
