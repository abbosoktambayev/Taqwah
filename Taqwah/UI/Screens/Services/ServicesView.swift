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

                        // MARK: - PRAYER TOOLS
                        sectionTitle("PRAYER TOOLS")

                        glassGroup {
                            VStack(spacing: 0) {
                                serviceRow("Prayer Settings", "gearshape.fill", .green) {
                                    PrayerSettingsView()
                                }
                                dividerLine
                                serviceRow("Calendar", "calendar", .green) {
                                    IslamicCalendarView()
                                }
                                dividerLine
                                serviceRow("Qibla Compass", "safari.fill", .green) {
                                    QiblaView()
                                }
                            }
                        }

                        // MARK: - APP SETTINGS
                        sectionTitle("APP SETTINGS")

                        glassGroup {
                            VStack(spacing: 0) {
                                serviceRow("Adhan Sound", "speaker.wave.2.fill", .green) {
                                    AdhanSettingsView()
                                }
                                dividerLine
                                serviceRow("Appearance", "paintpalette.fill", .green) {
                                    AppearanceView()
                                }
                                dividerLine
                                serviceRow("Language", "globe", .green) {
                                    LanguageView()
                                }
                            }
                        }

                        // MARK: - INFORMATION
                        sectionTitle("INFORMATION")

                        glassGroup {
                            VStack(spacing: 0) {
                                serviceRow("About App", "info.circle.fill", .gray) {
                                    AboutView()
                                }
                                dividerLine
                                serviceRow("Privacy Policy", "shield.lefthalf.filled", .gray) {
                                    PrivacyPolicyView()
                                }
                                dividerLine
                                serviceRow("Terms of Use", "doc.text.fill", .gray) {
                                    TermsView()
                                }
                                dividerLine
                                serviceRow("Contact Support", "bubble.left.and.bubble.right.fill", .gray) {
                                    SupportView()
                                }
                            }
                        }

                        Spacer(minLength: 32)
                    }
                    .padding(.top, 8)
                }
            }
            .navigationTitle("Services")
            .navigationBarTitleDisplayMode(.large)
            .foregroundColor(.adaptiveText(scheme))
        }
    }

    // MARK: - Components (moved inside struct)

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.caption.weight(.semibold))
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

                Text(title)
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
