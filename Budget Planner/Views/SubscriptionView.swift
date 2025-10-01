import SwiftUI
import StoreKit
import UIKit

// Review data structure
struct AppReview {
    let rating: Int
    let text: String
    let author: String
}

// Sample reviews data
let sampleReviews = [
    AppReview(
        rating: 5,
        text: "Really great app! The app is so useful and really helps track my expenses! Even give you reminders to add transactions - something I used to struggle with 🥲 thank you for creating this wonderful app 🤩🤩 the fonts and pictures are really cute and aesthetic as well, highly recommend! 💖💖",
        author: "joooeeeeyyyy"
    ),
    AppReview(
        rating: 5,
        text: "Perfect budgeting companion! Love how simple and intuitive it is. The categories are well thought out and the visual design is beautiful. Finally found an app that makes expense tracking enjoyable! 🌟",
        author: "BudgetMaster2024"
    ),
    AppReview(
        rating: 5,
        text: "This app changed my financial habits completely! The reminders feature is a game changer. I never forget to log my expenses anymore. Clean interface and great functionality! 💯",
        author: "FinanceGuru"
    ),
    AppReview(
        rating: 5,
        text: "Amazing app for tracking expenses! The premium features are totally worth it. Love the backup functionality and unlimited accounts. Best investment for my financial health! 💰",
        author: "SmartSaver"
    ),
    AppReview(
        rating: 5,
        text: "Beautifully designed and super functional! The recurring transactions feature saves me so much time. Highly recommend to anyone serious about budgeting! ⭐️",
        author: "MoneyWise"
    )
]

struct SubscriptionView: View {
    @State private var subscriptionManager = SubscriptionManager.shared
    @State private var showingLoadingIndicator = false
    @State private var showError = false
    @State private var errorTitle = "Error"
    @State private var errorMessage = ""
    @State private var errorSuggestion: String?
    @State private var currentReviewIndex = 0
    @Environment(\.dismiss) private var dismiss
    
    // Parameters for onboarding flow
    var isFromOnboarding: Bool = false
    var onboardingCompletion: (() -> Void)? = nil
    
