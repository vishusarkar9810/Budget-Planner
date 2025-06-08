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
    @State private var showSubscriptionView = false
    
    // Max number of categories for free users
    private let freeTierCategoryLimit = 5
    
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
                            selectedCategory: $selectedCategory,
                            isSubscribed: AppSettings.shared.isSubscribed,
                            freeTierLimit: freeTierCategoryLimit
                        )
                        
                        CategoryListSection(
                            model: model,
                            selectedCategory: $selectedCategory,
                            isSubscribed: AppSettings.shared.isSubscribed,
                            freeTierLimit: freeTierCategoryLimit
                        )
                        
                        if let selectedCategory = selectedCategory {
                            CategoryTransactionsSection(
                                model: model,
                                category: selectedCategory
                            )
                        }
                        
                        // Show premium banner if not subscribed
                        if !AppSettings.shared.isSubscribed {
                            PremiumBannerView(featureName: "unlimited categories")
                                .padding(.top, 20)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Categories")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if !AppSettings.shared.isSubscribed {
                        Button {
                            showSubscriptionView = true
                        } label: {
                            Label("Premium", systemImage: "crown.fill")
                                .foregroundColor(.yellow)
                        }
                    }
                }
            }
            .sheet(isPresented: $showSubscriptionView) {
                SubscriptionView()
            }
        }
    }
}

struct CategoryChartSection: View {
    let model: BudgetModel
    @Binding var selectedCategory: BudgetCategory?
    let isSubscribed: Bool
    let freeTierLimit: Int
    
    var body: some View {
        VStack {
            Text("Spending by Category")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Chart {
                ForEach(limitedCategoryData) { data in
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
                
                // Add an "Other" sector for non-premium users if there are more categories
                if !isSubscribed && allCategoryData.count > freeTierLimit {
                    let otherAmount = otherCategoriesAmount
                    let otherPercentage = otherAmount / model.totalSpent
                    
                    SectorMark(
                        angle: .value("Amount", otherAmount),
                        innerRadius: .ratio(0.6),
                        angularInset: 1
                    )
                    .foregroundStyle(Color.gray)
                    .cornerRadius(5)
                    .annotation(position: .overlay) {
                        if otherPercentage >= 0.05 {
                            Text("\(Int(otherPercentage * 100))%")
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
                ForEach(limitedCategoryData) { data in
                    HStack {
                        Circle()
                            .fill(data.category.color)
                            .frame(width: 10, height: 10)
                        
                        Text(data.category.displayName)
                            .font(.caption)
                    }
                }
                
                // Add "Other" legend for non-premium users if there are more categories
                if !isSubscribed && allCategoryData.count > freeTierLimit {
                    HStack {
                        Circle()
                            .fill(Color.gray)
                            .frame(width: 10, height: 10)
                        
                        Text("Other")
                            .font(.caption)
                    }
                }
            }
            .padding(.top)
            
            if !isSubscribed && allCategoryData.count > freeTierLimit {
                Text("Upgrade to Premium to see all categories")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 5)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    @State private var selectedAngle: Double?
    
    private var allCategoryData: [CategoryData] {
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
    
    private var limitedCategoryData: [CategoryData] {
        if isSubscribed {
            return allCategoryData
        } else {
            return Array(allCategoryData.prefix(freeTierLimit))
        }
    }
    
    private var otherCategoriesAmount: Double {
        if isSubscribed || allCategoryData.count <= freeTierLimit {
            return 0
        }
        
        return allCategoryData
            .dropFirst(freeTierLimit)
            .reduce(0) { $0 + $1.amount }
    }
    
    private func updateSelectedCategory(angle: Double?) {
        guard let angle = angle else {
            selectedCategory = nil
            return
        }
        
        // Calculate which category this angle corresponds to
        var startAngle: Double = 0
        
        for data in limitedCategoryData {
            let endAngle = startAngle + (data.amount / model.totalSpent) * 360
            
            if angle >= startAngle && angle <= endAngle {
                selectedCategory = data.category
                return
            }
            
            startAngle = endAngle
        }
        
        // Check if the angle falls in the "Other" section
        if !isSubscribed && allCategoryData.count > freeTierLimit {
            let otherAmount = otherCategoriesAmount
            let endAngle = startAngle + (otherAmount / model.totalSpent) * 360
            
            if angle >= startAngle && angle <= endAngle {
                // When "Other" is selected, don't select any specific category
                selectedCategory = nil
            }
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
    let isSubscribed: Bool
    let freeTierLimit: Int
    @State private var showSubscriptionView = false
    
    var body: some View {
        VStack {
            Text("All Categories")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            ForEach(limitedCategories, id: \.category) { data in
                CategoryListRow(
                    data: data,
                    isSelected: selectedCategory == data.category
                )
                .onTapGesture {
                    selectedCategory = data.category
                }
            }
            
            // Show a row for additional categories that are locked behind premium
            if !isSubscribed && sortedCategories.count > freeTierLimit {
                HStack {
                    Circle()
                        .fill(Color.gray)
                        .frame(width: 30, height: 30)
                        .overlay {
                            Image(systemName: "lock.fill")
                                .foregroundColor(.white)
                                .font(.caption)
                        }
                    
                    Text("\(sortedCategories.count - freeTierLimit) more categories")
                        .bold()
                    
                    Spacer()
                    
                    Button {
                        showSubscriptionView = true
                    } label: {
                        Text("Unlock")
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 5)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(15)
                    }
                }
                .padding(.vertical, 8)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
        .sheet(isPresented: $showSubscriptionView) {
            SubscriptionView()
        }
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
    
    private var limitedCategories: [CategoryData] {
        if isSubscribed {
            return sortedCategories
        } else {
            return Array(sortedCategories.prefix(freeTierLimit))
        }
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