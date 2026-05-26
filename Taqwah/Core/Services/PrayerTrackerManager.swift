import Foundation
import SwiftUI
import Combine

@MainActor
final class PrayerTrackerManager: ObservableObject {

    static let shared = PrayerTrackerManager()

    // MARK: - Published

    /// Set of prayer names completed today (e.g. ["Fajr", "Dhuhr"])
    @Published var todayCompleted: Set<String> = []

    /// Current streak (consecutive days with all 5 prayers)
    @Published var streak: Int = 0

    // MARK: - Constants

    static let allPrayers = ["Fajr", "Dhuhr", "Asr", "Maghrib", "Isha"]
    private let storageKey = "prayerTracker_data"
    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()

    // MARK: - Init

    private init() {
        loadToday()
        calculateStreak()
    }

    // MARK: - Public API

    /// Toggle a prayer as completed/uncompleted for today
    func togglePrayer(_ name: String) {
        if todayCompleted.contains(name) {
            todayCompleted.remove(name)
        } else {
            todayCompleted.insert(name)
        }
        saveToday()
        calculateStreak()
    }

    /// Check if a prayer is completed today
    func isCompleted(_ name: String) -> Bool {
        todayCompleted.contains(name)
    }

    /// Number of prayers completed today
    var completedCount: Int {
        todayCompleted.count
    }

    /// Progress value (0.0 - 1.0)
    var progress: CGFloat {
        CGFloat(completedCount) / CGFloat(Self.allPrayers.count)
    }

    // MARK: - Persistence

    /// Data format: [String: [String]] — "yyyy-MM-dd": ["Fajr", "Dhuhr", ...]
    private var allData: [String: [String]] {
        get {
            guard let data = UserDefaults.standard.data(forKey: storageKey),
                  let decoded = try? JSONDecoder().decode([String: [String]].self, from: data)
            else { return [:] }
            return decoded
        }
        set {
            if let encoded = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.set(encoded, forKey: storageKey)
            }
        }
    }

    private var todayKey: String {
        dateFormatter.string(from: Date())
    }

    private func loadToday() {
        let saved = allData[todayKey] ?? []
        todayCompleted = Set(saved)
    }

    private func saveToday() {
        var data = allData
        data[todayKey] = Array(todayCompleted)
        allData = data
    }

    // MARK: - Streak Calculation

    private func calculateStreak() {
        let calendar = Calendar.current
        let data = allData
        var count = 0
        var checkDate = Date()

        // If today is not complete yet, start checking from yesterday
        let todayPrayers = data[dateFormatter.string(from: checkDate)] ?? []
        if Set(todayPrayers) != Set(Self.allPrayers) {
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: checkDate) else {
                streak = 0
                return
            }
            checkDate = yesterday
        }

        // Count consecutive days with all 5 prayers
        while true {
            let key = dateFormatter.string(from: checkDate)
            let prayers = data[key] ?? []

            if Set(prayers) == Set(Self.allPrayers) {
                count += 1
                guard let previousDay = calendar.date(byAdding: .day, value: -1, to: checkDate) else { break }
                checkDate = previousDay
            } else {
                break
            }
        }

        // If today is fully complete, include today in streak
        if Set(todayPrayers) == Set(Self.allPrayers) {
            // Already counted
        }

        streak = count
    }

    /// Get completed prayers for a specific date
    func completedPrayers(for date: Date) -> Set<String> {
        let key = dateFormatter.string(from: date)
        return Set(allData[key] ?? [])
    }
}