    var body: some View {
        ZStack {
            // Clean blue and white background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.white,
                    Color.blue.opacity(0.05),
                    Color.blue.opacity(0.1)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    // Close button
                    HStack {
                        Button(action: {
                            if isFromOnboarding, let completion = onboardingCompletion {
                                completion()
                            } else {
                                dismiss()
                            }
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.primary)
                                .frame(width: 32, height: 32)
                                .background(Color.white.opacity(0.8))
                                .clipShape(Circle())
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    // App icon with blue theme - dollar sign design
                    VStack(spacing: 20) {
                        ZStack {
                            Circle()
                                .fill(Color.blue.opacity(0.1))
                                .frame(width: 160, height: 160)
                            
                            Image(systemName: "dollarsign.circle.fill")
                                .font(.system(size: 80))
                                .foregroundColor(.blue)
                        }
                        .padding(.top, 20)
                        
                        // Premium badge with blue theme
                        Text("LIFETIME PREMIUM")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            colors: [.blue, .blue.opacity(0.8)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                            )
                        
                        // Main title
                        VStack(spacing: 8) {
                            HStack(spacing: 0) {
                                Text("Save ")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(.primary)
                                
                                Text("80%")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(.blue)
                                
                                Text(" on")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(.primary)
                            }
                            
                            HStack(spacing: 8) {
                                Text("Lifetime Premium!")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(.primary)
                                
                                Text("💖")
                                    .font(.system(size: 28))
                            }
                        }
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                    }
                    .padding(.bottom, 30)
                    
                    // Features list with beautiful icons
                    VStack(spacing: 20) {
                        ModernFeatureRow(
                            icon: "📊",
                            title: "Unlimited Transactions",
                            color: .red
                        )
                        
                        ModernFeatureRow(
                            icon: "📈",
                            title: "Advanced Analytics",
                            color: .blue
                        )
                        
                        ModernFeatureRow(
                            icon: "🏷️",
                            title: "Unlimited Categories",
                            color: .green
                        )
                        
                        ModernFeatureRow(
                            icon: "☁️",
                            title: "Backup and Restore",
                            color: .orange
                        )
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 30)
                    
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
                        // Modern lifetime purchase button
                        if let lifetimeProduct = subscriptionManager.product(for: "com.budgetplanner.lifetime.premium") {
                            ModernLifetimeButton(product: lifetimeProduct) {
                                purchaseSubscription(lifetimeProduct)
                            }
                            .padding(.horizontal, 30)
                            .padding(.bottom, 30)
                        }
                    }
                    
                    // Reviews section with sliding functionality
                    VStack(spacing: 15) {
                        // Stars rating with blue theme
                        HStack(spacing: 4) {
                            ForEach(0..<5) { _ in
                                Image(systemName: "star.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.blue)
                            }
                        }
                        
                        // Slideable reviews
                        TabView(selection: $currentReviewIndex) {
                            ForEach(0..<sampleReviews.count, id: \.self) { index in
                                VStack(spacing: 12) {
                                    Text(sampleReviews[index].text)
                                        .font(.system(size: 14))
                                        .multilineTextAlignment(.center)
                                        .foregroundColor(.primary)
                                        .padding(.horizontal, 30)
                                        .lineLimit(nil)
                                    
                                    Text("- \(sampleReviews[index].author)")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.secondary)
                                }
                                .tag(index)
                            }
                        }
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                        .frame(height: 120)
                        
                        // Custom page indicator with blue theme
                        HStack(spacing: 8) {
                            ForEach(0..<sampleReviews.count, id: \.self) { index in
                                Circle()
                                    .fill(index == currentReviewIndex ? Color.blue : Color.gray.opacity(0.3))
                                    .frame(width: 8, height: 8)
                                    .animation(.easeInOut(duration: 0.3), value: currentReviewIndex)
                            }
                        }
                    }
                    .padding(.bottom, 30)
                    
                    // Restore purchases and legal links
                    VStack(spacing: 15) {
                        Button("Restore Purchase") {
                            restorePurchases()
                        }
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.blue)
                        .padding(.bottom, 5)
                        
                        Button("Terms & Privacy Policy") {
                            if let url = URL(string: "https://sites.google.com/aztty.com/budget-spending-tracker/home") {
                                UIApplication.shared.open(url)
                            }
                        }
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                    }
                    .padding(.bottom, 20)
                    
                    // Continue button with blue theme
                    Button(action: {
                        // Try to purchase the lifetime product when CONTINUE is clicked
                        if let lifetimeProduct = subscriptionManager.product(for: "com.budgetplanner.lifetime.premium") {
                            purchaseSubscription(lifetimeProduct)
                        } else {
                            // Fallback: if no product available, dismiss as before
                            if isFromOnboarding, let completion = onboardingCompletion {
                                completion()
                            } else {
                                dismiss()
                            }
                        }
                    }) {
                        Text("CONTINUE")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                LinearGradient(
                                    colors: [.blue, .blue.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(28)
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 30)
                    
                    // Current subscription status
                    if subscriptionManager.hasLifetimeAccess {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("You have lifetime premium access")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                        .padding(.bottom, 20)
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
            // Load products if not already loaded
            if subscriptionManager.products.isEmpty {
                subscriptionManager.loadProducts()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .subscriptionUpdated)) { _ in
            // Hide loading indicator when subscription updates
            showingLoadingIndicator = false
            updateErrorState()
            
            if subscriptionManager.hasPremiumAccess {
                // Auto-dismiss after successful purchase
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
    
    private func purchaseSubscription(_ product: SKProduct) {
        showingLoadingIndicator = true
        subscriptionManager.purchase(product)
    }
    
    private func restorePurchases() {
        showingLoadingIndicator = true
        subscriptionManager.restorePurchases()
        
        // The loading indicator will be turned off by the subscription manager
        // and notifications will be posted when restore completes
    }
    
    private func showError(title: String, message: String, suggestion: String? = nil) {
        errorTitle = title
        errorMessage = message
        errorSuggestion = suggestion
        showError = true
    }
    
    private func updateErrorState() {
        if let errorMessage = subscriptionManager.errorMessage {
            showingLoadingIndicator = false // Hide loading on error
            showError(title: "Purchase Error", message: errorMessage)
        }
    }
}

// MARK: - Modern UI Components

struct ModernFeatureRow: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 15) {
            Text(icon)
                .font(.system(size: 24))
                .frame(width: 40, height: 40)
                .background(color.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.primary)
            
            Spacer()
        }
    }
}

struct ModernLifetimeButton: View {
    let product: SKProduct
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Text("Pay Once. No subscription!")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.blue)
                
                HStack(spacing: 8) {
                    Text(displayPrice)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.primary)
                    
                    if let originalPrice = originalDisplayPrice {
                        Text("(\(originalPrice))")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                            .strikethrough()
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(
                            colors: [.blue, .blue.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: 2
                    )
            )
        }
    }
    
    private var displayPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = product.priceLocale
        return formatter.string(from: product.price) ?? "\(product.price)"
    }
    
    private var originalDisplayPrice: String? {
        // Calculate original price (assuming 80% discount)
        let originalPrice = product.price.doubleValue / 0.2 // If current is 20% of original
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = product.priceLocale
        return formatter.string(from: NSNumber(value: originalPrice))
    }
}

#Preview {
    SubscriptionView()
}
