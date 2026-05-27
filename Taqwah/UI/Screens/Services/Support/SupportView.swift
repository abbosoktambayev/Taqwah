import SwiftUI

struct SupportView: View {
    @Environment(\.colorScheme) private var scheme
    
    private struct FAQItem: Identifiable {
        let id = UUID()
        let question: String
        let answer: String
    }
    
    private let faqItems: [FAQItem] = [
        FAQItem(
            question: "Why are prayer times different from my local mosque?",
            answer: "Prayer times in Taqwah are calculated using astronomical algorithms (Muftiyat KZ method). Local mosques may use different calculation methods or make manual adjustments. You can use the Time Adjustments feature in Prayer Settings to fine-tune the times."
        ),
        FAQItem(
            question: "How do I calibrate the Qibla compass?",
            answer: "Move your phone in a figure-8 motion to calibrate the compass sensor. Make sure you're away from magnetic objects (speakers, magnets, metal surfaces). For best results, hold your phone flat and level."
        ),
        FAQItem(
            question: "Why is the Qibla compass not accurate?",
            answer: "Compass accuracy depends on your device's magnetometer. Nearby metal objects, electronic devices, or magnetic fields can interfere. Try moving to an open area and recalibrating. Also ensure Location Services are enabled."
        ),
        FAQItem(
            question: "Can I change the calculation method?",
            answer: "Currently, Taqwah uses the Muftiyat KZ calculation method. Support for additional calculation methods (ISNA, MWL, Egyptian, etc.) will be added in future updates."
        ),
        FAQItem(
            question: "How do I get prayer notifications?",
            answer: "Go to Services → Adhan Sound and enable notifications for each prayer. Make sure you've allowed notifications for Taqwah in your device's Settings app."
        ),
        FAQItem(
            question: "Is the Islamic calendar based on moon sighting?",
            answer: "Taqwah uses the Umm al-Qura calendar system for Hijri dates. This is a calculated calendar and may differ from dates based on local moon sighting in your region."
        ),
    ]
    
    @State private var expandedFAQ: UUID?
    
    var body: some View {
        ZStack {
            AppBackground()
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    
                    // MARK: - Contact Header
                    VStack(spacing: 16) {
                        Image(systemName: "bubble.left.and.bubble.right.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.adaptiveAccent(scheme))
                        
                        Text("How can we help?")
                            .font(.title3.weight(.semibold))
                            .foregroundColor(.adaptiveText(scheme))
                        
                        Text("We'd love to hear from you. Reach out through any of the channels below.")
                            .font(.subheadline)
                            .foregroundColor(.secondaryText(scheme))
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    
                    // MARK: - Contact Methods
                    sectionLabel("CONTACT US")
                    
                    VStack(spacing: 0) {
                        contactRow(
                            icon: "envelope.fill",
                            title: "Email",
                            subtitle: "taqwah.app@gmail.com",
                            action: {
                                if let url = URL(string: "mailto:taqwah.app@gmail.com") {
                                    UIApplication.shared.open(url)
                                }
                            }
                        )
                        
                        divider
                        
                        contactRow(
                            icon: "paperplane.fill",
                            title: "Telegram",
                            subtitle: "@taqwah_support",
                            action: {
                                if let url = URL(string: "https://t.me/taqwah_support") {
                                    UIApplication.shared.open(url)
                                }
                            }
                        )
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
                    
                    // MARK: - FAQ
                    sectionLabel("FREQUENTLY ASKED QUESTIONS")
                    
                    VStack(spacing: 12) {
                        ForEach(faqItems) { item in
                            faqCard(item)
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer(minLength: 32)
                }
                .padding(.top, 8)
            }
        }
        .navigationTitle("Support")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Components
    
    private func sectionLabel(_ text: String) -> some View {
        Text(LocalizedStringKey(text))
            .font(.caption.weight(.semibold))
            .foregroundColor(.sectionTitle(scheme))
            .padding(.horizontal)
    }
    
    private func contactRow(icon: String, title: String, subtitle: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(.adaptiveAccent(scheme))
                    .frame(width: 28)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.adaptiveText(scheme))
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondaryText(scheme))
                }
                
                Spacer()
                
                Image(systemName: "arrow.up.right")
                    .font(.caption)
                    .foregroundColor(.secondaryText(scheme))
            }
            .padding(.vertical, 10)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
    
    private func faqCard(_ item: FAQItem) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: 0.25)) {
                    if expandedFAQ == item.id {
                        expandedFAQ = nil
                    } else {
                        expandedFAQ = item.id
                    }
                }
            } label: {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "questionmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.adaptiveAccent(scheme))
                    
                    Text(item.question)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.adaptiveText(scheme))
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    Image(systemName: expandedFAQ == item.id ? "chevron.up" : "chevron.down")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.secondaryText(scheme))
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            
            if expandedFAQ == item.id {
                Text(item.answer)
                    .font(.system(size: 14))
                    .foregroundColor(.secondaryText(scheme))
                    .lineSpacing(3)
                    .padding(.top, 10)
                    .padding(.leading, 30)
                    .transition(.opacity.combined(with: .move(edge: .top)))
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
    }
    
    private var divider: some View {
        Rectangle()
            .fill(Color.dividerColor(scheme))
            .frame(height: 1)
            .padding(.vertical, 4)
    }
}

#Preview("Dark") {
    NavigationStack {
        SupportView()
    }
    .preferredColorScheme(.dark)
}

#Preview("Light") {
    NavigationStack {
        SupportView()
    }
    .preferredColorScheme(.light)
}
