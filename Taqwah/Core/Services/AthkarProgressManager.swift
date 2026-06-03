import Foundation
import SwiftUI
import Combine

struct AthkarLastOpenRecord: Codable, Equatable {
    let dateKey: String
    let index: Int
    let updatedAt: TimeInterval
}

struct AthkarCategoryProgressSnapshot: Equatable, Identifiable {
    let category: AthkarCategory
    let completedCount: Int
    let totalCount: Int
    let resumeIndex: Int
    let streak: Int

    var id: AthkarCategory { category }
    var isComplete: Bool { totalCount > 0 && completedCount >= totalCount }
    var fraction: Double {
        guard totalCount > 0 else { return 0 }
        return Double(completedCount) / Double(totalCount)
    }
}

/// Persists athkar progress by day and category, plus the user's last reading
/// position. Today's views read only today's key, while older days power streaks.
@MainActor
final class AthkarProgressManager: ObservableObject {

    static let shared = AthkarProgressManager()
    static let dailyCoreCategories: [AthkarCategory] = [.morning, .evening, .sleep]

    /// Key format: "yyyy-MM-dd|<CategoryRawValue>" → sorted completed indices.
    @Published private var store: [String: [Int]] = [:]
    @Published private var lastOpen: [String: AthkarLastOpenRecord] = [:]

    private let storageKey = "athkarProgress_data"
    private let lastOpenStorageKey = "athkarLastOpen_v1"
    private let historyDaysToKeep = 120
    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()

    private init() {
        load()
        pruneHistory()
    }

    // MARK: - Keys

    private func dateKey(for date: Date) -> String {
        dateFormatter.string(from: date)
    }

    private func key(for category: AthkarCategory, on date: Date = Date()) -> String {
        "\(dateKey(for: date))|\(category.rawValue)"
    }

    // MARK: - Public API

    /// Completed dhikr indices for a category today.
    func completed(for category: AthkarCategory, on date: Date = Date()) -> Set<Int> {
        Set(store[key(for: category, on: date)] ?? [])
    }

    /// Replace the completed set for a category today.
    func setCompleted(_ indices: Set<Int>, for category: AthkarCategory, on date: Date = Date()) {
        let clamped = indices.filter { $0 >= 0 && $0 < category.athkar.count }
        objectWillChange.send()
        store[key(for: category, on: date)] = Array(clamped).sorted()
        save()
    }

    /// A two-way binding suitable for passing into detail views.
    func binding(for category: AthkarCategory) -> Binding<Set<Int>> {
        Binding(
            get: { [weak self] in self?.completed(for: category) ?? [] },
            set: { [weak self] newValue in self?.setCompleted(newValue, for: category) }
        )
    }

    func recordOpened(_ category: AthkarCategory, index: Int, on date: Date = Date()) {
        guard !category.athkar.isEmpty else { return }
        let clamped = min(max(index, 0), category.athkar.count - 1)
        let record = AthkarLastOpenRecord(
            dateKey: dateKey(for: date),
            index: clamped,
            updatedAt: Date().timeIntervalSince1970
        )
        guard lastOpen[category.rawValue] != record else { return }
        objectWillChange.send()
        lastOpen[category.rawValue] = record
        saveLastOpen()
    }

    func status(for category: AthkarCategory, on date: Date = Date()) -> AthkarCategoryProgressSnapshot {
        AthkarCategoryProgressSnapshot(
            category: category,
            completedCount: completed(for: category, on: date).count,
            totalCount: category.athkar.count,
            resumeIndex: resumeIndex(for: category, on: date),
            streak: streak(for: category, endingAt: date)
        )
    }

    func dailyCoreCompletedCount(on date: Date = Date()) -> Int {
        Self.dailyCoreCategories.filter { isComplete($0, on: date) }.count
    }

    func isComplete(_ category: AthkarCategory, on date: Date = Date()) -> Bool {
        let total = category.athkar.count
        return total > 0 && completed(for: category, on: date).count >= total
    }

    func resumeIndex(for category: AthkarCategory, on date: Date = Date()) -> Int {
        let total = category.athkar.count
        guard total > 0 else { return 0 }

        let completed = completed(for: category, on: date)
        if completed.count >= total {
            return min(max(lastOpen[category.rawValue]?.index ?? total - 1, 0), total - 1)
        }

        if let record = lastOpen[category.rawValue], record.dateKey == dateKey(for: date) {
            let clamped = min(max(record.index, 0), total - 1)
            if !completed.contains(clamped) {
                return clamped
            }
            if let next = nextIncompleteIndex(for: category, on: date, after: clamped) {
                return next
            }
        }

        return nextIncompleteIndex(for: category, on: date) ?? 0
    }

    func nextIncompleteIndex(for category: AthkarCategory, on date: Date = Date(), after index: Int? = nil) -> Int? {
        let total = category.athkar.count
        guard total > 0 else { return nil }
        let completed = completed(for: category, on: date)
        guard completed.count < total else { return nil }

        let start = index.map { min(max($0 + 1, 0), total) } ?? 0
        if start < total {
            for i in start..<total where !completed.contains(i) {
                return i
            }
        }
        if start > 0 {
            for i in 0..<start where !completed.contains(i) {
                return i
            }
        }
        return nil
    }

    /// Current streak is forgiving during the day: if today's set is not done yet,
    /// the visible streak remains the consecutive run ending yesterday.
    func streak(for category: AthkarCategory, endingAt date: Date = Date(), calendar: Calendar = .current) -> Int {
        var cursor = isComplete(category, on: date)
            ? date
            : (calendar.date(byAdding: .day, value: -1, to: date) ?? date)

        var count = 0
        while isComplete(category, on: cursor) {
            count += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: cursor) else { break }
            cursor = previous
        }
        return count
    }

    // MARK: - Persistence

    private func load() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([String: [Int]].self, from: data) {
            store = decoded
        } else {
            store = [:]
        }
        if let data = UserDefaults.standard.data(forKey: lastOpenStorageKey),
           let decoded = try? JSONDecoder().decode([String: AthkarLastOpenRecord].self, from: data) {
            lastOpen = decoded
        } else {
            lastOpen = [:]
        }
    }

    /// Re-read from persistent storage (e.g. after an iCloud merge).
    func reloadFromStore() {
        load()
        pruneHistory()
    }

    private func save() {
        if let encoded = try? JSONEncoder().encode(store) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }

    private func saveLastOpen() {
        if let encoded = try? JSONEncoder().encode(lastOpen) {
            UserDefaults.standard.set(encoded, forKey: lastOpenStorageKey)
        }
    }

    /// Keep enough history for streaks without letting UserDefaults grow forever.
    private func pruneHistory() {
        guard let cutoffDate = Calendar.current.date(byAdding: .day, value: -historyDaysToKeep, to: Date()) else {
            return
        }
        let cutoff = dateKey(for: cutoffDate)
        let filtered = store.filter { entry in
            guard let day = entry.key.split(separator: "|").first else { return true }
            return String(day) >= cutoff
        }
        if filtered.count != store.count {
            store = filtered
            save()
        }

        let filteredLastOpen = lastOpen.filter { $0.value.dateKey >= cutoff }
        if filteredLastOpen.count != lastOpen.count {
            lastOpen = filteredLastOpen
            saveLastOpen()
        }
    }

    func resetForTesting() {
        store = [:]
        lastOpen = [:]
        UserDefaults.standard.removeObject(forKey: storageKey)
        UserDefaults.standard.removeObject(forKey: lastOpenStorageKey)
    }
}
