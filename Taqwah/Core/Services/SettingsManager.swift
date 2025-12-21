import SwiftUI
import Combine

@MainActor
final class SettingsManager: ObservableObject {

    static let shared = SettingsManager()

    // system | light | dark
    @Published var colorSchemeSelection: String {
        didSet {
            UserDefaults.standard.set(colorSchemeSelection, forKey: "selectedColorScheme")
        }
    }

    var colorScheme: ColorScheme? {
        switch colorSchemeSelection {
        case "light": return .light
        case "dark": return .dark
        default: return nil // system
        }
    }

    private init() {
        self.colorSchemeSelection =
            UserDefaults.standard.string(forKey: "selectedColorScheme") ?? "system"
    }
}
