import SwiftUI

extension Color {

    // MARK: - Text Colors

    /// Primary text: black in light, white in dark
    static func adaptiveText(_ scheme: ColorScheme?) -> Color {
        scheme == .light ? .black : .white
    }

    /// Secondary/subtitle text
    static func secondaryText(_ scheme: ColorScheme?) -> Color {
        scheme == .light
        ? .black.opacity(0.6)
        : .white.opacity(0.7)
    }

    /// Section titles (small caps labels)
    static func sectionTitle(_ scheme: ColorScheme?) -> Color {
        scheme == .light ? .black.opacity(0.4) : .white.opacity(0.5)
    }

    // MARK: - Accent Colors

    /// 🔆 Accent for prayers / timer / icons
    static let prayerAccent = Color(
        red: 242/255,
        green: 201/255,
        blue: 76/255
    )

    /// Green accent — used in light mode for timer, icons
    static let greenAccent = Color(
        red: 34/255,
        green: 139/255,
        blue: 34/255
    )

    /// Adaptive accent: green in light, gold in dark
    static func adaptiveAccent(_ scheme: ColorScheme?) -> Color {
        scheme == .light ? .greenAccent : .prayerAccent
    }

    /// Adaptive accent shadow
    static func accentShadow(_ scheme: ColorScheme?) -> Color {
        scheme == .light
        ? Color.greenAccent.opacity(0.35)
        : Color.prayerAccent.opacity(0.35)
    }

    // MARK: - Card / Surface Colors

    /// Card background
    static func cardBackground(_ scheme: ColorScheme?) -> Color {
        scheme == .light
        ? Color(red: 245/255, green: 249/255, blue: 246/255)
        : Color.white.opacity(0.08)
    }

    /// Card border
    static func cardBorder(_ scheme: ColorScheme?) -> Color {
        scheme == .light
        ? Color(red: 200/255, green: 230/255, blue: 201/255).opacity(0.4)
        : Color.white.opacity(0.1)
    }

    /// Glass-group fill (for grouped settings cards)
    static func glassFill(_ scheme: ColorScheme?) -> Color {
        scheme == .light
        ? Color.black.opacity(0.04)
        : Color.white.opacity(0.08)
    }

    /// Glass-group border
    static func glassBorder(_ scheme: ColorScheme?) -> Color {
        scheme == .light
        ? Color.black.opacity(0.08)
        : Color.white.opacity(0.1)
    }

    /// Divider line
    static func dividerColor(_ scheme: ColorScheme?) -> Color {
        scheme == .light
        ? Color.black.opacity(0.06)
        : Color.white.opacity(0.08)
    }

    // MARK: - Streak / Progress

    /// Streak badge background
    static func streakBackground(_ scheme: ColorScheme?) -> Color {
        scheme == .light
        ? Color.orange.opacity(0.12)
        : Color.white.opacity(0.08)
    }

    /// Progress bar track
    static func progressTrack(_ scheme: ColorScheme?) -> Color {
        scheme == .light
        ? Color.black.opacity(0.08)
        : Color.white.opacity(0.12)
    }

    // MARK: - Unchecked circle border
    static func uncheckedBorder(_ scheme: ColorScheme?) -> Color {
        scheme == .light
        ? Color.black.opacity(0.2)
        : Color.white.opacity(0.3)
    }
}
