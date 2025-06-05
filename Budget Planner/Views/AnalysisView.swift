import SwiftUI
import Charts
import SwiftData

struct AnalysisView: View {
    @Environment(BudgetModel.self) private var model
    @State private var selectedTimeFrame: TimeFrame = .month
    @State private var selectedAnalysisType: AnalysisType = .monthlyTrends
    
    enum TimeFrame: String, CaseIterable, Identifiable {
        case week = "Week"
        case month = "Month"
        case year = "Year"
        
        var id: String { rawValue }
    }
    
    enum AnalysisType: String, CaseIterable, Identifiable {
        case monthlyTrends = "Monthly Trends"
        case budgetVsActual = "Budget vs Actual"
        case categoryAnalysis = "Category Analysis"
        
        var id: String { rawValue }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Picker("Analysis Type", selection: $selectedAnalysisType) {
                    ForEach(AnalysisType.allCases) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                Picker("Time Frame", selection: $selectedTimeFrame) {
                    ForEach(TimeFrame.allCases) { timeFrame in
                        Text(timeFrame.rawValue).tag(timeFrame)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                ScrollView {
                    switch selectedAnalysisType {
                    case .monthlyTrends:
                        MonthlyTrendsView(timeFrame: selectedTimeFrame)
                    case .budgetVsActual:
                        BudgetVsActualView(timeFrame: selectedTimeFrame)
                    case .categoryAnalysis:
                        CategoryAnalysisView(timeFrame: selectedTimeFrame)
                    }
                }
                .padding()
            }
            .navigationTitle("Analysis")
        }
    }
}

struct MonthlyTrendsView: View {
    @Environment(BudgetModel.self) private var model
    let timeFrame: AnalysisView.TimeFrame
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Monthly Spending Trends")
                .font(.headline)
            
            if let data = prepareMonthlyTrendsData() {
                Chart(data) { item in
                    LineMark(
                        x: .value("Date", item.date),
                        y: .value("Amount", item.amount)
                    )
                    .foregroundStyle(Color.blue)
                    
                    AreaMark(
                        x: .value("Date", item.date),
                        y: .value("Amount", item.amount)
                    )
                    .foregroundStyle(Color.blue.opacity(0.2))
                }
                .frame(height: 250)
                .chartYScale(domain: 0...calculateMaxAmount())
                .chartXAxis {
                    AxisMarks(values: .automatic) { _ in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel(format: getDateFormat())
                    }
                }
            } else {
                Text("No data available for the selected time frame")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            }
            
            Text("Total Spent: \(formatCurrency(calculateTotalSpent()))")
                .font(.headline)
                .padding(.top, 10)
            
            Text("Daily Average: \(formatCurrency(calculateDailyAverage()))")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(radius: 2)
    }
    
    // MARK: - Helper Methods
    
    struct TrendItem: Identifiable {
        let id = UUID()
        let date: Date
        let amount: Double
    }
    
    private func prepareMonthlyTrendsData() -> [TrendItem]? {
        let filteredTransactions = getFilteredTransactions()
        
        if filteredTransactions.isEmpty {
            return nil
        }
        
        let calendar = Calendar.current
        let dateRanges = getDateRanges()
        
        var trendData: [TrendItem] = []
        
        for range in dateRanges {
            let startDate = range.lowerBound
            let endDate = range.upperBound
            
            let rangeTransactions = filteredTransactions.filter {
                $0.date >= startDate && $0.date < endDate && $0.isExpense
            }
            
            let total = rangeTransactions.reduce(0) { $0 + $1.amount }
            trendData.append(TrendItem(date: startDate, amount: total))
        }
        
        return trendData
    }
    
    private func getFilteredTransactions() -> [Transaction] {
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
        
        return model.transactions.filter { $0.date >= startDate && $0.date <= now }
    }
    
