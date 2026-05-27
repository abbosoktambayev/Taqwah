import Foundation
import Combine

@MainActor
final class PrayerTimesManager: ObservableObject {
    static let shared = PrayerTimesManager()

    @Published var todayPrayer: PrayerDay?
    @Published var allDays: [PrayerDay] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private var hasLoaded = false
    private var loadTask: Task<Void, Never>?

    private init() {}

    // MARK: - Public API

    /// Load prayer times using the current location from LocationManager.
    func loadIfNeeded() {
        guard !hasLoaded else { return }
        let location = LocationManager.shared
        load(latitude: location.latitude, longitude: location.longitude)
    }

    /// Force reload with new coordinates (e.g. when location updates).
    func reload(latitude: Double, longitude: Double) {
        hasLoaded = false
        load(latitude: latitude, longitude: longitude)
    }

    /// Reload using the current location (e.g. after the calculation method changes).
    func reloadForCurrentLocation() {
        let location = LocationManager.shared
        reload(latitude: location.latitude, longitude: location.longitude)
    }

    // MARK: - Private

    private func load(latitude: Double, longitude: Double) {
        guard !hasLoaded else { return }
        hasLoaded = true
        errorMessage = nil

        let year = Calendar.current.component(.year, from: Date())
        let method = SettingsManager.shared.calculationMethod
        let hanafiAsr = SettingsManager.shared.hanafiAsr

        // 1. Serve cached data instantly if available (works offline).
        if let cached = loadCache(year: year, latitude: latitude, longitude: longitude, method: method, hanafiAsr: hanafiAsr),
           !cached.isEmpty {
            applyDays(cached)
        } else {
            allDays = []
            todayPrayer = nil
            isLoading = true
        }

        // 2. Refresh from the network.
        loadTask?.cancel()
        loadTask = Task { [weak self] in
            guard let self else { return }
            do {
                let full = try await self.fetchWithFallback(
                    year: year, latitude: latitude, longitude: longitude, method: method, hanafiAsr: hanafiAsr
                )
                if Task.isCancelled { return }
                self.applyDays(full)
                self.isLoading = false
                self.saveCache(full, year: year, latitude: latitude, longitude: longitude, method: method, hanafiAsr: hanafiAsr)
            } catch {
                if Task.isCancelled { return }
                self.isLoading = false
                // Only surface an error if we have nothing to show (no cache).
                if self.allDays.isEmpty {
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }

    /// Fetch for the chosen method, falling back to a global provider when the
    /// Muftiyat KZ API can't serve the location (it only covers Kazakhstan).
    private func fetchWithFallback(
        year: Int, latitude: Double, longitude: Double, method: CalculationMethod, hanafiAsr: Bool
    ) async throws -> [PrayerDay] {
        do {
            return try await PrayerTimesService.shared.fetchYearPrayerTimes(
                year: year, latitude: latitude, longitude: longitude, method: method, hanafiAsr: hanafiAsr
            )
        } catch {
            // Only Muftiyat is region-locked; for it, retry with a worldwide method.
            guard case .muftyat = method.provider, method != .mwl else { throw error }
            return try await PrayerTimesService.shared.fetchYearPrayerTimes(
                year: year, latitude: latitude, longitude: longitude, method: .mwl, hanafiAsr: hanafiAsr
            )
        }
    }

    /// Prayer times for a specific calendar day, if available in the loaded year.
    func prayerDay(for date: Date) -> PrayerDay? {
        let calendar = Calendar.current
        return allDays.first { calendar.isDate($0.date, inSameDayAs: date) }
    }

    private func applyDays(_ days: [PrayerDay]) {
        allDays = days
        let calendar = Calendar.current
        let today = Date()
        if let found = days.first(where: { calendar.isDate($0.date, inSameDayAs: today) }) {
            todayPrayer = found
        }
        // Refresh prayer-time notifications whenever the schedule changes.
        NotificationManager.shared.reschedule(using: days)
        // Publish a snapshot for the home/lock-screen widgets.
        WidgetBridge.publish(days: days, locationName: LocationManager.shared.displayLocation)
    }

    // MARK: - Offline Cache

    private func cacheKey(year: Int, latitude: Double, longitude: Double, method: CalculationMethod, hanafiAsr: Bool) -> String {
        // Round coordinates to ~1km so small GPS jitter reuses the same cache.
        let lat = (latitude * 100).rounded() / 100
        let lon = (longitude * 100).rounded() / 100
        let asr = hanafiAsr ? "h" : "s"
        return "prayerCache_\(method.cacheToken)_\(asr)_\(year)_\(lat)_\(lon)"
    }

    private func loadCache(year: Int, latitude: Double, longitude: Double, method: CalculationMethod, hanafiAsr: Bool) -> [PrayerDay]? {
        let key = cacheKey(year: year, latitude: latitude, longitude: longitude, method: method, hanafiAsr: hanafiAsr)
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([PrayerDay].self, from: data)
        else { return nil }
        return decoded
    }

    private func saveCache(_ days: [PrayerDay], year: Int, latitude: Double, longitude: Double, method: CalculationMethod, hanafiAsr: Bool) {
        let key = cacheKey(year: year, latitude: latitude, longitude: longitude, method: method, hanafiAsr: hanafiAsr)
        if let encoded = try? JSONEncoder().encode(days) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
}
