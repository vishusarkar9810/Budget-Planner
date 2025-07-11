import SwiftUI
import StoreKit
import UIKit

struct SubscriptionView: View {
    @State private var subscriptionManager = SubscriptionManager.shared
    @State private var showingLoadingIndicator = false
    @State private var showError = false
    @State private var errorTitle = "Error"
    @State private var errorMessage = ""
    @State private var errorSuggestion: String?
    @Environment(\.dismiss) private var dismiss
    
    // Parameters for onboarding flow
    var isFromOnboarding: Bool = false
    var onboardingCompletion: (() -> Void)? = nil
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.yellow)
                            .padding(.bottom, 10)
                        
                        Text("Premium Features")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Unlock premium features to get the most out of your budget planning")
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 20)
                    
                    // Features list
                    VStack(alignment: .leading, spacing: 15) {
                        FeatureRow(icon: "chart.line.uptrend.xyaxis", title: "Advanced Analytics", description: "Detailed spending patterns and insights")
                        FeatureRow(icon: "doc.on.doc", title: "Unlimited Categories", description: "Create as many budget categories as you need")
                        FeatureRow(icon: "arrow.up.arrow.down", title: "Custom Budget Periods", description: "Weekly, bi-weekly, and custom periods")
                        FeatureRow(icon: "bell.badge", title: "Custom Reminders", description: "Set personalized budget alerts")
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 20)
                    
                    // Subscription options
                    if subscriptionManager.isLoading {
                        ProgressView()
                            .padding()
                    } else if subscriptionManager.products.isEmpty {
                        VStack(spacing: 10) {
                            Text("No subscription options available")
                                .padding()
                            
                            Button {
                                subscriptionManager.loadProducts()
                            } label: {
                                Label("Retry Loading Products", systemImage: "arrow.clockwise")
                                    .foregroundColor(.blue)
                            }
                        }
                    } else {
                        // Subscription options section
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Subscription Options")
                                .font(.headline)
                                .padding(.horizontal)
                            
                        VStack(spacing: 15) {
                                ForEach(subscriptionManager.products.filter { 
                                    $0.productIdentifier == "com.budgetplanner.subscription.monthly" || 
                                    $0.productIdentifier == "com.budgetplanner.subscription.yearly"
                                }, id: \.productIdentifier) { product in
                                SubscriptionOptionView(product: product) {
                                    purchaseSubscription(product)
                                }
                            }
                        }
                        .padding(.horizontal)
                        }
                        .padding(.bottom, 20)
                        
                        // One-time purchase option
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Lifetime Access")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            if let lifetimeProduct = subscriptionManager.product(for: "com.budgetplanner.lifetime.premium") {
                                LifetimeOptionView(product: lifetimeProduct) {
                                    purchaseSubscription(lifetimeProduct)
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    
                    // Current subscription status
                    if subscriptionManager.isSubscribed {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("You are currently subscribed")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 10)
                    } else if subscriptionManager.hasLifetimeAccess {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("You have lifetime premium access")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 10)
                    } else if subscriptionManager.isInFreeTrial {
                        VStack(spacing: 4) {
                            HStack {
                                Image(systemName: "gift.fill")
                                    .foregroundColor(.blue)
                                Text("You are in a free trial period")
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                            }
                            
                            if let daysRemaining = subscriptionManager.freeTrialRemainingDays {
                                Text("\(daysRemaining) \(daysRemaining == 1 ? "day" : "days") remaining")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.top, 10)
                    }
                    
                    Spacer(minLength: 20)
                    
                    // Restore purchases button
                    Button("Restore Purchases") {
                        restorePurchases()
                    }
                    .font(.footnote)
                    .padding(.bottom, 10)
                    
                    // Skip button when coming from onboarding
                    if isFromOnboarding {
                        Button("Continue with Free Version") {
                            if let completion = onboardingCompletion {
                                completion()
                            } else {
                                dismiss()
                            }
                        }
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 10)
                    }
                    
                    // Terms and privacy
                    VStack(spacing: 5) {
                        Text("By subscribing, you agree to our Terms of Service and Privacy Policy")
                            .font(.caption2)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                        
                        Text("Subscriptions will automatically renew until canceled")
                            .font(.caption2)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                        
                        Text("Free trial automatically converts to paid subscription unless canceled before trial ends")
                            .font(.caption2)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 20) {
                            Button("Terms of Service") {
                                // Open terms of service URL
                                if let url = URL(string: "https://sites.google.com/aztty.com/budget-spending-tracker/home") {
                                    UIApplication.shared.open(url)
                                }
                            }
                            .font(.caption2)
                            .foregroundColor(.blue)
                            
                            Button("Privacy Policy") {
                                // Open privacy policy URL
                                if let url = URL(string: "https://sites.google.com/aztty.com/budgetspendingtracker/home") {
                                    UIApplication.shared.open(url)
                                }
                            }
                            .font(.caption2)
                            .foregroundColor(.blue)
                        }
                        .padding(.top, 5)
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 20)
                }
                .padding(.bottom, 20)
            }
            .navigationTitle("Premium Subscription")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if !isFromOnboarding {
                    Button("Close") {
                        dismiss()
                        }
                    }
                }
            }
            .overlay {
                if showingLoadingIndicator {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    
                    ProgressView()
                        .scaleEffect(1.5)
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(10)
                        .shadow(radius: 10)
                }
            }
            .alert(errorTitle, isPresented: $showError, actions: {
                Button("OK") {
                    subscriptionManager.clearErrors()
                }
            }, message: {
                VStack(alignment: .leading, spacing: 8) {
                    Text(errorMessage)
                    
                    if let suggestion = errorSuggestion, !suggestion.isEmpty {
                        Text(suggestion)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            })
            .onAppear {
                // Load products when view appears
                if subscriptionManager.products.isEmpty {
                    subscriptionManager.loadProducts()
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .subscriptionUpdated)) { _ in
                // Handle subscription updates
                updateErrorState()
                
                if subscriptionManager.hasPremiumAccess {
                    // Dismiss the view if purchase was successful
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        if isFromOnboarding, let completion = onboardingCompletion {
                            completion()
                        } else {
                        dismiss()
                        }
                    }
                }
            }
        }
        .interactiveDismissDisabled(isFromOnboarding) // Prevent swipe to dismiss during onboarding
    }
    
    private func purchaseSubscription(_ product: SKProduct) {
        showingLoadingIndicator = true
        subscriptionManager.purchase(product)
    }
    
    private func restorePurchases() {
        showingLoadingIndicator = true
        subscriptionManager.restorePurchases()
    }
    
    private func updateErrorState() {
        // Update loading indicator
        showingLoadingIndicator = subscriptionManager.isLoading
        
        // Handle errors if any
        if subscriptionManager.errorMessage != nil {
            let (message, suggestion) = subscriptionManager.getErrorDetails()
            
            // Don't show alert for user cancellation
            if let error = subscriptionManager.detailedError, case .userCancelled = error {
                return
            }
            
            errorTitle = subscriptionManager.detailedError != nil ? "Subscription Error" : "Error"
            errorMessage = message
            errorSuggestion = suggestion
            showError = true
        }
    }
}

