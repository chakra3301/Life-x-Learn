import Foundation
import SwiftData

@Model
public final class Tag {
    public var id: UUID = UUID()
    public var name: String = ""
    public var colorHex: String = "#FF9500"

    public var knowledgeItems: [KnowledgeItem]?
    public var workspaces: [Workspace]?

    public init(name: String, colorHex: String = "#FF9500") {
        self.id = UUID()
        self.name = name
        self.colorHex = colorHex
    }
}
