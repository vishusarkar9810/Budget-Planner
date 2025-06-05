import Foundation
import SwiftUI

@Observable
class AnalysisViewModel {
    var transactions: [Transaction] = []
    
    func loadTransactions(from model: BudgetModel) {
        self.transactions = model.transactions
    }
    
    func getFilteredTransactions(timeFrame: TimeFrame) -> [Transaction] {
        let calendar = Calendar.current
        let now = Date()
        let startDate: Date
        
        switch timeFrame {
        case .week:
            startDate = calendar.date(byAdding: .day, value: -7, to: now) ?? now
        case .month:
            startDate = calendar.date(byAdding: .month, value: -1, to: now) ?? now
        case .year:
            startDate = calendar.date(byAdding: .year, value: -1, to: now) ?? now
        }
        
        return transactions.filter { $0.date >= startDate && $0.date <= now }
    }
    
    func calculateTotalSpent(timeFrame: TimeFrame) -> Double {
        getFilteredTransactions(timeFrame: timeFrame)
            .filter { $0.isExpense }
            .reduce(0) { $0 + $1.amount }
    }
    
    func calculateDailyAverage(timeFrame: TimeFrame) -> Double {
        let totalDays: Double
        
        switch timeFrame {
        case .week:
            totalDays = 7
        case .month:
            totalDays = 30
        case .year:
            totalDays = 365
        }
        
        return calculateTotalSpent(timeFrame: timeFrame) / totalDays
    }
    
    func getSpendingByCategory(timeFrame: TimeFrame) -> [(category: BudgetCategory, amount: Double)] {
        let filteredTransactions = getFilteredTransactions(timeFrame: timeFrame).filter { $0.isExpense }
        var categoryAmounts: [BudgetCategory: Double] = [:]
        
        for category in BudgetCategory.allCases {
            categoryAmounts[category] = 0
        }
        
        for transaction in filteredTransactions {
            let category = transaction.categoryEnum
            categoryAmounts[category] = (categoryAmounts[category] ?? 0) + transaction.amount
        }
        
        return categoryAmounts
            .filter { $0.value > 0 }
            .map { (category: $0.key, amount: $0.value) }
            .sorted { $0.amount > $1.amount }
    }
}

enum TimeFrame: String, CaseIterable, Identifiable {
    case week = "Week"
    case month = "Month"
    case year = "Year"
    
    var id: String { rawValue }
} 