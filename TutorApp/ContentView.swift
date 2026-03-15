import SwiftUI
import SwiftData
import TutorCore
import TutorData
import TutorUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(ThemeManager.self) private var themeManager

    @State private var selectedTab: AppTab = .home
    @State private var selectedSidebarItem: AppTab? = .home

    var body: some View {
        #if os(macOS)
        macOSLayout
        #else
        iOSLayout
        #endif
    }

    // MARK: - iOS Layout

    private var iOSLayout: some View {
        TabView(selection: $selectedTab) {
            HomeDashboardView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                .tag(AppTab.home)

            LearnView()
                .tabItem {
                    Label("Learn", systemImage: "brain.head.profile")
                }
                .tag(AppTab.learn)

            WorkspaceListView()
                .tabItem {
                    Label("Spaces", systemImage: "square.grid.2x2")
                }
                .tag(AppTab.workspaces)

            ChatConversationView()
                .tabItem {
                    Label("Chat", systemImage: "bubble.left.and.bubble.right")
                }
                .tag(AppTab.chat)

            ProfileSettingsView()
                .tabItem {
                    Label("Profile", systemImage: "person.circle")
                }
                .tag(AppTab.profile)
        }
        .tint(themeManager.currentTheme.accentColor)
    }

    // MARK: - macOS Layout

    private var macOSLayout: some View {
        NavigationSplitView {
            List(AppTab.allCases, selection: $selectedSidebarItem) { tab in
                Label(tab.title, systemImage: tab.icon)
                    .tag(tab)
            }
            .navigationTitle("Tutor")
            .listStyle(.sidebar)
        } detail: {
            switch selectedSidebarItem ?? .home {
            case .home: HomeDashboardView()
            case .learn: LearnView()
            case .workspaces: WorkspaceListView()
            case .chat: ChatConversationView()
            case .profile: ProfileSettingsView()
            }
        }
    }
}

// MARK: - Tab Definition

enum AppTab: String, CaseIterable, Identifiable {
    case home
    case learn
    case workspaces
    case chat
    case profile

    var id: String { rawValue }

    var title: String {
        switch self {
        case .home: return "Home"
        case .learn: return "Learn"
        case .workspaces: return "Spaces"
        case .chat: return "Chat"
        case .profile: return "Profile"
        }
    }

    var icon: String {
        switch self {
        case .home: return "house"
        case .learn: return "brain.head.profile"
        case .workspaces: return "square.grid.2x2"
        case .chat: return "bubble.left.and.bubble.right"
        case .profile: return "person.circle"
        }
    }
}

// MARK: - Learn View (Phase 2 placeholder with structure)

struct LearnView: View {
    @Environment(\.tutorTheme) private var theme

    @Query(sort: \Flashcard.dueDate) private var allCards: [Flashcard]

    private var dueCards: [Flashcard] {
        allCards.filter { $0.isDue }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: TutorSpacing.lg) {
                    // Due flashcards
                    GlassCard {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Label("Flashcards", systemImage: "rectangle.on.rectangle")
                                    .font(TutorTypography.headline)
                                Text("\(dueCards.count) cards due for review")
                                    .font(TutorTypography.caption)
                                    .foregroundStyle(theme.textSecondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundStyle(theme.textSecondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    // Quiz
                    GlassCard {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Label("Practice Quiz", systemImage: "checklist")
                                    .font(TutorTypography.headline)
                                Text("Test your knowledge")
                                    .font(TutorTypography.caption)
                                    .foregroundStyle(theme.textSecondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundStyle(theme.textSecondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    // Writing practice
                    GlassCard {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Label("Writing Practice", systemImage: "pencil.line")
                                    .font(TutorTypography.headline)
                                Text("Improve your writing skills")
                                    .font(TutorTypography.caption)
                                    .foregroundStyle(theme.textSecondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundStyle(theme.textSecondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    // Daily lesson
                    GlassCard {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Label("Daily Lesson", systemImage: "book.fill")
                                    .font(TutorTypography.headline)
                                Text("Your personalized daily review")
                                    .font(TutorTypography.caption)
                                    .foregroundStyle(theme.textSecondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundStyle(theme.textSecondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding()
            }
            .background(theme.background)
            .navigationTitle("Learn")
        }
    }
}

#Preview {
    ContentView()
        .environment(ThemeManager())
        .environment(\.tutorTheme, MinimalTheme())
        .modelContainer(try! TutorSchema.createPreviewContainer())
}
