import SwiftUI

enum WidgetStyle {

    // MARK: - Colors

    static let gold = Color(hex: 0xC9A96E)
    static let green = Color(hex: 0x3E7A63)
    static let text = Color(hex: 0xF3EBDD)
    static let textSecondary = Color(hex: 0xF3EBDD).opacity(0.68)
    static let hairline = Color(hex: 0xF3EBDD).opacity(0.10)

    private static let widgetBase = Color(hex: 0x0D100F)
    private static let obsidian = Color(hex: 0x0A0A0B)
    private static let deepElevated = Color(hex: 0x121214)

    static var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [widgetBase, deepElevated, obsidian],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    // MARK: - Icons

    static func icon(for prayer: String) -> String {
        switch prayer {
        case "Fajr":    return "sunrise.fill"
        case "Sunrise": return "sun.horizon.fill"
        case "Dhuhr":   return "sun.max.fill"
        case "Asr":     return "sun.haze.fill"
        case "Maghrib": return "sunset.fill"
        case "Isha":    return "moon.stars.fill"
        default:        return "moon.fill"
        }
    }
}

private extension Color {
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

extension View {
    /// Applies the app's branded gradient as the widget container background.
    func widgetBackground() -> some View {
        containerBackground(for: .widget) {
            WidgetStyle.backgroundGradient
        }
    }
}
