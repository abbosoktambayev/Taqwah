import SwiftUI

struct PrayersView: View {

    // MARK: - State
    @State private var streak: Int = 7
    @State private var completed: Set<String> = ["Fajr", "Dhuhr", "Asr"]
    @Namespace private var animation

    let prayers: [(name: String, time: String, icon: String)] = [
        ("Fajr", "05:20", "sun.and.horizon.fill"),
        ("Dhuhr", "12:30", "sun.max.fill"),
        ("Asr", "15:45", "sun.max.trianglebadge.exclamationmark.fill"),
        ("Maghrib", "18:10", "sunset.fill"),
        ("Isha", "19:40", "moon.stars.fill")
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                // MARK: - Background
                LinearGradient(
                    colors: [
                        Color(red: 9/255, green: 51/255, blue: 27/255),
                        Color(red: 1/255, green: 26/255, blue: 21/255),
                        .black
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {

                        headerSection
                        progressCard

                        VStack(spacing: 16) {
                            ForEach(prayers, id: \.name) { prayer in
                                prayerRow(prayer)
                                    .animation(.spring(response: 0.3), value: completed)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Prayer Tracker")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    // MARK: - Header
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                

                Text("Track your daily prayers")
                    .foregroundColor(.white.opacity(0.6))
            }

            Spacer()

            HStack(spacing: 6) {
                Image(systemName: "flame.fill")
                    .foregroundColor(.orange)

                Text("\(streak) days")
                    .bold()
                    .foregroundColor(.orange)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(Color.white.opacity(0.08))
            .clipShape(Capsule())
        }
        .foregroundColor(.white)
        .padding(.horizontal)
    }

    // MARK: - Progress Card
    private var progressCard: some View {
        let progressValue = CGFloat(completed.count) / 5

        return VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Today's Progress")
                    .font(.headline)

                Spacer()

                Text("\(completed.count)/5")
                    .bold()
                    .foregroundColor(.green)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.12))

                    Capsule()
                        .fill(Color.green)
                        .frame(width: geo.size.width * progressValue)
                        .animation(.easeInOut(duration: 0.35), value: completed.count)
                }
            }
            .frame(height: 10)
        }
        .foregroundColor(.white)
        .padding()
        .background(Color.white.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: 25))
        .padding(.horizontal)
    }

    // MARK: - Prayer Row
    private func prayerRow(_ prayer: (name: String, time: String, icon: String)) -> some View {
        let isDone = completed.contains(prayer.name)

        return Button {
            lightHaptic()
            togglePrayer(prayer.name)
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
                            .foregroundColor(.black)
                            .matchedGeometryEffect(id: prayer.name, in: animation)
                    } else {
                        Circle()
                            .strokeBorder(Color.white.opacity(0.3), lineWidth: 2)
                            .frame(width: 48, height: 48)
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(prayer.name)
                        .font(.headline)
                        .foregroundColor(.white)

                    Text(prayer.time)
                        .foregroundColor(.white.opacity(0.6))
                }

                Spacer()
            }
            .padding()
            .background(Color.white.opacity(0.07))
            .clipShape(RoundedRectangle(cornerRadius: 22))
            .scaleEffect(isDone ? 0.97 : 1.0)
            .animation(.spring(response: 0.25), value: isDone)
        }
        .buttonStyle(.plain)
        .padding(.horizontal)
    }

    // MARK: - Logic
    private func togglePrayer(_ name: String) {
        if completed.contains(name) {
            completed.remove(name)
        } else {
            completed.insert(name)
        }
    }

    private func lightHaptic() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
}

#Preview {
    PrayersView()
        .preferredColorScheme(.dark)
}
