//
//  ContentView.swift
//  Budget Planner
//
//  Created by Vishwajeet Sarkar on 06/06/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var modelContainer: ModelContainer?
    @State private var budgetModel: BudgetModel?
    @State private var selectedTab = 0
    @State private var showOnboarding = !AppSettings.shared.hasCompletedOnboarding
    @State private var appOpenCount = UserDefaults.standard.integer(forKey: "appOpenCount")
    
    var body: some View {
        Group {
            if let budgetModel = budgetModel {
                TabView(selection: $selectedTab) {
                    DashboardView(model: budgetModel)
                        .tabItem {
                            Label("Dashboard", systemImage: "chart.bar.fill")
                        }
                        .tag(0)
                    
                    TransactionsView()
                        .tabItem {
                            Label("Transactions", systemImage: "list.bullet")
                        }
                        .tag(1)
                    
                    CategoriesView()
                        .tabItem {
                            Label("Categories", systemImage: "folder.fill")
                        }
                        .tag(2)
                    
                    AnalysisView()
                        .tabItem {
                            Label("Analysis", systemImage: "chart.xyaxis.line")
                        }
                        .tag(3)
                    
                    SettingsView()
                        .tabItem {
                            Label("Settings", systemImage: "gear")
                        }
                        .tag(4)
                }
                .environment(budgetModel)
                .fullScreenCover(isPresented: $showOnboarding) {
                    OnboardingCoordinator()
                        .onDisappear {
                            // In case the user manually dismisses the onboarding
                            AppSettings.shared.completeOnboarding()
                        }
                }
                .onAppear {
                    // Track app opens for review prompting
                    trackAppOpen()
                }
            } else {
                ProgressView()
                    .onAppear {
                        setupModel()
                    }
            }
        }
    }
    
    private func setupModel() {
        do {
            let schema = Schema([Transaction.self])
            let config = ModelConfiguration("BudgetPlanner", schema: schema)
            let container = try ModelContainer(for: schema, configurations: [config])
            
            modelContainer = container
            budgetModel = BudgetModel(modelContainer: container)
            
        } catch {
            print("Failed to create model container: \(error)")
        }
    }
    
    private func trackAppOpen() {
        // Increment app open count
        appOpenCount += 1
        UserDefaults.standard.set(appOpenCount, forKey: "appOpenCount")
        
        // Check if this is a good time to prompt for a review
        // Apple recommends prompting after the user has had a good experience with the app
        // For a budget app, this could be after they've used it multiple times
        if appOpenCount == 5 || appOpenCount == 10 || appOpenCount % 20 == 0 {
            // This is a significant event - the user is regularly using the app
            AppReviewManager.shared.logSignificantEvent()
        }
    }
}

#Preview {
    ContentView()
}
