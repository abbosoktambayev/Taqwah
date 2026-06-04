import SwiftUI

struct LanguageView: View {
    @Environment(\.colorScheme) private var scheme
    @StateObject private var localization = LocalizationManager.shared

    private struct LanguageOption: Identifiable {
        let id = UUID()
        let name: String
        let nativeName: String
        let code: String
        let flag: String
        let isAvailable: Bool
    }

    private let languages: [LanguageOption] = [
        LanguageOption(name: "English", nativeName: "English", code: "en", flag: "🇺🇸", isAvailable: true),
        LanguageOption(name: "Russian", nativeName: "Русский", code: "ru", flag: "🇷🇺", isAvailable: true),
        LanguageOption(name: "Kazakh", nativeName: "Қазақша", code: "kk", flag: "🇰🇿", isAvailable: true),
        LanguageOption(name: "Uzbek", nativeName: "Oʻzbekcha", code: "uz", flag: "🇺🇿", isAvailable: true),
        LanguageOption(name: "Kyrgyz", nativeName: "Кыргызча", code: "ky", flag: "🇰🇬", isAvailable: false),
        LanguageOption(name: "Azerbaijani", nativeName: "Azərbaycanca", code: "az", flag: "🇦🇿", isAvailable: false)
    ]

    var body: some View {
        List {
            Section {
                ForEach(languages) { lang in
                    Button {
                        guard lang.isAvailable else { return }
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        localization.setLanguage(lang.code)
                    } label: {
                        HStack(spacing: 12) {
                            Text(lang.flag)
                                .font(.title2)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(LocalizedStringKey(lang.name))
                                    .foregroundStyle(lang.isAvailable ? Color.adaptiveText(scheme) : Color.secondaryText(scheme))
                                Text(lang.nativeName)
                                    .font(.caption)
                                    .foregroundStyle(Color.secondaryText(scheme))
                            }

                            Spacer()

                            if !lang.isAvailable {
                                Text("Coming Soon")
                                    .font(.caption)
                                    .foregroundStyle(Color.secondaryText(scheme))
                            } else if localization.languageCode == lang.code {
                                Image(systemName: "checkmark")
                                    .font(.body.weight(.semibold))
                                    .foregroundStyle(Color.adaptiveAccent(scheme))
                            }
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .disabled(!lang.isAvailable)
                    .listRowBackground(Color.cardBackground(scheme))
                }
            } footer: {
                Text("More languages will be available in future updates. If you'd like to help translate Taqwah, please contact us through the Support page.")
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(AppBackground())
        .navigationTitle("Language")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("Dark") {
    NavigationStack { LanguageView() }.preferredColorScheme(.dark)
}

#Preview("Light") {
    NavigationStack { LanguageView() }.preferredColorScheme(.light)
}
