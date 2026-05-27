import Foundation
import SwiftUI
import Combine

// MARK: - Completion Type

/// How a prayer was performed.
enum PrayerCompletion: String, Codable, CaseIterable, Identifiable {
    case alone
    case congregation
    case mosque

    var id: String { rawValue }

    var label: String {
        switch self {
        case .alone:        return "Alone"
        case .congregation: return "In Congregation"
        case .mosque:       return "In Mosque"
        }
    }

    var shortLabel: String {
        switch self {
        case .alone:        return "Alone"
        case .congregation: return "Jamaah"
        case .mosque:       return "Mosque"
        }
    }

    /// SF Symbol used in menus (where emoji isn't ideal).
    var icon: String {
        switch self {
        case .alone:        return "person.fill"
        case .congregation: return "person.2.fill"
        case .mosque:       return "building.2.fill"
        }
    }

    /// Emoji shown in the colored badge (SF Symbols has no mosque glyph).
    var emoji: String? {
        switch self {
        case .mosque: return "🕌"
        default:      return nil
        }
    }
}

// MARK: - Tracker

@MainActor
final class PrayerTrackerManager: ObservableObject {

    static let shared = PrayerTrackerManager()

    /// Bump whenever stored data changes, so views observing a single date refresh.
    @Published private(set) var revision: Int = 0
    @Published var streak: Int = 0

    static let allPrayers = ["Fajr", "Dhuhr", "Asr", "Maghrib", "Isha"]

    /// "yyyy-MM-dd" → [prayerName: PrayerCompletion.rawValue]
    private var data: [String: [String: String]] = [:]

    private let storageKey = "prayerTracker_v2"
    private let legacyKey = "prayerTracker_data"
    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()

    private init() {
        load()
        migrateLegacyIfNeeded()
        calculateStreak()
    }

    // MARK: - Keys

    private func key(for date: Date) -> String {
        dateFormatter.string(from: date)
    }

    // MARK: - Queries (date-aware)

    /// How a prayer was performed on a given date, or nil if not marked.
    func completion(_ name: String, on date: Date) -> PrayerCompletion? {
        guard let raw = data[key(for: date)]?[name] else { return nil }
        return PrayerCompletion(rawValue: raw)
    }

    func isCompleted(_ name: String, on date: Date) -> Bool {
        data[key(for: date)]?[name] != nil
    }

    /// All completion records for a date.
    func records(on date: Date) -> [String: PrayerCompletion] {
        let raw = data[key(for: date)] ?? [:]
        return raw.reduce(into: [:]) { result, pair in
            if let type = PrayerCompletion(rawValue: pair.value) {
                result[pair.key] = type
            }
        }
    }

    func completedCount(on date: Date) -> Int {
        data[key(for: date)]?.count ?? 0
    }

    func progress(on date: Date) -> CGFloat {
        CGFloat(completedCount(on: date)) / CGFloat(Self.allPrayers.count)
    }

    // MARK: - Mutations

    /// Mark a prayer as performed (with a type) on a date.
    func mark(_ name: String, as type: PrayerCompletion, on date: Date) {
        let k = key(for: date)
        var day = data[k] ?? [:]
        day[name] = type.rawValue
        data[k] = day
        persist()
        calculateStreak()
        revision += 1
    }

    /// Remove a prayer's completion for a date.
    func unmark(_ name: String, on date: Date) {
        let k = key(for: date)
        guard var day = data[k] else { return }
        day[name] = nil
        if day.isEmpty { data[k] = nil } else { data[k] = day }
        persist()
        calculateStreak()
        revision += 1
    }

    // MARK: - Today conveniences (used across the UI)

    var todayCompleted: Set<String> {
        Set(data[key(for: Date())]?.keys ?? [:].keys)
    }

    func isCompleted(_ name: String) -> Bool {
        isCompleted(name, on: Date())
    }

    var completedCount: Int { completedCount(on: Date()) }

    var progress: CGFloat { progress(on: Date()) }

    // MARK: - Persistence

    private func load() {
        guard let raw = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([String: [String: String]].self, from: raw)
        else { return }
        data = decoded
    }

    /// Re-read from persistent storage (e.g. after an iCloud merge).
    func reloadFromStore() {
        load()
        calculateStreak()
        revision += 1
    }

    private func persist() {
        if let encoded = try? JSONEncoder().encode(data) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }

    /// One-time migration from the old `[date: [names]]` format. Old entries
    /// have no recorded type, so they default to `.alone`.
    private func migrateLegacyIfNeeded() {
        guard data.isEmpty,
              let raw = UserDefaults.standard.data(forKey: legacyKey),
              let legacy = try? JSONDecoder().decode([String: [String]].self, from: raw)
        else { return }

        for (day, names) in legacy {
            var record: [String: String] = [:]
            for name in names { record[name] = PrayerCompletion.alone.rawValue }
            if !record.isEmpty { data[day] = record }
        }
        persist()
    }

    // MARK: - Streak

    private func calculateStreak() {
        let calendar = Calendar.current
        var count = 0
        var checkDate = Date()

        let todayDone = data[key(for: checkDate)]?.count == Self.allPrayers.count
        if !todayDone {
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: checkDate) else {
                streak = 0
                return
            }
            checkDate = yesterday
        }

        while data[key(for: checkDate)]?.count == Self.allPrayers.count {
            count += 1
            guard let prev = calendar.date(byAdding: .day, value: -1, to: checkDate) else { break }
            checkDate = prev
        }

        streak = count
    }

    // MARK: - Statistics

    func completedPrayers(for date: Date) -> Set<String> {
        Set(data[key(for: date)]?.keys ?? [:].keys)
    }

    func completedCount(for date: Date) -> Int {
        completedCount(on: date)
    }

    var bestStreak: Int {
        let calendar = Calendar.current
        let completeDates = data
            .filter { $0.value.count == Self.allPrayers.count }
            .keys
            .compactMap { dateFormatter.date(from: $0) }
            .map { calendar.startOfDay(for: $0) }
            .sorted()

        guard !completeDates.isEmpty else { return 0 }

        var best = 1
        var run = 1
        for i in 1..<completeDates.count {
            if let expected = calendar.date(byAdding: .day, value: 1, to: completeDates[i - 1]),
               calendar.isDate(expected, inSameDayAs: completeDates[i]) {
                run += 1
            } else {
                run = 1
            }
            best = max(best, run)
        }
        return max(best, streak)
    }

    var totalPrayersLogged: Int {
        data.values.reduce(0) { $0 + $1.count }
    }

    var perfectDays: Int {
        data.values.filter { $0.count == Self.allPrayers.count }.count
    }

    func completionRate(lastDays n: Int) -> Double {
        guard n > 0 else { return 0 }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var done = 0
        for offset in 0..<n {
            if let day = calendar.date(byAdding: .day, value: -offset, to: today) {
                done += completedCount(on: day)
            }
        }
        return Double(done) / Double(n * Self.allPrayers.count)
    }

    /// How many times a specific prayer has been completed across all history.
    func totalCount(for prayer: String) -> Int {
        data.values.reduce(0) { $0 + ($1[prayer] != nil ? 1 : 0) }
    }

    /// Count of all completed prayers by performance type across history.
    func typeBreakdown() -> [PrayerCompletion: Int] {
        var result: [PrayerCompletion: Int] = [:]
        for day in data.values {
            for raw in day.values {
                if let type = PrayerCompletion(rawValue: raw) {
                    result[type, default: 0] += 1
                }
            }
        }
        return result
    }

    func totalCount(forType type: PrayerCompletion) -> Int {
        typeBreakdown()[type] ?? 0
    }
}
