//
//  TransactionRow.swift
//  Budget Planner
//
//  Created on Phase 2
//

import SwiftUI

struct TransactionRow: View {
    let transaction: Transaction
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(transaction.categoryEnum.color)
                .frame(width: 40, height: 40)
                .overlay {
                    Image(systemName: transaction.categoryEnum.icon)
                        .foregroundColor(.white)
                }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.title)
                    .font(.headline)
                
                Text(transaction.categoryEnum.displayName)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(transaction.isExpense ? 
                     "-\(AppSettings.shared.formatCurrency(transaction.amount))" : 
                     "+\(AppSettings.shared.formatCurrency(transaction.amount))")
                    .font(.headline)
                    .foregroundColor(transaction.isExpense ? .red : .green)
                
                Text(transactionDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
    
    private var transactionDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: transaction.date)
    }
} 