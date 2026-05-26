import SwiftUI

struct AdhanSettingsView: View {
    @Environment(\.colorScheme) private var scheme
    
    @AppStorage("adhan_fajr") private var fajrEnabled = true
    @AppStorage("adhan_dhuhr") private var dhuhrEnabled = true
    @AppStorage("adhan_asr") private var asrEnabled = true
    @AppStorage("adhan_maghrib") private var maghribEnabled = true
    @AppStorage("adhan_isha") private var ishaEnabled = true
    
    private let prayers: [(name: String, icon: String, time: String)] = [
        ("Fajr", "sunrise.fill", "Dawn"),
        ("Dhuhr", "sun.max.fill", "Midday"),
        ("Asr", "sun.haze.fill", "Afternoon"),
        ("Maghrib", "sunset.fill", "Sunset"),
        ("Isha", "moon.stars.fill", "Night"),
    ]
    
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
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondaryText(scheme))
                                .font(.caption)
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
                    
                    // MARK: - Note
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.adaptiveAccent(scheme))
                            .font(.subheadline)
                        
                        Text("Push notifications for prayer times are coming in a future update. Currently, notifications use the system default sound.")
                            .font(.caption)
                            .foregroundColor(.secondaryText(scheme))
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 28)
                            .fill(Color.adaptiveAccent(scheme).opacity(0.08))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 28)
                            .stroke(Color.adaptiveAccent(scheme).opacity(0.2), lineWidth: 1)
                    )
                    .padding(.horizontal)
                    
                    Spacer(minLength: 32)
                }
                .padding(.top, 8)
            }
        }
        .navigationTitle("Adhan Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Components
    
    private func sectionLabel(_ text: String) -> some View {
        Text(text)
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
