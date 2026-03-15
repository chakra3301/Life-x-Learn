import SwiftUI

/// A small badge for displaying stats like XP, streak, level
public struct StatBadge: View {
    @Environment(\.tutorTheme) private var theme
    let icon: String
    let value: String
    let label: String
    let color: Color

    public init(icon: String, value: String, label: String, color: Color = TutorColors.primary) {
        self.icon = icon
        self.value = value
        self.label = label
        self.color = color
    }

    public var body: some View {
        VStack(spacing: TutorSpacing.xs) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(color)
                .frame(width: 32, height: 32)
                .background(color.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: TutorRadius.sm))
            Text(value)
                .font(TutorTypography.bodyMedium)
                .foregroundStyle(theme.textPrimary)
            Text(label)
                .font(TutorTypography.caption2)
                .foregroundStyle(theme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, TutorSpacing.sm)
        .background(theme.surfacePrimary)
        .clipShape(RoundedRectangle(cornerRadius: TutorRadius.md))
    }
}

/// XP progress bar
public struct XPProgressBar: View {
    @Environment(\.tutorTheme) private var theme
    let progress: Double
    let currentXP: Int
    let nextLevelXP: Int

    public init(progress: Double, currentXP: Int, nextLevelXP: Int) {
        self.progress = progress
        self.currentXP = currentXP
        self.nextLevelXP = nextLevelXP
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: TutorSpacing.xxs) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: TutorRadius.full)
                        .fill(theme.textSecondary.opacity(0.12))
                        .frame(height: 6)

                    RoundedRectangle(cornerRadius: TutorRadius.full)
                        .fill(
                            LinearGradient(
                                colors: [theme.accentColor.opacity(0.7), theme.accentColor],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * max(0, min(1, progress)), height: 6)
                }
            }
            .frame(height: 6)

            HStack {
                Text("\(currentXP) XP")
                    .font(TutorTypography.caption2)
                    .foregroundStyle(theme.textSecondary)
                Spacer()
                Text("\(nextLevelXP) XP")
                    .font(TutorTypography.caption2)
                    .foregroundStyle(theme.textSecondary)
            }
        }
    }
}
