import Foundation
import SwiftData
import TutorCore

@Model
public final class UserProfile {
    public var id: UUID = UUID()
    public var displayName: String = ""
    public var createdAt: Date = Date()
    public var currentMode: String = AppMode.life.rawValue
    public var themePreference: String = ThemeType.minimal.rawValue
    public var colorScheme: String = ColorSchemePreference.system.rawValue
    public var dailyLessonDuration: Int = 15
    public var reviewFrequency: String = ReviewFrequency.weekly.rawValue
    public var proactiveReminders: Bool = true

    @Relationship(deleteRule: .cascade, inverse: \TutorPersonality.user)
    public var personality: TutorPersonality?

    @Relationship(deleteRule: .cascade, inverse: \Workspace.owner)
    public var workspaces: [Workspace]?

    @Relationship(deleteRule: .cascade, inverse: \JournalEntry.user)
    public var journalEntries: [JournalEntry]?

    @Relationship(deleteRule: .cascade, inverse: \UserStats.user)
    public var stats: UserStats?

    public init(displayName: String = "", mode: AppMode = .life) {
        self.id = UUID()
        self.displayName = displayName
        self.currentMode = mode.rawValue
        self.createdAt = Date()
    }

    // MARK: - Computed Helpers

    public var appMode: AppMode {
        get { AppMode(rawValue: currentMode) ?? .life }
        set { currentMode = newValue.rawValue }
    }

    public var theme: ThemeType {
        get { ThemeType(rawValue: themePreference) ?? .minimal }
        set { themePreference = newValue.rawValue }
    }
}
