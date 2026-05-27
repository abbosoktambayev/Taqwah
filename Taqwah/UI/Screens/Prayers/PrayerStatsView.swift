import SwiftUI

struct PrayerStatsView: View {
    @Environment(\.colorScheme) private var scheme
    @Environment(\.dismiss) private var dismiss
    @StateObject private var tracker = PrayerTrackerManager.shared

    private let prayerIcons: [String: String] = [
        "Fajr": "sunrise.fill",
        "Dhuhr": "sun.max.fill",
        "Asr": "sun.haze.fill",
        "Maghrib": "sunset.fill",
        "Isha": "moon.stars.fill"
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        streakHeader
                        statGrid
                        completionSection
                        howYouPrayedSection
                        heatmapSection
                        perPrayerSection
                        Spacer(minLength: 24)
                    }
                    .padding(.top, 8)
                }
            }
            .navigationTitle("Statistics")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(.adaptiveAccent(scheme))
                }
            }
            .foregroundColor(.adaptiveText(scheme))
        }
    }

    // MARK: - Streak Header

    private var streakHeader: some View {
        HStack(spacing: 16) {
            streakCard(
                value: "\(tracker.streak)",
                label: "Current Streak",
                icon: "flame.fill",
                tint: .orange
            )
            streakCard(
                value: "\(tracker.bestStreak)",
                label: "Best Streak",
                icon: "trophy.fill",
                tint: .yellow
            )
        }
        .padding(.horizontal)
    }

    private func streakCard(value: String, label: String, icon: String, tint: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(tint)

            Text(value)
                .font(.system(size: 34, weight: .bold))
                .foregroundColor(.adaptiveText(scheme))

            Text(LocalizedStringKey(label))
                .font(.caption)
                .foregroundColor(.secondaryText(scheme))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 22)
        .background(Color.cardBackground(scheme))
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.cardBorder(scheme), lineWidth: 1)
        )
    }

    // MARK: - Stat Grid

    private var statGrid: some View {
        HStack(spacing: 16) {
            smallStat(value: "\(tracker.perfectDays)", label: "Perfect Days", icon: "checkmark.seal.fill")
            smallStat(value: "\(tracker.totalPrayersLogged)", label: "Total Prayers", icon: "hands.and.sparkles.fill")
        }
        .padding(.horizontal)
    }

    private func smallStat(value: String, label: String, icon: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.adaptiveAccent(scheme))

            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.title3.weight(.bold))
                    .foregroundColor(.adaptiveText(scheme))
                Text(LocalizedStringKey(label))
                    .font(.caption)
                    .foregroundColor(.secondaryText(scheme))
            }
            Spacer()
        }
        .padding()
        .background(Color.cardBackground(scheme))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.cardBorder(scheme), lineWidth: 1)
        )
    }

    // MARK: - Completion Section

    private var completionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Completion Rate")
                .font(.headline)
                .foregroundColor(.adaptiveText(scheme))

            completionBar(label: "Last 7 days", rate: tracker.completionRate(lastDays: 7))
            completionBar(label: "Last 30 days", rate: tracker.completionRate(lastDays: 30))
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.cardBackground(scheme))
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.cardBorder(scheme), lineWidth: 1)
        )
        .padding(.horizontal)
    }

    private func completionBar(label: String, rate: Double) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(LocalizedStringKey(label))
                    .font(.subheadline)
                    .foregroundColor(.secondaryText(scheme))
                Spacer()
                Text("\(Int(rate * 100))%")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.green)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.progressTrack(scheme))
                    Capsule()
                        .fill(Color.green)
                        .frame(width: geo.size.width * CGFloat(rate))
                }
            }
            .frame(height: 8)
        }
    }

    // MARK: - How You Prayed (by type)

    private var howYouPrayedSection: some View {
        let breakdown = tracker.typeBreakdown()
        let total = max(breakdown.values.reduce(0, +), 1)

        return VStack(alignment: .leading, spacing: 14) {
            Text("How You Prayed")
                .font(.headline)
                .foregroundColor(.adaptiveText(scheme))

            ForEach(PrayerCompletion.allCases) { type in
                let count = breakdown[type] ?? 0
                let fraction = Double(count) / Double(total)

                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 10) {
                        Group {
                            if let emoji = type.emoji {
                                Text(emoji).font(.system(size: 15))
                            } else {
                                Image(systemName: type.icon)
                                    .font(.system(size: 15))
                                    .foregroundColor(.adaptiveAccent(scheme))
                            }
                        }
                        .frame(width: 22)

                        Text(type.label)
                            .font(.subheadline)
                            .foregroundColor(.adaptiveText(scheme))

                        Spacer()

                        Text("\(count)")
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(.secondaryText(scheme))
                    }

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.progressTrack(scheme))
                            Capsule()
                                .fill(Color.adaptiveAccent(scheme))
                                .frame(width: geo.size.width * CGFloat(fraction))
                        }
                    }
                    .frame(height: 6)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.cardBackground(scheme))
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.cardBorder(scheme), lineWidth: 1)
        )
        .padding(.horizontal)
    }

    // MARK: - Heatmap (last 28 days)

    private var heatmapSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Last 4 Weeks")
                .font(.headline)
                .foregroundColor(.adaptiveText(scheme))

            let days = last28Days()
            let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 7)

            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(days, id: \.self) { date in
                    let count = tracker.completedCount(for: date)
                    RoundedRectangle(cornerRadius: 6)
                        .fill(heatColor(count))
                        .aspectRatio(1, contentMode: .fit)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.cardBorder(scheme), lineWidth: 0.5)
                        )
                }
            }

            HStack(spacing: 8) {
                Text("Less")
                    .font(.caption2)
                    .foregroundColor(.secondaryText(scheme))
                ForEach(0...5, id: \.self) { level in
                    RoundedRectangle(cornerRadius: 3)
                        .fill(heatColor(level))
                        .frame(width: 14, height: 14)
                }
                Text("More")
                    .font(.caption2)
                    .foregroundColor(.secondaryText(scheme))
            }
            .padding(.top, 4)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.cardBackground(scheme))
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.cardBorder(scheme), lineWidth: 1)
        )
        .padding(.horizontal)
    }

    private func last28Days() -> [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return (0..<28).reversed().compactMap {
            calendar.date(byAdding: .day, value: -$0, to: today)
        }
    }

    private func heatColor(_ count: Int) -> Color {
        guard count > 0 else { return Color.progressTrack(scheme) }
        return Color.green.opacity(0.25 + 0.15 * Double(min(count, 5)))
    }

    // MARK: - Per-prayer Section

    private var perPrayerSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("By Prayer")
                .font(.headline)
                .foregroundColor(.adaptiveText(scheme))

            ForEach(PrayerTrackerManager.allPrayers, id: \.self) { prayer in
                HStack(spacing: 12) {
                    Image(systemName: prayerIcons[prayer] ?? "circle")
                        .font(.system(size: 16))
                        .foregroundColor(.adaptiveAccent(scheme))
                        .frame(width: 24)

                    Text(prayer)
                        .font(.subheadline)
                        .foregroundColor(.adaptiveText(scheme))

                    Spacer()

                    Text("\(tracker.totalCount(for: prayer))")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.secondaryText(scheme))
                }
                .padding(.vertical, 4)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.cardBackground(scheme))
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.cardBorder(scheme), lineWidth: 1)
        )
        .padding(.horizontal)
    }
}

#Preview("Dark") {
    PrayerStatsView().preferredColorScheme(.dark)
}

#Preview("Light") {
    PrayerStatsView().preferredColorScheme(.light)
}
