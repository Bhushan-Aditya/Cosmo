import Foundation
import StoreKit

@MainActor
final class PurchaseManager: ObservableObject {
    static let shared = PurchaseManager()

    static let premiumLifetimeProductID = "premium_lifetime"

    enum PurchaseFlowResult {
        case success
        case pending
        case cancelled
        case failed(String)
    }

    @Published private(set) var premiumProduct: Product?
    @Published private(set) var hasPremium: Bool
    @Published private(set) var isLoadingProduct = false

    private let defaults = UserDefaults.standard
    private let urlSession = URLSession.shared
    private let localPremiumKey = "cosmo.iap.premiumLifetime"
    private let entitlementSyncFunctionName = "sync_storekit_entitlement"
    private var transactionUpdatesTask: Task<Void, Never>?
    private var latestPremiumTransactionID: String?
    private var syncTask: Task<Void, Never>?
    private var lastSyncAt: Date?

    private init() {
        hasPremium = defaults.bool(forKey: localPremiumKey)

        transactionUpdatesTask = Task { [weak self] in
            await self?.observeTransactionUpdates()
        }

        Task { [weak self] in
            guard let self else { return }
            await self.refreshEntitlementStatus()
            // Avoid auth churn while user is logged out.
            if AuthSessionStore.shared.hasValidLogin {
                await self.refreshAndSyncEntitlements()
            }
            await self.loadProductIfNeeded()
        }
    }

    deinit {
        transactionUpdatesTask?.cancel()
    }

    func loadProductIfNeeded() async {
        guard premiumProduct == nil else { return }
        isLoadingProduct = true
        defer { isLoadingProduct = false }

        do {
            let products = try await Product.products(for: [Self.premiumLifetimeProductID])
            premiumProduct = products.first
        } catch {
#if DEBUG
            print("[PurchaseManager] Product fetch failed: \(error.localizedDescription)")
#endif
        }
    }

    func refreshEntitlementStatus() async {
        var premiumActive = false
        var latestTransactionID: String?

        for await verification in Transaction.currentEntitlements {
            guard case .verified(let transaction) = verification else { continue }
            guard transaction.productID == Self.premiumLifetimeProductID else { continue }

            latestTransactionID = String(transaction.id)
            if transaction.revocationDate == nil {
                premiumActive = true
            }
        }

        latestPremiumTransactionID = latestTransactionID
        setPremiumLocally(premiumActive)
    }

    func refreshAndSyncEntitlements() async {
        guard AuthSessionStore.shared.hasValidLogin else { return }
        if let syncTask, !syncTask.isCancelled {
            await syncTask.value
            return
        }
        if let lastSyncAt, Date().timeIntervalSince(lastSyncAt) < 2 {
            return
        }

        let task = Task { [weak self] in
            guard let self else { return }
            await self.refreshEntitlementStatus()
            await self.syncPremiumEntitlementToSupabaseIfPossible()
        }
        syncTask = task
        await task.value
        lastSyncAt = Date()
        syncTask = nil
    }

    /// Runs after StoreKit reports a successful purchase so server-side limits catch up quickly.
    func syncPremiumWithBackendAfterPurchaseFlow() async {
        await syncPremiumEntitlementToSupabaseIfPossible()
    }

    func purchasePremium() async -> PurchaseFlowResult {
        await loadProductIfNeeded()

        guard let product = premiumProduct else {
            return .failed("Premium product is not available right now.")
        }

        do {
            let result: Product.PurchaseResult
            if let userId = AuthSessionStore.shared.currentUserId,
               let appAccountToken = UUID(uuidString: userId) {
                result = try await product.purchase(options: [.appAccountToken(appAccountToken)])
            } else {
                result = try await product.purchase()
            }

            switch result {
            case .success(let verification):
                guard case .verified(let transaction) = verification else {
                    return .failed("Purchase could not be verified.")
                }

                await applyVerifiedTransaction(transaction)
                await transaction.finish()
                return .success

            case .pending:
                return .pending

            case .userCancelled:
                return .cancelled

            @unknown default:
                return .failed("Purchase did not complete.")
            }
        } catch {
            return .failed(error.localizedDescription)
        }
    }

    func restorePurchases() async -> Bool {
        do {
            try await AppStore.sync()
            await refreshEntitlementStatus()
            await syncPremiumEntitlementToSupabaseIfPossible()
            return hasPremium
        } catch {
#if DEBUG
            print("[PurchaseManager] Restore failed: \(error.localizedDescription)")
#endif
            return false
        }
    }

    var premiumPriceLabel: String {
        premiumProduct?.displayPrice ?? "₹200"
    }

    /// Resets in-app premium cache after the Supabase user is deleted. StoreKit entitlements on device are unchanged; the next sign-in re-evaluates.
    func resetLocalStateAfterServerAccountDeleted() {
        latestPremiumTransactionID = nil
        setPremiumLocally(false)
    }

