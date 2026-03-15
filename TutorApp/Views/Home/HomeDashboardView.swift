import SwiftUI
import SwiftData
import TutorCore
import TutorData
import TutorUI
import TutorGamification

struct HomeDashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.tutorTheme) private var theme

    @Query private var profiles: [UserProfile]
    @Query(sort: \KnowledgeItem.importedAt, order: .reverse) private var recentItems: [KnowledgeItem]
    @Query(sort: \Flashcard.dueDate) private var allCards: [Flashcard]

    private var dueCards: [Flashcard] {
        allCards.filter { $0.isDue }
    }
    @Query(sort: \Workspace.sortOrder) private var workspaces: [Workspace]

    @State private var showUpload = false
    @State private var showJournal = false

    private var profile: UserProfile? { profiles.first }
    private var stats: UserStats? { profile?.stats }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: TutorSpacing.lg) {
                    welcomeHeader
                    statsRow
                    if !dueCards.isEmpty { dueCardsCard }
                    quickActions
                    recentUploads
                    activeWorkspaces
                }
                .padding()
            }
            .background(theme.background)
            .navigationTitle("Home")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button { showUpload = true } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showUpload) {
                UploadView()
            }
            .sheet(isPresented: $showJournal) {
                JournalHomeView()
            }
            .onAppear { ensureProfile() }
        }
    }

    // MARK: - Welcome

    private var welcomeHeader: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: TutorSpacing.sm) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(greeting)
                            .font(TutorTypography.title2)
                            .foregroundStyle(theme.textPrimary)
                        Text(motivationalText)
                            .font(TutorTypography.body)
                            .foregroundStyle(theme.textSecondary)
                    }
                    Spacer()
                    // Mode badge
                    Text(profile?.appMode.rawValue.capitalized ?? "Life")
                        .font(TutorTypography.caption)
                        .padding(.horizontal, TutorSpacing.sm)
                        .padding(.vertical, TutorSpacing.xxs)
                        .background(theme.accentColor.opacity(0.15))
                        .foregroundStyle(theme.accentColor)
                        .clipShape(Capsule())
                }

                // XP progress
                if let stats {
                    XPProgressBar(
                        progress: LevelSystem.progress(for: stats.totalXP),
                        currentXP: stats.totalXP,
                        nextLevelXP: stats.currentLevel < LevelSystem.maxLevel
                            ? LevelSystem.thresholds[stats.currentLevel]
                            : stats.totalXP
                    )
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Stats

    private var statsRow: some View {
        HStack(spacing: TutorSpacing.md) {
            StatBadge(
                icon: "flame.fill",
                value: "\(stats?.currentStreak ?? 0)",
                label: "Streak",
                color: TutorColors.streakFlame
            )
            StatBadge(
                icon: "star.fill",
                value: "\(stats?.totalXP ?? 0)",
                label: "XP",
                color: TutorColors.xpGold
            )
            StatBadge(
                icon: "chart.bar.fill",
                value: "Lv.\(stats?.currentLevel ?? 1)",
                label: "Level",
                color: TutorColors.levelPurple
            )
            StatBadge(
                icon: "clock.fill",
                value: formatMinutes(stats?.totalStudyMinutes ?? 0),
                label: "Study",
                color: TutorColors.primary
            )
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Due Cards

    private var dueCardsCard: some View {
        GlassCard {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Label("\(dueCards.count) cards due", systemImage: "rectangle.on.rectangle")
                        .font(TutorTypography.headline)
                        .foregroundStyle(theme.textPrimary)
                    Text("Review them to keep your knowledge fresh")
                        .font(TutorTypography.caption)
                        .foregroundStyle(theme.textSecondary)
                }
                Spacer()
                NavigationLink {
                    // FlashcardReviewView
                    Text("Review session coming soon")
                } label: {
                    Text("Review")
                        .font(TutorTypography.bodyMedium)
                        .padding(.horizontal, TutorSpacing.md)
                        .padding(.vertical, TutorSpacing.xs)
                        .background(theme.accentColor)
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Quick Actions

    private var quickActions: some View {
        VStack(alignment: .leading, spacing: TutorSpacing.sm) {
            Text("Quick Actions")
                .font(TutorTypography.headline)
                .foregroundStyle(theme.textPrimary)

            HStack(spacing: TutorSpacing.sm) {
                QuickActionButton(icon: "plus", title: "Upload", color: theme.accentColor) {
                    showUpload = true
                }
                QuickActionButton(icon: "rectangle.on.rectangle", title: "Study", color: .blue) {
                    // Navigate to flashcard review
                }
                QuickActionButton(icon: "checklist", title: "Quiz", color: .green) {
                    // Navigate to quiz
                }
                QuickActionButton(icon: "book", title: "Journal", color: .orange) {
                    showJournal = true
                }
            }
        }
    }

    // MARK: - Recent Uploads

    private var recentUploads: some View {
        VStack(alignment: .leading, spacing: TutorSpacing.sm) {
            HStack {
                Text("Recent")
                    .font(TutorTypography.headline)
                    .foregroundStyle(theme.textPrimary)
                Spacer()
            }

            if recentItems.isEmpty {
                GlassCard {
                    VStack(spacing: TutorSpacing.sm) {
                        Image(systemName: "tray")
                            .font(.title)
                            .foregroundStyle(theme.textSecondary)
                        Text("Nothing uploaded yet")
                            .font(TutorTypography.body)
                            .foregroundStyle(theme.textSecondary)
                        Text("Add your first piece of knowledge to get started")
                            .font(TutorTypography.caption)
                            .foregroundStyle(theme.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical)
                }
            } else {
                ForEach(Array(recentItems.prefix(5))) { item in
                    NavigationLink {
                        KnowledgeItemDetailView(item: item)
                    } label: {
                        KnowledgeItemRow(item: item)
                            .padding(.horizontal, TutorSpacing.sm)
                            .padding(.vertical, TutorSpacing.xxs)
                            .background(theme.surfacePrimary)
                            .clipShape(RoundedRectangle(cornerRadius: TutorRadius.md))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Active Workspaces

    private var activeWorkspaces: some View {
        VStack(alignment: .leading, spacing: TutorSpacing.sm) {
            if !workspaces.isEmpty {
                Text("Workspaces")
                    .font(TutorTypography.headline)
                    .foregroundStyle(theme.textPrimary)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: TutorSpacing.sm) {
                        ForEach(workspaces.filter { $0.parentWorkspace == nil }.prefix(6)) { workspace in
                            NavigationLink {
                                WorkspaceDetailView(workspace: workspace)
                            } label: {
                                MiniWorkspaceCard(workspace: workspace)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Helpers

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        case 17..<22: return "Good evening"
        default: return "Hey there"
        }
    }

    private var motivationalText: String {
        if let streak = stats?.currentStreak, streak > 0 {
            return "\(streak) day streak! Keep it going."
        }
        return "Ready to learn something new?"
    }

    private func formatMinutes(_ minutes: Int) -> String {
        if minutes < 60 { return "\(minutes)m" }
        return "\(minutes / 60)h"
    }

    private func ensureProfile() {
        if profiles.isEmpty {
            let profile = UserProfile()
            let stats = UserStats()
            stats.user = profile
            modelContext.insert(profile)
            modelContext.insert(stats)
            try? modelContext.save()
        }
    }
}

// MARK: - Quick Action Button

struct QuickActionButton: View {
    @Environment(\.tutorTheme) private var theme
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: TutorSpacing.xs) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(color)
                    .frame(width: 44, height: 44)
                    .background(color.opacity(0.12))
                    .clipShape(Circle())
                Text(title)
                    .font(TutorTypography.caption)
                    .foregroundStyle(theme.textPrimary)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Mini Workspace Card

struct MiniWorkspaceCard: View {
    @Environment(\.tutorTheme) private var theme
    let workspace: Workspace

    var body: some View {
        VStack(spacing: TutorSpacing.xs) {
            Image(systemName: workspace.icon)
                .font(.title2)
                .foregroundStyle(Color(hex: workspace.colorHex))
            Text(workspace.name)
                .font(TutorTypography.caption)
                .foregroundStyle(theme.textPrimary)
                .lineLimit(1)
            Text("\(workspace.knowledgeItems?.count ?? 0) items")
                .font(TutorTypography.caption2)
                .foregroundStyle(theme.textSecondary)
        }
        .frame(width: 90, height: 90)
        .background(theme.surfacePrimary)
        .clipShape(RoundedRectangle(cornerRadius: TutorRadius.md))
    }
}
