import Foundation
import StoreKit
import Observation

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
        return isSubscribed || hasLifetimeAccess
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