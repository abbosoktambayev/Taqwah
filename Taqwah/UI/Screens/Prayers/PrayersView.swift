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
    private let completionOptions = PrayerCompletion.allCases

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
                        trackerHero
                        dateNavigator
                        prayerCardsSection
                    }
                }
                .safeAreaPadding(.bottom, 96)
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

    // MARK: - Hero

    private var trackerHero: some View {
        let completed = tracker.completedCount(on: selectedDate)
        let total = PrayerTrackerManager.allPrayers.count

        return VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Group {
                        if isToday {
                            Text("TODAY")
                        } else {
                            Text("Progress")
                        }
                    }
                        .font(.mono(10))
                        .tracking(0.8)
                        .foregroundColor(.ter)

                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text("\(completed)/\(total)")
                            .font(.brandDisplay(54))
                            .foregroundColor(.adaptiveText(scheme))

                        Text("Prayers Logged")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(.secondaryText(scheme))
                    }
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)

                    HStack(spacing: 8) {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.prayerAccent)

                        Text("\(tracker.streak) days")
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(.prayerAccent)
                    }
                }

                Spacer(minLength: 12)

                Button {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    showStats = true
                } label: {
                    Image(systemName: "chart.bar.xaxis")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.adaptiveAccent(scheme))
                        .frame(width: 42, height: 42)
                        .background(Color.brandDim)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Statistics")
            }

            progressBar(progress: tracker.progress(on: selectedDate), height: 10)

            HStack(spacing: 8) {
                Image(systemName: "hand.tap.fill")
                    .foregroundColor(.adaptiveAccent(scheme))
                    .font(.caption)

                Text("Track your daily prayers")
                    .font(.caption)
                    .foregroundColor(.secondaryText(scheme))
            }
        }
        .padding(20)
        .background(Color.cardBackground(scheme))
        .clipShape(RoundedRectangle(cornerRadius: 28))
        .overlay(
            RoundedRectangle(cornerRadius: 28)
                .stroke(Color.cardBorder(scheme), lineWidth: 1)
        )
        .padding(.horizontal)
    }

    // MARK: - Date Navigator

    @ViewBuilder
    private var dateLabel: some View {
        if isToday {
            Text("Today")
        } else if Calendar.current.isDateInYesterday(selectedDate) {
            Text("Yesterday")
        } else {
            Text(verbatim: formattedSelectedDate)
        }
    }

    private var formattedSelectedDate: String {
        let f = DateFormatter()
        f.locale = LocalizationManager.shared.locale
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
                dateLabel
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

    // MARK: - Prayer Cards

    private var prayerCardsSection: some View {
        VStack(spacing: 14) {
            ForEach(PrayerTrackerManager.allPrayers, id: \.self) { prayerName in
                prayerRow(
                    name: prayerName,
                    time: timeForPrayer(prayerName),
                    icon: prayerIcons[prayerName] ?? "circle"
                )
            }
        }
        .padding(.horizontal)
        .animation(Motion.standard, value: tracker.revision)
    }

    private func prayerRow(name: String, time: String, icon: String) -> some View {
        let type = tracker.completion(name, on: selectedDate)
        let isDone = type != nil

        return VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(isDone ? Color.adaptiveAccent(scheme) : Color.clear)
                        .frame(width: 48, height: 48)
                        .overlay(
                            Circle()
                                .strokeBorder(
                                    isDone ? Color.clear : Color.uncheckedBorder(scheme),
                                    lineWidth: 2
                                )
                        )
                        .shadow(color: isDone ? .accentShadow(scheme) : .clear, radius: 8)

                    Image(systemName: type?.icon ?? icon)
                        .font(.headline)
                        .foregroundColor(isDone ? .parchment : .secondaryText(scheme))
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(name)
                        .font(.headline)
                        .foregroundColor(.adaptiveText(scheme))

                    if let type {
                        HStack(spacing: 4) {
                            Text(time)
                            Text("·")
                            Text(LocalizedStringKey(type.label))
                        }
                        .font(.subheadline)
                        .foregroundColor(.adaptiveAccent(scheme))
                    } else {
                        Text(time)
                            .font(.subheadline)
                            .foregroundColor(.secondaryText(scheme))
                    }
                }

                Spacer()

                if isDone {
                    Button {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        withAnimation(Motion.standard) {
                            tracker.unmark(name, on: selectedDate)
                        }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(.secondaryText(scheme))
                            .frame(width: 34, height: 34)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Mark as not prayed")
                }
            }

            HStack(spacing: 8) {
                ForEach(completionOptions) { option in
                    completionOptionButton(
                        option,
                        prayerName: name,
                        isSelected: type == option
                    )
                }
            }
        }
        .padding(16)
        .background(Color.cardBackground(scheme))
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(isDone ? Color.adaptiveAccent(scheme).opacity(0.3) : Color.cardBorder(scheme), lineWidth: 1)
        )
        .scaleEffect(isDone ? 0.98 : 1.0)
        .animation(Motion.standard, value: isDone)
    }

    private func completionOptionButton(
        _ option: PrayerCompletion,
        prayerName: String,
        isSelected: Bool
    ) -> some View {
        Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            withAnimation(Motion.standard) {
                tracker.mark(prayerName, as: option, on: selectedDate)
            }
        } label: {
            HStack(spacing: 5) {
                Image(systemName: option.icon)
                    .font(.caption.weight(.semibold))
                Text(LocalizedStringKey(option.shortLabel))
                    .font(.caption.weight(.semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
            }
            .foregroundColor(optionTextColor(isSelected: isSelected))
            .frame(maxWidth: .infinity)
            .frame(height: 36)
            .background(optionBackground(isSelected: isSelected))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(
                        isSelected ? Color.clear : Color.adaptiveAccent(scheme).opacity(scheme == .light ? 0.10 : 0.14),
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(.plain)
    }

    private func optionBackground(isSelected: Bool) -> Color {
        if isSelected {
            return Color.adaptiveAccent(scheme)
        }

        return Color.adaptiveAccent(scheme).opacity(scheme == .light ? 0.07 : 0.12)
    }

    private func optionTextColor(isSelected: Bool) -> Color {
        if isSelected {
            return Color.parchment
        }

        return Color.adaptiveAccent(scheme).opacity(scheme == .light ? 0.68 : 0.74)
    }

    private func progressBar(progress: CGFloat, height: CGFloat) -> some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.progressTrack(scheme))

                Capsule()
                    .fill(Color.adaptiveAccent(scheme))
                    .frame(width: geo.size.width * progress)
                    .animation(.easeInOut(duration: 0.35), value: tracker.revision)
            }
        }
        .frame(height: height)
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
