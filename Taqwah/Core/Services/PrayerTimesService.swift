import Foundation

@MainActor
final class PrayerTimesService {

    static let shared = PrayerTimesService()
    private init() {}

    // MARK: - Public API

    /// Fetch prayer times for entire year by loading all 12 months
    func fetchYearPrayerTimes(
        year: Int,
        latitude: Double,
        longitude: Double,
        completion: @escaping (Result<[PrayerDay], Error>) -> Void
    ) {
        let currentMonth = Calendar.current.component(.month, from: Date())

        // Load current month first for fast display, then load rest
        fetchMonthPrayerTimes(year: year, month: currentMonth, latitude: latitude, longitude: longitude) { result in
            switch result {
            case .success(let days):
                completion(.success(days))

                // Background-load remaining months
                Task { @MainActor in
                    var allDays = days
                    for m in 1...12 where m != currentMonth {
                        self.fetchMonthPrayerTimes(year: year, month: m, latitude: latitude, longitude: longitude) { monthResult in
                            if case .success(let monthDays) = monthResult {
                                allDays.append(contentsOf: monthDays)
                            }
                        }
                    }
                }

            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    /// Fetch prayer times for a single month from Aladhan API
    func fetchMonthPrayerTimes(
        year: Int,
        month: Int,
        latitude: Double,
        longitude: Double,
        completion: @escaping (Result<[PrayerDay], Error>) -> Void
    ) {
        let urlString =
            "https://api.aladhan.com/v1/calendar/\(year)/\(month)?latitude=\(latitude)&longitude=\(longitude)&method=2"

        guard let url = URL(string: urlString) else {
            completion(.failure(ServiceError.invalidURL))
            return
        }

        let request = URLRequest(url: url, timeoutInterval: 30)

        URLSession.shared.dataTask(with: request) { data, response, error in

            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(ServiceError.noData))
                return
            }

            Task { @MainActor in
                do {
                    let apiResponse = try JSONDecoder().decode(AladhanCalendarResponse.self, from: data)
                    let days = apiResponse.toPrayerDays()
                    completion(.success(days))
                } catch {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
}

// MARK: - Errors

enum ServiceError: Error, LocalizedError {
    case invalidURL
    case noData

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL for prayer times API"
        case .noData: return "No data received from prayer times API"
        }
    }
}
