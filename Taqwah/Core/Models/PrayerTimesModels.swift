import Foundation

// MARK: - Root API Response
import Foundation

// MARK: - Root API Response
struct PrayerTimesResponse: Decodable {
    let success: Bool
    let result: [PrayerDay]

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        success = try container.decode(Bool.self, forKey: .success)

        // 🔹 Кастомный декодер для даты
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        formatter.locale = Locale(identifier: "en_US_POSIX")

        let decoderWithDate = JSONDecoder()
        decoderWithDate.dateDecodingStrategy = .formatted(formatter)

        let rawResult = try container.decode([RawPrayerDay].self, forKey: .result)

        result = rawResult.compactMap {
            guard let date = formatter.date(from: $0.date) else { return nil }
            return PrayerDay(
                date: date,
                fajr: $0.fajr.trimmingCharacters(in: .whitespaces),
                sunrise: $0.sunrise.trimmingCharacters(in: .whitespaces),
                dhuhr: $0.dhuhr.trimmingCharacters(in: .whitespaces),
                asr: $0.asr.trimmingCharacters(in: .whitespaces),
                maghrib: $0.maghrib.trimmingCharacters(in: .whitespaces),
                isha: $0.isha.trimmingCharacters(in: .whitespaces)
            )
        }
    }

    enum CodingKeys: String, CodingKey {
        case success
        case result
    }
}

// MARK: - Raw model (date as String)
private struct RawPrayerDay: Decodable {
    let date: String
    let fajr: String
    let sunrise: String
    let dhuhr: String
    let asr: String
    let maghrib: String
    let isha: String

    enum CodingKeys: String, CodingKey {
        case date
        case fajr = "Fajr"
        case sunrise = "Sunrise"
        case dhuhr = "Dhuhr"
        case asr = "Asr"
        case maghrib = "Maghrib"
        case isha = "Isha"
    }
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
