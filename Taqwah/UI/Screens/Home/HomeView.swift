import SwiftUI

struct HomeView: View {
    @State private var todayPrayer: PrayerDay?
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            ZStack {
                // MARK: - Background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 9/255, green: 51/255, blue: 27/255),
                        Color(red: 1/255, green: 26/255, blue: 21/255),
                        Color(.black)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
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
        }
        .task {
            await loadPrayerTimes()
        }
    }
    @MainActor
    private func loadPrayerTimes() async {
        isLoading = true
        errorMessage = nil

        PrayerTimesService.shared.fetchYearPrayerTimes(
            year: Calendar.current.component(.year, from: Date()),
            latitude: 51.133333,
            longitude: 71.433333
        ) { result in
            isLoading = false

            switch result {
            case .success(let days):
                let calendar = Calendar.current
                let today = Date()

                todayPrayer = days.first { day in
                    calendar.isDate(day.date, inSameDayAs: today)
                }

                if todayPrayer == nil {
                    print("❌ Today prayer not found")
                } else {
                    print("✅ Today prayer found:", todayPrayer!)
                }

            case .failure(let error):
                errorMessage = error.localizedDescription
            }
        }
    }
}

// MARK: - Sections
extension HomeView {

    // MARK: - Header (location + date)
    private var headerSection: some View {
        VStack(spacing: 8) {

            // Row 1: Greeting + Day
            HStack {
                Text("As-salamu alaykum")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(.white)

                Spacer()

                Text("Tuesday")
                    .foregroundColor(.white.opacity(0.7))
            }

            // Row 2: Location + Hijri date
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "location.fill")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))

                    Text("Astana, Kazakhstan")
                        .foregroundColor(.white.opacity(0.8))
                }

                Spacer()

                Text("15 Jumada Al-Awwal 1447")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .padding(.horizontal)
    }

    // MARK: - Next Prayer Section
    private var nextPrayerSection: some View {
        VStack(alignment: .leading, spacing: 16) {

            Text("Next Prayer")
                .font(.title3)
                .foregroundColor(.white)
                .bold()

            VStack(spacing: 16) {

                Text("Dhuhr")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)

                Text("2h 15m")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(Color.yellow.opacity(0.9))

                Text("at 12:30")
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.top, -8)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 36)
            .background(
                RoundedRectangle(cornerRadius: 28)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.gray.opacity(0.15)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            )
        }
        .padding(.horizontal)
    }

    // MARK: - Today's Prayers
    private var todaysPrayerSection: some View {
        VStack(alignment: .leading, spacing: 16) {

            Text("Today's Prayers")
                .font(.title3)
                .bold()
                .foregroundColor(.white)

            if isLoading {
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(.white)
                    .frame(maxWidth: .infinity)
            } else if let prayer = todayPrayer {

                VStack(spacing: 14) {
                    prayerRow(icon: "sunrise", name: "Fajr", time: prayer.fajr)
                    prayerRow(icon: "sun.max.fill", name: "Dhuhr", time: prayer.dhuhr)
                    prayerRow(icon: "sun.max", name: "Asr", time: prayer.asr)
                    prayerRow(icon: "sunset", name: "Maghrib", time: prayer.maghrib)
                    prayerRow(icon: "moon.stars", name: "Isha", time: prayer.isha)
                }
                .padding(.vertical, 18)
                .background(Color.gray.opacity(0.15))
                .cornerRadius(28)

            } else if let errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            }  else {
                Text("Failed to load prayer times. Please check your internet connection or try again later.")
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding()
            }
            
        }
        .padding(.horizontal)
    }

    // MARK: - Prayer Row
    private func prayerRow(icon: String, name: String, time: String) -> some View {
        HStack {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(.yellow.opacity(0.9))
                    .font(.system(size: 20))

                Text(name)
                    .foregroundColor(.white)
            }

            Spacer()

            Text(time)
                .foregroundColor(.white.opacity(0.8))
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(Color.black.opacity(0.2))
        .cornerRadius(28)
        .padding(.horizontal, 6)
    }
}

// MARK: - Preview
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            HomeView()
                .preferredColorScheme(.dark)

            HomeView()
                .preferredColorScheme(.light)
        }
    }
}

