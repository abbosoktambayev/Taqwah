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
        List {
            if !notificationsAuthorized {
                permissionSection
            }

            Section {
                prayerToggle("Fajr", icon: "sunrise.fill", subtitle: "Dawn", isOn: $fajrEnabled)
                prayerToggle("Dhuhr", icon: "sun.max.fill", subtitle: "Midday", isOn: $dhuhrEnabled)
                prayerToggle("Asr", icon: "sun.haze.fill", subtitle: "Afternoon", isOn: $asrEnabled)
                prayerToggle("Maghrib", icon: "sunset.fill", subtitle: "Sunset", isOn: $maghribEnabled)
                prayerToggle("Isha", icon: "moon.stars.fill", subtitle: "Night", isOn: $ishaEnabled)
            } header: {
                Text("Prayer Notifications")
            }
            .disabled(!notificationsAuthorized)

            Section {
                Picker(selection: $reminderMinutes) {
                    ForEach(reminderOptions, id: \.self) { minutes in
                        Text(minutes == 0 ? LocalizedStringKey("Off") : "\(minutes) min")
                            .tag(minutes)
                    }
                } label: {
                    Text("Remind me before")
                        .foregroundStyle(Color.adaptiveText(scheme))
                }

                Toggle(isOn: $jummahReminder) {
                    Text("Jummah reminder")
                        .foregroundStyle(Color.adaptiveText(scheme))
                }
                .tint(.adaptiveAccent(scheme))
            } header: {
                Text("Reminders")
            } footer: {
                Text("Friday: Surah Al-Kahf & Jummah")
            }
            .disabled(!notificationsAuthorized)

            Section {
                HStack(spacing: 12) {
                    Image(systemName: "speaker.wave.2.fill")
                        .font(.system(size: 17))
                        .foregroundStyle(Color.adaptiveAccent(scheme))
                        .frame(width: 28)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Default System Sound")
                            .foregroundStyle(Color.adaptiveText(scheme))
                        Text("Custom Adhan sounds coming soon")
                            .font(.caption)
                            .foregroundStyle(Color.secondaryText(scheme))
                    }
                }
                .listRowBackground(Color.cardBackground(scheme))
            } header: {
                Text("Adhan Sound")
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(AppBackground())
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

    // MARK: - Permission

    @ViewBuilder
    private var permissionSection: some View {
        Section {
            switch notifications.authorizationStatus {
            case .denied:
                Button {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    permissionRow(icon: "bell.slash.fill",
                                  title: "Notifications Disabled",
                                  message: "Enable notifications in Settings to receive prayer reminders.",
                                  tint: .warningYellow)
                }
                .buttonStyle(.plain)
                .listRowBackground(Color.cardBackground(scheme))
            default:
                Button {
                    Task { await notifications.requestAuthorization() }
                } label: {
                    permissionRow(icon: "bell.fill",
                                  title: "Enable Notifications",
                                  message: "Allow Taqwah to remind you at each prayer time.",
                                  tint: .adaptiveAccent(scheme))
                }
                .buttonStyle(.plain)
                .listRowBackground(Color.cardBackground(scheme))
            }
        }
    }

    private func permissionRow(icon: String, title: String, message: String, tint: Color) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(tint)
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 3) {
                Text(LocalizedStringKey(title))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.adaptiveText(scheme))
                Text(LocalizedStringKey(message))
                    .font(.caption)
                    .foregroundStyle(Color.secondaryText(scheme))
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.secondaryText(scheme))
        }
        .contentShape(Rectangle())
    }

    // MARK: - Rows

    private func prayerToggle(_ name: String, icon: String, subtitle: String, isOn: Binding<Bool>) -> some View {
        Toggle(isOn: isOn) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 17))
                    .foregroundStyle(Color.adaptiveAccent(scheme))
                    .frame(width: 28)
                VStack(alignment: .leading, spacing: 2) {
                    Text(LocalizedStringKey(name))
                        .foregroundStyle(Color.adaptiveText(scheme))
                    Text(LocalizedStringKey(subtitle))
                        .font(.caption)
                        .foregroundStyle(Color.secondaryText(scheme))
                }
            }
        }
        .tint(.adaptiveAccent(scheme))
        .listRowBackground(Color.cardBackground(scheme))
    }

    private func applyChanges() {
        notifications.reschedule(using: PrayerTimesManager.shared.allDays)
    }
}

#Preview("Dark") {
    NavigationStack { AdhanSettingsView() }.preferredColorScheme(.dark)
}

#Preview("Light") {
    NavigationStack { AdhanSettingsView() }.preferredColorScheme(.light)
}
