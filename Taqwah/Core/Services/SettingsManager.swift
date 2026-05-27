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

    // MARK: - Prayer Calculation Method

    @Published var calculationMethod: CalculationMethod {
        didSet {
            guard oldValue != calculationMethod else { return }
            UserDefaults.standard.set(calculationMethod.rawValue, forKey: "calculationMethod")
            // Refetch prayer times with the newly selected method.
            PrayerTimesManager.shared.reloadForCurrentLocation()
        }
    }

    /// Asr calculation: Hanafi (shadow ×2) vs. the other three madhabs (×1).
    /// Only affects Aladhan-based methods; Muftiyat KZ is Hanafi by default.
    @Published var hanafiAsr: Bool {
        didSet {
            guard oldValue != hanafiAsr else { return }
            UserDefaults.standard.set(hanafiAsr, forKey: "hanafiAsr")
            PrayerTimesManager.shared.reloadForCurrentLocation()
        }
    }

    private init() {
        self.colorSchemeSelection =
            UserDefaults.standard.string(forKey: "selectedColorScheme") ?? "system"

        let savedMethod = UserDefaults.standard.string(forKey: "calculationMethod")
        self.calculationMethod = savedMethod.flatMap(CalculationMethod.init(rawValue:)) ?? .default

        // Default to Hanafi (the app's primary audience is Central Asia / KZ).
        self.hanafiAsr = UserDefaults.standard.object(forKey: "hanafiAsr") as? Bool ?? true
    }

    /// Re-read settings from storage (e.g. after an iCloud merge).
    func reloadFromStore() {
        let defaults = UserDefaults.standard
        let scheme = defaults.string(forKey: "selectedColorScheme") ?? "system"
        if scheme != colorSchemeSelection { colorSchemeSelection = scheme }

        if let raw = defaults.string(forKey: "calculationMethod"),
           let method = CalculationMethod(rawValue: raw), method != calculationMethod {
            calculationMethod = method
        }

        if let hanafi = defaults.object(forKey: "hanafiAsr") as? Bool, hanafi != hanafiAsr {
            hanafiAsr = hanafi
        }
    }
}
