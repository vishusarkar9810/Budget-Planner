//
//  CategoriesView.swift
//  Budget Planner
//
//  Created on Phase 3
//

import SwiftUI
import Charts

struct CategoriesView: View {
    @Environment(BudgetModel.self) private var model
    @State private var selectedCategory: BudgetCategory?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if model.transactions.isEmpty {
                        EmptyTransactionsView()
                            .padding(.top, 50)
                    } else {
                        CategoryChartSection(
                            model: model,
                            selectedCategory: $selectedCategory
                        )
                        
                        CategoryListSection(
                            model: model,
                            selectedCategory: $selectedCategory
                        )
                        
                        if let selectedCategory = selectedCategory {
                            CategoryTransactionsSection(
                                model: model,
                                category: selectedCategory
                            )
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Categories")
        }
    }
}

struct CategoryChartSection: View {
    let model: BudgetModel
    @Binding var selectedCategory: BudgetCategory?
    
    var body: some View {
        VStack {
            Text("Spending by Category")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Chart {
                ForEach(categoryData) { data in
                    SectorMark(
                        angle: .value("Amount", data.amount),
                        innerRadius: .ratio(0.6),
                        angularInset: 1
                    )
                    .foregroundStyle(data.category.color)
                    .cornerRadius(5)
                    .annotation(position: .overlay) {
                        if data.percentage >= 0.05 {
                            Text("\(Int(data.percentage * 100))%")
                                .font(.caption)
                                .bold()
                                .foregroundColor(.white)
                        }
                    }
                }
            }
            .frame(height: 250)
            .chartAngleSelection(value: $selectedAngle)
            .onChange(of: selectedAngle) { oldValue, newValue in
                updateSelectedCategory(angle: newValue)
            }
            
            HStack {
                ForEach(categoryData) { data in
                    HStack {
                        Circle()
                            .fill(data.category.color)
                            .frame(width: 10, height: 10)
                        
                        Text(data.category.displayName)
                            .font(.caption)
                    }
                }
            }
            .padding(.top)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    @State private var selectedAngle: Double?
    
    private var categoryData: [CategoryData] {
        let spending = model.spendingByCategory
        let totalSpent = model.totalSpent
        
        return BudgetCategory.allCases
            .filter { spending[$0] ?? 0 > 0 }
            .map { category in
                let amount = spending[category] ?? 0
                return CategoryData(
                    category: category,
                    amount: amount,
                    percentage: amount / totalSpent
                )
            }
            .sorted { $0.amount > $1.amount }
    }
    
    private func updateSelectedCategory(angle: Double?) {
        guard let angle = angle else {
            selectedCategory = nil
            return
        }
        
        // Calculate which category this angle corresponds to
        var startAngle: Double = 0
        
        for data in categoryData {
            let endAngle = startAngle + (data.amount / model.totalSpent) * 360
            
            if angle >= startAngle && angle <= endAngle {
                selectedCategory = data.category
                return
            }
            
            startAngle = endAngle
        }
    }
}

struct CategoryData: Identifiable {
    let category: BudgetCategory
    let amount: Double
    let percentage: Double
    
    var id: String { category.id }
}

struct CategoryListSection: View {
    let model: BudgetModel
    @Binding var selectedCategory: BudgetCategory?
    
    var body: some View {
        VStack {
            Text("All Categories")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            ForEach(sortedCategories, id: \.category) { data in
                CategoryListRow(
                    data: data,
                    isSelected: selectedCategory == data.category
                )
                .onTapGesture {
                    selectedCategory = data.category
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    private var sortedCategories: [CategoryData] {
        let spending = model.spendingByCategory
        let totalSpent = model.totalSpent
        
        return BudgetCategory.allCases
            .map { category in
                let amount = spending[category] ?? 0
                return CategoryData(
                    category: category,
                    amount: amount,
                    percentage: totalSpent > 0 ? amount / totalSpent : 0
                )
            }
            .sorted { $0.amount > $1.amount }
    }
}

struct CategoryListRow: View {
    let data: CategoryData
    let isSelected: Bool
    
    var body: some View {
        HStack {
            Circle()
                .fill(data.category.color)
                .frame(width: 30, height: 30)
                .overlay {
                    Image(systemName: data.category.icon)
                        .foregroundColor(.white)
                        .font(.caption)
                }
            
            Text(data.category.displayName)
                .bold(isSelected)
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text(AppSettings.shared.formatCurrency(data.amount))
                    .bold()
                
                if data.amount > 0 {
                    Text("\(Int(data.percentage * 100))%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 8)
        .background(isSelected ? Color.blue.opacity(0.1) : Color.clear)
        .cornerRadius(8)
    }
}

struct CategoryTransactionsSection: View {
    let model: BudgetModel
    let category: BudgetCategory
    
    var body: some View {
        VStack {
            Text("\(category.displayName) Transactions")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            if categoryTransactions.isEmpty {
                Text("No transactions in this category")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                ForEach(categoryTransactions) { transaction in
                    TransactionRow(transaction: transaction)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    private var categoryTransactions: [Transaction] {
        model.transactions(for: category)
    }
} 