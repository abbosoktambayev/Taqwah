import SwiftUI

struct HomeView: View {
    @StateObject private var manager = PrayerTimesManager.shared
    @StateObject private var location = LocationManager.shared
    @Environment(\.colorScheme) private var scheme

    // States for Next Prayer
    @State private var nextPrayerName: String = "Loading..."
    @State private var remainingTime: String = ""
    @State private var nextPrayerTime: String = ""
    @State private var nextIsSunrise: Bool = false
    @State private var flowKind: TodayFlowKind = .daytime
    @State private var countdownTimer: DispatchSourceTimer?
    @StateObject private var tracker = PrayerTrackerManager.shared
    @StateObject private var athkarProgress = AthkarProgressManager.shared

    // Identifier for tracking changes
    private var prayerTimesIdentifier: String {
        guard let prayer = manager.todayPrayer else { return "" }
        return "\(prayer.fajr)|\(prayer.dhuhr)|\(prayer.asr)|\(prayer.maghrib)|\(prayer.isha)"
    }

    // Dynamic day of week
    private var currentDayName: String {
        let formatter = DateFormatter()
        formatter.locale = LocalizationManager.shared.locale
        formatter.dateFormat = "EEEE"
        return formatter.string(from: Date())
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()
                    .foregroundColor(.primary)

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 26) {
                        headerSection
                        todayFlowCard
                        nextPrayerSection
                        todaysPrayerSection
                    }
                    .padding(.top, 8)
                }
                .safeAreaPadding(.bottom, 96)
            }
            .navigationTitle("Prayer Times")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .foregroundColor(.adaptiveText(scheme))
        }
        .task {
            location.requestLocationIfNeeded()
            manager.loadIfNeeded()

            if let prayer = manager.todayPrayer {
                updateNextPrayer(prayer: prayer)
                updateFlow(prayer: prayer)
                startCountdownTimer(prayer: prayer)
            }
        }
        .onChange(of: prayerTimesIdentifier) { _, _ in
            if let prayer = manager.todayPrayer {
                updateNextPrayer(prayer: prayer)
                updateFlow(prayer: prayer)
                startCountdownTimer(prayer: prayer)
            }
        }
        // Reload prayer times when location changes
        .onChange(of: location.latitude) { _, _ in
            manager.reload(latitude: location.latitude, longitude: location.longitude)
        }
        .onDisappear {
            stopCountdownTimer()
        }
    }

    // MARK: - Timer Logic

    private func startCountdownTimer(prayer: PrayerDay) {
        countdownTimer?.cancel()

        let timer = DispatchSource.makeTimerSource(queue: DispatchQueue.main)
        timer.schedule(deadline: .now(), repeating: 1.0)
        timer.setEventHandler {
            updateNextPrayer(prayer: prayer)
            updateFlow(prayer: prayer)
        }
        timer.resume()
        countdownTimer = timer
    }

    private func stopCountdownTimer() {
        countdownTimer?.cancel()
        countdownTimer = nil
    }

    // MARK: - UI Sections

    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("As-salamu alaykum")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.adaptiveText(scheme))

                HStack(spacing: 6) {
                    Image(systemName: "location.fill")
                        .foregroundColor(.adaptiveAccent(scheme))
                        .shadow(
                            color: .accentShadow(scheme),
                            radius: 12,
                            y: 6
                        )
                        .font(.caption)

                    Text(location.displayLocation)
                        .foregroundColor(.secondaryText(scheme))
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(currentDayName)
                    .foregroundColor(.secondaryText(scheme))

                Text(currentHijriDateString())
                    .font(.caption)
                    .foregroundColor(.secondaryText(scheme))
            }
        }
        .padding(.horizontal)
    }

    // MARK: - Today Worship Flow

    private struct FlowPresentation {
        let icon: String
        let title: LocalizedStringKey
        let subtitle: LocalizedStringKey
        let athkar: AthkarCategory?
        let opensPrayers: Bool
    }

    private func updateFlow(prayer: PrayerDay) {
        let weekday = Calendar.current.component(.weekday, from: Date())
        let newKind = TodayFlow.kind(for: prayer, now: Date(), weekday: weekday)
        if newKind != flowKind { flowKind = newKind }
    }

    private func flowPresentation(_ kind: TodayFlowKind) -> FlowPresentation {
        switch kind {
        case .beforeFajr:
            return .init(icon: "moon.stars.fill", title: "Before Fajr",
                         subtitle: "A quiet time for tahajjud and rest.",
                         athkar: nil, opensPrayers: false)
        case .afterPrayer:
            return .init(icon: "hands.and.sparkles.fill", title: "After the prayer",
                         subtitle: "Recite the after-prayer remembrances.",
                         athkar: .afterPrayer, opensPrayers: false)
        case .jummah:
            return .init(icon: "book.closed.fill", title: "Jummah Mubarak",
                         subtitle: "Read Surah Al-Kahf before Jummah.",
                         athkar: nil, opensPrayers: false)
        case .morningAthkar:
            return .init(icon: "sun.and.horizon.fill", title: "Morning Athkar",
                         subtitle: "Begin your day with the morning remembrances.",
                         athkar: .morning, opensPrayers: false)
        case .eveningAthkar:
            return .init(icon: "sunset.fill", title: "Evening Athkar",
                         subtitle: "Wind down with the evening remembrances.",
                         athkar: .evening, opensPrayers: false)
        case .beforeSleep:
            return .init(icon: "bed.double.fill", title: "Before Sleep",
                         subtitle: "End your day with the bedtime remembrances.",
                         athkar: .sleep, opensPrayers: false)
        case .daytime:
            return .init(icon: "checkmark.circle.fill", title: "Today's Prayers",
                         subtitle: "Keep your prayer tracker up to date.",
                         athkar: nil, opensPrayers: true)
        }
    }

    @ViewBuilder
    private var todayFlowCard: some View {
        if manager.todayPrayer != nil {
            let p = flowPresentation(flowKind)
            Group {
                if let cat = p.athkar {
                    NavigationLink { AthkarListView(category: cat) } label: { flowCardBody(p) }
                        .buttonStyle(.plain)
                } else if p.opensPrayers {
                    Button { AppRouter.shared.selectedTab = .prayers } label: { flowCardBody(p) }
                        .buttonStyle(.plain)
                } else {
                    flowCardBody(p)
                }
            }
            .padding(.horizontal)
            .animation(.easeInOut(duration: 0.35), value: flowKind)
        }
    }

    private func flowCardBody(_ p: FlowPresentation) -> some View {
        let interactive = p.athkar != nil || p.opensPrayers
        return HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.brandDim)
                    .frame(width: 52, height: 52)
                Image(systemName: p.icon)
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(.mutedEmerald)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text("TODAY")
                    .font(.mono(10)).tracking(0.8)
                    .foregroundColor(.ter)
                Text(p.title)
                    .font(.headline)
                    .foregroundColor(.adaptiveText(scheme))
                Text(p.subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondaryText(scheme))
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 8)

            if interactive {
                Image(systemName: "chevron.right")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.ter)
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 28).fill(Color.cardBackground(scheme)))
        .overlay(RoundedRectangle(cornerRadius: 28).stroke(Color.cardBorder(scheme), lineWidth: 1))
    }

    private var nextPrayerSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(nextIsSunrise ? "Up Next" : "Next Prayer")
                .font(.title2)
                .bold()
                .foregroundColor(.adaptiveText(scheme))

            VStack(spacing: 8) {
                Text(nextPrayerName)
                    .font(.title2)
                    .bold()
                    .foregroundColor(.adaptiveText(scheme))

                Text(remainingTime)
                    .font(.brandDisplay(52))
                    .foregroundColor(.prayerAccent)
                    .shadow(
                        color: .accentShadow(scheme),
                        radius: 10,
                        y: 5
                    )

                Text("at \(nextPrayerTime)")
                    .foregroundColor(.secondaryText(scheme))
                    .padding(.top, 6)

                // Sunrise is the end of the Fajr window, not a salah — clarify it.
                if nextIsSunrise {
                    Text("Fajr ends at sunrise")
                        .font(.caption)
                        .foregroundColor(.ter)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 36)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 28)
                        .fill(Color.cardBackground(scheme))

                    RoundedRectangle(cornerRadius: 28)
                        .stroke(Color.cardBorder(scheme), lineWidth: 1)
                }
            )
            .shadow(
                color: Color.black.opacity(scheme == .light ? 0.06 : 0.18),
                radius: 16,
                y: 8
            )
            .clipShape(RoundedRectangle(cornerRadius: 28))
        }
        .padding(.horizontal)
    }

    private var todaysPrayerSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Today's Prayers")
                .font(.title3)
                .bold()
                .foregroundColor(.adaptiveText(scheme))

            if manager.isLoading {
                ProgressView()
                    .tint(.adaptiveText(scheme))
                    .frame(maxWidth: .infinity)
            } else if let prayer = manager.todayPrayer {
                VStack(spacing: 14) {
                    prayerRow(icon: "sunrise", name: "Fajr", time: prayer.displayTime(for: "Fajr"))
                    prayerRow(icon: "sun.max.fill", name: "Dhuhr", time: prayer.displayTime(for: "Dhuhr"))
                    prayerRow(icon: "sun.max", name: "Asr", time: prayer.displayTime(for: "Asr"))
                    prayerRow(icon: "sunset", name: "Maghrib", time: prayer.displayTime(for: "Maghrib"))
                    prayerRow(icon: "moon.stars", name: "Isha", time: prayer.displayTime(for: "Isha"))
                }
                .padding(.vertical, 18)
                .background(
                    Color.glassFill(scheme)
                )
                .clipShape(RoundedRectangle(cornerRadius: 28))
            } else if let error = manager.errorMessage {
                Text(error)
                    .foregroundColor(.dangerRed)
                    .padding()
            } else {
                Text("Prayer times will load soon, inshaAllah.")
                    .foregroundColor(.secondaryText(scheme))
                    .italic()
                    .padding()
            }
        }
        .padding(.horizontal)
    }

    private func prayerRow(icon: String, name: String, time: String) -> some View {
        HStack {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(.adaptiveAccent(scheme))
                    .font(.system(size: 20))

                Text(name)
                    .foregroundColor(.adaptiveText(scheme))
                    .fontWeight(.medium)
            }

            Spacer()

            Text(time)
                .foregroundColor(.secondaryText(scheme))
                .fontWeight(.medium)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(Color.cardBackground(scheme))
                .overlay(
                    RoundedRectangle(cornerRadius: 28)
                        .stroke(Color.cardBorder(scheme), lineWidth: 1)
                )
        )
        .padding(.horizontal, 6)
    }

    // MARK: - Logic

    private func updateNextPrayer(prayer: PrayerDay) {
        let now = Date()
        let calendar = Calendar.current
        let events = prayer.timelineEvents()

        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        timeFormatter.locale = Locale(identifier: "en_US_POSIX")

        var nextDate = Date.distantFuture
        var nextName = "Fajr"
        var nextTimeStr = prayer.displayTime(for: "Fajr")

        // Find the next upcoming prayer today.
        for event in events where event.date > now && event.date < nextDate {
            nextDate = event.date
            nextName = event.name
            nextTimeStr = timeFormatter.string(from: event.date)
        }

        // If all of today's prayers have passed — roll over to tomorrow's Fajr.
        if nextDate == Date.distantFuture, let fajr = prayer.event(for: "Fajr"),
           let tomorrow = calendar.date(byAdding: .day, value: 1, to: fajr.date) {
            nextDate = tomorrow
            nextName = "Fajr"
            nextTimeStr = timeFormatter.string(from: fajr.date)
        }

        let components = calendar.dateComponents([.hour, .minute, .second], from: now, to: nextDate)
        let hours = components.hour ?? 0
        let minutes = components.minute ?? 0
        let seconds = components.second ?? 0

        if hours > 0 {
            remainingTime = "\(hours)h \(minutes)m \(seconds)s"
        } else if minutes > 0 {
            remainingTime = "\(minutes)m \(seconds)s"
        } else {
            remainingTime = "\(seconds)s"
        }

        nextPrayerName = nextName
        nextPrayerTime = nextTimeStr
        nextIsSunrise = (nextName == "Sunrise")
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            HomeView()
                .preferredColorScheme(.dark)
                .previewDisplayName("Dark Theme")

            HomeView()
                .preferredColorScheme(.light)
                .previewDisplayName("Light Theme")
        }
    }
}
