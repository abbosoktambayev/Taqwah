import Foundation
import WidgetKit

// MARK: - Shared snapshot (mirrored in the widget target)

/// Lightweight payload the app publishes to the shared App Group for widgets.
struct WidgetSnapshot: Codable {
    var locationName: String
    var hijriDate: String
    var generatedAt: Date
    var upcoming: [WidgetEvent]   // next ~2 days of markers (adjusted), incl. Sunrise
    var todayTimes: [WidgetTime]  // today's 5 prayers as "HH:mm"
}

struct WidgetEvent: Codable {
    let name: String
    let date: Date
}

struct WidgetTime: Codable {
    let name: String
    let time: String
}

// MARK: - Bridge

enum WidgetBridge {
    static let appGroup = "group.com.abbos.Taqwah"
    static let snapshotKey = "widgetSnapshot"

    /// Build a snapshot from prayer data and hand it to the widgets.
    static func publish(days: [PrayerDay], locationName: String) {
        guard !days.isEmpty else { return }

        let now = Date()
        let calendar = Calendar.current
        let sorted = days.sorted { $0.date < $1.date }

        // Upcoming markers (with adjustments + Sunrise) for the next couple of days.
        var upcoming: [WidgetEvent] = []
        for day in sorted {
            for ev in day.timelineEvents() where ev.date > now.addingTimeInterval(-60) {
                upcoming.append(WidgetEvent(name: ev.name, date: ev.date))
            }
            if upcoming.count >= 18 { break }
        }

        // Today's five prayers for the list widget.
        let today = sorted.first { calendar.isDate($0.date, inSameDayAs: now) }
        let todayTimes: [WidgetTime] = today.map { day in
            PrayerDay.salahNames.map { WidgetTime(name: $0, time: day.displayTime(for: $0)) }
        } ?? []

        let snapshot = WidgetSnapshot(
            locationName: locationName,
            hijriDate: currentHijriDateString(),
            generatedAt: now,
            upcoming: upcoming,
            todayTimes: todayTimes
        )

        guard let defaults = UserDefaults(suiteName: appGroup),
              let data = try? JSONEncoder().encode(snapshot) else { return }
        defaults.set(data, forKey: snapshotKey)

        WidgetCenter.shared.reloadAllTimelines()
    }
}
