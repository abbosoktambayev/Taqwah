import SwiftUI

struct ServicesView: View {

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
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
        }
    }
}

//
// MARK: - COMPONENTS
//

private func sectionTitle(_ text: String) -> some View {
    Text(text)
        .font(.caption.weight(.semibold))
        .foregroundColor(.white.opacity(0.5))
        .padding(.horizontal)
}

private func glassGroup(@ViewBuilder content: () -> some View) -> some View {
    VStack(spacing: 0) {
        content()
    }
    .padding(16)
    .background(
        RoundedRectangle(cornerRadius: 26)
            .fill(Color.white.opacity(0.08))
    )
    .overlay(
        RoundedRectangle(cornerRadius: 26)
            .stroke(Color.white.opacity(0.1), lineWidth: 1)
    )
    .shadow(color: .black.opacity(0.35), radius: 20, y: 10)
    .padding(.horizontal)
}

private var dividerLine: some View {
    Rectangle()
        .fill(Color.white.opacity(0.08))
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
                .foregroundColor(.white)

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.white.opacity(0.4))
        }
        .padding(.vertical, 10)
    }
    .buttonStyle(.plain)
}

#Preview {
    ServicesView()
        .preferredColorScheme(.dark)
}
