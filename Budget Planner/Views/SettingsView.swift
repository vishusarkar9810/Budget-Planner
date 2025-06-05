//
//  SettingsView.swift
//  Budget Planner
//
//  Created on Phase 4
//

import SwiftUI
import UniformTypeIdentifiers
import UserNotifications



// Theme for customization
enum AppTheme: String, CaseIterable, Identifiable {
    case system
    case light
    case dark
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .system: return "System"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }
    
    var accentColor: Color {
        switch self {
        case .system: return .blue
        case .light: return .blue
        case .dark: return .blue
        }
    }
}

// Currency for selection
enum Currency: String, CaseIterable, Identifiable {
    case usd = "USD"
    case eur = "EUR"
    case gbp = "GBP"
    case jpy = "JPY"
    case cad = "CAD"
    case aud = "AUD"
    case inr = "INR"
    
    var id: String { rawValue }
    
    var symbol: String {
        switch self {
        case .usd: return "$"
        case .eur: return "€"
        case .gbp: return "£"
        case .jpy: return "¥"
        case .cad: return "C$"
        case .aud: return "A$"
        case .inr: return "₹"
        }
    }
    
    var displayName: String {
        switch self {
        case .usd: return "US Dollar ($)"
        case .eur: return "Euro (€)"
        case .gbp: return "British Pound (£)"
        case .jpy: return "Japanese Yen (¥)"
        case .cad: return "Canadian Dollar (C$)"
        case .aud: return "Australian Dollar (A$)"
        case .inr: return "Indian Rupee (₹)"
        }
    }
}

struct SettingsView: View {
    @Environment(BudgetModel.self) private var model
    @State private var budgetAmount = ""
    @State private var showBudgetEditor = false
    @State private var showResetConfirmation = false
    @State private var selectedCurrency: Currency = AppSettings.shared.selectedCurrency
    @State private var selectedTheme: AppTheme = AppSettings.shared.selectedTheme
    @State private var selectedBudgetPeriod: BudgetPeriod = AppSettings.shared.budgetPeriod
    @State private var notificationsEnabled = false
    @State private var dailyReminderTime = Date()
    @State private var showCategoryManagement = false
    @State private var exportData = false
    @State private var showExportSheet = false
    @State private var exportUrl: URL?
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Budget Settings") {
                    HStack {
                        Text("Budget")
                        Spacer()
                        Button(AppSettings.shared.formatBudget()) {
                            // Initialize budget amount for editor
                            budgetAmount = String(format: "%.2f", AppSettings.shared.getCurrentPeriodBudget())
                            showBudgetEditor = true
                        }
                        .foregroundColor(.blue)
                    }
                    
                    Picker("Budget Period", selection: $selectedBudgetPeriod) {
                        ForEach(BudgetPeriod.allCases) { period in
                            Text(period.displayName).tag(period)
                        }
                    }
                    .onChange(of: selectedBudgetPeriod) { _, newPeriod in
                        AppSettings.shared.updateBudgetPeriod(newPeriod)
                    }
                    
