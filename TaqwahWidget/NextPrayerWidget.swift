import WidgetKit
import SwiftUI

struct NextPrayerWidget: Widget {
    let kind = "NextPrayerWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PrayerProvider()) { entry in
            NextPrayerView(entry: entry)
        }
        .configurationDisplayName("Next Prayer")
        .description("Countdown to your next prayer.")
        .supportedFamilies([
            .systemSmall, .systemMedium,
            .accessoryRectangular, .accessoryCircular, .accessoryInline
        ])
    }
}

// MARK: - View

struct NextPrayerView: View {
    var entry: PrayerEntry
    @Environment(\.widgetFamily) private var family

    private var next: WidgetEvent? {
        entry.snapshot?.nextEvent(after: entry.date)
    }

    var body: some View {
        content
            .containerBackground(for: .widget) {
                switch family {
                case .accessoryCircular, .accessoryRectangular, .accessoryInline:
                    Color.clear
                default:
                    WidgetStyle.backgroundGradient
                }
            }
            .widgetURL(URL(string: "taqwah://home"))
    }

    @ViewBuilder
    private var content: some View {
        switch family {
        case .accessoryInline:      inlineView
        case .accessoryCircular:    circularView
        case .accessoryRectangular: rectangularView
        case .systemMedium:         mediumView
        default:                    smallView
        }
    }

    // MARK: - System Small

    private var smallView: some View {
        VStack(alignment: .leading, spacing: 0) {
            Label("NEXT PRAYER", systemImage: "moon.stars.fill")
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(WidgetStyle.gold)
                .labelStyle(.titleAndIcon)

            Spacer(minLength: 4)

            if let next {
                Text(next.name)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.white)

                Text(next.date, style: .timer)
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundStyle(WidgetStyle.gold)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)

                Text("at \(timeString(next.date))")
                    .font(.system(size: 12))
                    .foregroundStyle(.white.opacity(0.7))
            } else {
                Text("Open Taqwah")
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.7))
            }

            Spacer(minLength: 0)
        }
    }

    // MARK: - System Medium

    private var mediumView: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 2) {
                Label("NEXT PRAYER", systemImage: "moon.stars.fill")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(WidgetStyle.gold)

                if let next {
                    Text(next.name)
                        .font(.system(size: 26, weight: .bold))
                        .foregroundStyle(.white)

                    Text(next.date, style: .timer)
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundStyle(WidgetStyle.gold)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)

                    Text("at \(timeString(next.date)) · \(entry.snapshot?.locationName ?? "")")
                        .font(.system(size: 11))
                        .foregroundStyle(.white.opacity(0.7))
                        .lineLimit(1)
                }
            }

            Spacer()

            upNextColumn
        }
    }

    private var upNextColumn: some View {
        let items = Array((entry.snapshot?.upcoming ?? [])
            .filter { $0.date > entry.date }
            .prefix(3))

        return VStack(alignment: .leading, spacing: 8) {
            ForEach(items) { ev in
                HStack(spacing: 8) {
                    Image(systemName: WidgetStyle.icon(for: ev.name))
                        .font(.system(size: 12))
                        .foregroundStyle(WidgetStyle.gold)
                        .frame(width: 16)
                    Text(ev.name)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.white.opacity(0.85))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    Spacer(minLength: 6)
                    Text(timeString(ev.date))
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                }
            }
        }
        .frame(width: 120)
    }

    // MARK: - Lock Screen

    private var inlineView: some View {
        if let next {
            Text("\(next.name) at \(timeString(next.date))")
        } else {
            Text("Taqwah")
        }
    }

    private var circularView: some View {
        ZStack {
            AccessoryWidgetBackground()
            VStack(spacing: 1) {
                Image(systemName: next.map { WidgetStyle.icon(for: $0.name) } ?? "moon.stars.fill")
                    .font(.system(size: 13, weight: .semibold))
                if let next {
                    Text(next.date, style: .timer)
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                        .frame(width: 44)
                }
            }
        }
    }

    private var rectangularView: some View {
        VStack(alignment: .leading, spacing: 2) {
            if let next {
                Label(next.name, systemImage: WidgetStyle.icon(for: next.name))
                    .font(.system(size: 14, weight: .bold))
                Text(next.date, style: .timer)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                Text("at \(timeString(next.date))")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            } else {
                Text("Open Taqwah")
            }
        }
        .widgetAccentable()
    }

    // MARK: - Helpers

    private func timeString(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f.string(from: date)
    }
}
