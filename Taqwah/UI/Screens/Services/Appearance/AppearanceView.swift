import SwiftUI

struct AppearanceView: View {
    @ObservedObject private var manager = SettingsManager.shared
    @Environment(\.colorScheme) private var scheme

    private struct ThemeOption: Identifiable {
        let id: String
        let title: String
        let subtitle: String
        let icon: String
    }

    private let options: [ThemeOption] = [
        ThemeOption(id: "system", title: "System", subtitle: "Match your device", icon: "iphone"),
        ThemeOption(id: "light", title: "Light", subtitle: "Always bright", icon: "sun.max.fill"),
        ThemeOption(id: "dark", title: "Dark", subtitle: "Always dark", icon: "moon.stars.fill")
    ]

    var body: some View {
        ZStack {
            AppBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    sectionLabel("CHOOSE YOUR THEME")

                    HStack(spacing: 14) {
                        ForEach(options) { option in
                            themeCard(option)
                        }
                    }
                    .padding(.horizontal)

                    HStack(spacing: 10) {
                        Image(systemName: "paintbrush.pointed.fill")
                            .foregroundColor(.adaptiveAccent(scheme))
                            .font(.subheadline)
                        Text("The app updates instantly when you pick a theme.")
                            .font(.caption)
                            .foregroundColor(.secondaryText(scheme))
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 22)
                            .fill(Color.adaptiveAccent(scheme).opacity(0.08))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 22)
                            .stroke(Color.adaptiveAccent(scheme).opacity(0.2), lineWidth: 1)
                    )
                    .padding(.horizontal)

                    Spacer(minLength: 24)
                }
                .padding(.top, 8)
            }
        }
        .navigationTitle("Appearance")
        .navigationBarTitleDisplayMode(.inline)
        .foregroundColor(.adaptiveText(scheme))
    }

    // MARK: - Theme Card

    private func themeCard(_ option: ThemeOption) -> some View {
        let isSelected = manager.colorSchemeSelection == option.id

        return Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            withAnimation(.easeInOut(duration: 0.2)) {
                manager.colorSchemeSelection = option.id
            }
        } label: {
            VStack(spacing: 12) {
                // Mini preview swatch
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(previewGradient(for: option.id))
                        .frame(height: 84)

                    Image(systemName: option.icon)
                        .font(.system(size: 26))
                        .foregroundColor(previewIconColor(for: option.id))
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.cardBorder(scheme), lineWidth: 1)
                )

                VStack(spacing: 2) {
                    Text(option.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.adaptiveText(scheme))
                    Text(option.subtitle)
                        .font(.caption2)
                        .foregroundColor(.secondaryText(scheme))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(isSelected ? .adaptiveAccent(scheme) : .uncheckedBorder(scheme))
            }
            .padding(12)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 22)
                    .fill(Color.glassFill(scheme))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22)
                    .stroke(isSelected ? Color.adaptiveAccent(scheme) : Color.glassBorder(scheme),
                            lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
    }

    private func previewGradient(for id: String) -> LinearGradient {
        switch id {
        case "light":
            return LinearGradient(colors: [.paper, .softIvory],
                                  startPoint: .top, endPoint: .bottom)
        case "dark":
            return LinearGradient(colors: [.obsidian, .deepElevated],
                                  startPoint: .top, endPoint: .bottom)
        default:
            return LinearGradient(colors: [.paper, .obsidian],
                                  startPoint: .top, endPoint: .bottom)
        }
    }

    private func previewIconColor(for id: String) -> Color {
        switch id {
        case "light": return .mutedEmerald
        case "dark":  return .warmGold
        default:      return .parchment
        }
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(LocalizedStringKey(text))
            .font(.mono(11)).tracking(0.6)
            .foregroundColor(.sectionTitle(scheme))
            .padding(.horizontal)
    }
}

#Preview("Dark") {
    NavigationStack { AppearanceView() }.preferredColorScheme(.dark)
}

#Preview("Light") {
    NavigationStack { AppearanceView() }.preferredColorScheme(.light)
}
