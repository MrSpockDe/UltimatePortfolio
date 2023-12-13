//
//  DataController-StoreKit.swift
//  UltimatePortfolio
//
//  Created by Albert on 25.11.23.
//

import Foundation
import StoreKit

// There are 6 steps to use in-app-purchases
// 1. Adding products to buy (and decide for what price)
// 2. Monitor transaction queue
// 3. Request from Apple a list of available products
// 4. Handle transactions
// 5. Handle restoring purchases (entitlements)
// 6. Creating a UI

// Configuring an IAP is usually done to Apples Content Management System
// once the app is available in the store (through appstore connect)
// For now, since the app is not in the store we mimic the function
// through a local StoreConfiguration File

let fullVersionKey = "fullVersionUnlocked"

extension DataController {
    ///  The product ID for our premium unlock
    static let unlockPremiumProductID = "de.zuzej.UltimatePortfolio.premiumUnlock"

    /// Loads and saves whether premium unlock has been purchased.
    var fullVersionUnlocked: Bool {
        get {
            defaults.bool(forKey: fullVersionKey)
        }

        set {
            defaults.setValue(newValue, forKey: fullVersionKey)
        }
    }

    /// fullfill step 4 of IAP
    ///
    /// 4. Handle transactions
    func monitorTransactions() async {
        // check for previous purchases
        for await entitlement in Transaction.currentEntitlements {
             // entitlement is a VerificationResult<Transaction>
            if case let .verified(transaction) = entitlement {
                await finalize(transaction)
            }
        }

        // watch for future transactions comming in
        for await update in Transaction.updates {
            if let transaction = try? update.payloadValue {
                await finalize(transaction)
            }
        }
    }

    func purchase(_ product: Product) async throws {
        let result = try await product.purchase()

        if case let .success(validation) = result {
            try await finalize(validation.payloadValue)
        }
    }

    // always change published properties of an ObservableObject on the MainActor
    /// Tell Apple that the transaction has been handled and does not have to be send again.
    @MainActor
    func finalize(_ transaction: Transaction) async {
        if transaction.productID == Self.unlockPremiumProductID {
            objectWillChange.send()
            fullVersionUnlocked = transaction.revocationDate == nil
            await transaction.finish()
        }
    }

    @MainActor
    func loadProducts() async throws {
        guard products.isEmpty else { return }

        try await Task.sleep(for: .seconds(0.2))
        products = try await Product.products(for: [Self.unlockPremiumProductID])
    }
}
