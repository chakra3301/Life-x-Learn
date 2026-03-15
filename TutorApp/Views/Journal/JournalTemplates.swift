import Foundation

/// Journal entry templates
enum JournalTemplate: String, CaseIterable, Identifiable {
    case freeform
    case dailyReflection
    case learningLog
    case readingResponse
    case gratitude
    case goalCheckIn
    case problemSolving
    case weeklyReview

    var id: String { rawValue }

    var name: String {
        switch self {
        case .freeform: return "Freeform"
        case .dailyReflection: return "Daily Reflection"
        case .learningLog: return "Learning Log"
        case .readingResponse: return "Reading Response"
        case .gratitude: return "Gratitude"
        case .goalCheckIn: return "Goal Check-In"
        case .problemSolving: return "Problem Solving"
        case .weeklyReview: return "Weekly Review"
        }
    }

    var icon: String {
        switch self {
        case .freeform: return "pencil"
        case .dailyReflection: return "sun.and.horizon"
        case .learningLog: return "brain.head.profile"
        case .readingResponse: return "book"
        case .gratitude: return "heart"
        case .goalCheckIn: return "target"
        case .problemSolving: return "lightbulb"
        case .weeklyReview: return "calendar"
        }
    }

    var description: String {
        switch self {
        case .freeform: return "Write whatever's on your mind"
        case .dailyReflection: return "Reflect on your day and what you learned"
        case .learningLog: return "Document what you studied and key takeaways"
        case .readingResponse: return "Respond to something you read"
        case .gratitude: return "Note what you're grateful for"
        case .goalCheckIn: return "Check in on your progress toward goals"
        case .problemSolving: return "Work through a challenge or problem"
        case .weeklyReview: return "Review your week's progress"
        }
    }

    var placeholder: String {
        switch self {
        case .freeform: return "Start writing..."
        case .dailyReflection: return "What stood out to you today?"
        case .learningLog: return "What did you learn today?"
        case .readingResponse: return "What did you read, and what resonated with you?"
        case .gratitude: return "What are you grateful for right now?"
        case .goalCheckIn: return "How are you progressing toward your goals?"
        case .problemSolving: return "What challenge are you working through?"
        case .weeklyReview: return "How did this week go?"
        }
    }

    var starterText: String {
        switch self {
        case .freeform:
            return ""
        case .dailyReflection:
            return """
            ## Today's Reflection

            **What went well today:**


            **What I learned:**


            **What I'd do differently:**


            **Tomorrow I want to:**

            """
        case .learningLog:
            return """
            ## Learning Log

            **Topic:**


            **Key concepts:**
            -\u{0020}

            **What clicked:**


            **What's still unclear:**


            **Next steps:**

            """
        case .readingResponse:
            return """
            ## Reading Response

            **What I read:**


            **Key ideas:**
            -\u{0020}

            **What resonated with me:**


            **How this connects to what I already know:**

            """
        case .gratitude:
            return """
            ## Gratitude

            **Three things I'm grateful for:**
            1.\u{0020}
            2.\u{0020}
            3.\u{0020}

            **Someone who made a difference today:**


            **A small moment I appreciated:**

            """
        case .goalCheckIn:
            return """
            ## Goal Check-In

            **Goal I'm working toward:**


            **Progress since last check-in:**


            **Obstacles I'm facing:**


            **What I'll do next:**

            """
        case .problemSolving:
            return """
            ## Problem Solving

            **The challenge:**


            **What I've tried:**
            -\u{0020}

            **What I think might work:**


            **Resources I need:**

            """
        case .weeklyReview:
            return """
            ## Weekly Review

            **Highlights of the week:**
            -\u{0020}

            **What I learned:**
            -\u{0020}

            **What challenged me:**


            **Goals for next week:**
            -\u{0020}

            **How I'm feeling overall:**

            """
        }
    }
}
