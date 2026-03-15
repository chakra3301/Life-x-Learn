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
    public let surfaceSecondary = Color(hex: "#F5F5F5")
    public let accentColor = Color(hex: "#1A1A1A")
    public let textPrimary = Color(hex: "#1A1A1A")
    public let textSecondary = Color(hex: "#8E8E93")
    public let cornerRadius: CGFloat = 12
    public let usesGlassMorphism = false
    public let cardShadow = TutorShadow.sm

    public init() {}
}

// MARK: - Rich Theme

public struct RichTheme: TutorTheme {
    public let type = ThemeType.rich
    public let name = "Rich & Colorful"
    public let background = Color(hex: "#F0EDFF")
    public let surfacePrimary = Color.white
    public let surfaceSecondary = Color(hex: "#E8E4FF")
    public let accentColor = Color(hex: "#6C5CE7")
    public let textPrimary = Color(hex: "#2D2D3F")
    public let textSecondary = Color(hex: "#7C7C8A")
    public let cornerRadius: CGFloat = 16
    public let usesGlassMorphism = false
    public let cardShadow = TutorShadow.md

    public init() {}
}

// MARK: - Locked In Theme

public struct LockedInTheme: TutorTheme {
    public let type = ThemeType.lockedIn
    public let name = "Locked In"
    public let background = Color(hex: "#0A0A0F")
    public let surfacePrimary = Color(hex: "#1C1C2E")
    public let surfaceSecondary = Color(hex: "#2A2A40")
    public let accentColor = Color(hex: "#00D1FF")
    public let textPrimary = Color.white
    public let textSecondary = Color(hex: "#9898A6")
    public let cornerRadius: CGFloat = 10
    public let usesGlassMorphism = true
    public let cardShadow = TutorShadow(color: Color(hex: "#00D1FF").opacity(0.1), radius: 12, x: 0, y: 4)

    public init() {}
}

// MARK: - Cozy Theme

public struct CozyTheme: TutorTheme {
    public let type = ThemeType.cozy
    public let name = "Warm & Cozy"
    public let background = Color(hex: "#FFF8F0")
    public let surfacePrimary = Color(hex: "#FFFDF9")
    public let surfaceSecondary = Color(hex: "#FFF0DE")
    public let accentColor = Color(hex: "#D4753A")
    public let textPrimary = Color(hex: "#3D2E1F")
    public let textSecondary = Color(hex: "#8B7355")
    public let cornerRadius: CGFloat = 20
    public let usesGlassMorphism = false
    public let cardShadow = TutorShadow(color: Color(hex: "#D4753A").opacity(0.08), radius: 10, x: 0, y: 4)

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
