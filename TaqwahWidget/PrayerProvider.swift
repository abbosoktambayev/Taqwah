import WidgetKit
import SwiftUI

struct PrayerEntry: TimelineEntry {
    let date: Date
    let snapshot: WidgetSnapshot?
}

struct PrayerProvider: TimelineProvider {

    func placeholder(in context: Context) -> PrayerEntry {
        PrayerEntry(date: Date(), snapshot: .sample)
    }

    func getSnapshot(in context: Context, completion: @escaping (PrayerEntry) -> Void) {
        let snap = context.isPreview ? .sample : (WidgetStore.load() ?? .sample)
        completion(PrayerEntry(date: Date(), snapshot: snap))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PrayerEntry>) -> Void) {
        let snapshot = WidgetStore.load()
        let now = Date()

        // One entry now, plus one at each upcoming prayer boundary so the
        // highlighted "next prayer" advances automatically. The countdown
        // itself uses Text(date, style: .timer), which ticks on its own.
        var dates: [Date] = [now]
        if let snapshot {
            let boundaries = snapshot.upcoming
                .map(\.date)
                .filter { $0 > now }
                .prefix(12)
            dates.append(contentsOf: boundaries)
        }

        let entries = dates.map { PrayerEntry(date: $0, snapshot: snapshot) }
        completion(Timeline(entries: entries, policy: .atEnd))
    }
}
