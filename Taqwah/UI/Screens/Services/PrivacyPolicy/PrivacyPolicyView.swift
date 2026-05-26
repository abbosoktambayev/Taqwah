import SwiftUI

struct PrivacyPolicyView: View {
    @Environment(\.colorScheme) private var scheme
    
    private let sections: [(title: String, icon: String, content: String)] = [
        (
            "Location Data",
            "location.fill",
            "Taqwah uses your device's location to calculate accurate prayer times for your area and to determine the Qibla (direction of Mecca). Location data is processed entirely on your device and is never transmitted to any server."
        ),
        (
            "Compass & Heading",
            "safari.fill",
            "The Qibla Compass feature uses your device's built-in compass sensor. Heading data is used in real-time only and is not stored or shared."
        ),
        (
            "Data Storage",
            "internaldrive.fill",
            "Your preferences (such as prayer notification settings, time adjustments, and appearance) are stored locally on your device using standard iOS storage. No personal data is collected or stored on external servers."
        ),
        (
            "No Personal Data Collection",
            "person.crop.circle.badge.xmark",
            "Taqwah does not require you to create an account and does not collect, store, or process any personal information such as your name, email address, or phone number."
        ),
        (
            "No Third-Party Sharing",
            "hand.raised.fill",
            "We do not share any of your data with third parties. There are no analytics, advertising SDKs, or tracking tools embedded in the app."
        ),
        (
            "No Analytics or Tracking",
            "eye.slash.fill",
            "Taqwah does not use any analytics frameworks or tracking tools. Your usage of the app is completely private."
        ),
        (
            "Children's Privacy",
            "figure.and.child.holdinghands",
            "Taqwah does not knowingly collect any information from children. The app is suitable for users of all ages."
        ),
        (
            "Changes to This Policy",
            "doc.text.fill",
            "We may update this Privacy Policy from time to time. Any changes will be reflected in app updates. We encourage you to review this page periodically."
        ),
    ]
    
    var body: some View {
        ZStack {
            AppBackground()
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Your privacy matters to us")
                            .font(.headline)
                            .foregroundColor(.adaptiveText(scheme))
                        
                        Text("Last updated: May 2025")
                            .font(.caption)
                            .foregroundColor(.secondaryText(scheme))
                    }
                    .padding(.horizontal)
                    
                    // Policy sections
                    ForEach(Array(sections.enumerated()), id: \.offset) { _, section in
                        policyCard(title: section.title, icon: section.icon, content: section.content)
                    }
                    
                    // Contact
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "envelope.fill")
                            .foregroundColor(.adaptiveAccent(scheme))
                            .font(.subheadline)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Questions?")
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(.adaptiveText(scheme))
                            
                            Text("If you have questions about this Privacy Policy, please contact us through the Support page.")
                                .font(.caption)
                                .foregroundColor(.secondaryText(scheme))
                        }
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
        .navigationTitle("Privacy Policy")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Components
    
    private func policyCard(title: String, icon: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(.adaptiveAccent(scheme))
                    .frame(width: 24)
                
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.adaptiveText(scheme))
            }
            
            Text(content)
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
}

#Preview("Dark") {
    NavigationStack {
        PrivacyPolicyView()
    }
    .preferredColorScheme(.dark)
}

#Preview("Light") {
    NavigationStack {
        PrivacyPolicyView()
    }
    .preferredColorScheme(.light)
}
