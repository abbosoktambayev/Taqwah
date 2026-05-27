import Foundation

// Mirror of the app's WidgetBridge payload. Kept in sync manually because the
// widget is a separate target and shares no source with the app.

struct WidgetSnapshot: Codable {
    var locationName: String
    var hijriDate: String
    var generatedAt: Date
    var upcoming: [WidgetEvent]
    var todayTimes: [WidgetTime]
}

struct WidgetEvent: Codable, Identifiable {
    let name: String
    let date: Date
    var id: String { "\(name)-\(date.timeIntervalSince1970)" }
}

struct WidgetTime: Codable, Identifiable {
    let name: String
    let time: String
    var id: String { name }
}

extension WidgetSnapshot {
    /// First upcoming marker strictly after the given date.
    func nextEvent(after date: Date) -> WidgetEvent? {
        upcoming.first { $0.date > date }
    }

    /// Sample data for previews and placeholders.
    static var sample: WidgetSnapshot {
        let now = Date()
        return WidgetSnapshot(
            locationName: "Astana, Kazakhstan",
            hijriDate: "10 Dhul Hijjah 1447",
            generatedAt: now,
            upcoming: [
                WidgetEvent(name: "Dhuhr", date: now.addingTimeInterval(60 * 73)),
                WidgetEvent(name: "Asr", date: now.addingTimeInterval(60 * 240)),
                WidgetEvent(name: "Maghrib", date: now.addingTimeInterval(60 * 470)),
            ],
            todayTimes: [
                WidgetTime(name: "Fajr", time: "05:12"),
                WidgetTime(name: "Dhuhr", time: "13:07"),
                WidgetTime(name: "Asr", time: "16:59"),
                WidgetTime(name: "Maghrib", time: "20:23"),
                WidgetTime(name: "Isha", time: "21:54"),
            ]
        )
    }
}

// MARK: - Shared store

enum WidgetStore {
    static let appGroup = "group.com.abbos.Taqwah"
    static let snapshotKey = "widgetSnapshot"

    static func load() -> WidgetSnapshot? {
        guard let data = UserDefaults(suiteName: appGroup)?.data(forKey: snapshotKey),
              let snapshot = try? JSONDecoder().decode(WidgetSnapshot.self, from: data)
        else { return nil }
        return snapshot
    }
}
