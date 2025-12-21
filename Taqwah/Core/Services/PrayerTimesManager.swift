import Foundation
import Combine

@MainActor
final class PrayerTimesManager: ObservableObject {
    static let shared = PrayerTimesManager()
    
    @Published var todayPrayer: PrayerDay?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var hasLoaded = false  // Чтобы загрузить только один раз
    
    private init() {}
    
    func loadIfNeeded() {
        guard !hasLoaded else { return }
        
        hasLoaded = true
        isLoading = true
        errorMessage = nil
        
        PrayerTimesService.shared.fetchYearPrayerTimes(
            year: Calendar.current.component(.year, from: Date()),
            latitude: 51.133333,
            longitude: 71.433333
        ) { [weak self] result in
            Task { @MainActor in
                self?.isLoading = false
                
                switch result {
                case .success(let days):
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
