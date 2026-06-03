import SwiftUI
import CoreText
import OSLog

/// Registers the bundled Abbos Design System typefaces at runtime.
///
/// The app has no Info.plist `UIAppFonts` entry, so fonts are registered with
/// Core Text instead. Call `AppFont.register()` once at launch.
///
/// Families (all OFL):
///  - Cormorant Garamond: editorial serif for hero numbers, titles, names
///  - IBM Plex Mono: metadata needing Cyrillic + Latin (RU/EN eyebrows)
///  - DM Mono: metadata, Latin / numeric only
///  - Amiri Quran: Quranic Arabic text only
enum AppFont {
    private static let logger = Logger(subsystem: "Taqwah", category: "Fonts")

    /// PostScript name of the bundled Quranic typeface.
    static let quranName = "AmiriQuran-Regular"

    /// All bundled font files (PostScript names == file names).
    private static let allFonts = [
        "AmiriQuran-Regular",
        "CormorantGaramond-Light",
        "CormorantGaramond-Regular",
        "CormorantGaramond-Medium",
        "CormorantGaramond-SemiBold",
        "IBMPlexMono-Light",
        "IBMPlexMono-Regular",
        "IBMPlexMono-Medium",
        "DMMono-Light",
        "DMMono-Regular",
        "DMMono-Medium"
    ]

    private static var didRegister = false

    static func register() {
        guard !didRegister else { return }
        didRegister = true
        for name in allFonts {
            registerFont(named: name, ext: "ttf")
        }
    }

    private static func registerFont(named name: String, ext: String) {
        guard let url = Bundle.main.url(forResource: name, withExtension: ext) else {
            logger.warning("Font \(name, privacy: .public).\(ext, privacy: .public) not found in bundle")
            return
        }
        var error: Unmanaged<CFError>?
        if !CTFontManagerRegisterFontsForURL(url as CFURL, .process, &error) {
            let desc = error?.takeRetainedValue().localizedDescription ?? "unknown error"
            logger.warning("Failed to register font \(name, privacy: .public): \(desc, privacy: .public)")
        }
    }
}

extension Font {

    /// Maps a point size to the nearest text style so a custom font scales with
    /// Dynamic Type via `relativeTo:`. A bare `.custom(size:)` is
    /// frozen and fails accessibility.
    static func textStyle(forSize size: CGFloat) -> Font.TextStyle {
        switch size {
        case ..<12: return .caption2
        case ..<13: return .caption
        case ..<15: return .footnote
        case ..<16: return .subheadline
        case ..<17: return .callout
        case ..<20: return .body
        case ..<23: return .title3
        case ..<28: return .title2
        case ..<34: return .title
        default: return .largeTitle
        }
    }

    private static func scaled(_ name: String, _ size: CGFloat) -> Font {
        .custom(name, size: size, relativeTo: textStyle(forSize: size))
    }

    // MARK: - Editorial serif - Cormorant Garamond (brand / titles / hero numbers)

    /// Lightest serif for big display numbers and hero moments.
    static func brandDisplay(_ size: CGFloat) -> Font {
        scaled("CormorantGaramond-Light", size)
    }

    /// Serif for screen titles, nav-bar titles, product names.
    static func brandTitle(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        switch weight {
        case .bold, .heavy, .black, .semibold: return scaled("CormorantGaramond-SemiBold", size)
        case .medium:                          return scaled("CormorantGaramond-Medium", size)
        case .light, .thin, .ultraLight:       return scaled("CormorantGaramond-Light", size)
        default:                               return scaled("CormorantGaramond-Regular", size)
        }
    }

    // MARK: - Metadata mono - IBM Plex Mono (Cyrillic + Latin)

    static func mono(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        switch weight {
        case .medium, .semibold, .bold:  return scaled("IBMPlexMono-Medium", size)
        case .light, .thin, .ultraLight: return scaled("IBMPlexMono-Light", size)
        default:                         return scaled("IBMPlexMono-Regular", size)
        }
    }

    // MARK: - Metadata mono - DM Mono (Latin / numeric only)

    static func monoLatin(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        switch weight {
        case .medium, .semibold, .bold:  return scaled("DMMono-Medium", size)
        case .light, .thin, .ultraLight: return scaled("DMMono-Light", size)
        default:                         return scaled("DMMono-Regular", size)
        }
    }

    // MARK: - Quranic Arabic - Amiri Quran (Quran text only)

    /// Traditional Quranic Naskh (Amiri Quran), scales with Dynamic Type.
    static func quran(size: CGFloat) -> Font {
        scaled(AppFont.quranName, size)
    }

    static let arabicQuran = scaled("AmiriQuran-Regular", 42)
    static let arabicSmall = scaled("AmiriQuran-Regular", 22)

    static func arabic(size: CGFloat) -> Font { quran(size: size) }
}
