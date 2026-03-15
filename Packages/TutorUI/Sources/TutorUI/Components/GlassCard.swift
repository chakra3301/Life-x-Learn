import SwiftUI

/// A card component with optional glass morphism effect (Apple's frosted glass style)
public struct GlassCard<Content: View>: View {
    @Environment(\.tutorTheme) private var theme
    let content: () -> Content

    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    public var body: some View {
        content()
            .padding(TutorSpacing.md)
            .background {
                if theme.usesGlassMorphism {
                    RoundedRectangle(cornerRadius: theme.cornerRadius)
                        .fill(.ultraThinMaterial)
                        .overlay {
                            RoundedRectangle(cornerRadius: theme.cornerRadius)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        }
                } else {
                    RoundedRectangle(cornerRadius: theme.cornerRadius)
                        .fill(theme.surfacePrimary)
                        .shadow(
                            color: theme.cardShadow.color,
                            radius: theme.cardShadow.radius,
                            x: theme.cardShadow.x,
                            y: theme.cardShadow.y
                        )
                }
            }
    }
}

/// Simple themed card without glass effect
public struct TutorCard<Content: View>: View {
    @Environment(\.tutorTheme) private var theme
    let content: () -> Content

    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    public var body: some View {
        content()
            .padding(TutorSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: theme.cornerRadius)
                    .fill(theme.surfacePrimary)
                    .shadow(
                        color: theme.cardShadow.color,
                        radius: theme.cardShadow.radius,
                        x: theme.cardShadow.x,
                        y: theme.cardShadow.y
                    )
            )
    }
}
