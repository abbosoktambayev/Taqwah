import SwiftUI

struct ServicesView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Prayer Tools") {
                    NavigationLink("Prayer Settings") { PrayerSettingsView() }
                    NavigationLink("Calendar") { IslamicCalendarView() }
                    NavigationLink("Qibla Compass") { QiblaView() }
                }

                Section("App Settings") {
                    NavigationLink("Adhan Sound") { AdhanSettingsView() }
                    NavigationLink("Appearance") { AppearanceView() }
                    NavigationLink("Language") { LanguageView() }
                }

                Section("Information") {
                    NavigationLink("About App") { AboutView() }
                    NavigationLink("Privacy Policy") { PrivacyPolicyView() }
                    NavigationLink("Terms of Use") { TermsView() }
                    NavigationLink("Contact Support") { SupportView() }
                }
            }
            .navigationTitle("Services")
        }
    }
}

#Preview {
    ServicesView()
}
