import SwiftUI
import SwiftData
import TutorCore
import TutorData
import TutorUI
import TutorWorkspaces

struct WorkspaceListView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.tutorTheme) private var theme

    @Query(sort: \Workspace.sortOrder) private var workspaces: [Workspace]
    @State private var showCreateSheet = false
    @State private var searchText = ""

    private var filteredWorkspaces: [Workspace] {
        if searchText.isEmpty { return workspaces }
        return workspaces.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    private var activeWorkspaces: [Workspace] {
        filteredWorkspaces.filter { $0.isActive && $0.parentWorkspace == nil }
    }

    var body: some View {
        NavigationStack {
            Group {
                if workspaces.isEmpty {
                    emptyState
                } else {
                    workspaceList
                }
            }
            .background(theme.background)
            .navigationTitle("Workspaces")
            .searchable(text: $searchText, prompt: "Search workspaces")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showCreateSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showCreateSheet) {
                CreateWorkspaceView()
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: TutorSpacing.lg) {
            Image(systemName: "square.grid.2x2")
                .font(.system(size: 60))
                .foregroundStyle(theme.textSecondary.opacity(0.5))
            Text("No workspaces yet")
                .font(TutorTypography.title3)
                .foregroundStyle(theme.textPrimary)
            Text("Create a workspace to organize your learning by class, subject, project, or goal")
                .font(TutorTypography.body)
                .foregroundStyle(theme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, TutorSpacing.xl)
            Button {
                showCreateSheet = true
            } label: {
                Label("Create Workspace", systemImage: "plus")
                    .font(TutorTypography.bodyMedium)
                    .padding(.horizontal, TutorSpacing.lg)
                    .padding(.vertical, TutorSpacing.sm)
                    .background(theme.accentColor)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
            }
        }
    }

    private var workspaceList: some View {
        ScrollView {
            LazyVStack(spacing: TutorSpacing.sm) {
                // Templates section
                if workspaces.isEmpty {
                    templatesSuggestion
                }

                ForEach(activeWorkspaces) { workspace in
                    NavigationLink(value: workspace) {
                        WorkspaceCard(workspace: workspace)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
        }
        .navigationDestination(for: Workspace.self) { workspace in
            WorkspaceDetailView(workspace: workspace)
        }
    }

    private var templatesSuggestion: some View {
        VStack(alignment: .leading, spacing: TutorSpacing.sm) {
            Text("Quick Start Templates")
                .font(TutorTypography.headline)
                .foregroundStyle(theme.textPrimary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: TutorSpacing.sm) {
                    ForEach(WorkspaceTemplate.allCases, id: \.rawValue) { template in
                        TemplateCard(template: template) {
                            createFromTemplate(template)
                        }
                    }
                }
            }
        }
    }

    private func createFromTemplate(_ template: WorkspaceTemplate) {
        let workspace = Workspace(name: template.name, type: template.workspaceType)
        workspace.icon = template.icon
        workspace.colorHex = template.defaultColor

        // Create sub-sections
        for (index, sectionName) in template.defaultSubSections.enumerated() {
            let subSection = Workspace(name: sectionName, type: .general)
            subSection.sortOrder = index
            subSection.parentWorkspace = workspace
            modelContext.insert(subSection)
        }

        modelContext.insert(workspace)
        try? modelContext.save()
    }
}

// MARK: - Workspace Card

struct WorkspaceCard: View {
    @Environment(\.tutorTheme) private var theme
    let workspace: Workspace

    var body: some View {
        GlassCard {
            HStack(spacing: TutorSpacing.sm) {
                Image(systemName: workspace.icon)
                    .font(.title2)
                    .foregroundStyle(Color(hex: workspace.colorHex))
                    .frame(width: 44, height: 44)
                    .background(Color(hex: workspace.colorHex).opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: TutorRadius.sm))

                VStack(alignment: .leading, spacing: 2) {
                    Text(workspace.name)
                        .font(TutorTypography.headline)
                        .foregroundStyle(theme.textPrimary)

                    HStack(spacing: TutorSpacing.xs) {
                        Text(workspace.type.rawValue.capitalized)
                            .font(TutorTypography.caption)
                            .foregroundStyle(theme.textSecondary)

                        let itemCount = workspace.knowledgeItems?.count ?? 0
                        if itemCount > 0 {
                            Text("· \(itemCount) items")
                                .font(TutorTypography.caption)
                                .foregroundStyle(theme.textSecondary)
                        }

                        let subCount = workspace.subSections?.count ?? 0
                        if subCount > 0 {
                            Text("· \(subCount) sections")
                                .font(TutorTypography.caption)
                                .foregroundStyle(theme.textSecondary)
                        }
                    }
                }

                Spacer()

                if workspace.isShared {
                    Image(systemName: "person.2.fill")
                        .font(.caption)
                        .foregroundStyle(theme.textSecondary)
                }

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(theme.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

// MARK: - Template Card

struct TemplateCard: View {
    @Environment(\.tutorTheme) private var theme
    let template: WorkspaceTemplate
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: TutorSpacing.xs) {
                Image(systemName: template.icon)
                    .font(.title2)
                    .foregroundStyle(Color(hex: template.defaultColor))
                Text(template.name)
                    .font(TutorTypography.caption)
                    .foregroundStyle(theme.textPrimary)
                    .lineLimit(1)
            }
            .frame(width: 100, height: 80)
            .background(theme.surfacePrimary)
            .clipShape(RoundedRectangle(cornerRadius: TutorRadius.md))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Create Workspace View

struct CreateWorkspaceView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.tutorTheme) private var theme

    @State private var name = ""
    @State private var selectedType: WorkspaceType = .general
    @State private var selectedIcon = "folder"
    @State private var selectedColor = "#007AFF"
    @State private var selectedTemplate: WorkspaceTemplate?

    private let iconOptions = [
        "folder", "book", "graduationcap", "brain.head.profile",
        "star", "flag", "target", "lightbulb",
        "globe", "music.note", "paintbrush", "wrench.and.screwdriver",
        "chart.bar", "heart", "leaf", "atom"
    ]

    private let colorOptions = [
        "#007AFF", "#34C759", "#FF9500", "#FF3B30",
        "#AF52DE", "#5856D6", "#00C7BE", "#FFD700",
        "#FF6B35", "#E91E63", "#795548", "#607D8B"
    ]

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Workspace name", text: $name)

                    Picker("Type", selection: $selectedType) {
                        ForEach(WorkspaceType.allCases, id: \.self) { type in
                            Text(type.rawValue.capitalized).tag(type)
                        }
                    }
                }

                Section("Icon") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 8), spacing: 12) {
                        ForEach(iconOptions, id: \.self) { icon in
                            Image(systemName: icon)
                                .font(.title3)
                                .frame(width: 36, height: 36)
                                .background(selectedIcon == icon ? theme.accentColor.opacity(0.2) : Color.clear)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .onTapGesture { selectedIcon = icon }
                        }
                    }
                }

                Section("Color") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                        ForEach(colorOptions, id: \.self) { color in
                            Circle()
                                .fill(Color(hex: color))
                                .frame(width: 32, height: 32)
                                .overlay {
                                    if selectedColor == color {
                                        Image(systemName: "checkmark")
                                            .font(.caption.bold())
                                            .foregroundStyle(.white)
                                    }
                                }
                                .onTapGesture { selectedColor = color }
                        }
                    }
                }

                Section("Templates") {
                    ForEach(WorkspaceTemplate.allCases, id: \.rawValue) { template in
                        Button {
                            name = template.name
                            selectedType = template.workspaceType
                            selectedIcon = template.icon
                            selectedColor = template.defaultColor
                            selectedTemplate = template
                        } label: {
                            HStack {
                                Image(systemName: template.icon)
                                    .foregroundStyle(Color(hex: template.defaultColor))
                                Text(template.name)
                                Spacer()
                                if selectedTemplate == template {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(theme.accentColor)
                                }
                            }
                        }
                        .tint(theme.textPrimary)
                    }
                }
            }
            .navigationTitle("New Workspace")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        createWorkspace()
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func createWorkspace() {
        let workspace = Workspace(name: name, type: selectedType)
        workspace.icon = selectedIcon
        workspace.colorHex = selectedColor

        if let template = selectedTemplate {
            for (index, sectionName) in template.defaultSubSections.enumerated() {
                let sub = Workspace(name: sectionName, type: .general)
                sub.sortOrder = index
                sub.parentWorkspace = workspace
                modelContext.insert(sub)
            }
        }

        modelContext.insert(workspace)
        try? modelContext.save()
    }
}
