import SwiftUI

struct ServicesView: View {
    @Environment(\.colorScheme) private var scheme
    @StateObject private var localization = LocalizationManager.shared

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()
                    .foregroundColor(.primary)

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {

                        // MARK: - PRAYER TOOLS
                        sectionTitle("PRAYER TOOLS")

                        glassGroup {
                            VStack(spacing: 0) {
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

                        // MARK: - APP SETTINGS
                        sectionTitle("APP SETTINGS")

                        glassGroup {
                            VStack(spacing: 0) {
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

                        // MARK: - SUPPORT
                        sectionTitle("SUPPORT")

                        glassGroup {
                            serviceRow("Support Taqwah", "heart.fill", .prayerAccent) {
                                DonateView()
                            }
                        }

                        // MARK: - INFORMATION
                        sectionTitle("INFORMATION")

                        glassGroup {
                            VStack(spacing: 0) {
                                serviceRow("About App", "info.circle.fill", .secondaryText(scheme)) {
                                    AboutView()
                                }
                                dividerLine
                                serviceRow("Privacy Policy", "shield.lefthalf.filled", .secondaryText(scheme)) {
                                    PrivacyPolicyView()
                                }
                                dividerLine
                                serviceRow("Terms of Use", "doc.text.fill", .secondaryText(scheme)) {
                                    TermsView()
                                }
                                dividerLine
                                serviceRow("Contact Support", "bubble.left.and.bubble.right.fill", .secondaryText(scheme)) {
                                    SupportView()
                                }
                            }
                        }

                        Spacer(minLength: 32)
                    }
                    .padding(.top, 8)
                }
                .safeAreaPadding(.bottom, 96)
            }
            .navigationTitle(localization.localized("Services"))
            .navigationBarTitleDisplayMode(.large)
            .foregroundColor(.adaptiveText(scheme))
        }
    }

    // MARK: - Components (moved inside struct)

    private func sectionTitle(_ text: String) -> some View {
        Text(LocalizedStringKey(text))
            .font(.mono(11)).tracking(0.6)
            .foregroundColor(.sectionTitle(scheme))
            .padding(.horizontal)
    }

    private func glassGroup(@ViewBuilder content: () -> some View) -> some View {
        VStack(spacing: 0) {
            content()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 26)
                .fill(Color.glassFill(scheme))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 26)
                .stroke(Color.glassBorder(scheme), lineWidth: 1)
        )
        .shadow(
            color: Color.black.opacity(scheme == .light ? 0.06 : 0.35),
            radius: scheme == .light ? 10 : 20,
            y: scheme == .light ? 4 : 10
        )
        .padding(.horizontal)
    }

    private var dividerLine: some View {
        Rectangle()
            .fill(Color.dividerColor(scheme))
            .frame(height: 1)
            .padding(.vertical, 6)
    }

    private func serviceRow<Destination: View>(
        _ title: String,
        _ icon: String,
        _ tint: Color,
        destination: @escaping () -> Destination
    ) -> some View {
        NavigationLink(destination: destination) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(tint)

                Text(LocalizedStringKey(title))
                    .font(.system(size: 17))
                    .foregroundColor(.adaptiveText(scheme))

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.secondaryText(scheme))
            }
            .padding(.vertical, 10)
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
