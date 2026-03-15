import Foundation
import SwiftData
import TutorCore

@Model
public final class Workspace {
    public var id: UUID = UUID()
    public var name: String = ""
    public var workspaceType: String = WorkspaceType.general.rawValue
    public var icon: String = "folder"
    public var colorHex: String = "#007AFF"
    public var createdAt: Date = Date()
    public var sortOrder: Int = 0
    public var isShared: Bool = false
    public var isTemplate: Bool = false
    public var isActive: Bool = true

    // Student mode fields
    public var className: String?
    public var semester: String?
    public var instructorName: String?
    public var scheduleJSON: String?

    // Relationships
    public var owner: UserProfile?

    @Relationship(deleteRule: .cascade, inverse: \Workspace.parentWorkspace)
    public var subSections: [Workspace]?

    public var parentWorkspace: Workspace?

    @Relationship(deleteRule: .cascade, inverse: \KnowledgeItem.workspace)
    public var knowledgeItems: [KnowledgeItem]?

    @Relationship(inverse: \Tag.workspaces)
    public var tags: [Tag]?

    public init(name: String, type: WorkspaceType = .general) {
        self.id = UUID()
        self.name = name
        self.workspaceType = type.rawValue
        self.createdAt = Date()
    }

    public var type: WorkspaceType {
        get { WorkspaceType(rawValue: workspaceType) ?? .general }
        set { workspaceType = newValue.rawValue }
    }
}