                    Picker("Currency", selection: $selectedCurrency) {
                        ForEach(Currency.allCases) { currency in
                            Text(currency.displayName).tag(currency)
                        }
                    }
                    .onChange(of: selectedCurrency) { _, newCurrency in
                        AppSettings.shared.updateCurrency(newCurrency)
                    }
                }
                
                Section("Appearance") {
                    Picker("Theme", selection: $selectedTheme) {
                        ForEach(AppTheme.allCases) { theme in
                            Text(theme.displayName).tag(theme)
                        }
                    }
                    .onChange(of: selectedTheme) { _, newTheme in
                        AppSettings.shared.updateTheme(newTheme)
                    }
                }
                
                Section("Notifications") {
                    Toggle("Enable Notifications", isOn: $notificationsEnabled)
                        .onChange(of: notificationsEnabled) { _, newValue in
                            if newValue {
                                requestNotificationPermission()
                            }
                        }
                    
                    if notificationsEnabled {
                        DatePicker("Daily Reminder", selection: $dailyReminderTime, displayedComponents: .hourAndMinute)
                            .onChange(of: dailyReminderTime) { _, _ in
                                scheduleDailyReminder()
                            }
                    }
                }
                
                Section("Categories") {
                    Button {
                        showCategoryManagement = true
                    } label: {
                        Text("Manage Custom Categories")
                    }
                }
                
                Section("Data Management") {
                    Button {
                        exportBudgetData()
                    } label: {
                        Label("Export Data", systemImage: "square.and.arrow.up")
                    }
                    
                    Button {
                        // Show import file picker (implementation needed)
                    } label: {
                        Label("Import Data", systemImage: "square.and.arrow.down")
                    }
                }
                
                Section("Statistics") {
                    StatRow(title: "Total Spent", amount: model.totalSpent, color: .red, currency: AppSettings.shared.selectedCurrency.symbol)
                    StatRow(title: "Total Income", amount: model.totalIncome, color: .green, currency: AppSettings.shared.selectedCurrency.symbol)
                    StatRow(title: "Remaining Budget", amount: model.remainingBudget, color: model.remainingBudget >= 0 ? .green : .red, currency: AppSettings.shared.selectedCurrency.symbol)
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
            .sheet(isPresented: $showBudgetEditor) {
                BudgetEditorSheet(
                    budgetAmount: $budgetAmount,
                    budgetPeriod: $selectedBudgetPeriod,
                    onSave: {
                        updateBudget()
                        showBudgetEditor = false
                    },
                    onCancel: {
                        showBudgetEditor = false
                    }
                )
            }
            .sheet(isPresented: $showCategoryManagement) {
                CategoryManagementView()
            }
            .sheet(isPresented: $showExportSheet) {
                if let url = exportUrl {
                    ActivityViewController(activityItems: [url])
                }
            }
            .alert("Reset All Data", isPresented: $showResetConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Reset", role: .destructive) {
                    resetAllData()
                }
            } message: {
                Text("This will delete all transactions and reset your budget. This action cannot be undone.")
            }
        }
    }
    
    private var isValidBudget: Bool {
        guard let amount = Double(budgetAmount) else { return false }
        return amount > 0
    }
    
    private func updateBudget() {
        guard let amount = Double(budgetAmount.trimmingCharacters(in: .whitespacesAndNewlines)),
              amount > 0 else {
            return
        }
        
        // Update budget using AppSettings
        AppSettings.shared.updateBudgetAmount(amount)
    }
    
    private func resetAllData() {
        // Call the BudgetModel's resetAllData method which also resets AppSettings
        model.resetAllData()
        
        // Update local UI state to match reset values
        DispatchQueue.main.async {
            self.selectedCurrency = .usd
            self.selectedTheme = .system
            self.selectedBudgetPeriod = .monthly
            self.budgetAmount = "1000.00"
        }
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if let error = error {
                print("Error requesting notification permissions: \(error.localizedDescription)")
            }
        }
    }
    
    private func scheduleDailyReminder() {
        // Remove any existing notifications
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        // Create a new notification
        let content = UNMutableNotificationContent()
        content.title = "Budget Reminder"
        content.body = "Don't forget to log your transactions for today!"
        content.sound = .default
        
        // Configure the trigger (daily at specified time)
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.hour, .minute], from: dailyReminderTime)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        // Create the request
        let request = UNNotificationRequest(identifier: "dailyReminder", content: content, trigger: trigger)
        
        // Add the request to the notification center
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }
    // Theme handling is now done by AppSettings
    
    private func exportBudgetData() {
        // Get CSV data using our helper function
        let csvString = exportTransactionsToCSV(model.transactions)
        
        do {
            // Create a temporary file
            let tempDir = FileManager.default.temporaryDirectory
            let fileName = "budget_data_\(Date().timeIntervalSince1970).csv"
            let fileURL = tempDir.appendingPathComponent(fileName)
            
            // Write the string to a file
            try csvString.write(to: fileURL, atomically: true, encoding: .utf8)
            
            // Show share sheet
            self.exportUrl = fileURL
            self.showExportSheet = true
        } catch {
            print("Error exporting data: \(error.localizedDescription)")
        }
    }
}

