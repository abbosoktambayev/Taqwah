import SwiftUI

struct PrayersView: View {

    // MARK: - State
    @StateObject private var tracker = PrayerTrackerManager.shared
    @StateObject private var prayerManager = PrayerTimesManager.shared
    @Environment(\.colorScheme) private var scheme
    @State private var showStats = false
    @State private var selectedDate = Date()

    private let prayerIcons: [String: String] = [
        "Fajr": "sun.and.horizon.fill",
        "Dhuhr": "sun.max.fill",
        "Asr": "sun.min.fill",
        "Maghrib": "sunset.fill",
        "Isha": "moon.stars.fill"
    ]

    private var isToday: Bool {
        Calendar.current.isDateInToday(selectedDate)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()
                    .foregroundColor(.primary)

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        headerSection
                        dateNavigator
                        progressCard

                        VStack(spacing: 16) {
                            ForEach(PrayerTrackerManager.allPrayers, id: \.self) { prayerName in
                                prayerRow(
                                    name: prayerName,
                                    time: timeForPrayer(prayerName),
                                    icon: prayerIcons[prayerName] ?? "circle"
                                )
                            }
                        }
                        .animation(.spring(response: 0.3), value: tracker.revision)
                    }
                }
            }
            .navigationTitle("Prayer Tracker")
            .navigationBarTitleDisplayMode(.large)
            .foregroundColor(.adaptiveText(scheme))
        }
        .sheet(isPresented: $showStats) {
            PrayerStatsView()
        }
    }

    // MARK: - Time from API

    private func selectedPrayerDay() -> PrayerDay? {
        if isToday {
            return prayerManager.todayPrayer ?? prayerManager.prayerDay(for: selectedDate)
        }
        return prayerManager.prayerDay(for: selectedDate)
    }

    private func timeForPrayer(_ name: String) -> String {
        selectedPrayerDay()?.displayTime(for: name) ?? "--:--"
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Track your daily prayers")
                    .foregroundColor(.secondaryText(scheme))
            }

            Spacer()

            Button {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                showStats = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)

                    Text("\(tracker.streak) days")
                        .bold()
                        .foregroundColor(.orange)

                    Image(systemName: "chevron.right")
                        .font(.caption2)
                        .foregroundColor(.orange.opacity(0.7))
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Color.streakBackground(scheme))
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .foregroundColor(.adaptiveText(scheme))
        .padding(.horizontal)
    }

    // MARK: - Date Navigator

    private var dateLabel: String {
        if isToday { return "Today" }
        if Calendar.current.isDateInYesterday(selectedDate) { return "Yesterday" }
        let f = DateFormatter()
        f.dateFormat = "EEEE, d MMM"
        return f.string(from: selectedDate)
    }

    private var dateNavigator: some View {
        HStack {
            Button {
                shiftDay(by: -1)
            } label: {
                Image(systemName: "chevron.left")
                    .font(.headline)
                    .foregroundColor(.adaptiveAccent(scheme))
                    .frame(width: 44, height: 36)
            }
            .buttonStyle(.plain)

            Spacer()

            VStack(spacing: 2) {
                Text(dateLabel)
                    .font(.headline)
                    .foregroundColor(.adaptiveText(scheme))
                if !isToday {
                    Text("Editing a past day")
                        .font(.caption2)
                        .foregroundColor(.secondaryText(scheme))
                }
            }

            Spacer()

            Button {
                shiftDay(by: 1)
            } label: {
                Image(systemName: "chevron.right")
                    .font(.headline)
                    .foregroundColor(isToday ? .secondaryText(scheme).opacity(0.4) : .adaptiveAccent(scheme))
                    .frame(width: 44, height: 36)
            }
            .buttonStyle(.plain)
            .disabled(isToday)
        }
        .padding(.horizontal)
    }

    private func shiftDay(by days: Int) {
        guard let newDate = Calendar.current.date(byAdding: .day, value: days, to: selectedDate) else { return }
        // Never navigate into the future.
        if days > 0 && newDate > Date() { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        withAnimation(.easeInOut(duration: 0.2)) {
            selectedDate = newDate
        }
    }

    // MARK: - Progress Card

    private var progressCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(isToday ? "Today's Progress" : "Progress")
                    .font(.headline)
                    .foregroundColor(.adaptiveText(scheme))

                Spacer()

                Text("\(tracker.completedCount(on: selectedDate))/5")
                    .bold()
                    .foregroundColor(.green)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.progressTrack(scheme))

                    Capsule()
                        .fill(Color.green)
                        .frame(width: geo.size.width * tracker.progress(on: selectedDate))
                        .animation(.easeInOut(duration: 0.35), value: tracker.revision)
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
        let type = tracker.completion(name, on: selectedDate)
        let isDone = type != nil

        return Menu {
            ForEach(PrayerCompletion.allCases) { option in
                Button {
                    tracker.mark(name, as: option, on: selectedDate)
                } label: {
                    Label(option.label, systemImage: option.icon)
                }
            }
            if isDone {
                Divider()
                Button(role: .destructive) {
                    tracker.unmark(name, on: selectedDate)
                } label: {
                    Label("Mark as not prayed", systemImage: "xmark.circle")
                }
            }
        } label: {
            HStack(spacing: 16) {
                ZStack {
                    if let type {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 48, height: 48)
                            .shadow(color: .green.opacity(0.4), radius: 10)

                        if let emoji = type.emoji {
                            Text(emoji)
                                .font(.system(size: 24))
                        } else {
                            Image(systemName: type.icon)
                                .font(.headline)
                                .foregroundColor(.white)
                        }
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

                    if let type {
                        Text("\(time) · \(type.label)")
                            .font(.subheadline)
                            .foregroundColor(.green)
                    } else {
                        Text(time)
                            .foregroundColor(.secondaryText(scheme))
                    }
                }

                Spacer()
            }
            .padding()
            .background(Color.cardBackground(scheme))
            .clipShape(RoundedRectangle(cornerRadius: 22))
            .overlay(
                RoundedRectangle(cornerRadius: 22)
                    .stroke(isDone ? Color.green.opacity(0.3) : Color.cardBorder(scheme), lineWidth: 1)
            )
            .scaleEffect(isDone ? 0.98 : 1.0)
            .animation(.spring(response: 0.25), value: isDone)
        }
        .buttonStyle(.plain)
        .padding(.horizontal)
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
