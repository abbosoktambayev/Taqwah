import Foundation
import SwiftUI
import Combine

/// Persists which athkar the user has completed today, per category.
/// Progress resets automatically each day (athkar are daily acts of worship).
@MainActor
final class AthkarProgressManager: ObservableObject {

    static let shared = AthkarProgressManager()

    /// Key format: "yyyy-MM-dd|<CategoryRawValue>" → sorted completed indices.
    @Published private var store: [String: [Int]] = [:]

    private let storageKey = "athkarProgress_data"
    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()

    private init() {
        load()
        pruneOldDays()
    }

    // MARK: - Keys

    private var todayKey: String { dateFormatter.string(from: Date()) }

    private func key(for category: AthkarCategory) -> String {
        "\(todayKey)|\(category.rawValue)"
    }

    // MARK: - Public API

    /// Completed dhikr indices for a category today.
    func completed(for category: AthkarCategory) -> Set<Int> {
        Set(store[key(for: category)] ?? [])
    }

    /// Replace the completed set for a category today.
    func setCompleted(_ indices: Set<Int>, for category: AthkarCategory) {
        store[key(for: category)] = Array(indices).sorted()
        save()
    }

    /// A two-way binding suitable for passing into detail views.
    func binding(for category: AthkarCategory) -> Binding<Set<Int>> {
        Binding(
            get: { [weak self] in self?.completed(for: category) ?? [] },
            set: { [weak self] newValue in self?.setCompleted(newValue, for: category) }
        )
    }

    // MARK: - Persistence

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([String: [Int]].self, from: data)
        else { return }
        store = decoded
    }

    /// Re-read from persistent storage (e.g. after an iCloud merge).
    func reloadFromStore() {
        load()
        pruneOldDays()
    }

    private func save() {
        if let encoded = try? JSONEncoder().encode(store) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }

    /// Drop entries from previous days so progress effectively resets daily.
    private func pruneOldDays() {
        let today = todayKey
        let filtered = store.filter { $0.key.hasPrefix(today) }
        if filtered.count != store.count {
            store = filtered
            save()
        }
    }
}
