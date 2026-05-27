import SwiftUI
import StoreKit

struct DonateView: View {
    @Environment(\.colorScheme) private var scheme
    @StateObject private var tipJar = TipJarManager.shared
    @State private var showThanks = false

    var body: some View {
        ZStack {
            AppBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    heroSection
                    tipsSection
                    noteSection
                    Spacer(minLength: 24)
                }
                .padding(.top, 8)
            }
        }
        .navigationTitle("Support Taqwah")
        .navigationBarTitleDisplayMode(.inline)
        .task { await tipJar.loadProducts() }
        .onChange(of: tipJar.state) { _, newState in
            if newState == .success { showThanks = true }
        }
        .alert("JazakAllahu Khayran! 🤲", isPresented: $showThanks) {
            Button("You're welcome") { tipJar.resetState() }
        } message: {
            Text("Your support helps keep Taqwah free and ad-free for the ummah. Thank you.")
        }
    }

    // MARK: - Hero

    private var heroSection: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.adaptiveAccent(scheme).opacity(0.15))
                    .frame(width: 88, height: 88)
                Image(systemName: "heart.fill")
                    .font(.system(size: 38))
                    .foregroundColor(.adaptiveAccent(scheme))
            }

            Text("Support the App")
                .font(.title2.weight(.bold))
                .foregroundColor(.adaptiveText(scheme))

            Text("Taqwah is free, ad-free, and built with love. If it benefits you, consider leaving a tip to support its development — it's completely optional.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondaryText(scheme))
                .padding(.horizontal, 24)
        }
        .padding(.top, 12)
    }

    // MARK: - Tips

    private var tipsSection: some View {
        VStack(spacing: 12) {
            if tipJar.isLoading {
                ProgressView()
                    .tint(.adaptiveAccent(scheme))
                    .padding(.vertical, 24)
            } else if tipJar.products.isEmpty {
                Text("Tips are not available right now. Please try again later.")
                    .font(.subheadline)
                    .foregroundColor(.secondaryText(scheme))
                    .multilineTextAlignment(.center)
                    .padding()
            } else {
                ForEach(tipJar.products, id: \.id) { product in
                    tipRow(product)
                }
            }
        }
        .padding(.horizontal)
    }

    private func tipRow(_ product: Product) -> some View {
        Button {
            Task { await tipJar.purchase(product) }
        } label: {
            HStack(spacing: 14) {
                Image(systemName: icon(for: product))
                    .font(.system(size: 22))
                    .foregroundColor(.adaptiveAccent(scheme))
                    .frame(width: 32)

                VStack(alignment: .leading, spacing: 2) {
                    Text(product.displayName)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.adaptiveText(scheme))
                    Text(product.description)
                        .font(.caption)
                        .foregroundColor(.secondaryText(scheme))
                }

                Spacer()

                Text(product.displayPrice)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Capsule().fill(Color.adaptiveAccent(scheme)))
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 22)
                    .fill(Color.glassFill(scheme))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22)
                    .stroke(Color.glassBorder(scheme), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .disabled(tipJar.state == .purchasing)
    }

    private func icon(for product: Product) -> String {
        switch product.id {
        case TipJarManager.productIDs.first: return "cup.and.saucer.fill"
        case TipJarManager.productIDs.last:  return "gift.fill"
        default:                             return "heart.circle.fill"
        }
    }

    // MARK: - Note

    private var noteSection: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "info.circle.fill")
                .foregroundColor(.adaptiveAccent(scheme))
                .font(.subheadline)
            Text("Tips are a one-time, optional donation and do not unlock any features — everything in Taqwah is free for everyone.")
                .font(.caption)
                .foregroundColor(.secondaryText(scheme))
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(Color.adaptiveAccent(scheme).opacity(0.08))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(Color.adaptiveAccent(scheme).opacity(0.2), lineWidth: 1)
        )
        .padding(.horizontal)
    }
}

#Preview {
    NavigationStack { DonateView() }
        .preferredColorScheme(.dark)
}
