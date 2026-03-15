import Foundation
import SwiftData

@Model
public final class DailyLesson {
    public var id: UUID = UUID()
    public var date: Date = Date()
    public var title: String = ""
    public var contentJSON: String = ""
    public var durationMinutes: Int = 15
    public var isCompleted: Bool = false
    public var completedAt: Date?
    public var workspaceID: UUID?

    public init(title: String, durationMinutes: Int = 15) {
        self.id = UUID()
        self.title = title
        self.durationMinutes = durationMinutes
        self.date = Date()
    }
}
