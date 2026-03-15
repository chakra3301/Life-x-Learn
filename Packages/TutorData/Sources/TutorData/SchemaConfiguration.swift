import Foundation
import SwiftData

/// Central schema configuration for the entire Tutor app
public enum TutorSchema {
    /// All SwiftData model types used in the app
    public static let modelTypes: [any PersistentModel.Type] = [
        UserProfile.self,
        TutorPersonality.self,
        Workspace.self,
        KnowledgeItem.self,
        KnowledgeChunk.self,
        Tag.self,
        Flashcard.self,
        FlashcardReview.self,
        Quiz.self,
        QuizQuestion.self,
        WritingExercise.self,
        Conversation.self,
        ChatMessage.self,
        CrossConnection.self,
        JournalEntry.self,
        UserStats.self,
        DailyActivity.self,
        GradeRecord.self,
        StudyPlan.self,
        Goal.self,
        GoalMilestone.self,
        DailyLesson.self,
    ]

    /// Create a ModelContainer for the app with iCloud sync
    public static func createContainer(inMemory: Bool = false) throws -> ModelContainer {
        let schema = Schema(modelTypes)

        let config = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: inMemory,
            cloudKitDatabase: inMemory ? .none : .automatic
        )

        return try ModelContainer(for: schema, configurations: [config])
    }

    /// Create an in-memory container for testing/previews
    public static func createPreviewContainer() throws -> ModelContainer {
        try createContainer(inMemory: true)
    }
}
