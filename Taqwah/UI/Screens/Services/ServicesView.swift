import SwiftUI

struct ServicesView: View {
    @Environment(\.colorScheme) private var scheme
    @StateObject private var settings = SettingsManager.shared
    @StateObject private var localization = LocalizationManager.shared

    var body: some View {
        NavigationStack {
            List {
                Section {
                    row("Prayer Settings", "gearshape.fill", .gray) { PrayerSettingsView() }
                    row("Calendar", "calendar", .red) { IslamicCalendarView() }
                    row("Qibla Compass", "safari.fill", .teal) { QiblaView() }
                    row("Tasbih", "circle.hexagongrid.fill", .green) { TasbihView() }
                }

                Section {
                    row("Adhan Sound", "speaker.wave.2.fill", .orange) { AdhanSettingsView() }
                    row("Appearance", "paintpalette.fill", .purple, value: themeValue) { AppearanceView() }
                    row("Language", "globe", .blue, value: languageValue) { LanguageView() }
                }

                Section {
                    row("Support Taqwah", "heart.fill", .pink) { DonateView() }
                    row("About App", "info.circle.fill", .gray) { AboutView() }
                    row("Contact Support", "bubble.left.and.bubble.right.fill", .green) { SupportView() }
                    row("Privacy Policy", "lock.shield.fill", .indigo) { PrivacyPolicyView() }
                    row("Terms of Use", "doc.text.fill", .gray) { TermsView() }
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(AppBackground())
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    // MARK: - Row

    private func row<Destination: View>(
        _ title: String,
        _ icon: String,
        _ color: Color,
        value: String? = nil,
        @ViewBuilder destination: @escaping () -> Destination
    ) -> some View {
        NavigationLink {
            destination()
        } label: {
            HStack(spacing: 12) {
                iconTile(icon, color)

                Text(LocalizedStringKey(title))
                    .foregroundStyle(Color.adaptiveText(scheme))

                Spacer(minLength: 8)

                if let value {
                    Text(value)
                        .foregroundStyle(Color.secondaryText(scheme))
                }
            }
        }
        .listRowBackground(Color.cardBackground(scheme))
    }

    private func iconTile(_ icon: String, _ color: Color) -> some View {
        Image(systemName: icon)
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(.white)
            .frame(width: 29, height: 29)
            .background(RoundedRectangle(cornerRadius: 7, style: .continuous).fill(color))
    }

    // MARK: - Trailing values

    private var themeValue: String {
        switch settings.colorSchemeSelection {
        case "light": return localization.localized("Light")
        case "dark": return localization.localized("Dark")
        default: return localization.localized("System")
        }
    }

    private var languageValue: String {
        switch localization.languageCode {
        case "ru": return "Русский"
        case "kk": return "Қазақша"
        case "uz": return "Oʻzbekcha"
        default: return "English"
        }
    }
}

#Preview {
    Group {
        ServicesView().preferredColorScheme(.dark)
        ServicesView().preferredColorScheme(.light)
    }
}
