//
//  CosmoApp.swift
//  Cosmo
//
//  Created by aditya bhushan on 13/02/25.
//

import SwiftUI

@main
struct CosmosApp: App {
    @StateObject private var purchaseManager = PurchaseManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(purchaseManager)
        }
    }
}
