import SwiftUI

enum WidgetStyle {

    // MARK: - Colors

    static let gold = Color(red: 242 / 255, green: 201 / 255, blue: 76 / 255)
    static let green = Color(red: 34 / 255, green: 139 / 255, blue: 34 / 255)

    private static let darkTop = Color(red: 9 / 255, green: 51 / 255, blue: 27 / 255)
    private static let darkMid = Color(red: 1 / 255, green: 26 / 255, blue: 21 / 255)

    static var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [darkTop, darkMid, .black],
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

extension View {
    /// Applies the app's branded gradient as the widget container background.
    func widgetBackground() -> some View {
        containerBackground(for: .widget) {
            WidgetStyle.backgroundGradient
        }
    }
}
