import Foundation
import SwiftData

@Model
public final class Goal {
    public var id: UUID = UUID()
    public var title: String = ""
    public var goalDescription: String = ""
    public var deadline: Date?
    public var createdAt: Date = Date()
    public var completedAt: Date?
    public var progressPercent: Double = 0
    public var aiPlanJSON: String?
    public var workspaceID: UUID?

    @Relationship(deleteRule: .cascade, inverse: \GoalMilestone.goal)
    public var milestones: [GoalMilestone]?

    public init(title: String, description: String = "", deadline: Date? = nil) {
        self.id = UUID()
        self.title = title
        self.goalDescription = description
        self.deadline = deadline
        self.createdAt = Date()
    }

    public var isCompleted: Bool {
        completedAt != nil
    }

    public var sortedMilestones: [GoalMilestone] {
        (milestones ?? []).sorted { $0.sortOrder < $1.sortOrder }
    }

    /// Recalculate progress based on completed milestones
    public func recalculateProgress() {
        let all = milestones ?? []
        guard !all.isEmpty else { progressPercent = 0; return }
        let completed = all.filter(\.isCompleted).count
        progressPercent = Double(completed) / Double(all.count) * 100
    }
}

@Model
public final class GoalMilestone {
    public var id: UUID = UUID()
    public var title: String = ""
    public var isCompleted: Bool = false
    public var dueDate: Date?
    public var completedAt: Date?
    public var sortOrder: Int = 0

    public var goal: Goal?

    public init(title: String, sortOrder: Int = 0) {
        self.id = UUID()
        self.title = title
        self.sortOrder = sortOrder
    }
}
