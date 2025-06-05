//
//  SettingsView.swift
//  Budget Planner
//
//  Created on Phase 4
//

import SwiftUI

struct SettingsView: View {
    @Environment(BudgetModel.self) private var model
    @State private var budgetAmount = ""
    @State private var showResetConfirmation = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Budget Settings") {
                    HStack {
                        Text("Monthly Budget")
                        Spacer()
                        TextField("Budget", text: $budgetAmount)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .onAppear {
                                budgetAmount = String(format: "%.2f", model.budget)
                            }
                    }
                    
                    Button("Update Budget") {
                        updateBudget()
                    }
                    .disabled(!isValidBudget)
                }
                
                Section("Statistics") {
                    StatRow(title: "Total Spent", amount: model.totalSpent, color: .red)
                    StatRow(title: "Total Income", amount: model.totalIncome, color: .green)
                    StatRow(title: "Remaining Budget", amount: model.remainingBudget, color: model.remainingBudget >= 0 ? .green : .red)
                    StatRow(title: "Transaction Count", value: "\(model.transactions.count)")
                }
                
                Section("App Actions") {
                    Button(role: .destructive) {
                        showResetConfirmation = true
                    } label: {
                        Label("Reset All Data", systemImage: "trash")
                    }
                }
                
                Section("About") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Budget Planner")
                            .font(.headline)
                        
                        Text("A simple app to track your expenses and income")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("Version 1.0")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("Settings")
            .alert("Reset Data", isPresented: $showResetConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    resetAllData()
                }
            } message: {
                Text("This will delete all your transactions and reset your budget. This action cannot be undone.")
            }
        }
    }
    
    private var isValidBudget: Bool {
        guard let amount = Double(budgetAmount) else { return false }
        return amount > 0
    }
    
    private func updateBudget() {
        guard let amount = Double(budgetAmount) else { return }
        model.updateBudget(amount)
    }
    
    private func resetAllData() {
        // Implementation will depend on how you want to handle this
        // For now, we'll just delete all transactions
        for transaction in model.transactions {
            model.deleteTransaction(transaction)
        }
        model.updateBudget(1000) // Reset to default
    }
}

struct StatRow: View {
    let title: String
    var amount: Double? = nil
    var value: String? = nil
    var color: Color = .primary
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            if let amount = amount {
                Text("$\(amount, specifier: "%.2f")")
                    .bold()
                    .foregroundColor(color)
            } else if let value = value {
                Text(value)
                    .bold()
                    .foregroundColor(color)
            }
        }
    }
} 