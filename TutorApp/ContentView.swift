import SwiftUI
import SwiftData
import TutorCore
import TutorData
import TutorUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(ThemeManager.self) private var themeManager

    @State private var selectedTab: AppTab = .home
    @State private var selectedSidebarItem: SidebarItem? = .home

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
            MacSidebarView(selection: $selectedSidebarItem)
        } detail: {
            macOSDetail
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .navigationSplitViewStyle(.balanced)
    }

    @ViewBuilder
    private var macOSDetail: some View {
        switch selectedSidebarItem {
        case .home, .none:
            HomeDashboardView()
        case .learn:
            LearnView()
        case .chat:
            ChatConversationView()
        case .journal:
            JournalHomeView()
        case .upload:
            UploadView()
        case .profile:
            ProfileSettingsView()
        case .workspace(let id):
            WorkspaceDetailRouter(workspaceID: id)
        case .allWorkspaces:
            WorkspaceListView()
        }
    }
}

// MARK: - Sidebar Item

enum SidebarItem: Hashable {
    case home
    case learn
    case chat
    case journal
    case upload
    case profile
    case workspace(UUID)
    case allWorkspaces
}

// MARK: - macOS Sidebar

struct MacSidebarView: View {
    @Environment(\.tutorTheme) private var theme
    @Binding var selection: SidebarItem?

    @Query(sort: \Workspace.sortOrder) private var workspaces: [Workspace]
    @Query(sort: \Flashcard.dueDate) private var allCards: [Flashcard]

    @State private var workspacesExpanded = true
    @State private var isHoveringNewWorkspace = false

    private var dueCards: Int {
        allCards.filter { $0.isDue }.count
    }

    private var topLevelWorkspaces: [Workspace] {
        workspaces.filter { $0.parentWorkspace == nil }
    }

    var body: some View {
        List(selection: $selection) {
            // MARK: Main
            Section {
                sidebarRow(.home, icon: "house", label: "Home")
                sidebarRow(.learn, icon: "brain.head.profile", label: "Learn", badge: dueCards > 0 ? "\(dueCards)" : nil)
                sidebarRow(.chat, icon: "bubble.left.and.text.bubble.right", label: "Chat")
                sidebarRow(.journal, icon: "book.closed", label: "Journal")
                sidebarRow(.upload, icon: "arrow.up.doc", label: "Upload")
            }

            // MARK: Workspaces
            Section {
                DisclosureGroup(isExpanded: $workspacesExpanded) {
                    ForEach(topLevelWorkspaces) { workspace in
                        sidebarRow(
                            .workspace(workspace.id),
                            icon: workspace.icon,
                            label: workspace.name,
                            iconColor: Color(hex: workspace.colorHex)
                        )
                    }

                    sidebarRow(.allWorkspaces, icon: "ellipsis.circle", label: "All Workspaces")
                } label: {
                    HStack {
                        Text("Workspaces")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(theme.textSecondary)
                        Spacer()
                    }
                }
            }

            // MARK: Settings
            Section {
                sidebarRow(.profile, icon: "gearshape", label: "Settings")
            }
        }
        .listStyle(.sidebar)
        .navigationTitle("Tutor")
        .frame(minWidth: 200, idealWidth: 240)
    }

    // MARK: - Sidebar Row

    private func sidebarRow(
        _ item: SidebarItem,
        icon: String,
        label: String,
        badge: String? = nil,
        iconColor: Color? = nil
    ) -> some View {
        Label {
            HStack {
                Text(label)
                Spacer()
                if let badge {
                    Text(badge)
                        .font(.caption2.weight(.medium))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(theme.accentColor.opacity(0.15))
                        .foregroundStyle(theme.accentColor)
                        .clipShape(Capsule())
                }
            }
        } icon: {
            Image(systemName: icon)
                .foregroundStyle(iconColor ?? theme.textSecondary)
                .frame(width: 18)
        }
        .tag(item)
    }
}

// MARK: - Workspace Detail Router

struct WorkspaceDetailRouter: View {
    let workspaceID: UUID
    @Query private var workspaces: [Workspace]

    private var workspace: Workspace? {
        workspaces.first { $0.id == workspaceID }
    }

    var body: some View {
        if let workspace {
            WorkspaceDetailView(workspace: workspace)
        } else {
            ContentUnavailableView("Workspace not found", systemImage: "folder.badge.questionmark")
        }
    }
}

// MARK: - Tab Definition (iOS)

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

// MARK: - Learn View

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
                    learnCard(
                        icon: "rectangle.on.rectangle",
                        title: "Flashcards",
                        subtitle: "\(dueCards.count) cards due for review",
                        color: theme.accentColor
                    )

                    learnCard(
                        icon: "checklist",
                        title: "Practice Quiz",
                        subtitle: "Test your knowledge",
                        color: theme.accentColor
                    )

                    learnCard(
                        icon: "pencil.line",
                        title: "Writing Practice",
                        subtitle: "Improve your writing skills",
                        color: theme.accentColor
                    )

                    learnCard(
                        icon: "book.fill",
                        title: "Daily Lesson",
                        subtitle: "Your personalized daily review",
                        color: theme.accentColor
                    )
                }
                .padding()
            }
            .background(theme.background)
            .navigationTitle("Learn")
        }
    }

    private func learnCard(icon: String, title: String, subtitle: String, color: Color) -> some View {
        GlassCard {
            HStack(spacing: TutorSpacing.sm) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(color.opacity(0.8))
                    .frame(width: 36, height: 36)
                    .background(color.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: TutorRadius.sm))

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(TutorTypography.bodyMedium)
                        .foregroundStyle(theme.textPrimary)
                    Text(subtitle)
                        .font(TutorTypography.caption)
                        .foregroundStyle(theme.textSecondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(theme.textSecondary.opacity(0.5))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    ContentView()
        .environment(ThemeManager())
        .environment(\.tutorTheme, MinimalTheme())
        .modelContainer(try! TutorSchema.createPreviewContainer())
}
