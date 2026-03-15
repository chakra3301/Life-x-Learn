import SwiftUI
import SwiftData
import TutorCore
import TutorData
import TutorUI
import TutorJournal

struct JournalEntryEditorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.tutorTheme) private var theme

    @Bindable var entry: JournalEntry
    let isNew: Bool

    @State private var showTemplateMenu = false
    @State private var showMoodPicker = false
    @State private var showFormatBar = false
    @State private var selectedTemplate: JournalTemplate = .freeform
    @FocusState private var isEditorFocused: Bool

    private let journalService = JournalService()

    init(entry: JournalEntry, isNew: Bool = false) {
        self.entry = entry
        self.isNew = isNew
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Warm personal background
                theme.background
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // AI gentle nudge
                    if isNew && entry.content.isEmpty {
                        gentleNudge
                    }

                    // Format bar (when toggled)
                    if showFormatBar {
                        formatBar
                    }

                    // Editor
                    editor

                    // Bottom toolbar
                    editorToolbar
                }
            }
            .navigationTitle(isNew ? "New Entry" : formattedDate)
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    if isNew {
                        Button("Cancel") {
                            modelContext.delete(entry)
                            dismiss()
                        }
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(isNew ? "Save" : "Done") {
                        saveEntry()
                        dismiss()
                    }
                    .disabled(entry.content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .sheet(isPresented: $showTemplateMenu) {
                TemplatePickerSheet(selectedTemplate: $selectedTemplate) { template in
                    applyTemplate(template)
                }
                .presentationDetents([.medium])
            }
            .sheet(isPresented: $showMoodPicker) {
                MoodPickerSheet(selectedMood: Binding(
                    get: { entry.mood },
                    set: { entry.mood = $0 }
                ))
                .presentationDetents([.height(280)])
            }
        }
    }

    // MARK: - Gentle Nudge

    private var gentleNudge: some View {
        let prompt = journalService.suggestPrompt(for: .general)
        return HStack(spacing: TutorSpacing.sm) {
            Image(systemName: "sparkles")
                .foregroundStyle(theme.accentColor.opacity(0.7))

            Text(prompt)
                .font(TutorTypography.callout)
                .foregroundStyle(theme.textSecondary)
                .italic()

            Spacer()

            Button {
                entry.aiPrompt = prompt
                entry.entryType = JournalType.aiPrompted.rawValue
            } label: {
                Text("Use")
                    .font(TutorTypography.caption)
                    .padding(.horizontal, TutorSpacing.sm)
                    .padding(.vertical, TutorSpacing.xxs)
                    .background(theme.accentColor.opacity(0.12))
                    .foregroundStyle(theme.accentColor)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding()
        .background(theme.surfaceSecondary.opacity(0.5))
    }

    // MARK: - Editor

    private var editor: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: TutorSpacing.md) {
                // Mood display (if set)
                if let mood = entry.mood, !mood.isEmpty {
                    HStack {
                        Text(mood)
                            .font(.title)
                        Text("Feeling \(moodLabel(mood))")
                            .font(TutorTypography.caption)
                            .foregroundStyle(theme.textSecondary)
                        Spacer()
                        Button {
                            showMoodPicker = true
                        } label: {
                            Image(systemName: "pencil")
                                .font(.caption)
                                .foregroundStyle(theme.textSecondary)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal)
                    .padding(.top, TutorSpacing.sm)
                }

                // AI prompt display (if using one)
                if let prompt = entry.aiPrompt, !prompt.isEmpty {
                    Text(prompt)
                        .font(TutorTypography.callout)
                        .foregroundStyle(theme.accentColor.opacity(0.8))
                        .italic()
                        .padding(.horizontal)
                }

                // Template header
                if selectedTemplate != .freeform {
                    templateHeader
                }

                // Main text editor
                TextEditor(text: $entry.content)
                    .font(.body)
                    .focused($isEditorFocused)
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 300)
                    .padding(.horizontal, TutorSpacing.xs)
            }
        }
        .onAppear {
            isEditorFocused = isNew
        }
    }

    // MARK: - Template Header

    private var templateHeader: some View {
        VStack(alignment: .leading, spacing: TutorSpacing.xs) {
            HStack {
                Image(systemName: selectedTemplate.icon)
                    .foregroundStyle(theme.accentColor)
                Text(selectedTemplate.name)
                    .font(TutorTypography.subheadline)
                    .foregroundStyle(theme.textSecondary)
            }

            if entry.content.isEmpty {
                Text(selectedTemplate.placeholder)
                    .font(TutorTypography.body)
                    .foregroundStyle(theme.textSecondary.opacity(0.5))
            }
        }
        .padding(.horizontal)
    }

    // MARK: - Format Bar

    private var formatBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: TutorSpacing.md) {
                FormatButton(icon: "bold", label: "Bold") {
                    insertMarkdown("**", "**")
                }
                FormatButton(icon: "italic", label: "Italic") {
                    insertMarkdown("_", "_")
                }
                FormatButton(icon: "list.bullet", label: "List") {
                    insertMarkdown("\n- ", "")
                }
                FormatButton(icon: "number", label: "Heading") {
                    insertMarkdown("\n## ", "")
                }
                FormatButton(icon: "text.quote", label: "Quote") {
                    insertMarkdown("\n> ", "")
                }
                FormatButton(icon: "minus", label: "Divider") {
                    insertMarkdown("\n---\n", "")
                }
                FormatButton(icon: "checkmark.square", label: "Checkbox") {
                    insertMarkdown("\n- [ ] ", "")
                }
            }
            .padding(.horizontal)
            .padding(.vertical, TutorSpacing.xs)
        }
        .background(theme.surfaceSecondary)
    }

    // MARK: - Editor Toolbar

    private var editorToolbar: some View {
        HStack(spacing: TutorSpacing.lg) {
            // Template button
            Button {
                showTemplateMenu = true
            } label: {
                VStack(spacing: 2) {
                    Image(systemName: "doc.text")
                        .font(.body)
                    Text("Template")
                        .font(.caption2)
                }
                .foregroundStyle(theme.textSecondary)
            }
            .buttonStyle(.plain)

            // Mood button
            Button {
                showMoodPicker = true
            } label: {
                VStack(spacing: 2) {
                    if let mood = entry.mood, !mood.isEmpty {
                        Text(mood)
                            .font(.body)
                    } else {
                        Image(systemName: "face.smiling")
                            .font(.body)
                    }
                    Text("Mood")
                        .font(.caption2)
                }
                .foregroundStyle(theme.textSecondary)
            }
            .buttonStyle(.plain)

            // Format button
            Button {
                withAnimation { showFormatBar.toggle() }
            } label: {
                VStack(spacing: 2) {
                    Image(systemName: "textformat")
                        .font(.body)
                    Text("Format")
                        .font(.caption2)
                }
                .foregroundStyle(showFormatBar ? theme.accentColor : theme.textSecondary)
            }
            .buttonStyle(.plain)

            Spacer()

            // Word count
            Text("\(wordCount) words")
                .font(TutorTypography.caption2)
                .foregroundStyle(theme.textSecondary)
        }
        .padding(.horizontal)
        .padding(.vertical, TutorSpacing.sm)
        .background(theme.surfacePrimary)
    }

    // MARK: - Helpers

    private var formattedDate: String {
        entry.createdAt.formatted(date: .long, time: .omitted)
    }

    private var wordCount: Int {
        entry.content.split(separator: " ").count
    }

    private func saveEntry() {
        if isNew {
            modelContext.insert(entry)
        }
        try? modelContext.save()
    }

    private func insertMarkdown(_ prefix: String, _ suffix: String) {
        entry.content += prefix + suffix
    }

    private func applyTemplate(_ template: JournalTemplate) {
        selectedTemplate = template
        if entry.content.isEmpty && template != .freeform {
            entry.content = template.starterText
        }
    }

    private func moodLabel(_ emoji: String) -> String {
        let labels: [String: String] = [
            "😊": "happy", "😌": "calm", "🤔": "thoughtful", "😤": "frustrated",
            "😴": "tired", "🔥": "motivated", "😰": "anxious", "🎉": "excited",
            "😢": "sad", "💪": "strong", "🧠": "focused", "😐": "neutral"
        ]
        return labels[emoji] ?? ""
    }
}

// MARK: - Format Button

struct FormatButton: View {
    @Environment(\.tutorTheme) private var theme
    let icon: String
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Image(systemName: icon)
                    .font(.body)
                Text(label)
                    .font(.caption2)
            }
            .foregroundStyle(theme.textPrimary)
            .frame(minWidth: 44)
        }
        .buttonStyle(.plain)
    }
}
