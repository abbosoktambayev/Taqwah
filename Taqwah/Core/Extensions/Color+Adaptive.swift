import SwiftUI
import UIKit

private func themedColor(
    light: UInt,
    dark: UInt,
    lightAlpha: CGFloat = 1,
    darkAlpha: CGFloat = 1
) -> Color {
    Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
        ? UIColor(hex: dark, alpha: darkAlpha)
        : UIColor(hex: light, alpha: lightAlpha)
    })
}

extension Color {

    // MARK: - Abbos Design System Palette

    /// #0A0A0B - dark background, not pure black.
    static let obsidian = Color(hex: 0x0A0A0B)

    /// #121214 - dark cards, sheets, elevated surfaces.
    static let deepElevated = Color(hex: 0x121214)

    /// #F3EBDD - warm parchment for dark mode text.
    static let parchment = Color(hex: 0xF3EBDD)

    /// #F5F1E8 - light-mode background paper.
    static let paper = Color(hex: 0xF5F1E8)

    /// #FBF8F1 - light elevated surface.
    static let softIvory = Color(hex: 0xFBF8F1)

    /// #1C1A15 - warm ink text, not pure black.
    static let ink = Color(hex: 0x1C1A15)

    /// Warm gold for key highlights; deeper in light mode for contrast.
    static let gold = themedColor(light: 0x9C7E45, dark: 0xC9A96E)
    static let warmGold = Color.gold
    static let goldFill = Color(hex: 0xC9A96E)
    static let onGold = Color(hex: 0x16130E)
    static let goldDim = themedColor(
        light: 0x9C7E45,
        dark: 0xC9A96E,
        lightAlpha: 0.14,
        darkAlpha: 0.16
    )

    /// Muted emerald for app accents and progress; never neon.
    static let brand = themedColor(light: 0x2F6A54, dark: 0x3E7A63)
    static let mutedEmerald = Color.brand
    static let brandDeep = themedColor(light: 0x265846, dark: 0x346854)
    static let brandDim = themedColor(
        light: 0x2F6A54,
        dark: 0x3E7A63,
        lightAlpha: 0.14,
        darkAlpha: 0.20
    )
    static var emerald: Color { brand }

    // MARK: - Semantic ADS Roles

    static let bg = themedColor(light: 0xF5F1E8, dark: 0x0A0A0B)
    static let surface = themedColor(light: 0xFBF8F1, dark: 0x121214)
    static let surface2 = themedColor(light: 0xEFEADF, dark: 0x1A1A1D)
    static let surface3 = themedColor(light: 0xE6E0D3, dark: 0x222226)
    static let readingSurface = themedColor(light: 0xF5F1E8, dark: 0x121214)

    static let textPrimary = themedColor(light: 0x1C1A15, dark: 0xF3EBDD)
    static let sec = themedColor(
        light: 0x1C1A15,
        dark: 0xF3EBDD,
        lightAlpha: 0.62,
        darkAlpha: 0.68
    )
    static let ter = themedColor(
        light: 0x1C1A15,
        dark: 0xF3EBDD,
        lightAlpha: 0.42,
        darkAlpha: 0.40
    )
    static let quat = themedColor(
        light: 0x1C1A15,
        dark: 0xF3EBDD,
        lightAlpha: 0.22,
        darkAlpha: 0.20
    )

    static let hairline = themedColor(
        light: 0x1C1A15,
        dark: 0xF3EBDD,
        lightAlpha: 0.12,
        darkAlpha: 0.10
    )
    static let hairlineSoft = themedColor(
        light: 0x1C1A15,
        dark: 0xF3EBDD,
        lightAlpha: 0.07,
        darkAlpha: 0.06
    )
    static let warningYellow = themedColor(light: 0xA88414, dark: 0xD6AE5C)
    static let dangerRed = themedColor(light: 0xB24A40, dark: 0xCE6E62)

    static let primaryAccent = Color.gold
    static let stateAccent = Color.brand

    // Backward-compatible aliases used around the app.
    static let elevatedSurface = Color.deepElevated
    static let brandGold = Color.warmGold
    static let unifiedEmerald = Color.mutedEmerald

    // MARK: - Theme Roles

    static func adaptiveBackground(_ scheme: ColorScheme?) -> Color {
        .bg
    }

    static func adaptiveText(_ scheme: ColorScheme?) -> Color {
        .textPrimary
    }

    static func secondaryText(_ scheme: ColorScheme?) -> Color {
        .sec
    }

    static func sectionTitle(_ scheme: ColorScheme?) -> Color {
        .ter
    }

    // MARK: - Accent Colors

    /// Warm gold for the main prayer/countdown focus.
    static let prayerAccent = Color.warmGold

    /// Legacy name kept for compatibility; now ADS muted emerald.
    static let greenAccent = Color.mutedEmerald

    /// Default Taqwah accent for controls, icons, progress, and selection.
    static func adaptiveAccent(_ scheme: ColorScheme?) -> Color {
        .mutedEmerald
    }

    static func accentShadow(_ scheme: ColorScheme?) -> Color {
        Color.black.opacity(scheme == .light ? 0.10 : 0.18)
    }

    // MARK: - Card / Surface Colors

    static func cardBackground(_ scheme: ColorScheme?) -> Color {
        .surface
    }

    static func cardBorder(_ scheme: ColorScheme?) -> Color {
        .hairline
    }

    static func glassFill(_ scheme: ColorScheme?) -> Color {
        .surface2
    }

    static func glassBorder(_ scheme: ColorScheme?) -> Color {
        .hairlineSoft
    }

    static func dividerColor(_ scheme: ColorScheme?) -> Color {
        .hairlineSoft
    }

    // MARK: - Streak / Progress

    static func streakBackground(_ scheme: ColorScheme?) -> Color {
        .goldDim
    }

    static func progressTrack(_ scheme: ColorScheme?) -> Color {
        .surface3
    }

    static func uncheckedBorder(_ scheme: ColorScheme?) -> Color {
        .quat
    }
}

// MARK: - ADS Radius / Spacing / Motion

enum Radius {
    static let card: CGFloat = 28
    static let cardAlt: CGFloat = 22
    static let list: CGFloat = 18
    static let control: CGFloat = 16
    static let button: CGFloat = 14
    static let small: CGFloat = 12
    static let tiny: CGFloat = 9
}

enum Spacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 40
    static let xxl: CGFloat = 64
}

enum Motion {
    static let standard = Animation.easeInOut(duration: 0.35)
    static let gentle = Animation.easeInOut(duration: 0.5)
}

extension View {
    func softShadow() -> some View {
        shadow(color: Color.black.opacity(0.18), radius: 16, x: 0, y: 8)
    }

    func cardStyle(_ radius: CGFloat = Radius.card) -> some View {
        background(Color.surface)
            .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
    }

    func cardStroke(_ radius: CGFloat = Radius.control) -> some View {
        overlay(
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .strokeBorder(Color.hairline, lineWidth: 0.7)
        )
    }
}

extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: alpha
        )
    }
}

private extension UIColor {
    convenience init(hex: UInt, alpha: CGFloat = 1) {
        self.init(
            red: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: alpha
        )
    }
}
