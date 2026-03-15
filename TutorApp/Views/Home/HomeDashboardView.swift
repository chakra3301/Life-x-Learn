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
                    Text(profile?.appMode.rawValue.capitalized ?? "Life")
                        .font(TutorTypography.caption)
                        .padding(.horizontal, TutorSpacing.sm)
                        .padding(.vertical, TutorSpacing.xxs)
                        .background(theme.accentColor.opacity(0.1))
                        .foregroundStyle(theme.accentColor)
                        .clipShape(Capsule())
                }

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
        HStack(spacing: TutorSpacing.sm) {
            StatBadge(
                icon: "flame.fill",
                value: "\(stats?.currentStreak ?? 0)",
                label: "Streak",
                color: TutorColors.tintOrange
            )
            StatBadge(
                icon: "star.fill",
                value: "\(stats?.totalXP ?? 0)",
                label: "XP",
                color: TutorColors.tintAmber
            )
            StatBadge(
                icon: "chart.bar.fill",
                value: "Lv.\(stats?.currentLevel ?? 1)",
                label: "Level",
                color: TutorColors.tintViolet
            )
            StatBadge(
                icon: "clock.fill",
                value: formatMinutes(stats?.totalStudyMinutes ?? 0),
                label: "Study",
                color: TutorColors.tintBlue
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
                        .font(TutorTypography.bodyMedium)
                        .foregroundStyle(theme.textPrimary)
                    Text("Review them to keep your knowledge fresh")
                        .font(TutorTypography.caption)
                        .foregroundStyle(theme.textSecondary)
                }
                Spacer()
                NavigationLink {
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
                .font(TutorTypography.bodyMedium)
                .foregroundStyle(theme.textSecondary)

            HStack(spacing: TutorSpacing.sm) {
                QuickActionButton(icon: "arrow.up.doc", title: "Upload", color: TutorColors.tintBlue) {
                    showUpload = true
                }
                QuickActionButton(icon: "rectangle.on.rectangle", title: "Study", color: TutorColors.tintIndigo) {
                    // Navigate to flashcard review
                }
                QuickActionButton(icon: "checklist", title: "Quiz", color: TutorColors.tintEmerald) {
                    // Navigate to quiz
                }
                QuickActionButton(icon: "book.closed", title: "Journal", color: TutorColors.tintAmber) {
                    showJournal = true
                }
            }
        }
    }

    // MARK: - Recent Uploads

    private var recentUploads: some View {
        VStack(alignment: .leading, spacing: TutorSpacing.sm) {
            Text("Recent")
                .font(TutorTypography.bodyMedium)
                .foregroundStyle(theme.textSecondary)

            if recentItems.isEmpty {
                GlassCard {
                    VStack(spacing: TutorSpacing.sm) {
                        Image(systemName: "tray")
                            .font(.title2)
                            .foregroundStyle(theme.textSecondary.opacity(0.5))
                        Text("Nothing uploaded yet")
                            .font(TutorTypography.body)
                            .foregroundStyle(theme.textSecondary)
                        Text("Add your first piece of knowledge to get started")
                            .font(TutorTypography.caption)
                            .foregroundStyle(theme.textSecondary.opacity(0.7))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, TutorSpacing.md)
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
                    .font(TutorTypography.bodyMedium)
                    .foregroundStyle(theme.textSecondary)

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
                    .font(.body)
                    .foregroundStyle(color)
                    .frame(width: 40, height: 40)
                    .background(color.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: TutorRadius.md))
                Text(title)
                    .font(TutorTypography.caption)
                    .foregroundStyle(theme.textSecondary)
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
                .font(.title3)
                .foregroundStyle(Color(hex: workspace.colorHex))
                .frame(width: 36, height: 36)
                .background(Color(hex: workspace.colorHex).opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: TutorRadius.sm))
            Text(workspace.name)
                .font(TutorTypography.caption)
                .foregroundStyle(theme.textPrimary)
                .lineLimit(1)
            Text("\(workspace.knowledgeItems?.count ?? 0) items")
                .font(TutorTypography.caption2)
                .foregroundStyle(theme.textSecondary)
        }
        .frame(width: 88, height: 88)
        .background(theme.surfacePrimary)
        .clipShape(RoundedRectangle(cornerRadius: TutorRadius.md))
    }
}
