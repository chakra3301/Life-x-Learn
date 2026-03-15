import SwiftUI

/// A small badge for displaying stats like XP, streak, level
public struct StatBadge: View {
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
        VStack(spacing: TutorSpacing.xxs) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            Text(value)
                .font(TutorTypography.headlineSemibold)
            Text(label)
                .font(TutorTypography.caption)
                .foregroundStyle(.secondary)
        }
        .frame(minWidth: 60)
    }
}

/// XP progress bar
public struct XPProgressBar: View {
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
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: TutorRadius.full)
                        .fill(
                            LinearGradient(
                                colors: [TutorColors.xpGold, TutorColors.accent],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * max(0, min(1, progress)), height: 8)
                }
            }
            .frame(height: 8)

            HStack {
                Text("\(currentXP) XP")
                    .font(TutorTypography.caption2)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(nextLevelXP) XP")
                    .font(TutorTypography.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
