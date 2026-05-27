import Foundation

// MARK: - Aladhan Calendar API Response

struct AladhanCalendarResponse: Decodable {
    let code: Int
    let status: String
    let data: [AladhanDayData]

    func toPrayerDays() -> [PrayerDay] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")

        return data.compactMap { dayData in
            guard let date = dateFormatter.date(from: dayData.date.gregorian.date) else { return nil }

            return PrayerDay(
                date: date,
                fajr: dayData.timings.Fajr.cleanTime(),
                sunrise: dayData.timings.Sunrise.cleanTime(),
                dhuhr: dayData.timings.Dhuhr.cleanTime(),
                asr: dayData.timings.Asr.cleanTime(),
                maghrib: dayData.timings.Maghrib.cleanTime(),
                isha: dayData.timings.Isha.cleanTime()
            )
        }
    }
}

struct AladhanDayData: Decodable {
    let timings: AladhanTimings
    let date: AladhanDate
}

struct AladhanTimings: Decodable {
    let Fajr: String
    let Sunrise: String
    let Dhuhr: String
    let Asr: String
    let Maghrib: String
    let Isha: String
}

struct AladhanDate: Decodable {
    let gregorian: AladhanGregorianDate
}

struct AladhanGregorianDate: Decodable {
    let date: String  // "27-05-2026"
}

// MARK: - Muftiyat KZ API Response (api.muftyat.kz)

struct MuftyatResponse: Decodable {
    let result: [MuftyatDay]

    func toPrayerDays() -> [PrayerDay] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")

        return result.compactMap { day in
            guard let date = formatter.date(from: day.date) else { return nil }
            return PrayerDay(
                date: date,
                fajr: day.fajr,
                sunrise: day.sunrise,
                dhuhr: day.dhuhr,
                asr: day.asr,
                maghrib: day.maghrib,
                isha: day.isha
            )
        }
    }
}

struct MuftyatDay: Decodable {
    let fajr: String
    let sunrise: String
    let dhuhr: String
    let asr: String
    let maghrib: String
    let isha: String
    let date: String  // "2026-01-01"

    enum CodingKeys: String, CodingKey {
        case fajr, sunrise, dhuhr, asr, maghrib, isha
        case date = "Date"
    }
}

// MARK: - One Day Prayer Times

struct PrayerDay: Identifiable, Codable {
    var id = UUID()

    let date: Date
    let fajr: String
    let sunrise: String
    let dhuhr: String
    let asr: String
    let maghrib: String
    let isha: String
}

// MARK: - Prayer Event (resolved Date for a named prayer)

struct PrayerEvent: Identifiable {
    let id = UUID()
    let name: String
    let date: Date
}

extension PrayerDay {

    /// The five obligatory prayers in order (Sunrise excluded — it is not a salah).
    static let salahNames = ["Fajr", "Dhuhr", "Asr", "Maghrib", "Isha"]

    /// Shared "HH:mm" formatter — creating DateFormatters is expensive and these
    /// helpers are called frequently (every view render and countdown tick).
    private static let hhmmFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()

    /// Raw "HH:mm" string for a given prayer name.
    private func rawTime(for name: String) -> String? {
        switch name {
        case "Fajr":    return fajr
        case "Sunrise": return sunrise
        case "Dhuhr":   return dhuhr
        case "Asr":     return asr
        case "Maghrib": return maghrib
        case "Isha":    return isha
        default:        return nil
        }
    }

    /// Minute adjustment configured by the user in Prayer Settings (key `adjust_<Name>`).
    private func adjustment(for name: String) -> Int {
        UserDefaults.standard.integer(forKey: "adjust_\(name)")
    }

    /// Display time ("HH:mm") for a prayer, including the user's minute adjustment.
    func displayTime(for name: String) -> String {
        guard let event = event(for: name) else {
            return rawTime(for: name) ?? "--:--"
        }
        return Self.hhmmFormatter.string(from: event.date)
    }

    /// Resolved `Date` for a single prayer on this day, including adjustment.
    func event(for name: String) -> PrayerEvent? {
        guard let raw = rawTime(for: name)?.trimmingCharacters(in: .whitespaces) else { return nil }

        guard let parsed = Self.hhmmFormatter.date(from: raw) else { return nil }

        let calendar = Calendar.current
        let comps = calendar.dateComponents([.hour, .minute], from: parsed)
        guard let hour = comps.hour, let minute = comps.minute,
              let base = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: date)
        else { return nil }

        let adj = adjustment(for: name)
        let final = adj == 0 ? base : (calendar.date(byAdding: .minute, value: adj, to: base) ?? base)
        return PrayerEvent(name: name, date: final)
    }

    /// All five salah as resolved, adjusted `PrayerEvent`s for this day, sorted ascending.
    /// Used for notifications (Sunrise is not a prayer, so it is excluded).
    func salahEvents() -> [PrayerEvent] {
        Self.salahNames.compactMap { event(for: $0) }.sorted { $0.date < $1.date }
    }

    /// Timeline of all time-markers including Sunrise, sorted ascending.
    /// Used for the "next" countdown: after Fajr the next marker is Sunrise
    /// (the end of the Fajr window), not Dhuhr.
    func timelineEvents() -> [PrayerEvent] {
        ["Fajr", "Sunrise", "Dhuhr", "Asr", "Maghrib", "Isha"]
            .compactMap { event(for: $0) }
            .sorted { $0.date < $1.date }
    }
}

// MARK: - String Cleanup

extension String {
    /// Remove timezone suffix like " (+05)" from Aladhan time strings
    func cleanTime() -> String {
        if let parenIndex = self.firstIndex(of: "(") {
            return String(self[self.startIndex..<parenIndex]).trimmingCharacters(in: .whitespaces)
        }
        return self.trimmingCharacters(in: .whitespaces)
    }
}
