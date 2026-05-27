import SwiftUI
import UserNotifications

struct AdhanSettingsView: View {
    @Environment(\.colorScheme) private var scheme
    @StateObject private var notifications = NotificationManager.shared

    @AppStorage("adhan_fajr") private var fajrEnabled = true
    @AppStorage("adhan_dhuhr") private var dhuhrEnabled = true
    @AppStorage("adhan_asr") private var asrEnabled = true
    @AppStorage("adhan_maghrib") private var maghribEnabled = true
    @AppStorage("adhan_isha") private var ishaEnabled = true
    @AppStorage("reminderMinutesBefore") private var reminderMinutes = 0
    @AppStorage("jummahReminder") private var jummahReminder = true

    private let reminderOptions = [0, 5, 10, 15, 30]

    private var notificationsAuthorized: Bool {
        notifications.authorizationStatus == .authorized
            || notifications.authorizationStatus == .provisional
    }

    var body: some View {
        ZStack {
            AppBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {

                    // MARK: - Header info
                    HStack(spacing: 12) {
                        Image(systemName: "bell.badge.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.adaptiveAccent(scheme))

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Prayer Notifications")
                                .font(.headline)
                                .foregroundColor(.adaptiveText(scheme))

                            Text("Get notified when it's time to pray")
                                .font(.caption)
                                .foregroundColor(.secondaryText(scheme))
                        }
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 28)
                            .fill(Color.glassFill(scheme))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 28)
                            .stroke(Color.glassBorder(scheme), lineWidth: 1)
                    )
                    .padding(.horizontal)

                    // MARK: - Permission state
                    permissionSection

                    // MARK: - Prayer toggles
                    sectionLabel("PRAYER NOTIFICATIONS")

                    VStack(spacing: 0) {
                        prayerToggle("Fajr", icon: "sunrise.fill", subtitle: "Dawn", isOn: $fajrEnabled)
                        divider
                        prayerToggle("Dhuhr", icon: "sun.max.fill", subtitle: "Midday", isOn: $dhuhrEnabled)
                        divider
                        prayerToggle("Asr", icon: "sun.haze.fill", subtitle: "Afternoon", isOn: $asrEnabled)
                        divider
                        prayerToggle("Maghrib", icon: "sunset.fill", subtitle: "Sunset", isOn: $maghribEnabled)
                        divider
                        prayerToggle("Isha", icon: "moon.stars.fill", subtitle: "Night", isOn: $ishaEnabled)
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 28)
                            .fill(Color.glassFill(scheme))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 28)
                            .stroke(Color.glassBorder(scheme), lineWidth: 1)
                    )
                    .padding(.horizontal)
                    .opacity(notificationsAuthorized ? 1 : 0.5)
                    .disabled(!notificationsAuthorized)

                    // MARK: - Reminders
                    sectionLabel("REMINDERS")

                    VStack(spacing: 0) {
                        HStack {
                            Image(systemName: "bell.and.waves.left.and.right.fill")
                                .font(.system(size: 18))
                                .foregroundColor(.adaptiveAccent(scheme))
                                .frame(width: 28)

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Remind me before")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.adaptiveText(scheme))
                                Text("Early heads-up before each prayer")
                                    .font(.caption)
                                    .foregroundColor(.secondaryText(scheme))
                            }

                            Spacer()

                            Menu {
                                ForEach(reminderOptions, id: \.self) { minutes in
                                    Button {
                                        reminderMinutes = minutes
                                    } label: {
                                        Text(minutes == 0 ? "Off" : "\(minutes) min")
                                    }
                                }
                            } label: {
                                Text(reminderMinutes == 0 ? "Off" : "\(reminderMinutes) min")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundColor(.adaptiveAccent(scheme))
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(Capsule().fill(Color.glassFill(scheme)))
                            }
                        }
                        .padding(.vertical, 8)

                        divider

                        HStack(spacing: 14) {
                            Image(systemName: "calendar.badge.clock")
                                .font(.system(size: 18))
                                .foregroundColor(.adaptiveAccent(scheme))
                                .frame(width: 28)

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Jummah reminder")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.adaptiveText(scheme))
                                Text("Friday: Surah Al-Kahf & Jummah")
                                    .font(.caption)
                                    .foregroundColor(.secondaryText(scheme))
                            }

                            Spacer()

                            Toggle("", isOn: $jummahReminder)
                                .labelsHidden()
                                .tint(.adaptiveAccent(scheme))
                        }
                        .padding(.vertical, 6)
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 28)
                            .fill(Color.glassFill(scheme))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 28)
                            .stroke(Color.glassBorder(scheme), lineWidth: 1)
                    )
                    .padding(.horizontal)
                    .opacity(notificationsAuthorized ? 1 : 0.5)
                    .disabled(!notificationsAuthorized)

                    // MARK: - Sound section
                    sectionLabel("ADHAN SOUND")

                    VStack(spacing: 0) {
                        HStack {
                            Image(systemName: "speaker.wave.2.fill")
                                .font(.system(size: 18))
                                .foregroundColor(.adaptiveAccent(scheme))
                                .frame(width: 28)

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Default System Sound")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.adaptiveText(scheme))

                                Text("Custom Adhan sounds coming soon")
                                    .font(.caption)
                                    .foregroundColor(.secondaryText(scheme))
                            }

                            Spacer()
                        }
                        .padding(.vertical, 10)
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 28)
                            .fill(Color.glassFill(scheme))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 28)
                            .stroke(Color.glassBorder(scheme), lineWidth: 1)
                    )
                    .padding(.horizontal)

                    Spacer(minLength: 32)
                }
                .padding(.top, 8)
            }
        }
        .navigationTitle("Adhan Settings")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await notifications.refreshAuthorizationStatus()
        }
        .onChange(of: fajrEnabled) { _, _ in applyChanges() }
        .onChange(of: dhuhrEnabled) { _, _ in applyChanges() }
        .onChange(of: asrEnabled) { _, _ in applyChanges() }
        .onChange(of: maghribEnabled) { _, _ in applyChanges() }
        .onChange(of: ishaEnabled) { _, _ in applyChanges() }
        .onChange(of: reminderMinutes) { _, _ in applyChanges() }
        .onChange(of: jummahReminder) { _, _ in applyChanges() }
    }

    // MARK: - Permission Section

    @ViewBuilder
    private var permissionSection: some View {
        switch notifications.authorizationStatus {
        case .notDetermined:
            Button {
                Task { await notifications.requestAuthorization() }
            } label: {
                permissionBanner(
                    icon: "bell.fill",
                    title: "Enable Notifications",
                    message: "Allow Taqwah to remind you at each prayer time.",
                    tint: .adaptiveAccent(scheme)
                )
            }
            .buttonStyle(.plain)
            .padding(.horizontal)

        case .denied:
            Button {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            } label: {
                permissionBanner(
                    icon: "bell.slash.fill",
                    title: "Notifications Disabled",
                    message: "Enable notifications in Settings to receive prayer reminders.",
                    tint: .orange
                )
            }
            .buttonStyle(.plain)
            .padding(.horizontal)

        default:
            EmptyView()
        }
    }

    private func permissionBanner(icon: String, title: String, message: String, tint: Color) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(tint)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.adaptiveText(scheme))
                Text(message)
                    .font(.caption)
                    .foregroundColor(.secondaryText(scheme))
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondaryText(scheme))
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(tint.opacity(0.10))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28)
                .stroke(tint.opacity(0.25), lineWidth: 1)
        )
    }

    private func applyChanges() {
        notifications.reschedule(using: PrayerTimesManager.shared.allDays)
    }

    // MARK: - Components
    
    private func sectionLabel(_ text: String) -> some View {
        Text(LocalizedStringKey(text))
            .font(.caption.weight(.semibold))
            .foregroundColor(.sectionTitle(scheme))
            .padding(.horizontal)
    }
    
    private func prayerToggle(_ name: String, icon: String, subtitle: String, isOn: Binding<Bool>) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(.adaptiveAccent(scheme))
                .frame(width: 28)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.adaptiveText(scheme))
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondaryText(scheme))
            }
            
            Spacer()
            
            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(.adaptiveAccent(scheme))
        }
        .padding(.vertical, 6)
    }
    
    private var divider: some View {
        Rectangle()
            .fill(Color.dividerColor(scheme))
            .frame(height: 1)
            .padding(.vertical, 4)
    }
}

#Preview("Dark") {
    NavigationStack {
        AdhanSettingsView()
    }
    .preferredColorScheme(.dark)
}

#Preview("Light") {
    NavigationStack {
        AdhanSettingsView()
    }
    .preferredColorScheme(.light)
}
