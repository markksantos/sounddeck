import StoreKit
import Combine
import os.log

/// Manages StoreKit 2 auto-renewable subscriptions for the Pro plan.
/// Replaces the old LemonSqueezy LicenseManager.
final class SubscriptionManager: ObservableObject {
    private let appState: AppState
    private let logger = Logger(subsystem: "com.sounddeck.app", category: "SubscriptionManager")

    static let monthlyProductID = "com.sounddeck.pro.monthly"
    static let yearlyProductID = "com.sounddeck.pro.yearly"
    static let productIDs: Set<String> = [monthlyProductID, yearlyProductID]

    @Published private(set) var products: [Product] = []
    @Published private(set) var purchaseInProgress = false
    @Published var purchaseError: String?

    private var transactionListener: Task<Void, Error>?

    init(appState: AppState) {
        self.appState = appState
        transactionListener = listenForTransactionUpdates()
    }

    deinit {
        transactionListener?.cancel()
    }

    // MARK: - Products

    func loadProducts() async {
        do {
            let storeProducts = try await Product.products(for: Self.productIDs)
            await MainActor.run {
                products = storeProducts.sorted { $0.price < $1.price }
            }
            logger.info("Loaded \(storeProducts.count) products")
        } catch {
            logger.error("Failed to load products: \(error.localizedDescription)")
        }
    }

    var monthlyProduct: Product? {
        products.first { $0.id == Self.monthlyProductID }
    }

    var yearlyProduct: Product? {
        products.first { $0.id == Self.yearlyProductID }
    }

    // MARK: - Purchase

    func purchase(_ product: Product) async {
        await MainActor.run {
            purchaseInProgress = true
            purchaseError = nil
        }

        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                if case .verified(let transaction) = verification {
                    await transaction.finish()
                    logger.info("Purchase successful: \(product.id)")
                    await updateEntitlementStatus()
                } else {
                    await MainActor.run { purchaseError = "Purchase could not be verified." }
                    logger.warning("Unverified transaction for \(product.id)")
                }
            case .userCancelled:
                logger.info("User cancelled purchase")
            case .pending:
                logger.info("Purchase pending approval")
            @unknown default:
                break
            }
        } catch {
            await MainActor.run { purchaseError = error.localizedDescription }
            logger.error("Purchase failed: \(error.localizedDescription)")
        }

        await MainActor.run { purchaseInProgress = false }
    }

    // MARK: - Restore

    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await updateEntitlementStatus()
            logger.info("Purchases restored")
        } catch {
            logger.error("Restore failed: \(error.localizedDescription)")
            await MainActor.run {
                purchaseError = "Could not restore purchases. Please try again."
            }
        }
    }

    // MARK: - Entitlement

    func updateEntitlementStatus() async {
        var foundActiveSubscription = false

        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result,
               Self.productIDs.contains(transaction.productID),
               transaction.revocationDate == nil {
                foundActiveSubscription = true
                break
            }
        }

        // Check for legacy LemonSqueezy license (grandfather existing users)
        if !foundActiveSubscription {
            foundActiveSubscription = hasLegacyLicense()
        }

        let isPro = foundActiveSubscription
        await MainActor.run {
            #if DEBUG
            // Don't override when the debug Pro toggle is active
            if appState.debugProOverride { return }
            #endif

            let wasPro = appState.isPro
            appState.isPro = isPro
            appState.currentPlan = isPro ? .pro : .free
            if wasPro != isPro {
                logger.info("Subscription status changed: isPro=\(isPro)")
            }
        }
    }

    // MARK: - Transaction Updates

    private func listenForTransactionUpdates() -> Task<Void, Error> {
        Task.detached { [weak self] in
            for await result in Transaction.updates {
                if case .verified(let transaction) = result {
                    await transaction.finish()
                    await self?.updateEntitlementStatus()
                }
            }
        }
    }

    // MARK: - Legacy License Migration

    /// Check if user has a LemonSqueezy license in Keychain (grandfather them as Pro).
    private func hasLegacyLicense() -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "com.sounddeck.license",
            kSecReturnData as String: false,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        let status = SecItemCopyMatching(query as CFDictionary, nil)
        if status == errSecSuccess {
            logger.info("Found legacy LemonSqueezy license — granting Pro access")
            return true
        }
        return false
    }
}
