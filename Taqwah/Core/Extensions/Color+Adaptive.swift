import SwiftUI

extension Color {

    // Основной текст
    static func adaptiveText(_ scheme: ColorScheme?) -> Color {
        scheme == .light ? .black : .white
    }

    // Вторичный текст
    static func secondaryText(_ scheme: ColorScheme?) -> Color {
        scheme == .light
        ? .black.opacity(0.6)
        : .white.opacity(0.7)
    }

    // 🔆 Акцентный цвет для намазов / таймера / иконок
    static let prayerAccent = Color(
        red: 242/255,
        green: 201/255,
        blue: 76/255
    )
}
//red: 242/255, green: 201/255,blue: 76/255
