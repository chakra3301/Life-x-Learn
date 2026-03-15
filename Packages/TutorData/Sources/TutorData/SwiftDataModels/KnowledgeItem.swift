import Foundation
import SwiftData
import TutorCore

@Model
public final class KnowledgeItem {
    public var id: UUID = UUID()
    public var title: String = ""
    public var sourceType: String = SourceType.note.rawValue
    public var rawContent: String?
    public var summary: String?
    public var fileBookmark: Data?
    public var fileSize: Int64 = 0
    public var mimeType: String?
    public var sourceURL: String?
    public var importedAt: Date = Date()
    public var lastReviewedAt: Date?
    public var processingStatus: String = ProcessingStatus.pending.rawValue
    public var aiCategory: String?

    // Relationships
    public var workspace: Workspace?

    @Relationship(inverse: \Tag.knowledgeItems)
    public var tags: [Tag]?

    @Relationship(deleteRule: .cascade, inverse: \Flashcard.sourceItem)
    public var flashcards: [Flashcard]?

    @Relationship(inverse: \Quiz.sourceItems)
    public var quizzes: [Quiz]?

    @Relationship(deleteRule: .cascade, inverse: \KnowledgeChunk.item)
    public var chunks: [KnowledgeChunk]?

    @Relationship(inverse: \CrossConnection.items)
    public var connections: [CrossConnection]?

    public init(title: String, sourceType: SourceType) {
        self.id = UUID()
        self.title = title
        self.sourceType = sourceType.rawValue
        self.importedAt = Date()
    }

    public var source: SourceType {
        get { SourceType(rawValue: sourceType) ?? .note }
        set { sourceType = newValue.rawValue }
    }

    public var status: ProcessingStatus {
        get { ProcessingStatus(rawValue: processingStatus) ?? .pending }
        set { processingStatus = newValue.rawValue }
    }
}
