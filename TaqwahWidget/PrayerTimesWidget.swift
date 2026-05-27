import WidgetKit
import SwiftUI

struct PrayerTimesWidget: Widget {
    let kind = "PrayerTimesWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PrayerProvider()) { entry in
            PrayerTimesView(entry: entry).widgetBackground()
        }
        .configurationDisplayName("Today's Prayers")
        .description("All five prayer times for today.")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

// MARK: - View

struct PrayerTimesView: View {
    var entry: PrayerEntry
    @Environment(\.widgetFamily) private var family

    private var nextName: String? {
        entry.snapshot?.nextEvent(after: entry.date)?.name
    }

    var body: some View {
        Group {
            if family == .systemLarge {
                largeView
            } else {
                mediumView
            }
        }
        .widgetURL(URL(string: "taqwah://prayers"))
    }

    // MARK: - Medium (row of 5)

    private var mediumView: some View {
        VStack(alignment: .leading, spacing: 10) {
            header

            HStack(spacing: 0) {
                ForEach(entry.snapshot?.todayTimes ?? []) { item in
                    VStack(spacing: 6) {
                        Image(systemName: WidgetStyle.icon(for: item.name))
                            .font(.system(size: 16))
                            .foregroundStyle(isNext(item.name) ? WidgetStyle.gold : .white.opacity(0.8))

                        Text(item.name)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(.white.opacity(0.7))

                        Text(item.time)
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundStyle(isNext(item.name) ? WidgetStyle.gold : .white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(isNext(item.name) ? WidgetStyle.gold.opacity(0.15) : .clear)
                    )
                }
            }
        }
    }

    // MARK: - Large (column of 5)

    private var largeView: some View {
        VStack(alignment: .leading, spacing: 12) {
            header

            VStack(spacing: 8) {
                ForEach(entry.snapshot?.todayTimes ?? []) { item in
                    HStack(spacing: 14) {
                        Image(systemName: WidgetStyle.icon(for: item.name))
                            .font(.system(size: 18))
                            .foregroundStyle(isNext(item.name) ? WidgetStyle.gold : .white.opacity(0.85))
                            .frame(width: 26)

                        Text(item.name)
                            .font(.system(size: 17, weight: .medium))
                            .foregroundStyle(.white)

                        Spacer()

                        Text(item.time)
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                            .foregroundStyle(isNext(item.name) ? WidgetStyle.gold : .white.opacity(0.9))
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(isNext(item.name)
                                  ? WidgetStyle.gold.opacity(0.15)
                                  : Color.white.opacity(0.06))
                    )
                }
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Today's Prayers")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.white)
                if let snapshot = entry.snapshot {
                    Text(snapshot.hijriDate)
                        .font(.system(size: 11))
                        .foregroundStyle(.white.opacity(0.6))
                }
            }
            Spacer()
            if let loc = entry.snapshot?.locationName {
                Label(loc, systemImage: "location.fill")
                    .font(.system(size: 10))
                    .foregroundStyle(WidgetStyle.gold)
                    .lineLimit(1)
            }
        }
    }

    private func isNext(_ name: String) -> Bool {
        name == nextName
    }
}
