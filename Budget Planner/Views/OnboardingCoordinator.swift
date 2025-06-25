//
//  OnboardingCoordinator.swift
//  Budget Planner
//
//  Created for enhanced onboarding
//

import SwiftUI

/// Manages the flow of onboarding screens and animations
struct OnboardingCoordinator: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var onboardingState: OnboardingState = .loading
    @State private var isLoadingComplete = false
    @State private var isWelcomeComplete = false
    @State private var showPremiumScreen = false
    
    // Onboarding stages
    enum OnboardingState {
        case loading     // Initial loading animation
        case welcome     // Welcome animation that matches the cream screenshots
        case mainFlow    // Main onboarding flow with the different feature screens
        case getStarted  // Final get started screen
        case premium     // Premium subscription screen
    }
    
    var body: some View {
        ZStack {
            switch onboardingState {
            case .loading:
                // Initial loading animation
                LoadingAnimation(
                    isComplete: $isLoadingComplete,
                    accentColor: .orange,
                    duration: 2.0
                ) {
                    // Move to welcome screen when loading completes
                    onboardingState = .welcome
                }
                
            case .welcome:
                // Welcome screen that matches the cream screenshots
                WelcomeAnimation(isAnimationComplete: $isWelcomeComplete)
                    .onChange(of: isWelcomeComplete) { _, newValue in
                        if newValue {
                            // Move to main onboarding when welcome completes
                            onboardingState = .mainFlow
                        }
                    }
                
            case .mainFlow:
                // Main onboarding flow with feature screens
                OnboardingView(onComplete: {
                    // Skip to get started when complete
                    onboardingState = .getStarted
                })
                
            case .getStarted:
                // Final get started view
                GetStartedView {
                    // Show premium screen after get started is tapped
                    onboardingState = .premium
                }
                
            case .premium:
                // Premium subscription screen
                SubscriptionView(isFromOnboarding: true) {
                    // Complete onboarding when subscription view is dismissed
                    AppSettings.shared.completeOnboarding()
                    dismiss()
                }
            }
        }
    }
}

/// The final get started view shown after main onboarding
struct GetStartedView: View {
    var onGetStarted: () -> Void
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Animated app icon
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 160, height: 160)
                
                Image(systemName: "dollarsign.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                    .symbolEffect(.pulse, options: .repeating)
            }
            .scaleEffect(isAnimating ? 1 : 0.8)
            .opacity(isAnimating ? 1 : 0)
            .animation(.spring(response: 0.5, dampingFraction: 0.6), value: isAnimating)
            
            Text("Welcome to Budget Planner!")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .padding(.top)
                .opacity(isAnimating ? 1 : 0)
                .offset(y: isAnimating ? 0 : 20)
                .animation(.easeOut(duration: 0.5).delay(0.2), value: isAnimating)
            
            Text("Your journey to financial wellness starts now")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal, 40)
                .opacity(isAnimating ? 1 : 0)
                .offset(y: isAnimating ? 0 : 20)
                .animation(.easeOut(duration: 0.5).delay(0.4), value: isAnimating)
            
            Spacer()
            
            Button {
                onGetStarted()
            } label: {
                Text("Continue")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(width: 300, height: 60)
                    .background(Color.blue)
                    .cornerRadius(30)
                    .shadow(color: Color.blue.opacity(0.4), radius: 10, x: 0, y: 5)
            }
            .opacity(isAnimating ? 1 : 0)
            .offset(y: isAnimating ? 0 : 20)
            .animation(.easeOut(duration: 0.5).delay(0.6), value: isAnimating)
            .padding(.bottom, 60)
            
            Text("Trusted by 10,000+ Users")
                .font(.footnote)
                .foregroundColor(.secondary)
                .padding(.bottom)
                .opacity(isAnimating ? 1 : 0)
                .animation(.easeOut(duration: 0.5).delay(0.8), value: isAnimating)
        }
        .onAppear {
            isAnimating = true
        }
    }
}

#Preview {
    OnboardingCoordinator()
} 