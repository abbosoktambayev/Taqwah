import SwiftUI

struct ServicesView: View {
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()
                    .foregroundColor(.primary)

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        settingsSection("PRAYER TOOLS") {
                            settingsGroup {
                                serviceRow("Prayer Settings", "gearshape.fill", .adaptiveAccent(scheme)) {
                                    PrayerSettingsView()
                                }
                                dividerLine
                                serviceRow("Calendar", "calendar", .adaptiveAccent(scheme)) {
                                    IslamicCalendarView()
                                }
                                dividerLine
                                serviceRow("Qibla Compass", "safari.fill", .adaptiveAccent(scheme)) {
                                    QiblaView()
                                }
                                dividerLine
                                serviceRow("Tasbih", "circle.hexagongrid.fill", .adaptiveAccent(scheme)) {
                                    TasbihView()
                                }
                            }
                        }

                        settingsSection("APPLICATION") {
                            settingsGroup {
                                serviceRow("Adhan Sound", "speaker.wave.2.fill", .adaptiveAccent(scheme)) {
                                    AdhanSettingsView()
                                }
                                dividerLine
                                serviceRow("Appearance", "paintpalette.fill", .adaptiveAccent(scheme)) {
                                    AppearanceView()
                                }
                                dividerLine
                                serviceRow("Language", "globe", .adaptiveAccent(scheme)) {
                                    LanguageView()
                                }
                            }
                        }

                        settingsSection("SUPPORT") {
                            settingsGroup {
                                serviceRow("Support Taqwah", "heart.fill", .prayerAccent) {
                                    DonateView()
                                }
                                dividerLine
                                serviceRow("About App", "info.circle.fill", .adaptiveAccent(scheme)) {
                                    AboutView()
                                }
                                dividerLine
                                serviceRow("Contact Support", "bubble.left.and.bubble.right.fill", .adaptiveAccent(scheme)) {
                                    SupportView()
                                }
                                dividerLine
                                serviceRow("Privacy Policy", "shield.lefthalf.filled", .adaptiveAccent(scheme)) {
                                    PrivacyPolicyView()
                                }
                                dividerLine
                                serviceRow("Terms of Use", "doc.text.fill", .adaptiveAccent(scheme)) {
                                    TermsView()
                                }
                            }
                        }

                        Spacer(minLength: 32)
                    }
                    .padding(.top, 8)
                }
                .safeAreaPadding(.bottom, 96)
            }
            .navigationTitle("Services")
            .navigationBarTitleDisplayMode(.large)
            .foregroundColor(.adaptiveText(scheme))
        }
    }

    // MARK: - Components

    private func settingsSection<Content: View>(
        _ title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionTitle(title)
            content()
        }
    }

    private func sectionTitle(_ text: String) -> some View {
        Text(LocalizedStringKey(text))
            .font(.mono(11)).tracking(0.6)
            .foregroundColor(.sectionTitle(scheme))
            .padding(.horizontal, 24)
    }

    private func settingsGroup(@ViewBuilder content: () -> some View) -> some View {
        VStack(spacing: 0) {
            content()
        }
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(Color.cardBackground(scheme))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(Color.cardBorder(scheme), lineWidth: 1)
        )
        .padding(.horizontal)
    }

    private var dividerLine: some View {
        Rectangle()
            .fill(Color.dividerColor(scheme))
            .frame(height: 1)
            .padding(.leading, 64)
            .padding(.trailing, 16)
    }

    private func serviceRow<Destination: View>(
        _ title: String,
        _ icon: String,
        _ tint: Color,
        destination: @escaping () -> Destination
    ) -> some View {
        NavigationLink(destination: destination) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(tint)
                    .frame(width: 34, height: 34)
                    .background(
                        RoundedRectangle(cornerRadius: 9)
                            .fill(tint.opacity(scheme == .light ? 0.10 : 0.16))
                    )

                Text(LocalizedStringKey(title))
                    .font(.system(size: 17))
                    .foregroundColor(.adaptiveText(scheme))

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.secondaryText(scheme))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    Group {
        ServicesView().preferredColorScheme(.dark)
        ServicesView().preferredColorScheme(.light)
    }
}