// Helper view for subscription options
struct SubscriptionOptionView: View {
    let product: SKProduct
    let action: () -> Void
    @State private var subscriptionManager = SubscriptionManager.shared
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text(displayName)
                        .font(.headline)
                    
                    // Show pricing information
                    Text(displayPrice)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    // Add free trial badge for yearly subscription
                    if product.productIdentifier == "com.budgetplanner.subscription.yearly" {
                        HStack(spacing: 5) {
                            Image(systemName: "gift")
                                .foregroundColor(.blue)
                                .font(.caption)
                            
                            Text("3-Day Free Trial")
                                .font(.caption)
                                .foregroundColor(.blue)
                                .fontWeight(.medium)
                        }
                        .padding(.top, 3)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.blue)
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(10)
            .overlay(
                Group {
                    if product.productIdentifier == "com.budgetplanner.subscription.yearly" {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.blue.opacity(0.5), lineWidth: 1.5)
                    }
                }
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // Helper computed properties
    private var displayName: String {
        switch product.productIdentifier {
        case "com.budgetplanner.subscription.monthly":
            return "Monthly Premium"
        case "com.budgetplanner.subscription.yearly":
            return "Yearly Premium (Save 16% + Free Trial)"
        default:
            return product.localizedTitle
        }
    }
    
    private var displayPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = product.priceLocale
        
        let priceString = formatter.string(from: product.price) ?? "\(product.price)"
        
        switch product.productIdentifier {
        case "com.budgetplanner.subscription.monthly":
            return "\(priceString) per month"
        case "com.budgetplanner.subscription.yearly":
            return "\(priceString) per year"
        default:
            return priceString
        }
    }
}

// Helper view for lifetime option
struct LifetimeOptionView: View {
    let product: SKProduct
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 15) {
                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Lifetime Premium Access")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        // Show pricing information
                        Text(displayPrice)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.blue)
                }
                
                HStack(spacing: 10) {
                    Text("✓ Pay once, use forever")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("✓ No recurring charges")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 4)
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.blue.opacity(0.5), lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // Helper computed property
    private var displayPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = product.priceLocale
        
        return formatter.string(from: product.price) ?? "\(product.price)"
    }
}

// Helper view for feature rows
struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .frame(width: 30, height: 30)
                .foregroundColor(.blue)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}

// Preview
#Preview {
    SubscriptionView()
} 