struct CategoryManagementView: View {
    @Environment(BudgetModel.self) private var model
    @Environment(\.dismiss) private var dismiss
    @State private var customCategories: [BudgetCategory] = BudgetCategory.allCases
    @State private var newCategoryName = ""
    @State private var showAddCategory = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(customCategories) { category in
                    HStack {
                        Image(systemName: category.icon)
                            .foregroundColor(category.color)
                        
                        Text(category.displayName)
                    }
                }
                .onDelete(perform: deleteCategory)
            }
            .navigationTitle("Manage Categories")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        showAddCategory = true
                    }
                }
            }
            .alert("Add Category", isPresented: $showAddCategory) {
                TextField("Category Name", text: $newCategoryName)
                
                Button("Cancel", role: .cancel) {
                    newCategoryName = ""
                }
                
                Button("Add") {
                    // In a real implementation, we would add the category
                    // For this demo, we'll just show the alert
                    newCategoryName = ""
                }
            } message: {
                Text("Enter a name for your new category")
            }
        }
    }
    
    private func deleteCategory(at offsets: IndexSet) {
        // In a real implementation, we would delete the category
        // For this demo, we'll just remove it from the array
        // Make sure we don't delete the built-in categories
        // customCategories.remove(atOffsets: offsets)
    }
}



struct ActivityViewController: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities
        )
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct StatRow: View {
    let title: String
    var amount: Double? = nil
    var value: String? = nil
    var color: Color = .primary
    var currency: String = "$"
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            if let amount = amount {
                // Handle potential NaN or infinite values
                let safeAmount = amount.isNaN || amount.isInfinite ? 0.0 : amount
                Text("\(currency)\(safeAmount, specifier: "%.2f")")
                    .bold()
                    .foregroundColor(color)
            } else if let value = value {
                Text(value)
                    .bold()
                    .foregroundColor(color)
            } else {
                // Fallback for nil values
                Text("\(currency)0.00")
                    .bold()
                    .foregroundColor(color)
            }
        }
    }
}

// Budget Editor Sheet
struct BudgetEditorSheet: View {
    @Binding var budgetAmount: String
    @Binding var budgetPeriod: BudgetPeriod
    var onSave: () -> Void
    var onCancel: () -> Void
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Set your \(budgetPeriod.displayName.lowercased()) budget")
                    .font(.headline)
                
                HStack {
                    Text(AppSettings.shared.selectedCurrency.symbol)
                        .font(.title)
                        .padding(.leading)
                    
                    TextField("0.00", text: $budgetAmount)
                        .font(.system(size: 40, weight: .bold))
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.center)
                        .focused($isInputFocused)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
                
                Picker("Budget Period", selection: $budgetPeriod) {
                    ForEach(BudgetPeriod.allCases) { period in
                        Text(period.displayName).tag(period)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                Spacer()
                
                // Examples for selected period
                VStack(alignment: .leading, spacing: 12) {
                    Text("Examples of what you can buy:")
                        .font(.headline)
                        .padding(.bottom, 4)
                    
                    if let amount = Double(budgetAmount), amount > 0 {
                        let dailyAmount = budgetPeriod.normalizeToDailyAmount(amount: amount)
                        
                        let safeCoffeeCups = max(0, min(10000, dailyAmount / 5))
                        let safeMeals = max(0, min(10000, amount / 15))
                        let safeClothingItems = max(0, min(10000, amount / 50))
                        
                        HStack {
                            Image(systemName: "cup.and.saucer")
                            Text("Coffee: \(Int(safeCoffeeCups)) cups per day")
                        }
                        
                        HStack {
                            Image(systemName: "takeoutbag.and.cup.and.straw")
                            Text("Take-out meals: \(Int(safeMeals)) meals per \(budgetPeriod.displayName.lowercased())")
                        }
                        
                        HStack {
                            Image(systemName: "tshirt")
                            Text("Clothing: \(Int(safeClothingItems)) items per \(budgetPeriod.displayName.lowercased())")
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Budget Editor")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel", action: onCancel)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        onSave()
                    }
                    .disabled(!isValidAmount)
                }
            }
            .onAppear {
                isInputFocused = true
            }
        }
    }
    
    private var isValidAmount: Bool {
        guard let amount = Double(budgetAmount.trimmingCharacters(in: .whitespacesAndNewlines)),
              amount > 0 else {
            return false
        }
        return true
    }
} 