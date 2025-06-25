//
//  Budget_PlannerApp.swift
//  Budget Planner
//
//  Created by Vishwajeet Sarkar on 06/06/25.
//

import SwiftUI
import SwiftData
import StoreKit

@main
struct Budget_PlannerApp: App {
    @State private var appSettings = AppSettings.shared
    @Environment(\.colorScheme) private var colorScheme
    
    // Initialize subscription manager
    private let subscriptionManager = SubscriptionManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(getPreferredColorScheme())
                .environment(appSettings)
                .onAppear {
                    // Load saved settings when app starts
                    appSettings.loadSettings()
                }
        }
        .onChange(of: subscriptionManager.isSubscribed) { _, isSubscribed in
            // Update app settings when subscription status changes
            appSettings.updateSubscriptionStatus(isSubscribed: isSubscribed)
        }
    }
    
    private func getPreferredColorScheme() -> ColorScheme {
        switch appSettings.selectedTheme {
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
}
