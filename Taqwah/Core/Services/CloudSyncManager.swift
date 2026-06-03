import Foundation
import Combine

/// Syncs the app's small data (prayer tracker, athkar progress, settings) across
/// the user's devices via iCloud Key-Value storage — no login screen required.
///
/// Requires the iCloud key-value-store entitlement AND the user being signed into
/// iCloud. When either is missing (e.g. a free developer account, or signed-out
/// device), `NSUbiquitousKeyValueStore.synchronize()` returns `false`; in that
/// case sync stays OFF and the app runs fully on-device — nothing is claimed or
/// broken.
///
/// Strategy when available:
/// - Dictionary stores (tracker, athkar) are **union-merged** to avoid data loss.
/// - Scalar settings take the cloud value when present (so a new device adopts them).
/// - Local UserDefaults changes are pushed to iCloud (debounced).
@MainActor
final class CloudSyncManager {

    /// Whether the iCloud KV store is actually usable (entitlement + signed in).
    private(set) var isAvailable = false

    static let shared = CloudSyncManager()

    private let store = NSUbiquitousKeyValueStore.default
    private var didStart = false
    private var isApplyingRemote = false
    private var pushWorkItem: DispatchWorkItem?

    // Keys mirrored to iCloud.
    private let trackerKey = "prayerTracker_v2"
    private let athkarKey = "athkarProgress_data"
    private let athkarLastOpenKey = "athkarLastOpen_v1"
    private let favoritesKey = "athkarFavorites_v1"
    private let stringKeys = ["selectedColorScheme", "calculationMethod"]
    private let intKeys = ["adjust_Fajr", "adjust_Sunrise", "adjust_Dhuhr",
                           "adjust_Asr", "adjust_Maghrib", "adjust_Isha",
                           "reminderMinutesBefore"]
    private let boolKeys = ["adhan_fajr", "adhan_dhuhr", "adhan_asr",
                            "adhan_maghrib", "adhan_isha",
                            "hanafiAsr", "jummahReminder"]

    private init() {}

    // MARK: - Lifecycle

    func start() {
        guard !didStart else { return }
        didStart = true

        // `synchronize()` returns false when the iCloud KV entitlement is absent
        // or the user isn't signed into iCloud. Don't register observers or claim
        // to sync in that case — the app works fully on-device.
        isAvailable = store.synchronize()
        guard isAvailable else { return }

        NotificationCenter.default.addObserver(
            self, selector: #selector(cloudChangedExternally(_:)),
            name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: store
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(localDefaultsChanged),
            name: UserDefaults.didChangeNotification,
            object: nil
        )

        pullFromCloud()   // adopt cloud data on launch (merged)
        pushToCloud()     // ensure cloud has our latest too
    }

    // MARK: - Pull (cloud → local)

    @objc private func cloudChangedExternally(_ note: Notification) {
        Task { @MainActor in pullFromCloud() }
    }

    private func pullFromCloud() {
        isApplyingRemote = true
        defer { isApplyingRemote = false }

        let defaults = UserDefaults.standard

        // Scalars: cloud wins when present.
        for key in stringKeys {
            if let value = store.string(forKey: key) {
                defaults.set(value, forKey: key)
            }
        }
        for key in intKeys where store.object(forKey: key) != nil {
            defaults.set(Int(store.longLong(forKey: key)), forKey: key)
        }
        for key in boolKeys where store.object(forKey: key) != nil {
            defaults.set(store.bool(forKey: key), forKey: key)
        }

        // Dictionary stores: union-merge.
        mergeTracker(defaults: defaults)
        mergeAthkar(defaults: defaults)
        mergeAthkarLastOpen(defaults: defaults)
        mergeFavorites(defaults: defaults)

        // Tell the in-memory managers to refresh from the updated store.
        PrayerTrackerManager.shared.reloadFromStore()
        AthkarProgressManager.shared.reloadFromStore()
        AthkarFavoritesManager.shared.reloadFromStore()
        SettingsManager.shared.reloadFromStore()
    }

