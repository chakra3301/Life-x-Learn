import Foundation
import TutorCore

/// Pre-built workspace templates for common use cases
public enum WorkspaceTemplate: String, CaseIterable, Sendable {
    case collegeCourse
    case highSchoolClass
    case bookStudy
    case languageLearning
    case codingProject
    case examPrep
    case research
    case skillDevelopment

    public var name: String {
        switch self {
        case .collegeCourse: return "College Course"
        case .highSchoolClass: return "High School Class"
        case .bookStudy: return "Book Study"
        case .languageLearning: return "Language Learning"
        case .codingProject: return "Coding Project"
        case .examPrep: return "Exam Prep"
        case .research: return "Research"
        case .skillDevelopment: return "Skill Development"
        }
    }

    public var icon: String {
        switch self {
        case .collegeCourse: return "graduationcap"
        case .highSchoolClass: return "book"
        case .bookStudy: return "text.book.closed"
        case .languageLearning: return "globe"
        case .codingProject: return "chevron.left.forwardslash.chevron.right"
        case .examPrep: return "checklist"
        case .research: return "magnifyingglass"
        case .skillDevelopment: return "star"
        }
    }

    public var defaultColor: String {
        switch self {
        case .collegeCourse: return "#007AFF"
        case .highSchoolClass: return "#34C759"
        case .bookStudy: return "#FF9500"
        case .languageLearning: return "#AF52DE"
        case .codingProject: return "#5856D6"
        case .examPrep: return "#FF3B30"
        case .research: return "#00C7BE"
        case .skillDevelopment: return "#FFD700"
        }
    }

    public var workspaceType: WorkspaceType {
        switch self {
        case .collegeCourse, .highSchoolClass: return .classType
        case .bookStudy: return .project
        case .languageLearning: return .subject
        case .codingProject: return .project
        case .examPrep: return .goal
        case .research: return .project
        case .skillDevelopment: return .goal
        }
    }

    /// Sub-sections that come with this template
    public var defaultSubSections: [String] {
        switch self {
        case .collegeCourse:
            return ["Lectures", "Assignments", "Readings", "Exam Prep", "Notes"]
        case .highSchoolClass:
            return ["Notes", "Homework", "Projects", "Study Guides"]
        case .bookStudy:
            return ["Chapter Notes", "Key Concepts", "Discussion Questions", "Vocabulary"]
        case .languageLearning:
            return ["Vocabulary", "Grammar", "Practice", "Culture", "Listening"]
        case .codingProject:
            return ["Documentation", "Tutorials", "Reference", "Notes"]
        case .examPrep:
            return ["Study Materials", "Practice Tests", "Weak Areas", "Review Notes"]
        case .research:
            return ["Sources", "Notes", "Drafts", "Data", "References"]
        case .skillDevelopment:
            return ["Fundamentals", "Practice", "Projects", "Resources"]
        }
    }
}
