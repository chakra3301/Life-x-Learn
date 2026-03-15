import SwiftUI
import SwiftData
import TutorCore
import TutorData
import TutorUI
import TutorFileProcessing
import UniformTypeIdentifiers

struct UploadView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.tutorTheme) private var theme
    @Environment(\.dismiss) private var dismiss

    @State private var isImporting = false
    @State private var isProcessing = false
    @State private var processingStatus: String = ""
    @State private var selectedWorkspace: Workspace?
    @State private var showCamera = false
    @State private var noteText = ""
    @State private var showNoteEditor = false
    @State private var errorMessage: String?

    @Query(sort: \Workspace.sortOrder) private var workspaces: [Workspace]

    private let importCoordinator = FileImportCoordinator()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: TutorSpacing.lg) {
                    headerSection
                    uploadOptionsGrid
                    workspaceSelector
                    if isProcessing { processingIndicator }
                    if let error = errorMessage { errorBanner(error) }
                }
                .padding()
            }
            .background(theme.background)
            .navigationTitle("Add Knowledge")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .fileImporter(
                isPresented: $isImporting,
                allowedContentTypes: supportedTypes,
                allowsMultipleSelection: true
            ) { result in
                Task { await handleFileImport(result) }
            }
            .sheet(isPresented: $showNoteEditor) {
                NoteEditorView(text: $noteText) { text in
                    Task { await saveNote(text) }
                }
            }
            #if os(iOS)
            .sheet(isPresented: $showCamera) {
                CameraCaptureView { image in
                    Task { await handleCameraCapture(image) }
                }
            }
            #endif
        }
    }

    // MARK: - Sections

    private var headerSection: some View {
        VStack(spacing: TutorSpacing.xs) {
            Image(systemName: "plus.circle.fill")
                .font(.system(size: 48))
                .foregroundStyle(theme.accentColor)
            Text("What would you like to add?")
                .font(TutorTypography.title3)
                .foregroundStyle(theme.textPrimary)
            Text("Upload files, take photos, or write notes")
                .font(TutorTypography.body)
                .foregroundStyle(theme.textSecondary)
        }
        .padding(.top, TutorSpacing.lg)
    }

    private var uploadOptionsGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: TutorSpacing.md) {
            UploadOptionCard(
                icon: "doc.fill",
                title: "Documents",
                subtitle: "PDF, Word, TXT",
                color: .blue
            ) {
                isImporting = true
            }

            UploadOptionCard(
                icon: "camera.fill",
                title: "Camera",
                subtitle: "Scan notes",
                color: .green
            ) {
                #if os(iOS)
                showCamera = true
                #else
                isImporting = true
                #endif
            }

            UploadOptionCard(
                icon: "photo.fill",
                title: "Photos",
                subtitle: "Images, screenshots",
                color: .orange
            ) {
                isImporting = true
            }

            UploadOptionCard(
                icon: "note.text",
                title: "Quick Note",
                subtitle: "Type or paste",
                color: .purple
            ) {
                showNoteEditor = true
            }

            UploadOptionCard(
                icon: "link",
                title: "Web Link",
                subtitle: "Save articles",
                color: .cyan
            ) {
                showNoteEditor = true
            }

            UploadOptionCard(
                icon: "waveform",
                title: "Audio",
                subtitle: "Lectures, podcasts",
                color: .pink
            ) {
                isImporting = true
            }
        }
    }

    private var workspaceSelector: some View {
        VStack(alignment: .leading, spacing: TutorSpacing.xs) {
            Text("Add to workspace")
                .font(TutorTypography.subheadline)
                .foregroundStyle(theme.textSecondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: TutorSpacing.xs) {
                    WorkspaceChip(name: "None", isSelected: selectedWorkspace == nil) {
                        selectedWorkspace = nil
                    }
                    ForEach(workspaces) { workspace in
                        WorkspaceChip(
                            name: workspace.name,
                            isSelected: selectedWorkspace?.id == workspace.id
                        ) {
                            selectedWorkspace = workspace
                        }
                    }
                }
            }
        }
    }

    private var processingIndicator: some View {
        GlassCard {
            HStack(spacing: TutorSpacing.sm) {
                ProgressView()
                Text(processingStatus)
                    .font(TutorTypography.body)
                    .foregroundStyle(theme.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func errorBanner(_ message: String) -> some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.red)
            Text(message)
                .font(TutorTypography.callout)
            Spacer()
            Button("Dismiss") { errorMessage = nil }
                .font(TutorTypography.callout)
        }
        .padding()
        .background(Color.red.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: TutorRadius.md))
    }

    // MARK: - Actions

    private func handleFileImport(_ result: Result<[URL], Error>) async {
        switch result {
        case .success(let urls):
            for url in urls {
                await processFile(url: url)
            }
        case .failure(let error):
            errorMessage = error.localizedDescription
        }
    }

    private func processFile(url: URL) async {
        isProcessing = true
        processingStatus = "Processing \(url.lastPathComponent)..."

        let accessing = url.startAccessingSecurityScopedResource()
        defer { if accessing { url.stopAccessingSecurityScopedResource() } }

        do {
            let result = try await importCoordinator.importFile(at: url)

            let item = KnowledgeItem(title: result.title, sourceType: result.sourceType)
            item.rawContent = result.rawContent
            item.fileSize = result.fileSize
            item.mimeType = result.mimeType
            item.sourceURL = result.sourceURL
            item.processingStatus = ProcessingStatus.completed.rawValue
            item.workspace = selectedWorkspace

            modelContext.insert(item)
            try modelContext.save()

            processingStatus = "Done!"
            try? await Task.sleep(for: .seconds(1))
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }

        isProcessing = false
    }

    private func saveNote(_ text: String) async {
        let item = KnowledgeItem(title: String(text.prefix(50)), sourceType: .note)
        item.rawContent = text
        item.processingStatus = ProcessingStatus.completed.rawValue
        item.workspace = selectedWorkspace

        modelContext.insert(item)
        try? modelContext.save()
        dismiss()
    }

    private func handleCameraCapture(_ imageData: Data) async {
        // Save image and process with OCR
        isProcessing = true
        processingStatus = "Scanning text from image..."

        let item = KnowledgeItem(title: "Scanned Note - \(Date().formatted(date: .abbreviated, time: .shortened))", sourceType: .handwritten)
        item.processingStatus = ProcessingStatus.processing.rawValue
        item.workspace = selectedWorkspace

        modelContext.insert(item)
        try? modelContext.save()

        isProcessing = false
        dismiss()
    }

    private var supportedTypes: [UTType] {
        [.pdf, .image, .plainText, .rtf, .audio,
         UTType("com.microsoft.word.doc") ?? .data,
         UTType("org.openxmlformats.wordprocessingml.document") ?? .data]
    }
}

