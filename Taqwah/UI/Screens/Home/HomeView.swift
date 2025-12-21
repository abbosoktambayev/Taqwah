import SwiftUI

struct HomeView: View {
    @StateObject private var manager = PrayerTimesManager.shared
    @Environment(\.colorScheme) private var colorScheme
    
    // States for Next Prayer
    @State private var nextPrayerName: String = "Loading..."
    @State private var remainingTime: String = ""
    @State private var nextPrayerTime: String = ""
    @State private var countdownTimer: DispatchSourceTimer?
    @Environment(\.colorScheme) private var scheme
    
    // Вспомогательное свойство для отслеживания изменений (исправляет ошибку компиляции)
    private var prayerTimesIdentifier: String {
        guard let prayer = manager.todayPrayer else { return "" }
        return "\(prayer.fajr)|\(prayer.dhuhr)|\(prayer.asr)|\(prayer.maghrib)|\(prayer.isha)"
    }
    
    // Dynamic day of week
    private var currentDayName: String {
        let formatter = DateFormatter()
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
                        nextPrayerSection
                        todaysPrayerSection
                    }
                    .padding(.top, 8)
                }
            }
            .navigationTitle("Prayer Times")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .foregroundColor(.adaptiveText(scheme))
        }
        .task {
            manager.loadIfNeeded()
            
            if let prayer = manager.todayPrayer {
                updateNextPrayer(prayer: prayer)
                startCountdownTimer(prayer: prayer)
            }
        }
        // Упрощенный onChange
        .onChange(of: prayerTimesIdentifier) { _, _ in
            if let prayer = manager.todayPrayer {
                updateNextPrayer(prayer: prayer)
                startCountdownTimer(prayer: prayer)
            }
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
        }
        timer.resume()
        countdownTimer = timer
    }
    
    private func stopCountdownTimer() {
        countdownTimer?.cancel()
        countdownTimer = nil
    }
    // MARK: - Location Icon Styling

    private var locationIconColor: Color {
        scheme == .light ? .green : .prayerAccent
    }

    private var locationIconShadow: Color {
        scheme == .light
        ? Color.green.opacity(0.35)
        : Color.prayerAccent.opacity(0.35)
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
                        .foregroundColor(locationIconColor)
                        .shadow(
                            color: locationIconShadow,
                            radius: 12,
                            y: 6
                        )
                        .font(.caption)

                    Text("Astana, Kazakhstan")
                        .foregroundColor(.secondaryText(scheme))
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(currentDayName)
                    .foregroundColor(.secondaryText(scheme))

                Text("15 Jumada Al-Awwal 1447")
                    .font(.caption)
                    .foregroundColor(.secondaryText(scheme))
            }
        }
        .padding(.horizontal)
    }
    
    //Timer color
    private var timerColor: Color {
        scheme == .light ? .green : .prayerAccent
    }
    
    //Light under timer
    private var timerShadow: Color {
        scheme == .light ? Color.green.opacity(0.35) : Color.prayerAccent.opacity(0.35)
    }

    private var nextPrayerSection: some View {
            VStack(alignment: .leading, spacing: 16) {
                Text("Next Prayer")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.adaptiveText(scheme))

                VStack(spacing: 8) {
                    Text(nextPrayerName)
                        .font(.title2)
                        .bold()
                        .foregroundColor(.adaptiveText(scheme))

                    Text(remainingTime)
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(timerColor)
                        .shadow(
                            color: timerShadow,
                            radius: 12,
                            y: 6
                        )

                    Text("at \(nextPrayerTime)")
                        .foregroundColor(.secondaryText(scheme))
                        .padding(.top, 6)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 36)
                .background(
                    ZStack {
                        // Основной слой
                        RoundedRectangle(cornerRadius: 28)
                            .fill(Color.primary.opacity(scheme == .light ? 0.06 : 0.12))

                        // ВНУТРЕННИЙ СВЕТ (edge glow)
                        RoundedRectangle(cornerRadius: 28)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(scheme == .light ? 0.6 : 0.15),
                                        Color.clear
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.2
                            )
                    }
                )
                .shadow(
                    color: Color.black.opacity(scheme == .light ? 0.08 : 0.4),
                    radius: scheme == .light ? 18 : 30,
                    y: scheme == .light ? 8 : 16
                )                .clipShape(RoundedRectangle(cornerRadius: 28))
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
                        prayerRow(icon: "sunrise", name: "Fajr", time: prayer.fajr)
                        prayerRow(icon: "sun.max.fill", name: "Dhuhr", time: prayer.dhuhr)
                        prayerRow(icon: "sun.max", name: "Asr", time: prayer.asr)
                        prayerRow(icon: "sunset", name: "Maghrib", time: prayer.maghrib)
                        prayerRow(icon: "moon.stars", name: "Isha", time: prayer.isha)
                    }
                    .padding(.vertical, 18)
                    .background(
                        Color.primary.opacity(scheme == .light ? 0.06 : 0.15)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 28))
                } else if let error = manager.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
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
                    .foregroundColor(.prayerAccent)  // Жёлтый акцент в обеих темах
                    .font(.system(size: 20))

                Text(name)
                    .foregroundColor(scheme == .light ? .black : .white)
                    .fontWeight(.medium)
            }

            Spacer()

            Text(time)
                .foregroundColor(scheme == .light ? .black.opacity(0.7) : .white.opacity(0.8))
                .fontWeight(.medium)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(
                    scheme == .light
                    ? Color(red: 245/255, green: 249/255, blue: 246/255)  // Очень мягкий светло-зелёный (как утренняя роса)
                    : Color.black.opacity(0.25)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 28)
                        .stroke(
                            scheme == .light
                            ? Color(red: 200/255, green: 230/255, blue: 201/255).opacity(0.4)
                            : Color.white.opacity(0.1),
                            lineWidth: 1
                        )
                )
        )
        .padding(.horizontal, 6)
    }
    
    // MARK: - Logic
    
    private func updateNextPrayer(prayer: PrayerDay) {
        let times: [(String, String)] = [
            ("Fajr", prayer.fajr),
            ("Dhuhr", prayer.dhuhr),
            ("Asr", prayer.asr),
            ("Maghrib", prayer.maghrib),
            ("Isha", prayer.isha)
        ]
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let now = Date()
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: now)
        
        var nextDate = Date.distantFuture
        var nextName = "Fajr"
        var nextTimeStr = prayer.fajr
        
        for (name, timeStr) in times {
            let trimmed = timeStr.trimmingCharacters(in: .whitespaces)
            guard let prayerTime = formatter.date(from: trimmed) else { continue }
            
            let comps = calendar.dateComponents([.hour, .minute], from: prayerTime)
            if let hour = comps.hour, let minute = comps.minute,
               let fullDate = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: today) {
                if fullDate > now && fullDate < nextDate {
                    nextDate = fullDate
                    nextName = name
                    nextTimeStr = trimmed
                }
            }
        }
        
        // Если все намазы прошли — Фаджр завтра
        if nextDate == Date.distantFuture {
            nextName = "Fajr"
            nextTimeStr = prayer.fajr
            if let fajrTime = formatter.date(from: prayer.fajr.trimmingCharacters(in: .whitespaces)),
               let tomorrow = calendar.date(byAdding: .day, value: 1, to: today) {
                let fajrComps = calendar.dateComponents([.hour, .minute], from: fajrTime)
                if let hour = fajrComps.hour, let minute = fajrComps.minute {
                    nextDate = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: tomorrow) ?? Date.distantFuture
                }
            }
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

