import Foundation
import UserNotifications
import Combine

@MainActor
final class NotificationManager: ObservableObject {

    static let shared = NotificationManager()

    @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined

    private let center = UNUserNotificationCenter.current()

    /// iOS allows at most 64 pending local notifications; stay safely below.
    private let maxPending = 60
    private let identifierPrefix = "prayer."

    private init() {}

    // MARK: - Authorization

    /// Re-read the current system authorization status.
    func refreshAuthorizationStatus() async {
        let settings = await center.notificationSettings()
        authorizationStatus = settings.authorizationStatus
    }

    /// Ask the user for notification permission. Returns whether it was granted.
    @discardableResult
    func requestAuthorization() async -> Bool {
        let granted = (try? await center.requestAuthorization(options: [.alert, .sound, .badge])) ?? false
        await refreshAuthorizationStatus()
        if granted {
            reschedule(using: PrayerTimesManager.shared.allDays)
        }
        return granted
    }

    // MARK: - Per-prayer toggles & options

    /// Names of prayers the user has enabled notifications for (key `adhan_<lowercased>`).
    private func enabledPrayers() -> Set<String> {
        let defaults = UserDefaults.standard
        return Set(PrayerDay.salahNames.filter { name in
            // Default to ON if the user never touched the toggle.
            defaults.object(forKey: "adhan_\(name.lowercased())") as? Bool ?? true
        })
    }

    /// Minutes before a prayer to send an early reminder (0 = off).
    private var reminderMinutes: Int {
        UserDefaults.standard.integer(forKey: "reminderMinutesBefore")
    }

    /// Whether the special Jummah (Friday) reminder is enabled.
    private var jummahEnabled: Bool {
        UserDefaults.standard.object(forKey: "jummahReminder") as? Bool ?? true
    }

    // MARK: - Scheduling

    /// Rebuild all pending prayer notifications from the given prayer days.
    /// Fire-and-forget wrapper around the async implementation.
    func reschedule(using days: [PrayerDay]) {
        Task { await rescheduleAsync(using: days) }
    }

    private func rescheduleAsync(using days: [PrayerDay]) async {
        // 1. Clear our previously scheduled prayer notifications (leave any others alone).
        let pending = await center.pendingNotificationRequests()
        let staleIDs = pending.map(\.identifier).filter { $0.hasPrefix(identifierPrefix) }
        if !staleIDs.isEmpty {
            center.removePendingNotificationRequests(withIdentifiers: staleIDs)
        }

        guard authorizationStatus == .authorized || authorizationStatus == .provisional else { return }

        let enabled = enabledPrayers()
        guard !enabled.isEmpty, !days.isEmpty else { return }

        // 2. Schedule upcoming prayers up to the system limit.
        let now = Date()
        let calendar = Calendar.current
        let reminder = reminderMinutes
        var scheduled = 0

        for day in days.sorted(by: { $0.date < $1.date }) {
            for event in day.salahEvents() where enabled.contains(event.name) {
                guard scheduled < maxPending else { return }

                let isFriday = calendar.component(.weekday, from: event.date) == 6
                let isJummah = isFriday && event.name == "Dhuhr" && jummahEnabled

                // Early reminder before the prayer.
                if reminder > 0, scheduled < maxPending,
                   let remindAt = calendar.date(byAdding: .minute, value: -reminder, to: event.date),
                   remindAt > now {
                    schedule(
                        at: remindAt,
                        title: isJummah ? "Jummah soon 🕌" : "\(event.name) in \(reminder) min",
                        body: isJummah
                            ? "Jummah is in \(reminder) minutes. Prepare for the Friday prayer."
                            : "\(event.name) prayer is in \(reminder) minutes.",
                        suffix: "r"
                    )
                    scheduled += 1
                }

                // Main notification at prayer time.
                if event.date > now, scheduled < maxPending {
                    schedule(
                        at: event.date,
                        title: isJummah ? "Jummah Mubarak 🕌" : "\(event.name) Prayer",
                        body: isJummah
                            ? "It's time for Jummah. Don't forget to read Surah Al-Kahf."
                            : "It's time for \(event.name). الله أكبر",
                        suffix: "m"
                    )
                    scheduled += 1
                }
            }
        }
    }

    private func schedule(at date: Date, title: String, body: String, suffix: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let comps = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute], from: date
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)

        let id = "\(identifierPrefix)\(Int(date.timeIntervalSince1970)).\(suffix)"
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        center.add(request)
    }

    /// Cancel every scheduled prayer notification.
    func cancelAll() {
        Task {
            let pending = await center.pendingNotificationRequests()
            let ids = pending.map(\.identifier).filter { $0.hasPrefix(identifierPrefix) }
            center.removePendingNotificationRequests(withIdentifiers: ids)
        }
    }
}
