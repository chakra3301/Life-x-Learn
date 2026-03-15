import SwiftUI
import SwiftData
import TutorCore
import TutorData
import TutorUI

struct WorkspaceDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.tutorTheme) private var theme

    @Bindable var workspace: Workspace
    @State private var showUpload = false
    @State private var showAddSection = false
    @State private var newSectionName = ""

    private var sortedItems: [KnowledgeItem] {
        (workspace.knowledgeItems ?? []).sorted { $0.importedAt > $1.importedAt }
    }

    private var sortedSections: [Workspace] {
        (workspace.subSections ?? []).sorted { $0.sortOrder < $1.sortOrder }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: TutorSpacing.lg) {
                // Header stats
                headerStats

                // Sub-sections
                if !sortedSections.isEmpty {
                    sectionsView
                }

                // Knowledge items
                itemsView

                // Student mode extras
                if workspace.type == .classType {
                    studentInfoView
                }
            }
            .padding()
        }
        .background(theme.background)
        .navigationTitle(workspace.name)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button { showUpload = true } label: {
                        Label("Add Content", systemImage: "plus")
                    }
                    Button { showAddSection = true } label: {
                        Label("Add Section", systemImage: "folder.badge.plus")
                    }
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showUpload) {
            UploadView()
        }
        .alert("New Section", isPresented: $showAddSection) {
            TextField("Section name", text: $newSectionName)
            Button("Cancel", role: .cancel) { newSectionName = "" }
            Button("Add") {
                addSection()
                newSectionName = ""
            }
        }
    }

    // MARK: - Sections

    private var headerStats: some View {
        HStack(spacing: TutorSpacing.lg) {
            StatBadge(
                icon: "doc.fill",
                value: "\(workspace.knowledgeItems?.count ?? 0)",
                label: "Items",
                color: Color(hex: workspace.colorHex)
            )
            StatBadge(
                icon: "rectangle.on.rectangle",
                value: "\(countFlashcards())",
                label: "Cards",
                color: .blue
            )
            StatBadge(
                icon: "checkmark.circle",
                value: "\(countQuizzes())",
                label: "Quizzes",
                color: .green
            )
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(theme.surfaceSecondary)
        .clipShape(RoundedRectangle(cornerRadius: TutorRadius.lg))
    }

    private var sectionsView: some View {
        VStack(alignment: .leading, spacing: TutorSpacing.sm) {
            Text("Sections")
                .font(TutorTypography.headline)
                .foregroundStyle(theme.textPrimary)

            ForEach(sortedSections) { section in
                NavigationLink(value: section) {
                    HStack {
                        Image(systemName: "folder.fill")
                            .foregroundStyle(Color(hex: workspace.colorHex))
                        Text(section.name)
                            .font(TutorTypography.body)
                            .foregroundStyle(theme.textPrimary)
                        Spacer()
                        Text("\(section.knowledgeItems?.count ?? 0)")
                            .font(TutorTypography.caption)
                            .foregroundStyle(theme.textSecondary)
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(theme.textSecondary)
                    }
                    .padding()
                    .background(theme.surfacePrimary)
                    .clipShape(RoundedRectangle(cornerRadius: TutorRadius.md))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var itemsView: some View {
        VStack(alignment: .leading, spacing: TutorSpacing.sm) {
            HStack {
                Text("Content")
                    .font(TutorTypography.headline)
                    .foregroundStyle(theme.textPrimary)
                Spacer()
                Text("\(sortedItems.count) items")
                    .font(TutorTypography.caption)
                    .foregroundStyle(theme.textSecondary)
            }

            if sortedItems.isEmpty {
                GlassCard {
                    VStack(spacing: TutorSpacing.sm) {
                        Image(systemName: "doc.badge.plus")
                            .font(.title)
                            .foregroundStyle(theme.textSecondary)
                        Text("No content yet")
                            .font(TutorTypography.body)
                            .foregroundStyle(theme.textSecondary)
                        Button("Add Content") { showUpload = true }
                            .font(TutorTypography.bodyMedium)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical)
                }
            } else {
                ForEach(sortedItems) { item in
                    NavigationLink {
                        KnowledgeItemDetailView(item: item)
                    } label: {
                        KnowledgeItemRow(item: item)
                            .padding(.horizontal)
                            .padding(.vertical, TutorSpacing.xxs)
                            .background(theme.surfacePrimary)
                            .clipShape(RoundedRectangle(cornerRadius: TutorRadius.md))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var studentInfoView: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: TutorSpacing.sm) {
                Label("Class Info", systemImage: "graduationcap")
                    .font(TutorTypography.headline)

                if let className = workspace.className {
                    LabeledContent("Class", value: className)
                }
                if let semester = workspace.semester {
                    LabeledContent("Semester", value: semester)
                }
                if let instructor = workspace.instructorName {
                    LabeledContent("Instructor", value: instructor)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Helpers

    private func addSection() {
        let section = Workspace(name: newSectionName, type: .general)
        section.sortOrder = (workspace.subSections?.count ?? 0)
        section.parentWorkspace = workspace
        modelContext.insert(section)
        try? modelContext.save()
    }

    private func countFlashcards() -> Int {
        (workspace.knowledgeItems ?? []).reduce(0) { $0 + ($1.flashcards?.count ?? 0) }
    }

    private func countQuizzes() -> Int {
        (workspace.knowledgeItems ?? []).reduce(0) { $0 + ($1.quizzes?.count ?? 0) }
    }
}
