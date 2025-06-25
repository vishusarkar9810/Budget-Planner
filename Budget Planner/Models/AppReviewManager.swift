import Foundation
import StoreKit
import SwiftUI

/// Manages app review requests following Apple's guidelines
class AppReviewManager {
    // Singleton instance
    static let shared = AppReviewManager()
    
    // UserDefaults keys
    private enum Keys {
        static let lastReviewRequestDate = "lastReviewRequestDate"
        static let reviewRequestCount = "reviewRequestCount"
        static let significantEventsCount = "significantEventsCount"
        static let hasShownOnboardingReview = "hasShownOnboardingReview"
    }
    
    // Constants
    private let minDaysBetweenPrompts = 90 // 3 months between review prompts
    private let significantEventsBeforePrompt = 3 // Number of significant events before prompting
    
    private init() {}
    
    /// Check if we should show a review prompt during onboarding
    var shouldShowOnboardingReview: Bool {
        // Only show during onboarding if we haven't shown it before
        return !UserDefaults.standard.bool(forKey: Keys.hasShownOnboardingReview)
    }
    
    /// Request a review during onboarding
    func requestOnboardingReview() {
        guard shouldShowOnboardingReview else { return }
        
        // Request the review
        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
        
        // Mark that we've shown the onboarding review
        UserDefaults.standard.set(true, forKey: Keys.hasShownOnboardingReview)
        
        // Update the last review request date
        UserDefaults.standard.set(Date(), forKey: Keys.lastReviewRequestDate)
        
        // Increment the review request count
        let currentCount = UserDefaults.standard.integer(forKey: Keys.reviewRequestCount)
        UserDefaults.standard.set(currentCount + 1, forKey: Keys.reviewRequestCount)
    }
    
    /// Log a significant event (like adding transactions, creating categories, etc.)
    func logSignificantEvent() {
        let currentCount = UserDefaults.standard.integer(forKey: Keys.significantEventsCount)
        UserDefaults.standard.set(currentCount + 1, forKey: Keys.significantEventsCount)
        
        // Check if we should request a review after this event
        checkAndRequestReviewIfNeeded()
    }
    
    /// Check if we should request a review and do so if needed
    func checkAndRequestReviewIfNeeded() {
        // Don't show if we've recently shown a review prompt
        guard daysSinceLastReviewRequest() >= minDaysBetweenPrompts else { return }
        
        // Check if we've had enough significant events
        let eventCount = UserDefaults.standard.integer(forKey: Keys.significantEventsCount)
        guard eventCount >= significantEventsBeforePrompt else { return }
        
        // Reset the significant events counter
        UserDefaults.standard.set(0, forKey: Keys.significantEventsCount)
        
        // Request the review
        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
        
        // Update the last review request date
        UserDefaults.standard.set(Date(), forKey: Keys.lastReviewRequestDate)
        
        // Increment the review request count
        let currentCount = UserDefaults.standard.integer(forKey: Keys.reviewRequestCount)
        UserDefaults.standard.set(currentCount + 1, forKey: Keys.reviewRequestCount)
    }
    
    /// Calculate days since the last review request
    private func daysSinceLastReviewRequest() -> Int {
        guard let lastDate = UserDefaults.standard.object(forKey: Keys.lastReviewRequestDate) as? Date else {
            return Int.max // No previous request
        }
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: lastDate, to: Date())
        return components.day ?? Int.max
    }
}

// SwiftUI View Modifier for requesting reviews
struct ReviewRequestModifier: ViewModifier {
    @State private var hasRequested = false
    let trigger: Bool
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                guard trigger && !hasRequested else { return }
                
                // Add a slight delay to ensure the view is fully visible
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                        SKStoreReviewController.requestReview(in: scene)
                        hasRequested = true
                    }
                }
            }
    }
}

extension View {
    /// Request a review when the condition is true
    func requestReview(when trigger: Bool) -> some View {
        self.modifier(ReviewRequestModifier(trigger: trigger))
    }
} 