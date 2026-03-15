import Foundation
import SwiftData
import TutorCore

@Model
public final class WritingExercise {
    public var id: UUID = UUID()
    public var prompt: String = ""
    public var exerciseType: String = WritingType.paragraph.rawValue
    public var userResponse: String = ""
    public var aiFeedback: String?
    public var score: Double?
    public var createdAt: Date = Date()
    public var completedAt: Date?
    public var workspaceID: UUID?

    public init(prompt: String, type: WritingType = .paragraph) {
        self.id = UUID()
        self.prompt = prompt
        self.exerciseType = type.rawValue
        self.createdAt = Date()
    }

    public var type: WritingType {
        get { WritingType(rawValue: exerciseType) ?? .paragraph }
        set { exerciseType = newValue.rawValue }
    }

    public var isCompleted: Bool {
        completedAt != nil
    }
}
