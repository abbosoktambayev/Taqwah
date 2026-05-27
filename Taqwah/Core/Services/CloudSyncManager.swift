import Foundation
import Combine

/// Syncs the app's small data (prayer tracker, athkar progress, settings) across
/// the user's devices via iCloud Key-Value storage — no login screen required.
///
/// Strategy:
/// - Dictionary stores (tracker, athkar) are **union-merged** to avoid data loss.
/// - Scalar settings take the cloud value when present (so a new device adopts them).
/// - Local UserDefaults changes are pushed to iCloud (debounced).
@MainActor
final class CloudSyncManager {

    static let shared = CloudSyncManager()

    private let store = NSUbiquitousKeyValueStore.default
    private var isApplyingRemote = false
    private var pushWorkItem: DispatchWorkItem?

    // Keys mirrored to iCloud.
    private let trackerKey = "prayerTracker_v2"
    private let athkarKey = "athkarProgress_data"
    private let stringKeys = ["selectedColorScheme", "calculationMethod"]
    private let intKeys = ["adjust_Fajr", "adjust_Sunrise", "adjust_Dhuhr",
                           "adjust_Asr", "adjust_Maghrib", "adjust_Isha"]
    private let boolKeys = ["adhan_fajr", "adhan_dhuhr", "adhan_asr",
                            "adhan_maghrib", "adhan_isha"]

    private init() {}

    // MARK: - Lifecycle

    func start() {
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

        store.synchronize()
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

        // Tell the in-memory managers to refresh from the updated store.
        PrayerTrackerManager.shared.reloadFromStore()
        AthkarProgressManager.shared.reloadFromStore()
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
}
