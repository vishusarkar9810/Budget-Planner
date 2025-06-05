import Foundation

enum BudgetPeriod: String, CaseIterable, Identifiable, Codable {
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
    case quarterly = "Quarterly"
    case yearly = "Yearly"
    case custom = "Custom"
    
    var id: String { rawValue }
    
    var displayName: String {
        return rawValue
    }
    
    var daysInPeriod: Int {
        switch self {
        case .daily:
            return 1
        case .weekly:
            return 7
        case .monthly:
            return 30
        case .quarterly:
            return 90
        case .yearly:
            return 365
        case .custom:
            return 30 // Default to monthly for custom
        }
    }
    
    // Convert a budget amount to its daily equivalent
    func normalizeToDailyAmount(amount: Double) -> Double {
        // Safeguard against invalid values
        guard amount.isFinite, amount >= 0 else { return 0.0 }
        let result = amount / Double(daysInPeriod)
        return result.isFinite ? result : 0.0
    }
    
    // Convert a budget amount from daily to this period
    func convertFromDailyAmount(dailyAmount: Double) -> Double {
        // Safeguard against invalid values
        guard dailyAmount.isFinite, dailyAmount >= 0 else { return 0.0 }
        let result = dailyAmount * Double(daysInPeriod)
        return result.isFinite ? result : 0.0
    }
} 