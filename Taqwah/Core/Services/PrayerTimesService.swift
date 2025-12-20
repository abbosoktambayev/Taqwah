import Foundation

@MainActor
final class PrayerTimesService {

    // Singleton (просто и удобно для старта)
    static let shared = PrayerTimesService()
    private init() {}

    // MARK: - Public API
    func fetchYearPrayerTimes(
        year: Int,
        latitude: Double,
        longitude: Double,
        completion: @escaping (Result<[PrayerDay], Error>) -> Void
    ) {

        let urlString =
        "https://namaz.muftyat.kz/api/times/\(year)/\(latitude)/\(longitude)"

        guard let url = URL(string: urlString) else {
            completion(.failure(ServiceError.invalidURL))
            return
        }

        let request = URLRequest(url: url, timeoutInterval: 30)

        URLSession.shared.dataTask(with: request) { data, response, error in

            // 1️⃣ Ошибка сети
            if let error = error {
                completion(.failure(error))
                return
            }

            // 2️⃣ Нет данных
            guard let data = data else {
                completion(.failure(ServiceError.noData))
                return
            }

            // 3️⃣ Декодирование (на главном акторе)
            Task { @MainActor in
                do {
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(PrayerTimesResponse.self, from: data)
                    completion(.success(response.result)) // result — это [PrayerDay]
                } catch {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
}

// MARK: - Errors
enum ServiceError: Error {
    case invalidURL
    case noData
}
