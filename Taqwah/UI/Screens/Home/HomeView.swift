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
                        nowPrayerCard
                        prayerTimelineSection
                        contextualActionCard
                        trackerSummaryCard
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

    // MARK: - Prayer Rhythm

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
    private var nowPrayerCard: some View {
        if manager.isLoading {
            rhythmSurface {
                VStack(alignment: .leading, spacing: 14) {
                    Text("NOW")
                        .font(.mono(10))
                        .tracking(0.8)
                        .foregroundColor(.ter)

                    HStack(spacing: 12) {
                        ProgressView()
                            .tint(.adaptiveAccent(scheme))
                        Text("Prayer times will load soon, inshaAllah.")
                            .font(.subheadline)
                            .foregroundColor(.secondaryText(scheme))
                    }
                }
            }
            .padding(.horizontal)
        } else if manager.todayPrayer != nil {
            let p = flowPresentation(flowKind)
            rhythmSurface {
                VStack(alignment: .leading, spacing: 22) {
                    HStack(alignment: .top, spacing: 16) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("NOW")
                                .font(.mono(10))
                                .tracking(0.8)
                                .foregroundColor(.ter)

                            Text(p.title)
                                .font(.title2.weight(.bold))
                                .foregroundColor(.adaptiveText(scheme))

                            Text(p.subtitle)
                                .font(.subheadline)
                                .foregroundColor(.secondaryText(scheme))
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        Spacer(minLength: 8)

                        ZStack {
                            Circle()
                                .fill(Color.goldDim)
                                .frame(width: 54, height: 54)
                            Image(systemName: p.icon)
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundColor(.prayerAccent)
                        }
                    }

                    Rectangle()
                        .fill(Color.cardBorder(scheme))
                        .frame(height: 1)

                    VStack(alignment: .leading, spacing: 8) {
                        Text(nextIsSunrise ? "Up Next" : "Next Prayer")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(.ter)

                        HStack(alignment: .firstTextBaseline) {
                            Text(nextPrayerName)
                                .font(.title3.weight(.semibold))
                                .foregroundColor(.adaptiveText(scheme))

                            Spacer()

                            Text("at \(nextPrayerTime)")
                                .font(.subheadline)
                                .foregroundColor(.secondaryText(scheme))
                        }

                        Text(remainingTime)
                            .font(.brandDisplay(58))
                            .foregroundColor(.prayerAccent)
                            .lineLimit(1)
                            .minimumScaleFactor(0.72)
                            .shadow(color: .accentShadow(scheme), radius: 10, y: 5)

                        if nextIsSunrise {
                            Text("Fajr ends at sunrise")
                                .font(.caption)
                                .foregroundColor(.ter)
                        }
                    }
                }
            }
            .padding(.horizontal)
            .animation(.easeInOut(duration: 0.35), value: flowKind)
        } else {
            rhythmSurface {
                Text("Prayer times will load soon, inshaAllah.")
                    .font(.subheadline)
                    .foregroundColor(.secondaryText(scheme))
            }
            .padding(.horizontal)
        }
    }

    private func rhythmSurface<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(22)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 28).fill(Color.cardBackground(scheme)))
            .overlay(RoundedRectangle(cornerRadius: 28).stroke(Color.cardBorder(scheme), lineWidth: 1))
            .shadow(color: Color.black.opacity(scheme == .light ? 0.06 : 0.18), radius: 16, y: 8)
    }

    @ViewBuilder
    private var prayerTimelineSection: some View {
        if let prayer = manager.todayPrayer {
            let events = prayer.salahEvents()
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Prayer Rhythm")
                        .font(.headline)
                        .foregroundColor(.adaptiveText(scheme))

                    Spacer()

                    Text("Today")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.adaptiveAccent(scheme))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.brandDim)
                        .clipShape(Capsule())
                }

                timelineBar(events: events)
                timelineLabels(events: events)
            }
            .padding(18)
            .background(Color.cardBackground(scheme))
            .clipShape(RoundedRectangle(cornerRadius: 28))
            .overlay(
                RoundedRectangle(cornerRadius: 28)
                    .stroke(Color.cardBorder(scheme), lineWidth: 1)
            )
            .padding(.horizontal)
        }
    }

    private func timelineBar(events: [PrayerEvent]) -> some View {
        GeometryReader { geo in
            let width = max(geo.size.width - 10, 1)
            let progress = timelineProgress(events: events)

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.progressTrack(scheme))
                    .frame(height: 6)
                    .position(x: geo.size.width / 2, y: 12)

                Capsule()
                    .fill(Color.prayerAccent)
                    .frame(width: width * progress, height: 6)
                    .position(x: 5 + (width * progress / 2), y: 12)
                    .animation(.easeInOut(duration: 0.35), value: progress)

                ForEach(Array(events.enumerated()), id: \.element.name) { index, event in
                    Circle()
                        .fill(timelineNodeColor(event))
                        .frame(width: 13, height: 13)
                        .overlay(
                            Circle()
                                .stroke(Color.cardBackground(scheme), lineWidth: 3)
                        )
                        .position(x: 5 + width * eventPosition(index: index, count: events.count), y: 12)
                }

                Circle()
                    .fill(Color.prayerAccent)
                    .frame(width: 17, height: 17)
                    .overlay(
                        Circle()
                            .stroke(Color.cardBackground(scheme), lineWidth: 3)
                    )
                    .shadow(color: .accentShadow(scheme), radius: 8, y: 3)
                    .position(x: 5 + width * progress, y: 12)
            }
        }
        .frame(height: 24)
    }

    private func timelineLabels(events: [PrayerEvent]) -> some View {
        let now = Date()
        return HStack(alignment: .top, spacing: 0) {
            ForEach(events, id: \.name) { event in
                VStack(spacing: 4) {
                    Text(event.name)
                        .font(.caption2.weight(.semibold))
                        .foregroundColor(timelineLabelColor(event, now: now))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)

                    Text(timeString(for: event.date))
                        .font(.caption2)
                        .foregroundColor(.secondaryText(scheme))
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }

    private func timelineProgress(events: [PrayerEvent], now: Date = Date()) -> CGFloat {
        guard events.count > 1 else {
            return 0
        }

        if now <= events[0].date {
            return 0
        }
        if let last = events.last, now >= last.date {
            return 1
        }

        for index in 0..<(events.count - 1) {
            let start = events[index].date
            let end = events[index + 1].date
            guard now >= start, now <= end, end > start else { continue }

            let segment = now.timeIntervalSince(start) / end.timeIntervalSince(start)
            let sequencePosition = (Double(index) + segment) / Double(events.count - 1)
            return CGFloat(min(max(sequencePosition, 0), 1))
        }

        return 0
    }

    private func eventPosition(index: Int, count: Int) -> CGFloat {
        guard count > 1 else { return 0 }
        return CGFloat(index) / CGFloat(count - 1)
    }

    private func timelineNodeColor(_ event: PrayerEvent, now: Date = Date()) -> Color {
        if event.name == upcomingSalahName(now: now) {
            return .prayerAccent
        }
        if event.date < now {
            return .adaptiveAccent(scheme)
        }
        return .progressTrack(scheme)
    }

    private func timelineLabelColor(_ event: PrayerEvent, now: Date = Date()) -> Color {
        if event.name == upcomingSalahName(now: now) {
            return .prayerAccent
        }
        if event.date < now {
            return .adaptiveAccent(scheme)
        }
        return .secondaryText(scheme)
    }

    private func upcomingSalahName(now: Date = Date()) -> String? {
        manager.todayPrayer?.salahEvents().first { $0.date >= now }?.name
    }

    @ViewBuilder
    private var contextualActionCard: some View {
        if manager.todayPrayer != nil {
            let p = flowPresentation(flowKind)
            if let category = p.athkar {
                let status = athkarProgress.status(for: category)
                let actionTitle: LocalizedStringKey = status.isComplete ? "Review" : "Continue"

                NavigationLink {
                    athkarDetailDestination(for: category)
                } label: {
                    contextualActionBody(icon: p.icon, title: p.title, actionTitle: actionTitle) {
                        contextualAthkarSubtitle(p, status: status)
                    }
                }
                .buttonStyle(.plain)
                .padding(.horizontal)
            } else if p.opensPrayers {
                Button {
                    AppRouter.shared.selectedTab = .prayers
                } label: {
                    contextualActionBody(
                        icon: p.icon,
                        title: "Today's Prayers",
                        actionTitle: "Open"
                    ) {
                        trackerSubtitle
                    }
                }
                .buttonStyle(.plain)
                .padding(.horizontal)
            }
        }
    }

    private func contextualActionBody<Subtitle: View>(
        icon: String,
        title: LocalizedStringKey,
        actionTitle: LocalizedStringKey,
        @ViewBuilder subtitle: () -> Subtitle
    ) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.brandDim)
                    .frame(width: 46, height: 46)
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.adaptiveAccent(scheme))
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.adaptiveText(scheme))

                subtitle()
                    .font(.caption)
                    .foregroundColor(.secondaryText(scheme))
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 8)

            Text(actionTitle)
                .font(.caption.weight(.semibold))
                .foregroundColor(.adaptiveAccent(scheme))

            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundColor(.ter)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.cardBackground(scheme))
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(Color.cardBorder(scheme), lineWidth: 1)
        )
    }

    @ViewBuilder
    private func contextualAthkarSubtitle(_ p: FlowPresentation, status: AthkarCategoryProgressSnapshot) -> some View {
        if status.isComplete {
            Text("Completed today")
        } else if status.completedCount > 0 {
            Text("\(status.completedCount)/\(status.totalCount) done · Continue #\(status.resumeIndex + 1)")
        } else {
            Text(p.subtitle)
        }
    }

    private func athkarDetailDestination(for category: AthkarCategory) -> some View {
        AthkarDetailView(
            athkarList: category.athkar,
            startIndex: athkarProgress.resumeIndex(for: category),
            completedIndices: athkarProgress.binding(for: category)
        )
    }

    private var trackerSummaryCard: some View {
        Button {
            AppRouter.shared.selectedTab = .prayers
        } label: {
            HStack(spacing: 14) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(.adaptiveAccent(scheme))
                    .frame(width: 42, height: 42)
                    .background(Color.brandDim)
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 4) {
                    Text("Prayer Tracker")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.adaptiveText(scheme))

                    trackerSubtitle
                        .font(.caption)
                        .foregroundColor(.secondaryText(scheme))
                }

                Spacer(minLength: 8)

                trackerMiniProgress

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.ter)
            }
            .padding(16)
            .background(Color.cardBackground(scheme))
            .clipShape(RoundedRectangle(cornerRadius: 22))
            .overlay(
                RoundedRectangle(cornerRadius: 22)
                    .stroke(Color.cardBorder(scheme), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .padding(.horizontal)
    }

    @ViewBuilder
    private var trackerSubtitle: some View {
        let completed = tracker.completedCount(on: Date())
        let total = PrayerTrackerManager.allPrayers.count
        if completed >= total {
            Text("Completed today")
        } else {
            Text("\(completed)/\(total) logged today")
        }
    }

    private var trackerMiniProgress: some View {
        let progress = tracker.progress(on: Date())
        return ZStack(alignment: .leading) {
            Capsule()
                .fill(Color.progressTrack(scheme))
            Capsule()
                .fill(Color.adaptiveAccent(scheme))
                .frame(width: 54 * progress)
        }
        .frame(width: 54, height: 7)
    }

    private func timeString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: date)
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
