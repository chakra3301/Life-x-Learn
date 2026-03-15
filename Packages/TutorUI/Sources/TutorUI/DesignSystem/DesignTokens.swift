import SwiftUI
import TutorCore

// MARK: - Color Tokens

public enum TutorColors {
    // Primary
    public static let primary = Color(hex: "#007AFF")
    public static let secondary = Color(hex: "#5856D6")
    public static let accent = Color(hex: "#FF9500")
    public static let success = Color(hex: "#34C759")
    public static let warning = Color(hex: "#FF9500")
    public static let error = Color(hex: "#FF3B30")

    // Surfaces
    public static let surfacePrimary = Color(hex: "#FFFFFF")
    public static let surfaceSecondary = Color(hex: "#F2F2F7")
    public static let surfaceTertiary = Color(hex: "#E5E5EA")

    // Text
    public static let textPrimary = Color(hex: "#000000")
    public static let textSecondary = Color(hex: "#3C3C43", opacity: 0.6)
    public static let textTertiary = Color(hex: "#3C3C43", opacity: 0.3)

    // Gamification
    public static let xpGold = Color(hex: "#FFD700")
    public static let streakFlame = Color(hex: "#FF6B35")
    public static let levelPurple = Color(hex: "#AF52DE")
}

// MARK: - Typography

public enum TutorTypography {
    public static let largeTitle = Font.largeTitle
    public static let title = Font.title
    public static let title2 = Font.title2
    public static let title3 = Font.title3
    public static let headline = Font.headline
    public static let body = Font.body
    public static let callout = Font.callout
    public static let subheadline = Font.subheadline
    public static let footnote = Font.footnote
    public static let caption = Font.caption
    public static let caption2 = Font.caption2

    // Custom weighted
    public static let bodyMedium = Font.body.weight(.medium)
    public static let bodyBold = Font.body.weight(.bold)
    public static let headlineSemibold = Font.headline.weight(.semibold)
}

// MARK: - Spacing

public enum TutorSpacing {
    public static let xxxs: CGFloat = 2
    public static let xxs: CGFloat = 4
    public static let xs: CGFloat = 8
    public static let sm: CGFloat = 12
    public static let md: CGFloat = 16
    public static let lg: CGFloat = 24
    public static let xl: CGFloat = 32
    public static let xxl: CGFloat = 48
    public static let xxxl: CGFloat = 64
}

// MARK: - Corner Radius

public enum TutorRadius {
    public static let sm: CGFloat = 6
    public static let md: CGFloat = 10
    public static let lg: CGFloat = 16
    public static let xl: CGFloat = 24
    public static let full: CGFloat = 9999
}

// MARK: - Shadows

public struct TutorShadow: Sendable {
    public let color: Color
    public let radius: CGFloat
    public let x: CGFloat
    public let y: CGFloat

    public static let sm = TutorShadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    public static let md = TutorShadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    public static let lg = TutorShadow(color: .black.opacity(0.15), radius: 16, x: 0, y: 8)
}

// MARK: - Color Extension

public extension Color {
    init(hex: String, opacity: Double = 1.0) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255 * opacity
        )
    }
}
