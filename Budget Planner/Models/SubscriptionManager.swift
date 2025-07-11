import Foundation
import StoreKit
import Observation
import UserNotifications

// Enhanced error types for subscription failures
enum SubscriptionError: Error, LocalizedError {
    case productNotFound
    case purchaseFailed(Error)
    case userCancelled
    case pending
    case networkError
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .productNotFound:
            return "The requested subscription product could not be found."
        case .purchaseFailed(let error):
            return "Purchase failed: \(error.localizedDescription)"
        case .userCancelled:
            return "Purchase was cancelled."
        case .pending:
            return "Purchase is pending approval."
        case .networkError:
            return "Network error occurred. Please check your connection and try again."
        case .unknown:
            return "An unknown error occurred. Please try again later."
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .productNotFound:
            return "Please try again later or contact support."
        case .purchaseFailed:
            return "Please try again or contact support if the issue persists."
        case .userCancelled:
            return nil
        case .pending:
            return "Your purchase will be processed once it's approved."
        case .networkError:
            return "Check your internet connection and try again."
        case .unknown:
            return "Try restarting the app or contact support if the issue persists."
        }
    }
}

// Notification for subscription updates
extension Notification.Name {
    static let subscriptionUpdated = Notification.Name("subscriptionUpdated")
}

@Observable
final class SubscriptionManager: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    // Singleton instance
    static let shared = SubscriptionManager()
    
    // Available subscription products
    private(set) var products: [SKProduct] = []
    
    // Current subscription status
    private(set) var isSubscribed: Bool = false
    private(set) var currentSubscription: SKProduct?
    private(set) var isLoading: Bool = false
    private(set) var hasLifetimeAccess: Bool = false
    
    // Free trial status
    private(set) var isInFreeTrial: Bool = false
    private(set) var freeTrialEndDate: Date?
    
    // Error handling
    private(set) var errorMessage: String?
    private(set) var detailedError: SubscriptionError?
    
    // Product IDs
    private let monthlySubscriptionID = "com.budgetplanner.subscription.monthly"
    private let yearlySubscriptionID = "com.budgetplanner.subscription.yearly"
    private let lifetimePremiumID = "com.budgetplanner.lifetime.premium"
    
    // Initialize the subscription manager
    private override init() {
        super.init()
        
        // Add the transaction observer
        SKPaymentQueue.default().add(self)
        
        // Load products immediately
        loadProducts()
        
        // Load subscription status from user defaults
        isSubscribed = UserDefaults.standard.bool(forKey: "isSubscribed")
        hasLifetimeAccess = UserDefaults.standard.bool(forKey: "hasLifetimeAccess")
        
        // Load free trial status
        isInFreeTrial = UserDefaults.standard.bool(forKey: "isInFreeTrial")
        if let endDateTimestamp = UserDefaults.standard.object(forKey: "freeTrialEndDate") as? Date {
            freeTrialEndDate = endDateTimestamp
            
            // Check if free trial has expired
            if let endDate = freeTrialEndDate, Date() > endDate {
                isInFreeTrial = false
                UserDefaults.standard.set(false, forKey: "isInFreeTrial")
                UserDefaults.standard.removeObject(forKey: "freeTrialEndDate")
            }
        }
        
        // Check receipt for subscription status
        verifySubscriptionStatus()
    }
    
    deinit {
        SKPaymentQueue.default().remove(self)
    }
    
    // MARK: - Public Methods
    
    // Load available products from the App Store
    func loadProducts() {
        isLoading = true
        errorMessage = nil
        detailedError = nil
        
        let productIdentifiers = Set([monthlySubscriptionID, yearlySubscriptionID, lifetimePremiumID])
        let productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
        productsRequest.delegate = self
        productsRequest.start()
    }
    
    // Purchase a subscription
    func purchase(_ product: SKProduct) {
        if SKPaymentQueue.canMakePayments() {
            isLoading = true
            errorMessage = nil
            detailedError = nil
            
            // Use the standard StoreKit payment process for all products
            // The App Store will handle the free trial for products with introductory offers
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(payment)
        } else {
            detailedError = .unknown
            errorMessage = "Unable to make payments. Check your device settings."
        }
    }
    
    // Restore purchases
    func restorePurchases() {
        isLoading = true
        errorMessage = nil
        detailedError = nil
        
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    // Get a specific product by ID
    func product(for productID: String) -> SKProduct? {
        return products.first { $0.productIdentifier == productID }
    }
    
    // Get error details for UI display
    func getErrorDetails() -> (message: String, suggestion: String?) {
        guard let error = detailedError else {
            return (errorMessage ?? "Unknown error", nil)
        }
        
        return (error.errorDescription ?? "Unknown error", error.recoverySuggestion)
    }
    
    // Clear error state
    func clearErrors() {
        errorMessage = nil
        detailedError = nil
    }
    
    // Check if user has premium access (either subscription or lifetime)
    var hasPremiumAccess: Bool {
        return isSubscribed || hasLifetimeAccess || isInFreeTrial
    }
    
    // Get free trial remaining days
    var freeTrialRemainingDays: Int? {
        guard isInFreeTrial, let endDate = freeTrialEndDate else { return nil }
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: endDate)
        return components.day
    }
    
    // Check if a product has a free trial offer
    func hasFreeTrial(for product: SKProduct) -> Bool {
        if #available(iOS 12.2, *) {
            return product.introductoryPrice != nil
        }
        return false
    }
    
    // Get free trial duration in days for a product
    func freeTrialDuration(for product: SKProduct) -> Int {
        if #available(iOS 12.2, *), let introPrice = product.introductoryPrice {
            if introPrice.paymentMode == .freeTrial {
                switch introPrice.subscriptionPeriod.unit {
                case .day:
                    return introPrice.subscriptionPeriod.numberOfUnits
                case .week:
                    return introPrice.subscriptionPeriod.numberOfUnits * 7
                case .month:
                    return introPrice.subscriptionPeriod.numberOfUnits * 30
                case .year:
                    return introPrice.subscriptionPeriod.numberOfUnits * 365
                @unknown default:
                    return 0
                }
            }
        }
        return 0
    }
    
    // Format free trial duration
    func formatFreeTrialDuration(for product: SKProduct) -> String {
        let days = freeTrialDuration(for: product)
        if days == 0 {
            return ""
        } else if days == 1 {
            return "1-Day Free Trial"
        } else {
            return "\(days)-Day Free Trial"
        }
    }
    
    // Verify current subscription status
    private func verifySubscriptionStatus() {
        // In a real app, this would validate the receipt with Apple's servers
        // For now, we'll rely on UserDefaults for the demo
        
        // Check if we need to refresh the receipt
        if let receiptURL = Bundle.main.appStoreReceiptURL,
           let receiptData = try? Data(contentsOf: receiptURL) {
            // In a real app, you would send this receipt data to your server
            // Your server would then validate with Apple's servers
            print("Receipt data available: \(receiptData.count) bytes")
            
            // For demo purposes, we'll just check if receipt exists
            if receiptData.count > 0 {
                // Receipt exists, but we'll still rely on our stored values
                // In a real app, you would validate the receipt properly
            }
        } else {
            // No receipt found, refresh it
            let request = SKReceiptRefreshRequest(receiptProperties: nil)
            request.delegate = self
            request.start()
        }
    }
    
    // MARK: - SKProductsRequestDelegate
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        DispatchQueue.main.async {
            self.products = response.products
            self.isLoading = false
            
            if response.products.isEmpty {
                self.detailedError = .productNotFound
                self.errorMessage = self.detailedError?.errorDescription
            }
            
            // Post notification that products were loaded
            NotificationCenter.default.post(name: .subscriptionUpdated, object: nil)
        }
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.detailedError = .networkError
            self.errorMessage = "Failed to load products: \(error.localizedDescription)"
            self.isLoading = false
            print("StoreKit error loading products: \(error)")
            
            // Post notification that an error occurred
            NotificationCenter.default.post(name: .subscriptionUpdated, object: nil)
        }
    }
    
    // MARK: - SKPaymentTransactionObserver
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                handlePurchased(transaction)
            case .failed:
                handleFailed(transaction)
            case .restored:
                handleRestored(transaction)
            case .deferred:
                handleDeferred(transaction)
            case .purchasing:
                // Transaction is in progress
                break
            @unknown default:
                break
            }
        }
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        DispatchQueue.main.async {
            self.isLoading = false
            
            if !self.hasPremiumAccess {
                // No subscriptions were found to restore
                self.errorMessage = "No previous purchases found"
            }
            
            // Post notification that restore completed
            NotificationCenter.default.post(name: .subscriptionUpdated, object: nil)
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        DispatchQueue.main.async {
            self.detailedError = .purchaseFailed(error)
            self.errorMessage = "Failed to restore purchases: \(error.localizedDescription)"
            self.isLoading = false
            print("StoreKit restore error: \(error)")
            
            // Post notification that an error occurred
            NotificationCenter.default.post(name: .subscriptionUpdated, object: nil)
        }
    }
    
    // MARK: - Private Transaction Handling
    
    private func handlePurchased(_ transaction: SKPaymentTransaction) {
        let productID = transaction.payment.productIdentifier
        
        // Check if this is one of our subscription products or lifetime product
        if productID == monthlySubscriptionID || productID == yearlySubscriptionID {
            DispatchQueue.main.async {
                self.isSubscribed = true
                self.currentSubscription = self.product(for: productID)
                
                // Check if this is a free trial
                if #available(iOS 12.2, *), 
                   let product = self.product(for: productID),
                   let introPrice = product.introductoryPrice,
                   introPrice.paymentMode == .freeTrial {
                    
                    // Calculate trial end date based on the introductory price period
                    let trialDays = self.freeTrialDuration(for: product)
                    if trialDays > 0 {
                        self.isInFreeTrial = true
                        self.freeTrialEndDate = Calendar.current.date(byAdding: .day, value: trialDays, to: Date())
                        
                        // Save free trial status
                        UserDefaults.standard.set(true, forKey: "isInFreeTrial")
                        UserDefaults.standard.set(self.freeTrialEndDate, forKey: "freeTrialEndDate")
                        
                        // Schedule end of trial notification
                        if let endDate = self.freeTrialEndDate {
                            self.scheduleEndOfTrialNotification(endDate: endDate)
                        }
                    }
                } else {
                    // Clear free trial status if this is a direct purchase
                    if self.isInFreeTrial {
                        self.isInFreeTrial = false
                        UserDefaults.standard.set(false, forKey: "isInFreeTrial")
                        UserDefaults.standard.removeObject(forKey: "freeTrialEndDate")
                    }
                }
                
                // Save subscription status
                UserDefaults.standard.set(true, forKey: "isSubscribed")
                
                // Update subscription status in AppSettings
                AppSettings.shared.updateSubscriptionStatus(isSubscribed: true)
                
                self.isLoading = false
                
                // Post notification that subscription status has changed
                NotificationCenter.default.post(name: .subscriptionUpdated, object: nil)
            }
        } else if productID == lifetimePremiumID {
            DispatchQueue.main.async {
                self.hasLifetimeAccess = true
                
                // Save lifetime access status
                UserDefaults.standard.set(true, forKey: "hasLifetimeAccess")
                
                // Update lifetime access status in AppSettings
                AppSettings.shared.updateLifetimeAccessStatus(hasLifetimeAccess: true)
                
                self.isLoading = false
                
                // Post notification that subscription status has changed
                NotificationCenter.default.post(name: .subscriptionUpdated, object: nil)
            }
        }
        
        // Finish the transaction
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    // Schedule notification for end of trial
    private func scheduleEndOfTrialNotification(endDate: Date) {
        let content = UNMutableNotificationContent()
        content.title = "Free Trial Ending Soon"
        content.body = "Your free trial of Budget Planner Premium will end tomorrow. Your subscription will continue automatically."
        content.sound = UNNotificationSound.default
        
        // Schedule notification for 1 day before trial ends
        let oneDayBefore = Calendar.current.date(byAdding: .day, value: -1, to: endDate)!
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: oneDayBefore)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let request = UNNotificationRequest(identifier: "trialEndingReminder", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
    
    private func handleFailed(_ transaction: SKPaymentTransaction) {
        DispatchQueue.main.async {
            self.isLoading = false
            
            if let error = transaction.error as? SKError {
                if error.code == .paymentCancelled {
                    // User cancelled the payment
                    self.detailedError = .userCancelled
                    self.errorMessage = self.detailedError?.errorDescription
                } else {
                    // Other error
                    self.detailedError = .purchaseFailed(error)
                    self.errorMessage = "Purchase failed: \(error.localizedDescription)"
                }
            } else if let error = transaction.error {
                self.detailedError = .purchaseFailed(error)
                self.errorMessage = "Purchase failed: \(error.localizedDescription)"
            } else {
                self.detailedError = .unknown
                self.errorMessage = "Purchase failed with unknown error"
            }
            
            print("Transaction failed: \(String(describing: transaction.error))")
            
            // Post notification that an error occurred
            NotificationCenter.default.post(name: .subscriptionUpdated, object: nil)
        }
        
        // Finish the transaction
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func handleRestored(_ transaction: SKPaymentTransaction) {
        guard let productID = transaction.original?.payment.productIdentifier else {
            SKPaymentQueue.default().finishTransaction(transaction)
            return
        }
        
        // Check if this is one of our subscription products or lifetime product
        if productID == monthlySubscriptionID || productID == yearlySubscriptionID {
            DispatchQueue.main.async {
                self.isSubscribed = true
                self.currentSubscription = self.product(for: productID)
                
                // Save subscription status
                UserDefaults.standard.set(true, forKey: "isSubscribed")
                
                // Update subscription status in AppSettings
                AppSettings.shared.updateSubscriptionStatus(isSubscribed: true)
                
                self.isLoading = false
                
                // Post notification that subscription status has changed
                NotificationCenter.default.post(name: .subscriptionUpdated, object: nil)
            }
        } else if productID == lifetimePremiumID {
            DispatchQueue.main.async {
                self.hasLifetimeAccess = true
                
                // Save lifetime access status
                UserDefaults.standard.set(true, forKey: "hasLifetimeAccess")
                
                // Update lifetime access status in AppSettings
                AppSettings.shared.updateLifetimeAccessStatus(hasLifetimeAccess: true)
                
                self.isLoading = false
                
                // Post notification that subscription status has changed
                NotificationCenter.default.post(name: .subscriptionUpdated, object: nil)
            }
        }
        
        // Finish the transaction
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func handleDeferred(_ transaction: SKPaymentTransaction) {
        DispatchQueue.main.async {
            self.detailedError = .pending
            self.errorMessage = "Purchase is pending approval."
            self.isLoading = false
            
            // Post notification that an error occurred
            NotificationCenter.default.post(name: .subscriptionUpdated, object: nil)
        }
    }
} 