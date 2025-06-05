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
    var budget: Double = 1000
    
    init(modelContainer: ModelContainer) {
        self.modelContext = ModelContext(modelContainer)
        
        self.transactionsDescriptor = FetchDescriptor<Transaction>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        
        fetchTransactions()
    }
    
    func fetchTransactions() {
        do {
            transactions = try modelContext.fetch(transactionsDescriptor)
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
    }
    
    private func saveContext() {
        do {
            try modelContext.save()
        } catch {
            print("Failed to save context: \(error)")
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