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
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                .tag(AppTab.home)

            LearnView()
                .tabItem {
                    Label("Learn", systemImage: "brain.head.profile")
                }
                .tag(AppTab.learn)

            WorkspacesView()
                .tabItem {
                    Label("Spaces", systemImage: "square.grid.2x2")
                }
                .tag(AppTab.workspaces)

            ChatView()
                .tabItem {
                    Label("Chat", systemImage: "bubble.left.and.bubble.right")
                }
                .tag(AppTab.chat)

            ProfileView()
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
            case .home: HomeView()
            case .learn: LearnView()
            case .workspaces: WorkspacesView()
            case .chat: ChatView()
            case .profile: ProfileView()
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

// MARK: - Placeholder Views

struct HomeView: View {
    @Environment(\.tutorTheme) private var theme

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: TutorSpacing.lg) {
                    // Welcome header
                    GlassCard {
                        VStack(alignment: .leading, spacing: TutorSpacing.sm) {
                            Text("Welcome back")
                                .font(TutorTypography.title2)
                                .foregroundStyle(theme.textPrimary)
                            Text("Ready to learn something new?")
                                .font(TutorTypography.body)
                                .foregroundStyle(theme.textSecondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    // Quick stats
                    HStack(spacing: TutorSpacing.md) {
                        StatBadge(icon: "flame.fill", value: "0", label: "Streak", color: TutorColors.streakFlame)
                        StatBadge(icon: "star.fill", value: "0", label: "XP", color: TutorColors.xpGold)
                        StatBadge(icon: "chart.bar.fill", value: "1", label: "Level", color: TutorColors.levelPurple)
                    }
                    .padding(.horizontal)

                    // Daily lesson card
                    GlassCard {
                        VStack(alignment: .leading, spacing: TutorSpacing.sm) {
                            Label("Daily Lesson", systemImage: "book.fill")
                                .font(TutorTypography.headline)
                            Text("Upload your first material to get started")
                                .font(TutorTypography.body)
                                .foregroundStyle(theme.textSecondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding()
            }
            .background(theme.background)
            .navigationTitle("Home")
        }
    }
}

struct LearnView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: TutorSpacing.lg) {
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 60))
                    .foregroundStyle(.secondary)
                Text("Your learning tools will appear here")
                    .font(TutorTypography.headline)
                Text("Flashcards, quizzes, daily lessons, and more")
                    .font(TutorTypography.body)
                    .foregroundStyle(.secondary)
            }
            .navigationTitle("Learn")
        }
    }
}

struct WorkspacesView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: TutorSpacing.lg) {
                Image(systemName: "square.grid.2x2")
                    .font(.system(size: 60))
                    .foregroundStyle(.secondary)
                Text("No workspaces yet")
                    .font(TutorTypography.headline)
                Text("Create a workspace to organize your learning")
                    .font(TutorTypography.body)
                    .foregroundStyle(.secondary)
            }
            .navigationTitle("Workspaces")
        }
    }
}

struct ChatView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: TutorSpacing.lg) {
                Image(systemName: "bubble.left.and.bubble.right")
                    .font(.system(size: 60))
                    .foregroundStyle(.secondary)
                Text("Chat with your AI tutor")
                    .font(TutorTypography.headline)
                Text("Ask questions about anything you've uploaded")
                    .font(TutorTypography.body)
                    .foregroundStyle(.secondary)
            }
            .navigationTitle("Chat")
        }
    }
}

struct ProfileView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: TutorSpacing.lg) {
                Image(systemName: "person.circle")
                    .font(.system(size: 60))
                    .foregroundStyle(.secondary)
                Text("Your Profile")
                    .font(TutorTypography.headline)
                Text("Stats, settings, and preferences")
                    .font(TutorTypography.body)
                    .foregroundStyle(.secondary)
            }
            .navigationTitle("Profile")
        }
    }
}

#Preview {
    ContentView()
        .environment(ThemeManager())
        .environment(\.tutorTheme, MinimalTheme())
        .modelContainer(try! TutorSchema.createPreviewContainer())
}
