//
//  Budget_PlannerApp.swift
//  Budget Planner
//
//  Created by Vishwajeet Sarkar on 06/06/25.
//

import SwiftUI
import SwiftData

@main
struct Budget_PlannerApp: App {
    @State private var appSettings = AppSettings.shared
    @Environment(\.colorScheme) private var colorScheme
    
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
    }
    
    private func getPreferredColorScheme() -> ColorScheme? {
        switch appSettings.selectedTheme {
        case .light:
            return .light
        case .dark:
            return .dark
        case .system:
            return nil
        default:
            return nil // For colored themes, we use system default
        }
    }
}
