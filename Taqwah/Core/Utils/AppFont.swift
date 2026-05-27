import SwiftUI
import CoreText

/// Registers and exposes the bundled Arabic Quran typeface (Amiri Quran).
///
/// The app has no Info.plist `UIAppFonts` entry, so fonts are registered at
/// runtime with Core Text instead. Call `AppFont.register()` once at launch.
enum AppFont {

    /// PostScript name of the bundled Quranic typeface.
    static let quranName = "AmiriQuran-Regular"

    private static var didRegister = false

    static func register() {
        guard !didRegister else { return }
        didRegister = true
        registerFont(named: quranName, ext: "ttf")
    }

    private static func registerFont(named name: String, ext: String) {
        guard let url = Bundle.main.url(forResource: name, withExtension: ext) else {
            print("⚠️ Font \(name).\(ext) not found in bundle")
            return
        }
        var error: Unmanaged<CFError>?
        if !CTFontManagerRegisterFontsForURL(url as CFURL, .process, &error) {
            let desc = error?.takeRetainedValue().localizedDescription ?? "unknown error"
            print("⚠️ Failed to register font \(name): \(desc)")
        }
    }
}

extension Font {
    /// Traditional Quranic Naskh (Amiri Quran). Falls back to the system font
    /// automatically if the custom font failed to register.
    static func quran(size: CGFloat) -> Font {
        .custom(AppFont.quranName, size: size)
    }
}