    private func observeTransactionUpdates() async {
        for await update in Transaction.updates {
            guard case .verified(let transaction) = update else { continue }
            await applyVerifiedTransaction(transaction)
            await transaction.finish()
        }
    }

    private func applyVerifiedTransaction(_ transaction: Transaction) async {
        guard transaction.productID == Self.premiumLifetimeProductID else { return }

        latestPremiumTransactionID = String(transaction.id)
        if transaction.revocationDate == nil {
            setPremiumLocally(true)
            await syncPremiumEntitlementToSupabaseIfPossible(
                latestTransactionID: String(transaction.id)
            )
        } else {
            setPremiumLocally(false)
            await syncPremiumEntitlementToSupabaseIfPossible(
                latestTransactionID: String(transaction.id)
            )
        }
    }

    private func setPremiumLocally(_ premium: Bool) {
        hasPremium = premium
        defaults.set(premium, forKey: localPremiumKey)
    }

    private func syncPremiumEntitlementToSupabaseIfPossible(latestTransactionID: String? = nil) async {
        guard AuthSessionStore.shared.hasValidLogin else { return }
        guard AuthSessionStore.shared.currentUserId != nil else { return }
        let transactionIDForSync = latestTransactionID ?? latestPremiumTransactionID

        let maxAttempts = 4
        let delayBeforeRetry: [UInt64] = [
            400_000_000,
            900_000_000,
            1_800_000_000,
        ]

        for attempt in 0..<maxAttempts {
            if attempt > 0 {
                try? await Task.sleep(nanoseconds: delayBeforeRetry[attempt - 1])
            }
            do {
                try await callEntitlementSyncFunction(transactionID: transactionIDForSync)
                return
            } catch {
#if DEBUG
                print("[PurchaseManager] Entitlement sync attempt \(attempt + 1)/\(maxAttempts) failed: \(error.localizedDescription)")
#endif
                if let restError = error as? SupabaseRESTError,
                   case .server(let status, _) = restError,
                   (400..<500).contains(status),
                   status != 401,
                   status != 408,
                   status != 429 {
                    return
                }
            }
        }
    }

    private func callEntitlementSyncFunction(transactionID: String?) async throws {
        let body = EntitlementSyncRequest(
            productId: Self.premiumLifetimeProductID,
            transactionId: transactionID
        )
        try await sendEntitlementSyncRequest(body: body, isRetry: false)
    }

    private func sendEntitlementSyncRequest(body: EntitlementSyncRequest, isRetry: Bool) async throws {
        let accessToken = try await validAccessToken()
        let url = SupabaseConfig.functionsURL.appendingPathComponent(entitlementSyncFunctionName)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(SupabaseConfig.anonKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await urlSession.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw SupabaseRESTError.invalidResponse
        }

        if http.statusCode == 401 && !isRetry {
            let refreshed: SupabaseSession
            do {
                refreshed = try await SupabaseAuthService.shared.refreshSession()
            } catch {
                throw SupabaseRESTError.notAuthenticated
            }

            AuthSessionStore.shared.updateTokens(
                accessToken: refreshed.accessToken,
                refreshToken: refreshed.refreshToken
            )
            try await sendEntitlementSyncRequest(body: body, isRetry: true)
            return
        }

        guard (200..<300).contains(http.statusCode) else {
#if DEBUG
            let rawBody = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)
            print("[PurchaseManager] Entitlement sync raw response status=\(http.statusCode) body=\(rawBody?.isEmpty == false ? rawBody! : "<empty>")")
#endif
            if let errBody = try? JSONDecoder().decode(FunctionErrorPayload.self, from: data) {
                throw SupabaseRESTError.server(status: http.statusCode, message: errBody.error)
            }
            throw SupabaseRESTError.server(status: http.statusCode, message: "Entitlement sync failed (\(http.statusCode))")
        }
    }

    private func validAccessToken() async throws -> String {
        if let token = AuthSessionStore.shared.currentAccessToken,
           !AuthSessionStore.shared.isAccessTokenExpired {
            return token
        }

        if AuthSessionStore.shared.currentRefreshToken != nil {
            let refreshed = try await SupabaseAuthService.shared.refreshSession()
            AuthSessionStore.shared.updateTokens(
                accessToken: refreshed.accessToken,
                refreshToken: refreshed.refreshToken
            )

            if let token = AuthSessionStore.shared.currentAccessToken {
                return token
            }
        }

        throw SupabaseRESTError.notAuthenticated
    }
}

private struct EntitlementSyncRequest: Encodable {
    let productId: String
    let transactionId: String?

    enum CodingKeys: String, CodingKey {
        case productId = "product_id"
        case transactionId = "transaction_id"
    }
}

private struct FunctionErrorPayload: Decodable {
    let error: String
}
