import SwiftUI
import TutorCore

// MARK: - Color Tokens

public enum TutorColors {
    // Brand
    public static let primary = Color(hex: "#3B82F6")       // Clean blue
    public static let secondary = Color(hex: "#6366F1")     // Indigo
    public static let accent = Color(hex: "#8B5CF6")        // Soft violet

    // Semantic
    public static let success = Color(hex: "#22C55E")       // Green
    public static let warning = Color(hex: "#F59E0B")       // Amber
    public static let error = Color(hex: "#EF4444")         // Red

    // Surfaces
    public static let surfacePrimary = Color(hex: "#FFFFFF")
    public static let surfaceSecondary = Color(hex: "#F4F4F5")
    public static let surfaceTertiary = Color(hex: "#E4E4E7")

    // Text
    public static let textPrimary = Color(hex: "#18181B")
    public static let textSecondary = Color(hex: "#71717A")
    public static let textTertiary = Color(hex: "#A1A1AA")

    // Gamification — muted, cohesive palette
    public static let xpGold = Color(hex: "#EAB308")        // Warm gold
    public static let streakFlame = Color(hex: "#F97316")    // Soft orange
    public static let levelPurple = Color(hex: "#8B5CF6")    // Matches accent

    // Functional tints (for icons, badges, subtle backgrounds)
    public static let tintBlue = Color(hex: "#3B82F6")
    public static let tintIndigo = Color(hex: "#6366F1")
    public static let tintViolet = Color(hex: "#8B5CF6")
    public static let tintCyan = Color(hex: "#06B6D4")
    public static let tintEmerald = Color(hex: "#10B981")
    public static let tintAmber = Color(hex: "#F59E0B")
    public static let tintRose = Color(hex: "#F43F5E")
    public static let tintOrange = Color(hex: "#F97316")
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

    public static let sm = TutorShadow(color: .black.opacity(0.04), radius: 2, x: 0, y: 1)
    public static let md = TutorShadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)
    public static let lg = TutorShadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
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
