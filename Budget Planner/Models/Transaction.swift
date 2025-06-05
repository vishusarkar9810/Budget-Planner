//
//  Transaction.swift
//  Budget Planner
//
//  Created on Phase 1
//

import Foundation
import SwiftData

@Model
final class Transaction {
    var id: UUID
    var amount: Double
    var title: String
    var category: String
    var date: Date
    var isExpense: Bool
    
    init(
        id: UUID = UUID(),
        amount: Double,
        title: String,
        category: String,
        date: Date = Date(),
        isExpense: Bool = true
    ) {
        self.id = id
        self.amount = amount
        self.title = title
        self.category = category
        self.date = date
        self.isExpense = isExpense
    }
    
    var categoryEnum: BudgetCategory {
        BudgetCategory(rawValue: category) ?? .other
    }
    
    // Function to create an encodable dictionary representation
    func encodableRepresentation() -> [String: Any] {
        return [
            "id": id.uuidString,
            "amount": amount,
            "title": title,
            "category": category,
            "date": date.timeIntervalSince1970,
            "isExpense": isExpense
        ]
    }
} 