import SwiftUI
import Combine

/// Manages the in-app UI language, applied via `.environment(\.locale, ...)` at
/// the root. SwiftUI then localizes `Text("key")` / `LocalizedStringKey` from
/// the String Catalog for that locale — switching is instant, no restart.
@MainActor
final class LocalizationManager: ObservableObject {

    static let shared = LocalizationManager()

    /// Languages with a real translation available.
    static let available = ["en", "ru", "kk", "uz"]

    @Published var languageCode: String {
        didSet {
            guard oldValue != languageCode else { return }
            UserDefaults.standard.set(languageCode, forKey: "appLanguage")
        }
    }

    var locale: Locale { Locale(identifier: languageCode) }

    private init() {
        let saved = UserDefaults.standard.string(forKey: "appLanguage")
        if let saved, Self.available.contains(saved) {
            languageCode = saved
        } else {
            let device = Locale.current.language.languageCode?.identifier ?? "en"
            languageCode = Self.available.contains(device) ? device : "en"
        }
    }

    func setLanguage(_ code: String) {
        guard Self.available.contains(code) else { return }
        languageCode = code
    }
}
