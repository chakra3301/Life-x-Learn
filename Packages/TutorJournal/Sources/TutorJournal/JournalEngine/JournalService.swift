import Foundation
import TutorCore

/// Service for journal-related features
public struct JournalService: Sendable {

    public init() {}

    /// Suggested journal prompts for different contexts
    public func suggestPrompt(for context: JournalContext) -> String {
        let prompts = promptsForContext(context)
        return prompts.randomElement() ?? "What did you learn today?"
    }

    private func promptsForContext(_ context: JournalContext) -> [String] {
        switch context {
        case .learningReflection:
            return [
                "What was the most challenging concept you studied today? How did you work through it?",
                "Describe a moment today when something 'clicked' in your understanding.",
                "What connections did you notice between what you learned today and something you already knew?",
                "If you had to teach today's material to someone else, what would you emphasize?",
                "What questions do you still have about what you studied today?",
            ]
        case .dailyReview:
            return [
                "What are three things you accomplished today?",
                "What would you do differently if you could redo today's study session?",
                "Rate your focus today from 1-10. What helped or hindered your concentration?",
                "What are you most curious about right now?",
                "How did your learning align with your goals today?",
            ]
        case .goalReflection:
            return [
                "How are you progressing toward your current learning goals?",
                "What obstacles are between you and your next milestone?",
                "What skills have you developed recently that you're proud of?",
                "If you could master one topic instantly, what would it be and why?",
                "How has your perspective on learning changed recently?",
            ]
        case .general:
            return [
                "What's on your mind today?",
                "Describe something that inspired you recently.",
                "What are you grateful for in your learning journey?",
                "What would your ideal learning day look like?",
                "Write about a mistake that taught you something valuable.",
            ]
        }
    }
}

public enum JournalContext: Sendable {
    case learningReflection
    case dailyReview
    case goalReflection
    case general
}
