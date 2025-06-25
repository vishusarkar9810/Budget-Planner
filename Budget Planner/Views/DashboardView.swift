//
//  DashboardView.swift
//  Budget Planner
//
//  Created on Phase 2
//

import SwiftUI

struct DashboardView: View {
    let model: BudgetModel
    @State private var showAddTransaction = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    BudgetSummaryCard(
                        budget: model.budget,
                        spent: model.totalSpent,
                        remaining: model.remainingBudget
                    )
                    
                    RecentTransactionsSection(transactions: model.recentTransactions)
                    
                    CategorySpendingSection(model: model)
                }
                .padding()
            }
            .navigationTitle("Budget Dashboard")
            .toolbar {
                Button(action: {
                    showAddTransaction = true
                }) {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $showAddTransaction) {
                AddTransactionView(model: model)
            }
        }
    }
}

struct BudgetSummaryCard: View {
    let budget: Double
    let spent: Double
    let remaining: Double
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Budget Overview")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 20) {
                ProgressCircle(
                    progress: safeProgress,
                    color: progressColor
                )
                .frame(width: 100, height: 100)
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Total Budget")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(AppSettings.shared.formatBudget())
                            .bold()
                    }
                    BudgetRow(title: "Spent", amount: spent, textColor: .red)
                    BudgetRow(title: "Remaining", amount: remaining, textColor: remaining >= 0 ? .green : .red)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    private var safeProgress: Double {
        guard budget > 0 else { return 0 }
        return spent / budget
    }
    
    private var progressColor: Color {
        guard budget > 0 else { return .green }
        
        let ratio = spent / budget
        if ratio < 0.5 {
            return .green
        } else if ratio < 0.75 {
            return .yellow
        } else {
            return .red
        }
    }
}

struct ProgressCircle: View {
    let progress: Double
    let color: Color
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 10)
            
            Circle()
                .trim(from: 0, to: min(CGFloat(safeProgress), 1.0))
                .stroke(color, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                .rotationEffect(.degrees(-90))
            
            Text("\(safeProgressPercentage)%")
                .font(.system(.title3, design: .rounded))
                .bold()
        }
    }
    
    // Safely handle NaN or infinity values
    private var safeProgress: Double {
        guard progress.isFinite && !progress.isNaN else {
            return 0
        }
        return progress
    }
    
    private var safeProgressPercentage: Int {
        Int(min(safeProgress, 1.0) * 100)
    }
}

struct BudgetRow: View {
    let title: String
    let amount: Double
    var textColor: Color = .primary
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(AppSettings.shared.formatCurrency(amount))
                .bold()
                .foregroundColor(textColor)
        }
    }
}

struct RecentTransactionsSection: View {
    let transactions: [Transaction]
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Text("Recent Transactions")
                    .font(.headline)
                
                Spacer()
                
                NavigationLink(destination: TransactionsView()) {
                    Text("See All")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
            }
            
            if transactions.isEmpty {
                EmptyTransactionsView()
            } else {
                ForEach(transactions) { transaction in
                    TransactionRow(transaction: transaction)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct EmptyTransactionsView: View {
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "chart.bar.doc.horizontal")
                .font(.largeTitle)
                .foregroundColor(.secondary)
                .padding()
            
            Text("No transactions yet")
                .font(.headline)
            
            Text("Add your first transaction to get started")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
}

struct CategorySpendingSection: View {
    let model: BudgetModel
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Text("Spending by Category")
                    .font(.headline)
                
                Spacer()
                
                NavigationLink(destination: CategoriesView()) {
                    Text("See All")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
            }
            
            if model.transactions.isEmpty {
                Text("Add transactions to see category breakdown")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                ForEach(BudgetCategory.allCases.filter { model.totalSpent(for: $0) > 0 }) { category in
                    CategoryRow(
                        category: category,
                        amount: model.totalSpent(for: category),
                        percentage: safePercentage(for: category)
                    )
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    // Calculate percentage safely, avoiding division by zero
    private func safePercentage(for category: BudgetCategory) -> Double {
        let totalSpent = model.totalSpent
        guard totalSpent > 0 else {
            return 0
        }
        return model.totalSpent(for: category) / totalSpent
    }
}

struct CategoryRow: View {
    let category: BudgetCategory
    let amount: Double
    let percentage: Double
    
    var body: some View {
        HStack {
            Image(systemName: category.icon)
                .foregroundColor(category.color)
                .frame(width: 30)
            
            Text(category.displayName)
            
            Spacer()
            
            Text(AppSettings.shared.formatCurrency(amount))
                .bold()
            
            Text("(\(safePercentage)%)")
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
    
    // Safely handle NaN or infinity values
    private var safePercentage: Int {
        guard percentage.isFinite && !percentage.isNaN else {
            return 0
        }
        return Int(percentage * 100)
    }
} 