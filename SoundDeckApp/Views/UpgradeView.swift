import SwiftUI
import StoreKit

/// Custom paywall view presented as a sheet.
/// Uses StoreKit 2 via SubscriptionManager (macOS 13+ compatible — no SubscriptionStoreView).
struct UpgradeView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var selectedPlan: Plan = .yearly
    @State private var isPurchasing = false
    @State private var errorMessage: String?

    enum Plan: String, CaseIterable {
        case monthly, yearly
    }

    var body: some View {
        VStack(spacing: 0) {
            // Close button
            HStack {
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding(.trailing, 16)
            .padding(.top, 16)

            ScrollView {
                VStack(spacing: 0) {
                    // Header
                    headerSection

                    // Feature comparison
                    featureComparisonSection
                        .padding(.horizontal, 24)
                        .padding(.top, 16)

                    // Plan toggle + pricing
                    planSelector
                        .padding(.horizontal, 24)
                        .padding(.top, 16)

                    // Purchase button
                    purchaseButton
                        .padding(.horizontal, 24)
                        .padding(.top, 16)

                    // Error message
                    if let errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                            .padding(.top, 6)
                    }

                    // Restore link
                    Button {
                        restorePurchases()
                    } label: {
                        Text("Restore Purchases")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                            .underline()
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 10)
                    .padding(.bottom, 20)
                }
            }
        }
        .frame(width: 420, height: 520)
        .background(Color(nsColor: .windowBackgroundColor))
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.purple, .blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 56, height: 56)

                Image(systemName: "crown.fill")
                    .font(.system(size: 26))
                    .foregroundColor(.white)
            }

            Text("SoundDeck Pro")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)

            Text("Unlock the full soundboard experience")
                .font(.system(size: 13))
                .foregroundColor(.secondary)
        }
    }

    // MARK: - Feature Comparison

    private var featureComparisonSection: some View {
        VStack(spacing: 0) {
            // Column headers
            HStack {
                Text("Feature")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text("Free")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.secondary)
                    .frame(width: 70)

                Text("Pro")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.purple)
                    .frame(width: 70)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)

            Divider().opacity(0.3)

            // Feature rows
            ForEach(features) { feature in
                featureRow(feature)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white.opacity(0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(Color.white.opacity(0.06), lineWidth: 1)
                )
        )
    }

    private func featureRow(_ feature: FeatureRow) -> some View {
        HStack {
            Text(feature.name)
                .font(.system(size: 12))
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)

            featureValue(feature.freeValue)
                .frame(width: 70)

            featureValue(feature.proValue)
                .frame(width: 70)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
    }

    @ViewBuilder
    private func featureValue(_ value: FeatureValue) -> some View {
        switch value {
        case .check:
            Image(systemName: "checkmark")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.green)
        case .cross:
            Image(systemName: "xmark")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.secondary.opacity(0.4))
        case .text(let label):
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(.primary)
        }
    }

    // MARK: - Plan Selector

    private var planSelector: some View {
        HStack(spacing: 10) {
            planCard(
                plan: .monthly,
                title: "Monthly",
                price: monthlyPriceString,
                subtitle: "per month"
            )

            planCard(
                plan: .yearly,
                title: "Yearly",
                price: yearlyPriceString,
                subtitle: "per year",
                badge: "Save 50%"
            )
        }
    }

    private func planCard(
        plan: Plan,
        title: String,
        price: String,
        subtitle: String,
        badge: String? = nil
    ) -> some View {
        let isSelected = selectedPlan == plan

        return Button {
            selectedPlan = plan
        } label: {
            VStack(spacing: 4) {
                if let badge {
                    Text(badge)
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(Color.green))
                } else {
                    // Spacer to align card heights
                    Text(" ")
                        .font(.system(size: 9, weight: .bold))
                        .padding(.vertical, 2)
                        .opacity(0)
                }

                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.primary)

                Text(price)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(isSelected ? .purple : .primary)

                Text(subtitle)
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? Color.purple.opacity(0.12) : Color.white.opacity(0.04))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(
                                isSelected ? Color.purple.opacity(0.6) : Color.white.opacity(0.06),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Purchase Button

    private var purchaseButton: some View {
        Button {
            purchase()
        } label: {
            Group {
                if isPurchasing {
                    ProgressView()
                        .scaleEffect(0.8)
                        .frame(maxWidth: .infinity)
                        .frame(height: 20)
                } else {
                    Text("Subscribe \(selectedPlan == .monthly ? monthlyPriceString + "/mo" : yearlyPriceString + "/yr")")
                        .font(.system(size: 14, weight: .semibold))
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.vertical, 10)
            .foregroundColor(.white)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(
                        LinearGradient(
                            colors: [.purple, .blue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            )
        }
        .buttonStyle(.plain)
        .disabled(isPurchasing)
    }

    // MARK: - Price Helpers

    private var monthlyPriceString: String {
        subscriptionManager?.monthlyProduct?.displayPrice ?? "$4.99"
    }

    private var yearlyPriceString: String {
        subscriptionManager?.yearlyProduct?.displayPrice ?? "$29.99"
    }

    // MARK: - SubscriptionManager Access

    private var subscriptionManager: SubscriptionManager? {
        (NSApplication.shared.delegate as? AppDelegate)?.subscriptionManager
    }

    // MARK: - Actions

    private func purchase() {
        guard let manager = subscriptionManager else {
            errorMessage = "Unable to access subscription manager."
            return
        }

        let product: Product?
        switch selectedPlan {
        case .monthly:
            product = manager.monthlyProduct
        case .yearly:
            product = manager.yearlyProduct
        }

        guard let product else {
            errorMessage = "Products not available. Please try again later."
            return
        }

        isPurchasing = true
        errorMessage = nil

        Task {
            await manager.purchase(product)
            await MainActor.run {
                isPurchasing = false
                if let err = manager.purchaseError {
                    errorMessage = err
                } else if appState.isPro {
                    dismiss()
                }
            }
        }
    }

    private func restorePurchases() {
        guard let manager = subscriptionManager else {
            errorMessage = "Unable to access subscription manager."
            return
        }

        isPurchasing = true
        errorMessage = nil

        Task {
            await manager.restorePurchases()
            await MainActor.run {
                isPurchasing = false
                if let err = manager.purchaseError {
                    errorMessage = err
                } else if appState.isPro {
                    dismiss()
                }
            }
        }
    }
}

// MARK: - Feature Data

private enum FeatureValue {
    case check
    case cross
    case text(String)
}

private struct FeatureRow: Identifiable {
    let id = UUID()
    let name: String
    let freeValue: FeatureValue
    let proValue: FeatureValue
}

private let features: [FeatureRow] = [
    FeatureRow(name: "Sound slots", freeValue: .text("8"), proValue: .text("Unlimited")),
    FeatureRow(name: "Voice changer", freeValue: .cross, proValue: .check),
    FeatureRow(name: "Per-sound hotkeys", freeValue: .cross, proValue: .check),
    FeatureRow(name: "Watermark beep", freeValue: .text("Yes"), proValue: .text("None")),
    FeatureRow(name: "Pro sound library", freeValue: .cross, proValue: .check),
    FeatureRow(name: "Trim editor", freeValue: .cross, proValue: .check),
    FeatureRow(name: "Custom import", freeValue: .text("8 max"), proValue: .text("Unlimited")),
    FeatureRow(name: "Basic hotkeys (mute/stop)", freeValue: .check, proValue: .check),
]

#Preview {
    UpgradeView()
        .environmentObject(AppState())
}
