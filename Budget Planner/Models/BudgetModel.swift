//
//  BudgetModel.swift
//  Budget Planner
//
//  Created on Phase 1
//

import Foundation
import SwiftData
import Observation

@Observable
final class BudgetModel {
    private var modelContext: ModelContext
    
    @ObservationIgnored
    private var transactionsDescriptor: FetchDescriptor<Transaction>
    
    var transactions: [Transaction] = []
    
    // Track transaction counts for milestones
    private var previousTransactionCount = 0
    
    // Budget is now computed from AppSettings
    var budget: Double {
        get { AppSettings.shared.getCurrentPeriodBudget() }
        set { AppSettings.shared.updateBudgetAmount(newValue) }
    }
    
    init(modelContainer: ModelContainer) {
        self.modelContext = ModelContext(modelContainer)
        
        self.transactionsDescriptor = FetchDescriptor<Transaction>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        
        fetchTransactions()
        previousTransactionCount = transactions.count
    }
    
    func fetchTransactions() {
        do {
            transactions = try modelContext.fetch(transactionsDescriptor)
            checkTransactionMilestones()
        } catch {
            print("Failed to fetch transactions: \(error)")
        }
    }
    
    func addTransaction(_ transaction: Transaction) {
        modelContext.insert(transaction)
        saveContext()
        fetchTransactions()
    }
    
    func deleteTransaction(_ transaction: Transaction) {
        modelContext.delete(transaction)
        saveContext()
        fetchTransactions()
    }
    
    func deleteTransactions(at indexSet: IndexSet) {
        for index in indexSet {
            if index < transactions.count {
                modelContext.delete(transactions[index])
            }
        }
        saveContext()
        fetchTransactions()
    }
    
    func updateTransaction(_ transaction: Transaction) {
        saveContext()
        fetchTransactions()
    }
    
    func updateBudget(_ newBudget: Double) {
        budget = newBudget
        
        // Budget updates are significant events
        AppReviewManager.shared.logSignificantEvent()
    }
    
    private func saveContext() {
        do {
            try modelContext.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }
    
    // Check for transaction milestones that might be good times for review prompts
    private func checkTransactionMilestones() {
        let currentCount = transactions.count
        
        // Check if we've reached certain milestones
        let milestones = [5, 10, 25, 50, 100]
        
        for milestone in milestones {
            // If we've crossed a milestone
            if previousTransactionCount < milestone && currentCount >= milestone {
                print("Reached transaction milestone: \(milestone)")
                
                // This is a significant event - the user is actively using the app
                AppReviewManager.shared.logSignificantEvent()
                break
            }
        }
        
        // Update the previous count for next check
        previousTransactionCount = currentCount
    }
    
    // Reset all data in the app
    func resetAllData() {
        do {
            // Fetch all transactions directly from the database
            let fetchDescriptor = FetchDescriptor<Transaction>()
            let allTransactions = try modelContext.fetch(fetchDescriptor)
            
            // Clear array first to avoid UI updates during deletion
            transactions = []
            
            // Delete all transactions
            for transaction in allTransactions {
                modelContext.delete(transaction)
            }
            
            // Save changes to clear transactions
            try modelContext.save()
            
            // Reset all settings
            AppSettings.shared.resetToDefaults()
            
            // After everything is reset, fetch empty transactions to refresh UI
            fetchTransactions()
            
            print("Data reset successful")
            return
        } catch {
            print("Error during reset: \(error.localizedDescription)")
            // Even if an error occurs, try to put the app in a clean state
            transactions = []
            AppSettings.shared.resetToDefaults()
        }
    }
    
    // MARK: - Computed Properties
    
    var totalSpent: Double {
        transactions.filter { $0.isExpense }.reduce(0) { $0 + $1.amount }
    }
    
    var totalIncome: Double {
        transactions.filter { !$0.isExpense }.reduce(0) { $0 + $1.amount }
    }
    
    var remainingBudget: Double {
        budget - totalSpent + totalIncome
    }
    
    var spendingByCategory: [BudgetCategory: Double] {
        var result: [BudgetCategory: Double] = [:]
        
        for category in BudgetCategory.allCases {
            result[category] = 0
        }
        
        for transaction in transactions where transaction.isExpense {
            let category = transaction.categoryEnum
            result[category] = (result[category] ?? 0) + transaction.amount
        }
        
        return result
    }
    
    func transactions(for category: BudgetCategory) -> [Transaction] {
        transactions.filter { $0.categoryEnum == category }
    }
    
    func totalSpent(for category: BudgetCategory) -> Double {
        transactions(for: category)
            .filter { $0.isExpense }
            .reduce(0) { $0 + $1.amount }
    }
    
    var recentTransactions: [Transaction] {
        Array(transactions.prefix(5))
    }
} 