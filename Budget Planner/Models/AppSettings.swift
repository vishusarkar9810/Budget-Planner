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
    var selectedTheme: AppTheme = .light
    
    // Budget settings
    var budgetPeriod: BudgetPeriod = .monthly
    var dailyBudgetAmount: Double = 33.33 // Default ~$1000/month
    
    // Onboarding
    var hasCompletedOnboarding: Bool = false
    
    // Subscription status
    var isSubscribed: Bool = false
    var hasLifetimeAccess: Bool = false
    
    // Premium features access
    var premiumFeaturesEnabled: Bool {
        return isSubscribed || hasLifetimeAccess
    }
    
    // UserDefaults keys
    private enum Keys {
        static let currency = "selectedCurrency"
        static let theme = "selectedTheme"
        static let budgetPeriod = "budgetPeriod"
        static let dailyBudgetAmount = "dailyBudgetAmount"
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
        static let hasCurrencyBeenDetected = "hasCurrencyBeenDetected"
        static let isSubscribed = "isSubscribed"
        static let hasLifetimeAccess = "hasLifetimeAccess"
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
        } else {
            // If no currency has been set, detect and set the currency based on device locale
            let hasCurrencyBeenDetected = UserDefaults.standard.bool(forKey: Keys.hasCurrencyBeenDetected)
            if !hasCurrencyBeenDetected {
                detectAndSetCurrency()
                UserDefaults.standard.set(true, forKey: Keys.hasCurrencyBeenDetected)
            }
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
        
        hasCompletedOnboarding = UserDefaults.standard.bool(forKey: Keys.hasCompletedOnboarding)
        
        // Load subscription status
        isSubscribed = UserDefaults.standard.bool(forKey: Keys.isSubscribed)
        hasLifetimeAccess = UserDefaults.standard.bool(forKey: Keys.hasLifetimeAccess)
    }
    
    // Detect and set the currency based on device locale
    private func detectAndSetCurrency() {
        // Get the current locale's region code
        let currentRegionCode = Locale.current.region?.identifier.uppercased() ?? ""
        
        // Match the region code to a currency
        switch currentRegionCode {
        case "US": selectedCurrency = .usd
        case "GB": selectedCurrency = .gbp
        case "EU", "DE", "FR", "IT", "ES", "NL", "BE", "PT", "AT", "IE", "FI", "SK", "SI", "LV", "LT", "EE", "GR", "MT", "CY", "LU":
            selectedCurrency = .eur
        case "JP": selectedCurrency = .jpy
        case "CH": selectedCurrency = .chf
        case "CA": selectedCurrency = .cad
        case "AU": selectedCurrency = .aud
        case "NZ": selectedCurrency = .nzd
        case "CN": selectedCurrency = .cny
        case "HK": selectedCurrency = .hkd
        case "SG": selectedCurrency = .sgd
        case "IN": selectedCurrency = .inr
        case "KR": selectedCurrency = .krw
        case "TH": selectedCurrency = .thb
        case "ID": selectedCurrency = .idr
        case "MY": selectedCurrency = .myr
        case "PH": selectedCurrency = .php
        case "TW": selectedCurrency = .twd
        case "PK": selectedCurrency = .pkr
        case "BD": selectedCurrency = .bdt
        case "VN": selectedCurrency = .vnd
        case "SE": selectedCurrency = .sek
        case "NO": selectedCurrency = .nok
        case "DK": selectedCurrency = .dkk
        case "PL": selectedCurrency = .pln
        case "CZ": selectedCurrency = .czk
        case "HU": selectedCurrency = .huf
        case "RO": selectedCurrency = .ron
        case "BG": selectedCurrency = .bgn
        case "HR": selectedCurrency = .hrk
        case "RS": selectedCurrency = .rsd
        case "IS": selectedCurrency = .isk
        case "TR": selectedCurrency = .lira
        case "RU": selectedCurrency = .rub
        case "UA": selectedCurrency = .uah
        case "IL": selectedCurrency = .ils
        case "AE": selectedCurrency = .aed
        case "SA": selectedCurrency = .sar
        case "QA": selectedCurrency = .qar
        case "KW": selectedCurrency = .kwd
        case "BH": selectedCurrency = .bhd
        case "OM": selectedCurrency = .omr
        case "EG": selectedCurrency = .egp
        case "MX": selectedCurrency = .mxn
        case "BR": selectedCurrency = .brl
        case "AR": selectedCurrency = .ars
        case "CL": selectedCurrency = .clp
        case "CO": selectedCurrency = .cop
        case "PE": selectedCurrency = .pen
        case "UY": selectedCurrency = .uyu
        case "ZA": selectedCurrency = .zar
        case "NG": selectedCurrency = .ngn
        case "KE": selectedCurrency = .kes
        case "GH": selectedCurrency = .ghs
        case "MA": selectedCurrency = .mad
        case "SN", "BJ", "BF", "CI", "GW", "ML", "NE", "TG":
            selectedCurrency = .xof
        case "CM", "CF", "TD", "CG", "GQ", "GA":
            selectedCurrency = .xaf
        case "FJ": selectedCurrency = .fjd
        case "PG": selectedCurrency = .pgk
        case "TO": selectedCurrency = .top
        case "VU": selectedCurrency = .vuv
        case "WS": selectedCurrency = .wst
        default:
            // Default to USD if region not recognized
            selectedCurrency = .usd
        }
        
        // Save the detected currency
        saveSettings()
    }
    
    // Save settings to UserDefaults
    func saveSettings() {
        UserDefaults.standard.set(selectedCurrency.rawValue, forKey: Keys.currency)
        UserDefaults.standard.set(selectedTheme.rawValue, forKey: Keys.theme)
        UserDefaults.standard.set(budgetPeriod.rawValue, forKey: Keys.budgetPeriod)
        UserDefaults.standard.set(dailyBudgetAmount, forKey: Keys.dailyBudgetAmount)
        UserDefaults.standard.set(hasCompletedOnboarding, forKey: Keys.hasCompletedOnboarding)
        UserDefaults.standard.set(isSubscribed, forKey: Keys.isSubscribed)
        UserDefaults.standard.set(hasLifetimeAccess, forKey: Keys.hasLifetimeAccess)
    }
    
    // Mark onboarding as completed
    func completeOnboarding() {
        hasCompletedOnboarding = true
        saveSettings()
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
        return selectedCurrency.format(amount)
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
    
    // Update subscription status
    func updateSubscriptionStatus(isSubscribed: Bool) {
        self.isSubscribed = isSubscribed
        saveSettings()
    }
    
    // Update lifetime access status
    func updateLifetimeAccessStatus(hasLifetimeAccess: Bool) {
        self.hasLifetimeAccess = hasLifetimeAccess
        saveSettings()
    }
    
    // Check if premium feature is accessible
    func canAccessPremiumFeature() -> Bool {
        return isSubscribed || hasLifetimeAccess
    }
    
    // Reset all settings to default values
    func resetToDefaults() {
        // Reset to default values
        selectedCurrency = .usd
        selectedTheme = .light
        budgetPeriod = .monthly
        dailyBudgetAmount = 33.33 // Default ~$1000/month
        isSubscribed = false
        hasLifetimeAccess = false
        
        // Clear user defaults to ensure clean state
        UserDefaults.standard.removeObject(forKey: Keys.currency)
        UserDefaults.standard.removeObject(forKey: Keys.theme)
        UserDefaults.standard.removeObject(forKey: Keys.budgetPeriod)
        UserDefaults.standard.removeObject(forKey: Keys.dailyBudgetAmount)
        UserDefaults.standard.removeObject(forKey: Keys.hasCurrencyBeenDetected)
        UserDefaults.standard.removeObject(forKey: Keys.isSubscribed)
        UserDefaults.standard.removeObject(forKey: Keys.hasLifetimeAccess)
        
        // Save defaults
        saveSettings()
    }
} 