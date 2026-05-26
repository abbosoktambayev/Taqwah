import SwiftUI

struct TermsView: View {
    @Environment(\.colorScheme) private var scheme
    
    private let sections: [(title: String, content: String)] = [
        (
            "Acceptance of Terms",
            "By downloading, installing, or using Taqwah, you agree to these Terms of Use. If you do not agree with these terms, please do not use the app."
        ),
        (
            "Purpose of the App",
            "Taqwah is designed to assist Muslims in their daily worship by providing prayer time calculations, Qibla direction, and Islamic calendar information. The app is intended as a helpful tool and spiritual companion."
        ),
        (
            "Prayer Time Accuracy",
            "Prayer times displayed in Taqwah are calculated using established astronomical algorithms and are approximations. They may vary slightly from times announced by local mosques or religious authorities. We recommend verifying prayer times with your local mosque, especially during critical times like Ramadan."
        ),
        (
            "Qibla Direction",
            "The Qibla compass feature relies on your device's built-in sensors and GPS. Accuracy may be affected by magnetic interference, device calibration, or GPS signal quality. The direction shown should be used as guidance and may not be perfectly precise in all conditions."
        ),
        (
            "Islamic Calendar",
            "The Islamic (Hijri) calendar dates shown in the app are calculated using the Umm al-Qura calendar system. Actual dates of Islamic events may differ based on local moon sighting practices in your region."
        ),
        (
            "No Religious Authority",
            "Taqwah is a technology tool and does not serve as a religious authority. For matters of Islamic jurisprudence and religious guidance, please consult qualified scholars and religious authorities."
        ),
        (
            "User Responsibility",
            "You are responsible for ensuring that the app's settings (location permissions, calculation method, time adjustments) are properly configured for your needs. The developers are not responsible for missed prayers due to incorrect settings or technical issues."
        ),
        (
            "Intellectual Property",
            "All content, design, and code within Taqwah are the property of the developer. You may not reproduce, distribute, or create derivative works without permission."
        ),
        (
            "Limitation of Liability",
            "Taqwah is provided \"as is\" without warranties of any kind. The developer shall not be liable for any direct, indirect, or consequential damages arising from the use of the app."
        ),
        (
            "Changes to Terms",
            "We reserve the right to update these Terms of Use at any time. Continued use of the app after changes constitutes acceptance of the new terms."
        ),
    ]
    
    var body: some View {
        ZStack {
            AppBackground()
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Terms of Use")
                            .font(.headline)
                            .foregroundColor(.adaptiveText(scheme))
                        
                        Text("Please read these terms carefully before using Taqwah.")
                            .font(.caption)
                            .foregroundColor(.secondaryText(scheme))
                        
                        Text("Effective: May 2025")
                            .font(.caption2)
                            .foregroundColor(.secondaryText(scheme))
                    }
                    .padding(.horizontal)
                    
                    // Terms sections
                    ForEach(Array(sections.enumerated()), id: \.offset) { index, section in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 10) {
                                Text("\(index + 1)")
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                    .foregroundColor(.adaptiveAccent(scheme))
                                    .frame(width: 24, height: 24)
                                    .background(
                                        Circle()
                                            .fill(Color.adaptiveAccent(scheme).opacity(0.15))
                                    )
                                
                                Text(section.title)
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(.adaptiveText(scheme))
                            }
                            
                            Text(section.content)
                                .font(.system(size: 14))
                                .foregroundColor(.secondaryText(scheme))
                                .lineSpacing(3)
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
                    }
                    
                    Spacer(minLength: 32)
                }
                .padding(.top, 8)
            }
        }
        .navigationTitle("Terms of Use")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("Dark") {
    NavigationStack {
        TermsView()
    }
    .preferredColorScheme(.dark)
}

#Preview("Light") {
    NavigationStack {
        TermsView()
    }
    .preferredColorScheme(.light)
}
