import SwiftUI
import TutorUI

struct MoodPickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.tutorTheme) private var theme
    @Binding var selectedMood: String?

    private let moods: [(emoji: String, label: String)] = [
        ("😊", "Happy"),
        ("😌", "Calm"),
        ("🔥", "Motivated"),
        ("🧠", "Focused"),
        ("🎉", "Excited"),
        ("💪", "Strong"),
        ("🤔", "Thoughtful"),
        ("😐", "Neutral"),
        ("😴", "Tired"),
        ("😰", "Anxious"),
        ("😤", "Frustrated"),
        ("😢", "Sad"),
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: TutorSpacing.lg) {
                Text("How are you feeling?")
                    .font(TutorTypography.title3)
                    .foregroundStyle(theme.textPrimary)

                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: TutorSpacing.md) {
                    ForEach(moods, id: \.emoji) { mood in
                        Button {
                            if selectedMood == mood.emoji {
                                selectedMood = nil
                            } else {
                                selectedMood = mood.emoji
                            }
                        } label: {
                            VStack(spacing: 4) {
                                Text(mood.emoji)
                                    .font(.system(size: 36))
                                Text(mood.label)
                                    .font(TutorTypography.caption2)
                                    .foregroundStyle(theme.textSecondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, TutorSpacing.xs)
                            .background(
                                RoundedRectangle(cornerRadius: TutorRadius.md)
                                    .fill(selectedMood == mood.emoji
                                          ? theme.accentColor.opacity(0.12)
                                          : Color.clear)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: TutorRadius.md)
                                    .stroke(selectedMood == mood.emoji
                                            ? theme.accentColor
                                            : Color.clear, lineWidth: 2)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)

                Button {
                    dismiss()
                } label: {
                    Text("Done")
                        .font(TutorTypography.bodyMedium)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, TutorSpacing.sm)
                        .background(theme.accentColor)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: TutorRadius.md))
                }
                .padding(.horizontal)
            }
            .padding(.top)
        }
    }
}

// MARK: - Template Picker Sheet

struct TemplatePickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.tutorTheme) private var theme
    @Binding var selectedTemplate: JournalTemplate
    let onSelect: (JournalTemplate) -> Void

    var body: some View {
        NavigationStack {
            List {
                ForEach(JournalTemplate.allCases) { template in
                    Button {
                        selectedTemplate = template
                        onSelect(template)
                        dismiss()
                    } label: {
                        HStack(spacing: TutorSpacing.sm) {
                            Image(systemName: template.icon)
                                .font(.title3)
                                .foregroundStyle(theme.accentColor)
                                .frame(width: 32)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(template.name)
                                    .font(TutorTypography.bodyMedium)
                                    .foregroundStyle(theme.textPrimary)
                                Text(template.description)
                                    .font(TutorTypography.caption)
                                    .foregroundStyle(theme.textSecondary)
                            }

                            Spacer()

                            if selectedTemplate == template {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(theme.accentColor)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Templates")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
