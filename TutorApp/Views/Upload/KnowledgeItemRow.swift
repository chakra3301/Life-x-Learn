import SwiftUI
import TutorCore
import TutorData
import TutorUI

struct KnowledgeItemRow: View {
    @Environment(\.tutorTheme) private var theme
    let item: KnowledgeItem

    var body: some View {
        HStack(spacing: TutorSpacing.sm) {
            // Source type icon
            Image(systemName: iconForSourceType)
                .font(.title3)
                .foregroundStyle(colorForSourceType)
                .frame(width: 36, height: 36)
                .background(colorForSourceType.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: TutorRadius.sm))

            VStack(alignment: .leading, spacing: 2) {
                Text(item.title)
                    .font(TutorTypography.bodyMedium)
                    .foregroundStyle(theme.textPrimary)
                    .lineLimit(1)

                HStack(spacing: TutorSpacing.xs) {
                    Text(item.source.rawValue.capitalized)
                        .font(TutorTypography.caption)
                        .foregroundStyle(theme.textSecondary)

                    if let date = item.importedAt as Date? {
                        Text("·")
                            .foregroundStyle(theme.textSecondary)
                        Text(date.relativeDescription)
                            .font(TutorTypography.caption)
                            .foregroundStyle(theme.textSecondary)
                    }
                }
            }

            Spacer()

            // Processing status
            if item.status == .processing {
                ProgressView()
                    .scaleEffect(0.8)
            } else if item.status == .failed {
                Image(systemName: "exclamationmark.circle.fill")
                    .foregroundStyle(.red)
            }
        }
        .padding(.vertical, TutorSpacing.xxs)
    }

    private var iconForSourceType: String {
        switch item.source {
        case .pdf: return "doc.fill"
        case .image, .handwritten: return "photo.fill"
        case .audio: return "waveform"
        case .video: return "play.rectangle.fill"
        case .webLink: return "link"
        case .document: return "doc.text.fill"
        case .note: return "note.text"
        case .slides: return "rectangle.split.3x3.fill"
        }
    }

    private var colorForSourceType: Color {
        switch item.source {
        case .pdf: return .red
        case .image, .handwritten: return .orange
        case .audio: return .pink
        case .video: return .purple
        case .webLink: return .cyan
        case .document: return .blue
        case .note: return .green
        case .slides: return .indigo
        }
    }
}

// MARK: - Knowledge Item Detail

struct KnowledgeItemDetailView: View {
    @Environment(\.tutorTheme) private var theme
    let item: KnowledgeItem

    @State private var showFlashcardGeneration = false
    @State private var showQuizGeneration = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: TutorSpacing.lg) {
                // Header
                VStack(alignment: .leading, spacing: TutorSpacing.xs) {
                    Text(item.title)
                        .font(TutorTypography.title2)
                        .foregroundStyle(theme.textPrimary)

                    HStack {
                        Label(item.source.rawValue.capitalized, systemImage: "tag")
                        if let category = item.aiCategory {
                            Text("·")
                            Text(category)
                        }
                    }
                    .font(TutorTypography.caption)
                    .foregroundStyle(theme.textSecondary)
                }

                // Summary
                if let summary = item.summary {
                    GlassCard {
                        VStack(alignment: .leading, spacing: TutorSpacing.xs) {
                            Label("AI Summary", systemImage: "sparkles")
                                .font(TutorTypography.subheadline)
                                .foregroundStyle(theme.accentColor)
                            Text(summary)
                                .font(TutorTypography.body)
                                .foregroundStyle(theme.textPrimary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }

                // Content
                if let content = item.rawContent {
                    VStack(alignment: .leading, spacing: TutorSpacing.xs) {
                        Text("Content")
                            .font(TutorTypography.headline)
                            .foregroundStyle(theme.textPrimary)
                        Text(content)
                            .font(TutorTypography.body)
                            .foregroundStyle(theme.textPrimary)
                    }
                }

                // Action buttons
                VStack(spacing: TutorSpacing.sm) {
                    ActionButton(title: "Generate Flashcards", icon: "rectangle.on.rectangle", color: .blue) {
                        showFlashcardGeneration = true
                    }
                    ActionButton(title: "Create Quiz", icon: "checklist", color: .green) {
                        showQuizGeneration = true
                    }
                    ActionButton(title: "Chat About This", icon: "bubble.left.and.bubble.right", color: .purple) {
                        // Navigate to chat with context
                    }
                }
            }
            .padding()
        }
        .background(theme.background)
        .navigationTitle(item.title)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

struct ActionButton: View {
    @Environment(\.tutorTheme) private var theme
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                Text(title)
                    .font(TutorTypography.bodyMedium)
                Spacer()
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
