import Foundation
import SwiftData

@Model
public final class StudyPlan {
    public var id: UUID = UUID()
    public var examName: String = ""
    public var examDate: Date = Date()
    public var createdAt: Date = Date()
    public var planJSON: String = ""
    public var isActive: Bool = true
    public var workspaceID: UUID?

    public init(examName: String, examDate: Date) {
        self.id = UUID()
        self.examName = examName
        self.examDate = examDate
        self.createdAt = Date()
    }

    /// Days until the exam
    public var daysUntilExam: Int {
        Calendar.current.dateComponents([.day], from: Date(), to: examDate).day ?? 0
    }
}
