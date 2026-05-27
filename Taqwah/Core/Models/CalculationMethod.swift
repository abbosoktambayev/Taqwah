import Foundation

// MARK: - Provider backend

/// Which web API actually serves the prayer times for a method.
enum PrayerProvider: Equatable {
    case muftyat                 // api.muftyat.kz — whole year in one request
    case aladhan(method: Int)    // api.aladhan.com — `method` query parameter
}

// MARK: - Calculation Method

/// A user-selectable prayer-time calculation method. More can be added later.
enum CalculationMethod: String, CaseIterable, Identifiable, Codable {
    case muftyatKZ
    case mwl
    case ummAlQura
    case isna
    case egypt
    case karachi

    var id: String { rawValue }

    /// Short display name.
    var title: String {
        switch self {
        case .muftyatKZ: return "Muftiyat KZ"
        case .mwl:       return "Muslim World League"
        case .ummAlQura: return "Umm al-Qura"
        case .isna:      return "ISNA"
        case .egypt:     return "Egyptian Authority"
        case .karachi:   return "University of Karachi"
        }
    }

    /// Secondary line describing the region the method is intended for.
    var subtitle: String {
        switch self {
        case .muftyatKZ: return "ДУМК — official for Kazakhstan"
        case .mwl:       return "Standard, used worldwide"
        case .ummAlQura: return "Makkah, Saudi Arabia"
        case .isna:      return "North America"
        case .egypt:     return "Egypt, parts of Africa"
        case .karachi:   return "Pakistan, India, Bangladesh"
        }
    }

    /// The backend that serves this method.
    var provider: PrayerProvider {
        switch self {
        case .muftyatKZ: return .muftyat
        case .mwl:       return .aladhan(method: 3)
        case .ummAlQura: return .aladhan(method: 4)
        case .isna:      return .aladhan(method: 2)
        case .egypt:     return .aladhan(method: 5)
        case .karachi:   return .aladhan(method: 1)
        }
    }

    /// Stable token used inside the offline-cache key so switching method refetches.
    var cacheToken: String { rawValue }

    static let `default`: CalculationMethod = .muftyatKZ
}
