import Foundation
import SwiftData

@Model
public final class KnowledgeChunk {
    public var id: UUID = UUID()
    public var content: String = ""
    public var chunkIndex: Int = 0
    public var embedding: Data?

    public var item: KnowledgeItem?

    public init(content: String, chunkIndex: Int) {
        self.id = UUID()
        self.content = content
        self.chunkIndex = chunkIndex
    }
}
