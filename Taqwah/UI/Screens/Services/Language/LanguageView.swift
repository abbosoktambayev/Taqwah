import SwiftUI

struct LanguageView: View {
    @Environment(\.colorScheme) private var scheme
    
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
        LanguageOption(name: "Russian", nativeName: "Русский", code: "ru", flag: "🇷🇺", isAvailable: false),
        LanguageOption(name: "Kazakh", nativeName: "Қазақша", code: "kk", flag: "🇰🇿", isAvailable: false),
    ]
    
    var body: some View {
        ZStack {
            AppBackground()
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    
                    sectionLabel("SELECT LANGUAGE")
                    
                    VStack(spacing: 0) {
                        ForEach(Array(languages.enumerated()), id: \.element.id) { index, lang in
                            HStack(spacing: 14) {
                                Text(lang.flag)
                                    .font(.title2)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(lang.name)
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(lang.isAvailable ? .adaptiveText(scheme) : .secondaryText(scheme))
                                    
                                    Text(lang.nativeName)
                                        .font(.caption)
                                        .foregroundColor(.secondaryText(scheme))
                                }
                                
                                Spacer()
                                
                                if lang.isAvailable {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.adaptiveAccent(scheme))
                                        .font(.title3)
                                } else {
                                    Text("Coming Soon")
                                        .font(.caption.weight(.medium))
                                        .foregroundColor(.secondaryText(scheme))
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 4)
                                        .background(
                                            Capsule()
                                                .fill(Color.glassFill(scheme))
                                        )
                                        .overlay(
                                            Capsule()
                                                .stroke(Color.glassBorder(scheme), lineWidth: 1)
                                        )
                                }
                            }
                            .padding(.vertical, 10)
                            .opacity(lang.isAvailable ? 1 : 0.6)
                            
                            if index < languages.count - 1 {
                                Rectangle()
                                    .fill(Color.dividerColor(scheme))
                                    .frame(height: 1)
                                    .padding(.vertical, 4)
                            }
                        }
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
                    
                    // Info note
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "globe")
                            .foregroundColor(.adaptiveAccent(scheme))
                            .font(.subheadline)
                        
                        Text("More languages will be available in future updates. If you'd like to help translate Taqwah, please contact us through the Support page.")
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
        .navigationTitle("Language")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .foregroundColor(.sectionTitle(scheme))
            .padding(.horizontal)
    }
}

#Preview("Dark") {
    NavigationStack {
        LanguageView()
    }
    .preferredColorScheme(.dark)
}

#Preview("Light") {
    NavigationStack {
        LanguageView()
    }
    .preferredColorScheme(.light)
}
