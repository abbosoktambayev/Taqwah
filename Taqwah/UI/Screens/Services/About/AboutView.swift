import SwiftUI

struct AboutView: View {
    @Environment(\.colorScheme) private var scheme
    
    var body: some View {
        ZStack {
            AppBackground()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    Spacer(minLength: 24)
                    
                    // MARK: - App Icon & Name
                    VStack(spacing: 16) {
                        // App icon placeholder
                        ZStack {
                            RoundedRectangle(cornerRadius: 28)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.adaptiveAccent(scheme),
                                            Color.adaptiveAccent(scheme).opacity(0.7)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 100, height: 100)
                                .shadow(color: Color.accentShadow(scheme), radius: 16, y: 8)
                            
                            Image(systemName: "moon.stars.fill")
                                .font(.system(size: 44))
                                .foregroundColor(.white)
                        }
                        
                        VStack(spacing: 6) {
                            Text("Taqwah")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(.adaptiveText(scheme))
                            
                            Text("Your Guiding Light")
                                .font(.subheadline.weight(.medium))
                                .foregroundColor(.adaptiveAccent(scheme))
                            
                            Text("Version 1.0.0")
                                .font(.caption)
                                .foregroundColor(.secondaryText(scheme))
                                .padding(.top, 2)
                        }
                    }
                    
                    // MARK: - Description
                    VStack(spacing: 12) {
                        Text("Taqwah is a beautifully designed Islamic prayer companion app that helps you stay connected with your daily prayers, find the Qibla direction, and keep track of important Islamic dates.")
                            .font(.subheadline)
                            .foregroundColor(.secondaryText(scheme))
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                    }
                    .padding(.horizontal, 24)
                    
                    // MARK: - Info Cards
                    VStack(spacing: 0) {
                        infoRow(icon: "person.fill", title: "Developer", value: "Abbos Oktambayev")
                        divider
                        infoRow(icon: "swift", title: "Built with", value: "SwiftUI")
                        divider
                        infoRow(icon: "iphone", title: "Platform", value: "iOS 17+")
                        divider
                        infoRow(icon: "heart.fill", title: "Made with", value: "Love & Taqwah")
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
                    
                    // MARK: - Acknowledgment
                    VStack(spacing: 8) {
                        Text("بسم الله الرحمن الرحيم")
                            .font(.title3)
                            .foregroundColor(.adaptiveAccent(scheme))
                        
                        Text("In the name of Allah, the Most Gracious, the Most Merciful")
                            .font(.caption)
                            .foregroundColor(.secondaryText(scheme))
                            .multilineTextAlignment(.center)
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 28)
                            .fill(Color.adaptiveAccent(scheme).opacity(0.08))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 28)
                            .stroke(Color.adaptiveAccent(scheme).opacity(0.2), lineWidth: 1)
                    )
                    .padding(.horizontal)
                    
                    Text("© 2025 Taqwah. All rights reserved.")
                        .font(.caption2)
                        .foregroundColor(.secondaryText(scheme))
                    
                    Spacer(minLength: 32)
                }
            }
        }
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Components
    
    private func infoRow(icon: String, title: String, value: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.adaptiveAccent(scheme))
                .frame(width: 28)
            
            Text(title)
                .font(.system(size: 15))
                .foregroundColor(.secondaryText(scheme))
            
            Spacer()
            
            Text(value)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.adaptiveText(scheme))
        }
        .padding(.vertical, 8)
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
        AboutView()
    }
    .preferredColorScheme(.dark)
}

#Preview("Light") {
    NavigationStack {
        AboutView()
    }
    .preferredColorScheme(.light)
}
