import SwiftUI
import TutorCore

// MARK: - Theme Protocol

public protocol TutorTheme: Sendable {
    var type: ThemeType { get }
    var name: String { get }

    // Colors
    var background: Color { get }
    var surfacePrimary: Color { get }
    var surfaceSecondary: Color { get }
    var accentColor: Color { get }
    var textPrimary: Color { get }
    var textSecondary: Color { get }

    // Style
    var cornerRadius: CGFloat { get }
    var usesGlassMorphism: Bool { get }
    var cardShadow: TutorShadow { get }
}

// MARK: - Minimal Theme

public struct MinimalTheme: TutorTheme {
    public let type = ThemeType.minimal
    public let name = "Minimal"
    public let background = Color(hex: "#FAFAFA")
    public let surfacePrimary = Color.white
    public let surfaceSecondary = Color(hex: "#F4F4F5")
    public let accentColor = Color(hex: "#18181B")
    public let textPrimary = Color(hex: "#18181B")
    public let textSecondary = Color(hex: "#71717A")
    public let cornerRadius: CGFloat = 10
    public let usesGlassMorphism = false
    public let cardShadow = TutorShadow(color: .black.opacity(0.03), radius: 3, x: 0, y: 1)

    public init() {}
}

// MARK: - Rich Theme

public struct RichTheme: TutorTheme {
    public let type = ThemeType.rich
    public let name = "Vibrant"
    public let background = Color(hex: "#F5F3FF")
    public let surfacePrimary = Color.white
    public let surfaceSecondary = Color(hex: "#EDE9FE")
    public let accentColor = Color(hex: "#7C3AED")
    public let textPrimary = Color(hex: "#1E1B4B")
    public let textSecondary = Color(hex: "#6B7280")
    public let cornerRadius: CGFloat = 14
    public let usesGlassMorphism = false
    public let cardShadow = TutorShadow(color: Color(hex: "#7C3AED").opacity(0.06), radius: 8, x: 0, y: 2)

    public init() {}
}

// MARK: - Locked In Theme

public struct LockedInTheme: TutorTheme {
    public let type = ThemeType.lockedIn
    public let name = "Locked In"
    public let background = Color(hex: "#09090B")
    public let surfacePrimary = Color(hex: "#18181B")
    public let surfaceSecondary = Color(hex: "#27272A")
    public let accentColor = Color(hex: "#38BDF8")
    public let textPrimary = Color(hex: "#FAFAFA")
    public let textSecondary = Color(hex: "#A1A1AA")
    public let cornerRadius: CGFloat = 10
    public let usesGlassMorphism = true
    public let cardShadow = TutorShadow(color: Color(hex: "#38BDF8").opacity(0.06), radius: 8, x: 0, y: 2)

    public init() {}
}

// MARK: - Cozy Theme

public struct CozyTheme: TutorTheme {
    public let type = ThemeType.cozy
    public let name = "Cozy"
    public let background = Color(hex: "#FFFBF5")
    public let surfacePrimary = Color(hex: "#FFFFFF")
    public let surfaceSecondary = Color(hex: "#FEF3E2")
    public let accentColor = Color(hex: "#C2410C")
    public let textPrimary = Color(hex: "#292524")
    public let textSecondary = Color(hex: "#78716C")
    public let cornerRadius: CGFloat = 14
    public let usesGlassMorphism = false
    public let cardShadow = TutorShadow(color: Color(hex: "#C2410C").opacity(0.04), radius: 6, x: 0, y: 2)

    public init() {}
}

// MARK: - Theme Manager

@Observable
public final class ThemeManager {
    public var currentTheme: any TutorTheme

    public init(type: ThemeType = .minimal) {
        self.currentTheme = Self.theme(for: type)
    }

    public func setTheme(_ type: ThemeType) {
        currentTheme = Self.theme(for: type)
    }

    public static func theme(for type: ThemeType) -> any TutorTheme {
        switch type {
        case .minimal: MinimalTheme()
        case .rich: RichTheme()
        case .lockedIn: LockedInTheme()
        case .cozy: CozyTheme()
        }
    }
}

// MARK: - Environment Key

private struct ThemeKey: EnvironmentKey {
    static let defaultValue: any TutorTheme = MinimalTheme()
}

public extension EnvironmentValues {
    var tutorTheme: any TutorTheme {
        get { self[ThemeKey.self] }
        set { self[ThemeKey.self] = newValue }
    }
}
