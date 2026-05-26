import SwiftUI

struct PrayersView: View {

    // MARK: - State
    @StateObject private var tracker = PrayerTrackerManager.shared
    @StateObject private var prayerManager = PrayerTimesManager.shared
    @Namespace private var animation
    @Environment(\.colorScheme) private var scheme

    private let prayerIcons: [String: String] = [
        "Fajr": "sun.and.horizon.fill",
        "Dhuhr": "sun.max.fill",
        "Asr": "sun.min.fill",
        "Maghrib": "sunset.fill",
        "Isha": "moon.stars.fill"
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()
                    .foregroundColor(.primary)

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        headerSection
                        progressCard

                        VStack(spacing: 16) {
                            ForEach(PrayerTrackerManager.allPrayers, id: \.self) { prayerName in
                                prayerRow(
                                    name: prayerName,
                                    time: timeForPrayer(prayerName),
                                    icon: prayerIcons[prayerName] ?? "circle"
                                )
                                .animation(.spring(response: 0.3), value: tracker.todayCompleted)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Prayer Tracker")
            .navigationBarTitleDisplayMode(.large)
            .foregroundColor(.adaptiveText(scheme))
        }
    }

    // MARK: - Time from API

    private func timeForPrayer(_ name: String) -> String {
        guard let prayer = prayerManager.todayPrayer else { return "--:--" }
        switch name {
        case "Fajr": return prayer.fajr
        case "Dhuhr": return prayer.dhuhr
        case "Asr": return prayer.asr
        case "Maghrib": return prayer.maghrib
        case "Isha": return prayer.isha
        default: return "--:--"
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Track your daily prayers")
                    .foregroundColor(.secondaryText(scheme))
            }

            Spacer()

            HStack(spacing: 6) {
                Image(systemName: "flame.fill")
                    .foregroundColor(.orange)

                Text("\(tracker.streak) days")
                    .bold()
                    .foregroundColor(.orange)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(Color.streakBackground(scheme))
            .clipShape(Capsule())
        }
        .foregroundColor(.adaptiveText(scheme))
        .padding(.horizontal)
    }

    // MARK: - Progress Card

    private var progressCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Today's Progress")
                    .font(.headline)
                    .foregroundColor(.adaptiveText(scheme))

                Spacer()

                Text("\(tracker.completedCount)/5")
                    .bold()
                    .foregroundColor(.green)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.progressTrack(scheme))

                    Capsule()
                        .fill(Color.green)
                        .frame(width: geo.size.width * tracker.progress)
                        .animation(.easeInOut(duration: 0.35), value: tracker.completedCount)
                }
            }
            .frame(height: 10)
        }
        .foregroundColor(.adaptiveText(scheme))
        .padding()
        .background(Color.cardBackground(scheme))
        .clipShape(RoundedRectangle(cornerRadius: 25))
        .overlay(
            RoundedRectangle(cornerRadius: 25)
                .stroke(Color.cardBorder(scheme), lineWidth: 1)
        )
        .padding(.horizontal)
    }

    // MARK: - Prayer Row

    private func prayerRow(name: String, time: String, icon: String) -> some View {
        let isDone = tracker.isCompleted(name)

        return Button {
            lightHaptic()
            tracker.togglePrayer(name)
        } label: {
            HStack(spacing: 16) {
                ZStack {
                    if isDone {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 48, height: 48)
                            .shadow(color: .green.opacity(0.4), radius: 10)

                        Image(systemName: "checkmark")
                            .font(.headline)
                            .foregroundColor(.white)
                            .matchedGeometryEffect(id: name, in: animation)
                    } else {
                        Circle()
                            .strokeBorder(Color.uncheckedBorder(scheme), lineWidth: 2)
                            .frame(width: 48, height: 48)
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(name)
                        .font(.headline)
                        .foregroundColor(.adaptiveText(scheme))

                    Text(time)
                        .foregroundColor(.secondaryText(scheme))
                }

                Spacer()
            }
            .padding()
            .background(Color.cardBackground(scheme))
            .clipShape(RoundedRectangle(cornerRadius: 22))
            .overlay(
                RoundedRectangle(cornerRadius: 22)
                    .stroke(Color.cardBorder(scheme), lineWidth: 1)
            )
            .scaleEffect(isDone ? 0.97 : 1.0)
            .animation(.spring(response: 0.25), value: isDone)
        }
        .buttonStyle(.plain)
        .padding(.horizontal)
    }

    // MARK: - Haptic

    private func lightHaptic() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
}

#Preview("Dark") {
    PrayersView()
        .preferredColorScheme(.dark)
}

#Preview("Light") {
    PrayersView()
        .preferredColorScheme(.light)
}
