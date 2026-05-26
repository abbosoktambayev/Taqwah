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

// MARK: - One Day Prayer Times

struct PrayerDay: Identifiable {
    let id = UUID()

    let date: Date
    let fajr: String
    let sunrise: String
    let dhuhr: String
    let asr: String
    let maghrib: String
    let isha: String
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