    private func getDateRanges() -> [Range<Date>] {
        let calendar = Calendar.current
        let now = Date()
        var ranges: [Range<Date>] = []
        
        switch timeFrame {
        case .week:
            // Daily intervals for a week
            for i in 0..<7 {
                let startDay = calendar.date(byAdding: .day, value: -i, to: now) ?? now
                let startOfDay = calendar.startOfDay(for: startDay)
                let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? startOfDay
                ranges.insert(startOfDay..<endOfDay, at: 0)
            }
            
        case .month:
            // Weekly intervals for a month
            for i in 0..<4 {
                let startWeek = calendar.date(byAdding: .weekOfYear, value: -i, to: now) ?? now
                let startOfWeek = calendar.date(
                    from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: startWeek)
                ) ?? startWeek
                let endOfWeek = calendar.date(byAdding: .weekOfYear, value: 1, to: startOfWeek) ?? startOfWeek
                ranges.insert(startOfWeek..<endOfWeek, at: 0)
            }
            
        case .year:
            // Monthly intervals for a year
            for i in 0..<12 {
                let startMonth = calendar.date(byAdding: .month, value: -i, to: now) ?? now
                let components = calendar.dateComponents([.year, .month], from: startMonth)
                let startOfMonth = calendar.date(from: components) ?? startMonth
                let endOfMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth) ?? startOfMonth
                ranges.insert(startOfMonth..<endOfMonth, at: 0)
            }
        }
        
        return ranges
    }
    
    private func getDateFormat() -> Date.FormatStyle {
        switch timeFrame {
        case .week:
            return .dateTime.day().month(.abbreviated)
        case .month:
            return .dateTime.day().month(.abbreviated)
        case .year:
            return .dateTime.month(.abbreviated)
        }
    }
    
    private func calculateTotalSpent() -> Double {
        getFilteredTransactions().filter { $0.isExpense }.reduce(0) { $0 + $1.amount }
    }
    
    private func calculateDailyAverage() -> Double {
        let totalDays: Double
        
        switch timeFrame {
        case .week:
            totalDays = 7
        case .month:
            totalDays = 30
        case .year:
            totalDays = 365
        }
        
        return calculateTotalSpent() / totalDays
    }
    
    private func calculateMaxAmount() -> Double {
        if let maxValue = prepareMonthlyTrendsData()?.map({ $0.amount }).max(), maxValue > 0 {
            return maxValue * 1.2 // Add 20% padding
        }
        return 1000
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        return AppSettings.shared.formatCurrency(amount)
    }
}

struct BudgetVsActualView: View {
    @Environment(BudgetModel.self) private var model
    let timeFrame: AnalysisView.TimeFrame
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Budget vs. Actual Comparison")
                .font(.headline)
            
            HStack(spacing: 20) {
                VStack {
                    Text("Budget")
                        .font(.subheadline)
                    
                    Text(formatCurrency(model.budget))
                        .font(.title2)
                        .fontWeight(.bold)
                }
                .frame(maxWidth: .infinity)
                
                VStack {
                    Text("Actual Spending")
                        .font(.subheadline)
                    
                    Text(formatCurrency(calculatePeriodSpending()))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(calculatePeriodSpending() > getAdjustedBudget() ? .red : .green)
                }
                .frame(maxWidth: .infinity)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
            
            // Budget vs Actual Bar Chart
            Chart {
                BarMark(
                    x: .value("Category", "Budget"),
                    y: .value("Amount", getAdjustedBudget())
                )
                .foregroundStyle(Color.blue)
                
                BarMark(
                    x: .value("Category", "Actual"),
                    y: .value("Amount", calculatePeriodSpending())
                )
                .foregroundStyle(calculatePeriodSpending() > getAdjustedBudget() ? Color.red : Color.green)
            }
            .frame(height: 200)
            
            // Variance
            VStack(alignment: .leading) {
                Text("Variance")
                    .font(.headline)
                
                let variance = getAdjustedBudget() - calculatePeriodSpending()
                Text(formatCurrency(abs(variance)))
                    .font(.title3)
                    .foregroundColor(variance >= 0 ? .green : .red)
                
                Text(variance >= 0 ? "Under Budget" : "Over Budget")
                    .font(.subheadline)
                    .foregroundColor(variance >= 0 ? .green : .red)
                
                // Percentage of budget used
                let percentUsed = calculatePeriodSpending() / getAdjustedBudget() * 100
                
                Text("Budget Utilization")
                    .font(.headline)
                    .padding(.top, 10)
                
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 5)
                        .frame(height: 20)
                        .foregroundColor(Color(.systemGray5))
                    
                    RoundedRectangle(cornerRadius: 5)
                        .frame(width: min(CGFloat(percentUsed / 100) * 300, 300), height: 20)
                        .foregroundColor(percentUsed > 100 ? .red : .blue)
                }
                .frame(width: 300)
                
