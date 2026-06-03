import Foundation

/// What the Home "Today" card should nudge the user toward, based on the time of
/// day relative to the prayer schedule. A pure, deterministic function — easy to
/// unit-test and reason about.
enum TodayFlowKind: Equatable {
    case beforeFajr                 // the small hours, before Fajr
    case afterPrayer(prayer: String) // 0–20 min right after a salah
    case jummah                     // Friday late-morning, before Dhuhr
    case morningAthkar              // Fajr → Dhuhr
    case eveningAthkar              // Asr → Isha
    case beforeSleep                // after Isha
    case daytime                    // the Dhuhr → Asr gap: next prayer + tracker
}

enum TodayFlow {

    /// Minutes after a salah during which we surface the after-prayer remembrances.
    static let afterPrayerWindow: TimeInterval = 20 * 60

    /// Hours before Friday Dhuhr to start the Jummah / Surah Al-Kahf nudge.
    static let jummahLeadHours: TimeInterval = 3 * 60 * 60

    /// Resolve the worship context. `weekday` uses `Calendar` numbering (1=Sun … 6=Fri).
    static func kind(for day: PrayerDay, now: Date, weekday: Int) -> TodayFlowKind {
        let t: (String) -> Date? = { day.event(for: $0)?.date }
        let fajr = t("Fajr"), dhuhr = t("Dhuhr"), asr = t("Asr"), isha = t("Isha")

        // 1) Right after any salah → after-prayer athkar (highest priority).
        for name in PrayerDay.salahNames {
            if let start = t(name), now >= start, now < start.addingTimeInterval(afterPrayerWindow) {
                return .afterPrayer(prayer: name)
            }
        }

        // 2) Friday, approaching Dhuhr → Jummah + Surah Al-Kahf.
        if weekday == 6, let dhuhr, now < dhuhr, now >= dhuhr.addingTimeInterval(-jummahLeadHours) {
            return .jummah
        }

        // 3) Before Fajr — the night.
        if let fajr, now < fajr { return .beforeFajr }

        // 4) Fajr → Dhuhr — morning remembrances.
        if let fajr, let dhuhr, now >= fajr, now < dhuhr { return .morningAthkar }

        // 5) Asr → Isha — evening remembrances.
        if let asr, let isha, now >= asr, now < isha { return .eveningAthkar }

        // 6) After Isha — before-sleep remembrances.
        if let isha, now >= isha { return .beforeSleep }

        // 7) Dhuhr → Asr gap — focus on the next prayer + today's progress.
        return .daytime
    }
}