    private func mergeTracker(defaults: UserDefaults) {
        let local = decodeTracker(defaults.data(forKey: trackerKey))
        let cloud = decodeTracker(store.data(forKey: trackerKey))
        guard !cloud.isEmpty else { return }

        var merged = local
        for (day, prayers) in cloud {
            merged[day, default: [:]].merge(prayers) { localVal, _ in localVal }
        }
        if let data = try? JSONEncoder().encode(merged) {
            defaults.set(data, forKey: trackerKey)
            store.set(data, forKey: trackerKey)
        }
    }

    private func mergeAthkar(defaults: UserDefaults) {
        let local = decodeAthkar(defaults.data(forKey: athkarKey))
        let cloud = decodeAthkar(store.data(forKey: athkarKey))
        guard !cloud.isEmpty else { return }

        var merged = local
        for (key, indices) in cloud {
            let union = Set(merged[key] ?? []).union(indices)
            merged[key] = union.sorted()
        }
        if let data = try? JSONEncoder().encode(merged) {
            defaults.set(data, forKey: athkarKey)
            store.set(data, forKey: athkarKey)
        }
    }

    private func mergeAthkarLastOpen(defaults: UserDefaults) {
        let local = decodeAthkarLastOpen(defaults.data(forKey: athkarLastOpenKey))
        let cloud = decodeAthkarLastOpen(store.data(forKey: athkarLastOpenKey))
        guard !cloud.isEmpty else { return }

        var merged = local
        for (category, cloudRecord) in cloud {
            if let localRecord = merged[category], localRecord.updatedAt >= cloudRecord.updatedAt {
                continue
            }
            merged[category] = cloudRecord
        }
        if let data = try? JSONEncoder().encode(merged) {
            defaults.set(data, forKey: athkarLastOpenKey)
            store.set(data, forKey: athkarLastOpenKey)
        }
    }

    private func mergeFavorites(defaults: UserDefaults) {
        let local = Set(defaults.stringArray(forKey: favoritesKey) ?? [])
        let cloud = Set(store.array(forKey: favoritesKey) as? [String] ?? [])
        guard !cloud.isEmpty else { return }

        let merged = local.union(cloud).sorted()
        defaults.set(merged, forKey: favoritesKey)
        store.set(merged, forKey: favoritesKey)
    }

    // MARK: - Push (local → cloud)

    @objc private func localDefaultsChanged() {
        guard !isApplyingRemote else { return }
        // Debounce: coalesce bursts of changes into a single push.
        pushWorkItem?.cancel()
        let work = DispatchWorkItem { [weak self] in
            Task { @MainActor in self?.pushToCloud() }
        }
        pushWorkItem = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: work)
    }

    private func pushToCloud() {
        let defaults = UserDefaults.standard

        for key in stringKeys {
            if let value = defaults.string(forKey: key) { store.set(value, forKey: key) }
        }
        for key in intKeys where defaults.object(forKey: key) != nil {
            store.set(Int64(defaults.integer(forKey: key)), forKey: key)
        }
        for key in boolKeys where defaults.object(forKey: key) != nil {
            store.set(defaults.bool(forKey: key), forKey: key)
        }
        if let data = defaults.data(forKey: trackerKey) { store.set(data, forKey: trackerKey) }
        if let data = defaults.data(forKey: athkarKey) { store.set(data, forKey: athkarKey) }
        if let data = defaults.data(forKey: athkarLastOpenKey) { store.set(data, forKey: athkarLastOpenKey) }
        if let favorites = defaults.stringArray(forKey: favoritesKey) { store.set(favorites, forKey: favoritesKey) }

        store.synchronize()
    }

    // MARK: - Decoding helpers

    private func decodeTracker(_ data: Data?) -> [String: [String: String]] {
        guard let data, let v = try? JSONDecoder().decode([String: [String: String]].self, from: data)
        else { return [:] }
        return v
    }

    private func decodeAthkar(_ data: Data?) -> [String: [Int]] {
        guard let data, let v = try? JSONDecoder().decode([String: [Int]].self, from: data)
        else { return [:] }
        return v
    }

    private func decodeAthkarLastOpen(_ data: Data?) -> [String: AthkarLastOpenRecord] {
        guard let data, let v = try? JSONDecoder().decode([String: AthkarLastOpenRecord].self, from: data)
        else { return [:] }
        return v
    }
}