                Text("\(Int(percentUsed))% of budget used")
                    .font(.subheadline)
                    .padding(.top, 5)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(radius: 2)
    }
    
    // MARK: - Helper Methods
    
    private func calculatePeriodSpending() -> Double {
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
        
        return model.transactions
            .filter { $0.date >= startDate && $0.date <= now && $0.isExpense }
            .reduce(0) { $0 + $1.amount }
    }
    
    private func getAdjustedBudget() -> Double {
        switch timeFrame {
        case .week:
            return model.budget / 4 // Assuming monthly budget divided by 4 weeks
        case .month:
            return model.budget
        case .year:
            return model.budget * 12
        }
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        return AppSettings.shared.formatCurrency(amount)
    }
}

struct CategoryAnalysisView: View {
    @Environment(BudgetModel.self) private var model
    let timeFrame: AnalysisView.TimeFrame
    @State private var selectedCategory: BudgetCategory?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Category Spending Analysis")
                .font(.headline)
            
            // Pie Chart for Category Distribution
            VStack {
                Text("Spending Distribution by Category")
                    .font(.subheadline)
                    .padding(.bottom, 5)
                
                if !categoryData.isEmpty {
                    Chart(categoryData) { item in
                        SectorMark(
                            angle: .value("Amount", item.amount),
                            innerRadius: .ratio(0.5),
                            angularInset: 1.5
                        )
                        .foregroundStyle(item.category.color)
                        .cornerRadius(5)
                    }
                    .chartLegend(position: .bottom, alignment: .center, spacing: 20)
                    .frame(height: 250)
                } else {
                    Text("No data available for the selected time frame")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
            
            // Top Categories List
            VStack(alignment: .leading) {
                Text("Top Categories")
                    .font(.headline)
                
                ForEach(topCategories, id: \.category) { item in
                    HStack {
                        Image(systemName: item.category.icon)
                            .foregroundColor(item.category.color)
                            .frame(width: 30)
                        
                        Text(item.category.displayName)
                        
                        Spacer()
                        
                        Text(formatCurrency(item.amount))
                            .font(.subheadline)
                        
                        Text("(\(calculatePercentage(item.amount, of: calculateTotalSpent()))%)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 5)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
            
            // Category Trend over Time
            if let selectedCategory = selectedCategory {
                VStack(alignment: .leading) {
                    Text("\(selectedCategory.displayName) Spending Trend")
                        .font(.headline)
                    
                    if let trendData = prepareCategoryTrendData(for: selectedCategory), !trendData.isEmpty {
                        Chart(trendData) { item in
                            LineMark(
                                x: .value("Date", item.date),
                                y: .value("Amount", item.amount)
                            )
                            .foregroundStyle(selectedCategory.color)
                        }
                        .frame(height: 150)
                    } else {
                        Text("No data available for this category in the selected time frame")
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
            }
            
            // Category Selection
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(BudgetCategory.allCases) { category in
                        Button(action: {
                            if selectedCategory == category {
                                selectedCategory = nil
                            } else {
                                selectedCategory = category
                            }
                        }) {
                            VStack {
                                Image(systemName: category.icon)
                                    .foregroundColor(.white)
                                    .padding(8)
                                    .background(
                                        Circle()
                                            .fill(category.color)
                                    )
                                
                                Text(category.displayName)
                                    .font(.caption)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        .opacity(selectedCategory == nil || selectedCategory == category ? 1.0 : 0.5)
                    }
                }
                .padding(.vertical, 5)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(radius: 2)
    }
    
    // MARK: - Helper Methods
    
    struct CategoryItem: Identifiable {
        let id = UUID()
        let category: BudgetCategory
        let amount: Double
    }
    
    struct TrendItem: Identifiable {
        let id = UUID()
        let date: Date
        let amount: Double
    }
    
    private var categoryData: [CategoryItem] {
        let transactions = getFilteredTransactions().filter { $0.isExpense }
        var categoryAmounts: [BudgetCategory: Double] = [:]
        
        for category in BudgetCategory.allCases {
            categoryAmounts[category] = 0
        }
        
        for transaction in transactions {
            let category = transaction.categoryEnum
            categoryAmounts[category] = (categoryAmounts[category] ?? 0) + transaction.amount
        }
        
        return categoryAmounts
            .filter { $0.value > 0 }
            .map { CategoryItem(category: $0.key, amount: $0.value) }
            .sorted { $0.amount > $1.amount }
    }
    
    private var topCategories: [CategoryItem] {
        Array(categoryData.prefix(5))
    }
    
    private func prepareCategoryTrendData(for category: BudgetCategory) -> [TrendItem]? {
        let filteredTransactions = getFilteredTransactions().filter { 
            $0.categoryEnum == category && $0.isExpense
        }
        
        if filteredTransactions.isEmpty {
            return nil
        }
        
        let calendar = Calendar.current
        let dateRanges = getDateRanges()
        
        var trendData: [TrendItem] = []
        
        for range in dateRanges {
            let startDate = range.lowerBound
            let endDate = range.upperBound
            
            let rangeTransactions = filteredTransactions.filter {
                $0.date >= startDate && $0.date < endDate
            }
            
            let total = rangeTransactions.reduce(0) { $0 + $1.amount }
            trendData.append(TrendItem(date: startDate, amount: total))
        }
        
        return trendData
    }
    
    private func getFilteredTransactions() -> [Transaction] {
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
        
        return model.transactions.filter { $0.date >= startDate && $0.date <= now }
    }
    
    private func getDateRanges() -> [Range<Date>] {
        let calendar = Calendar.current
        let now = Date()
        var ranges: [Range<Date>] = []
        
        switch timeFrame {
        case .week:
            // Daily intervals for a week
            for i in 0..<7 {
                let startDay = calendar.date(byAdding: .day, value: -i, to: now) ?? now
                let startOfDay = calendar.startOfDay(for: startDay)
                let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? startOfDay
                ranges.insert(startOfDay..<endOfDay, at: 0)
            }
            
        case .month:
            // Weekly intervals for a month
            for i in 0..<4 {
                let startWeek = calendar.date(byAdding: .weekOfYear, value: -i, to: now) ?? now
                let startOfWeek = calendar.date(
                    from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: startWeek)
                ) ?? startWeek
                let endOfWeek = calendar.date(byAdding: .weekOfYear, value: 1, to: startOfWeek) ?? startOfWeek
                ranges.insert(startOfWeek..<endOfWeek, at: 0)
            }
            
        case .year:
            // Monthly intervals for a year
            for i in 0..<12 {
                let startMonth = calendar.date(byAdding: .month, value: -i, to: now) ?? now
                let components = calendar.dateComponents([.year, .month], from: startMonth)
                let startOfMonth = calendar.date(from: components) ?? startMonth
                let endOfMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth) ?? startOfMonth
                ranges.insert(startOfMonth..<endOfMonth, at: 0)
            }
        }
        
        return ranges
    }
    
    private func calculateTotalSpent() -> Double {
        getFilteredTransactions().filter { $0.isExpense }.reduce(0) { $0 + $1.amount }
    }
    
    private func calculatePercentage(_ amount: Double, of total: Double) -> Int {
        guard total > 0 else { return 0 }
        return Int((amount / total) * 100)
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        return AppSettings.shared.formatCurrency(amount)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Transaction.self, configurations: config)
    let model = BudgetModel(modelContainer: container)
    
    // Add some sample data
    let categories = BudgetCategory.allCases
    for i in 1...20 {
        let amount = Double.random(in: 10...100)
        let category = categories.randomElement()!
        let date = Date().addingTimeInterval(-Double(i * 86400))
        let isExpense = true
        
        let transaction = Transaction(
            amount: amount,
            title: "Sample Transaction \(i)",
            category: category.rawValue,
            date: date,
            isExpense: isExpense
        )
        
        model.addTransaction(transaction)
    }
    
    return AnalysisView()
        .environment(model)
} 