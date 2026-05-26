import Foundation

// MARK: - Hijri Date Utility

/// Returns the current Hijri (Islamic) date formatted as a human-readable string.
/// Example: "15 Jumada Al-Awwal 1447"
func currentHijriDateString() -> String {
    let hijriCalendar = Calendar(identifier: .islamicUmmAlQura)
    let now = Date()

    let day = hijriCalendar.component(.day, from: now)
    let month = hijriCalendar.component(.month, from: now)
    let year = hijriCalendar.component(.year, from: now)

    let monthNames = [
        1: "Muharram",
        2: "Safar",
        3: "Rabi' Al-Awwal",
        4: "Rabi' Al-Thani",
        5: "Jumada Al-Awwal",
        6: "Jumada Al-Thani",
        7: "Rajab",
        8: "Sha'ban",
        9: "Ramadan",
        10: "Shawwal",
        11: "Dhul Qi'dah",
        12: "Dhul Hijjah"
    ]

    let monthName = monthNames[month] ?? "Unknown"
    return "\(day) \(monthName) \(year)"
}

/// Returns today's date formatted for the API (dd-MM-yyyy).
func todayStringForAPI() -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "dd-MM-yyyy"
    formatter.locale = Locale(identifier: "en_US_POSIX")
    return formatter.string(from: Date())
}