// MARK: - Upload Option Card

struct UploadOptionCard: View {
    @Environment(\.tutorTheme) private var theme

    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            GlassCard {
                VStack(spacing: TutorSpacing.sm) {
                    Image(systemName: icon)
                        .font(.system(size: 28))
                        .foregroundStyle(color)
                    Text(title)
                        .font(TutorTypography.headline)
                        .foregroundStyle(theme.textPrimary)
                    Text(subtitle)
                        .font(TutorTypography.caption)
                        .foregroundStyle(theme.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, TutorSpacing.sm)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Workspace Chip

struct WorkspaceChip: View {
    @Environment(\.tutorTheme) private var theme
    let name: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(name)
                .font(TutorTypography.subheadline)
                .padding(.horizontal, TutorSpacing.sm)
                .padding(.vertical, TutorSpacing.xs)
                .background(
                    Capsule()
                        .fill(isSelected ? theme.accentColor : theme.surfaceSecondary)
                )
                .foregroundStyle(isSelected ? .white : theme.textPrimary)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Note Editor

struct NoteEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.tutorTheme) private var theme
    @Binding var text: String
    let onSave: (String) async -> Void

    var body: some View {
        NavigationStack {
            TextEditor(text: $text)
                .padding()
                .background(theme.background)
                .navigationTitle("New Note")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { dismiss() }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            Task {
                                await onSave(text)
                                dismiss()
                            }
                        }
                        .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
        }
    }
}

// MARK: - Camera Capture (iOS only)

#if os(iOS)
struct CameraCaptureView: View {
    @Environment(\.dismiss) private var dismiss
    let onCapture: (Data) async -> Void

    var body: some View {
        // Placeholder — will integrate UIImagePickerController
        VStack {
            Text("Camera capture will be available here")
            Button("Close") { dismiss() }
        }
    }
}
#endif
