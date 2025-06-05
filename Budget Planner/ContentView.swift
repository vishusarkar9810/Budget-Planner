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
                    
                    SettingsView()
                        .tabItem {
                            Label("Settings", systemImage: "gear")
                        }
                        .tag(3)
                }
                .environment(budgetModel)
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
            let config = ModelConfiguration()
            let container = try ModelContainer(for: Transaction.self, configurations: config)
            self.modelContainer = container
            self.budgetModel = BudgetModel(modelContainer: container)
        } catch {
            print("Failed to create model container: \(error)")
        }
    }
}

#Preview {
    ContentView()
}
