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

    private init() {}

    // MARK: - Public API

    /// Load prayer times using current location from LocationManager
    func loadIfNeeded() {
        guard !hasLoaded else { return }
        let location = LocationManager.shared
        load(latitude: location.latitude, longitude: location.longitude)
    }

    /// Force reload with new coordinates (e.g. when location updates)
    func reload(latitude: Double, longitude: Double) {
        hasLoaded = false
        load(latitude: latitude, longitude: longitude)
    }

    // MARK: - Private

    private func load(latitude: Double, longitude: Double) {
        guard !hasLoaded else { return }

        hasLoaded = true
        isLoading = true
        errorMessage = nil

        PrayerTimesService.shared.fetchYearPrayerTimes(
            year: Calendar.current.component(.year, from: Date()),
            latitude: latitude,
            longitude: longitude
        ) { [weak self] result in
            Task { @MainActor in
                self?.isLoading = false

                switch result {
                case .success(let days):
                    self?.allDays = days
                    let calendar = Calendar.current
                    let today = Date()

                    self?.todayPrayer = days.first { day in
                        calendar.isDate(day.date, inSameDayAs: today)
                    }

                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
