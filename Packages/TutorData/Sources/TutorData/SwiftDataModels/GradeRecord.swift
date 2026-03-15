import Foundation
import SwiftData
import TutorCore

@Model
public final class GradeRecord {
    public var id: UUID = UUID()
    public var assignmentName: String = ""
    public var grade: Double?
    public var totalPoints: Double = 100
    public var weight: Double = 1.0
    public var category: String = GradeCategory.other.rawValue
    public var date: Date = Date()
    public var workspaceID: UUID?

    public init(assignmentName: String, grade: Double? = nil, totalPoints: Double = 100) {
        self.id = UUID()
        self.assignmentName = assignmentName
        self.grade = grade
        self.totalPoints = totalPoints
        self.date = Date()
    }

    public var gradeCategory: GradeCategory {
        get { GradeCategory(rawValue: category) ?? .other }
        set { category = newValue.rawValue }
    }

    /// Percentage score (0-100)
    public var percentage: Double? {
        guard let grade else { return nil }
        return (grade / totalPoints) * 100
    }
}
