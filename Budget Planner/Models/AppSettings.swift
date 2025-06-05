import Foundation
import SwiftUI
import Observation

@Observable
final class AppSettings {
    // Singleton instance
    static let shared = AppSettings()
    
    // Currency settings
    var selectedCurrency: Currency = .usd
    
    // Theme settings
    var selectedTheme: AppTheme = .system
    
    // Budget settings
    var budgetPeriod: BudgetPeriod = .monthly
    var dailyBudgetAmount: Double = 33.33 // Default ~$1000/month
    
    // UserDefaults keys
    private enum Keys {
        static let currency = "selectedCurrency"
        static let theme = "selectedTheme"
        static let budgetPeriod = "budgetPeriod"
        static let dailyBudgetAmount = "dailyBudgetAmount"
    }
    
    // Private init for singleton
    private init() {
        loadSettings()
    }
    
    // Load settings from UserDefaults
    func loadSettings() {
        if let currencyString = UserDefaults.standard.string(forKey: Keys.currency),
           let currency = Currency(rawValue: currencyString) {
            selectedCurrency = currency
        }
        
        if let themeString = UserDefaults.standard.string(forKey: Keys.theme),
           let theme = AppTheme(rawValue: themeString) {
            selectedTheme = theme
        }
        
        if let periodString = UserDefaults.standard.string(forKey: Keys.budgetPeriod),
           let period = BudgetPeriod(rawValue: periodString) {
            budgetPeriod = period
        }
        
        let savedDailyBudget = UserDefaults.standard.double(forKey: Keys.dailyBudgetAmount)
        if savedDailyBudget > 0 {
            dailyBudgetAmount = savedDailyBudget
        }
    }
    
    // Save settings to UserDefaults
    func saveSettings() {
        UserDefaults.standard.set(selectedCurrency.rawValue, forKey: Keys.currency)
        UserDefaults.standard.set(selectedTheme.rawValue, forKey: Keys.theme)
        UserDefaults.standard.set(budgetPeriod.rawValue, forKey: Keys.budgetPeriod)
        UserDefaults.standard.set(dailyBudgetAmount, forKey: Keys.dailyBudgetAmount)
    }
    
    // Update currency and save
    func updateCurrency(_ currency: Currency) {
        selectedCurrency = currency
        saveSettings()
    }
    
    // Update theme and save
    func updateTheme(_ theme: AppTheme) {
        selectedTheme = theme
        saveSettings()
        applyTheme(theme)
    }
    
    // Apply theme
    private func applyTheme(_ theme: AppTheme) {
        // In a real app, we would apply the theme system-wide
        // This would involve setting the color scheme for the app
        print("Theme changed to \(theme.displayName)")
    }
    
    // Format currency amount
    func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = selectedCurrency.symbol
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: amount)) ?? "\(selectedCurrency.symbol)\(amount)"
    }
    
    // Update budget period
    func updateBudgetPeriod(_ period: BudgetPeriod) {
        budgetPeriod = period
        saveSettings()
    }
    
    // Update budget amount for current period
    func updateBudgetAmount(_ amount: Double) {
        // Convert the provided amount to a daily budget
        dailyBudgetAmount = budgetPeriod.normalizeToDailyAmount(amount: amount)
        saveSettings()
    }
    
    // Get current period budget amount
    func getCurrentPeriodBudget() -> Double {
        return budgetPeriod.convertFromDailyAmount(dailyAmount: dailyBudgetAmount)
    }
    
    // Format current budget with period
    func formatBudget() -> String {
        return "\(formatCurrency(getCurrentPeriodBudget())) per \(budgetPeriod.displayName.lowercased())"
    }
    
    // Reset all settings to default values
    func resetToDefaults() {
        // Reset to default values
        selectedCurrency = .usd
        selectedTheme = .system
        budgetPeriod = .monthly
        dailyBudgetAmount = 33.33 // Default ~$1000/month
        
        // Clear user defaults to ensure clean state
        UserDefaults.standard.removeObject(forKey: Keys.currency)
        UserDefaults.standard.removeObject(forKey: Keys.theme)
        UserDefaults.standard.removeObject(forKey: Keys.budgetPeriod)
        UserDefaults.standard.removeObject(forKey: Keys.dailyBudgetAmount)
        
        // Save defaults
        saveSettings()
    }
} 