import SwiftUI

struct PremiumPaywallSheet: View {
    enum Context {
        case quizLimit
        case gameContinue
        case profile

        var title: String {
            switch self {
            case .quizLimit:
                return "Get More Daily Attempts"
            case .gameContinue:
                return "Unlock Continue"
            case .profile:
                return "Upgrade to Premium"
            }
        }

        var subtitle: String {
            switch self {
            case .quizLimit:
                return "Premium gives you 3 Daily Quiz attempts every day."
            case .gameContinue:
                return "Premium gives you 1 continue per run from your exact progress."
            case .profile:
                return "One-time purchase. Lifetime premium benefits."
            }
        }
    }

    let context: Context
    var onPurchased: (() -> Void)?

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var purchaseManager: PurchaseManager

    @State private var isPurchasing = false
    @State private var isRestoring = false
    @State private var statusMessage: String?

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(context.title)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                    Text(context.subtitle)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }

                VStack(alignment: .leading, spacing: 10) {
                    benefitRow(icon: "checkmark.seal.fill", text: "Daily Quiz: 3 attempts/day")
                    benefitRow(icon: "checkmark.seal.fill", text: "Space Game: 1 continue per run")
                    benefitRow(icon: "checkmark.seal.fill", text: "Membership badge in profile")
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.white.opacity(0.08))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.white.opacity(0.15), lineWidth: 1)
                        )
                )

                if let statusMessage {
                    Text(statusMessage)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }

                Spacer(minLength: 0)

                Button {
                    Task { await buyPremium() }
                } label: {
                    HStack {
                        if isPurchasing {
                            ProgressView().tint(.white)
                        } else {
                            Image(systemName: "sparkles")
                        }
                        Text(isPurchasing ? "Processing..." : "Buy Premium · \(purchaseManager.premiumPriceLabel)")
                            .font(.headline)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(
                            colors: [Color.purple.opacity(0.9), Color.indigo.opacity(0.9)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(14)
                }
                .disabled(isPurchasing || isRestoring)

                Button {
                    Task { await restorePurchases() }
                } label: {
                    HStack {
                        if isRestoring {
                            ProgressView().tint(.white)
                        } else {
                            Image(systemName: "arrow.clockwise")
                        }
                        Text(isRestoring ? "Restoring..." : "Restore Purchases")
                            .font(.headline)
                        Spacer()
                    }
                    .foregroundColor(.white.opacity(0.9))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.white.opacity(0.08))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.white.opacity(0.15), lineWidth: 1)
                            )
                    )
                }
                .disabled(isPurchasing || isRestoring)

                Button("Not Now") {
                    dismiss()
                }
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.white.opacity(0.7))
                .frame(maxWidth: .infinity)
                .padding(.top, 2)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 24)
            .background(
                LinearGradient(
                    colors: [Color.black, Color(red: 0.06, green: 0.08, blue: 0.14)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
            }
            .task {
                await purchaseManager.loadProductIfNeeded()
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    private func benefitRow(icon: String, text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.green)
            Text(text)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.88))
            Spacer()
        }
    }

    @MainActor
    private func buyPremium() async {
        isPurchasing = true
        defer { isPurchasing = false }

        switch await purchaseManager.purchasePremium() {
        case .success:
            await purchaseManager.syncPremiumWithBackendAfterPurchaseFlow()
            ToastManager.shared.show("Premium unlocked", style: .success)
            onPurchased?()
            dismiss()
        case .pending:
            statusMessage = "Purchase is pending approval."
        case .cancelled:
            statusMessage = "Purchase cancelled."
        case .failed(let message):
            statusMessage = message
        }
    }

    @MainActor
    private func restorePurchases() async {
        isRestoring = true
        defer { isRestoring = false }

        let restored = await purchaseManager.restorePurchases()
        if restored {
            ToastManager.shared.show("Premium restored", style: .success)
            onPurchased?()
            dismiss()
        } else {
            statusMessage = "No premium purchase found to restore."
        }
    }
}
