import Foundation

final class PrayerTimesService {

    static let shared = PrayerTimesService()
    private init() {}

    // MARK: - Public API

    /// Fetch a full year of prayer times for the given method, sorted by date.
    /// `hanafiAsr` only applies to Aladhan methods (school=1); Muftiyat is Hanafi already.
    func fetchYearPrayerTimes(
        year: Int,
        latitude: Double,
        longitude: Double,
        method: CalculationMethod,
        hanafiAsr: Bool
    ) async throws -> [PrayerDay] {
        switch method.provider {
        case .muftyat:
            return try await fetchMuftyatYear(year: year, latitude: latitude, longitude: longitude)
        case .aladhan(let code):
            return try await fetchAladhanYear(
                year: year, latitude: latitude, longitude: longitude,
                method: code, school: hanafiAsr ? 1 : 0
            )
        }
    }

    // MARK: - Muftiyat KZ (whole year in one request)

    /// Beyond this distance (km) from the nearest Muftiyat city we treat the
    /// location as outside Kazakhstan and let the caller fall back to Aladhan.
    private let muftyatMaxCityDistanceKm = 100.0

    private func fetchMuftyatYear(
        year: Int,
        latitude: Double,
        longitude: Double
    ) async throws -> [PrayerDay] {
        // The prayer-times endpoint only answers for EXACT city coordinates, so
        // resolve the nearest Muftiyat city first and query with its coordinates.
        let city = try await nearestMuftyatCity(latitude: latitude, longitude: longitude)

        // Out of Kazakhstan → signal "not covered" so we fall back to Aladhan.
        if let distance = city.distance, distance > muftyatMaxCityDistanceKm {
            throw ServiceError.outOfCoverage
        }

        let urlString = "https://api.muftyat.kz/prayer-times/\(year)/\(city.lat)/\(city.lng)"
        guard let url = URL(string: urlString) else { throw ServiceError.invalidURL }

        let request = URLRequest(url: url, timeoutInterval: 30)
        let (data, response) = try await URLSession.shared.data(for: request)
        try Self.validate(response)

        let decoded = try JSONDecoder().decode(MuftyatResponse.self, from: data)
        let days = decoded.toPrayerDays().sorted { $0.date < $1.date }
        guard !days.isEmpty else { throw ServiceError.noData }
        return days
    }

    /// Resolve the nearest Muftiyat city; the API computes distance server-side.
    private func nearestMuftyatCity(latitude: Double, longitude: Double) async throws -> MuftyatCity {
        let urlString = "https://api.muftyat.kz/cities/?lat=\(latitude)&lng=\(longitude)"
        guard let url = URL(string: urlString) else { throw ServiceError.invalidURL }

        let request = URLRequest(url: url, timeoutInterval: 30)
        let (data, response) = try await URLSession.shared.data(for: request)
        try Self.validate(response)

        let decoded = try JSONDecoder().decode(MuftyatCitiesResponse.self, from: data)
        guard let city = decoded.results.first else { throw ServiceError.outOfCoverage }
        return city
    }

    // MARK: - Aladhan (one request per month)

    private func fetchAladhanYear(
        year: Int,
        latitude: Double,
        longitude: Double,
        method: Int,
        school: Int
    ) async throws -> [PrayerDay] {
        try await withThrowingTaskGroup(of: [PrayerDay].self) { group in
            for month in 1...12 {
                group.addTask {
                    try await self.fetchAladhanMonth(
                        year: year, month: month,
                        latitude: latitude, longitude: longitude, method: method, school: school
                    )
                }
            }

            var all: [PrayerDay] = []
            for try await monthDays in group {
                all.append(contentsOf: monthDays)
            }
            return all.sorted { $0.date < $1.date }
        }
    }

    private func fetchAladhanMonth(
        year: Int,
        month: Int,
        latitude: Double,
        longitude: Double,
        method: Int,
        school: Int
    ) async throws -> [PrayerDay] {
        let urlString =
            "https://api.aladhan.com/v1/calendar/\(year)/\(month)?latitude=\(latitude)&longitude=\(longitude)&method=\(method)&school=\(school)"
        guard let url = URL(string: urlString) else { throw ServiceError.invalidURL }

        let request = URLRequest(url: url, timeoutInterval: 30)
        let (data, response) = try await URLSession.shared.data(for: request)
        try Self.validate(response)

        let apiResponse = try JSONDecoder().decode(AladhanCalendarResponse.self, from: data)
        return apiResponse.toPrayerDays()
    }

    // MARK: - Helpers

    /// Throw if the response is an HTTP error (e.g. Muftiyat returns 404 for
    /// coordinates outside Kazakhstan, as an HTML page that can't be decoded).
    private static func validate(_ response: URLResponse) throws {
        guard let http = response as? HTTPURLResponse else { return }
        guard (200..<300).contains(http.statusCode) else {
            throw ServiceError.httpStatus(http.statusCode)
        }
    }
}

// MARK: - Errors

enum ServiceError: Error, LocalizedError {
    case invalidURL
    case noData
    case httpStatus(Int)
    case outOfCoverage

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL for prayer times API"
        case .noData: return "No data received from prayer times API"
        case .httpStatus(let code): return "Prayer times API returned status \(code)"
        case .outOfCoverage: return "Location is outside this provider's coverage"
        }
    }
}
