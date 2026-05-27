import Foundation
import StoreKit
import Combine

/// Voluntary "tip jar" donations via StoreKit 2 consumable in-app purchases.
@MainActor
final class TipJarManager: ObservableObject {

    static let shared = TipJarManager()

    enum PurchaseState: Equatable {
        case idle
        case purchasing
        case success
        case failed(String)
    }

    @Published var products: [Product] = []
    @Published var isLoading = false
    @Published var state: PurchaseState = .idle

    /// Product identifiers — must match App Store Connect / the .storekit file.
    static let productIDs = [
        "com.abbos.Taqwah.tip.small",
        "com.abbos.Taqwah.tip.medium",
        "com.abbos.Taqwah.tip.large"
    ]

    private init() {}

    // MARK: - Loading

    func loadProducts() async {
        guard products.isEmpty else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            let loaded = try await Product.products(for: Self.productIDs)
            products = loaded.sorted { $0.price < $1.price }
        } catch {
            products = []
        }
    }

    // MARK: - Purchase

    func purchase(_ product: Product) async {
        state = .purchasing
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                switch verification {
                case .verified(let transaction):
                    // Consumable tip — nothing to unlock, just finish it.
                    await transaction.finish()
                    state = .success
                case .unverified:
                    state = .failed("Could not verify the purchase.")
                }
            case .userCancelled:
                state = .idle
            case .pending:
                state = .idle
            @unknown default:
                state = .idle
            }
        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    func resetState() {
        state = .idle
    }
}
