//
//  OnboardingView.swift
//  Budget Planner
//
//  Created on Phase 5
//

import SwiftUI

struct OnboardingView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentPage = 0
    @State private var pageOffset: CGFloat = 0
    @State private var showGetStarted = false
    
    let onboardingPages = [
        OnboardingPage(
            title: "Track Your Expenses",
            description: "Easily record and categorize your daily spending to stay on top of your finances.",
            imageName: "chart.bar.fill",
            accentColor: .blue
        ),
        OnboardingPage(
            title: "Set Budget Goals",
            description: "Create personalized budgets for daily, weekly, monthly or custom periods.",
            imageName: "target",
            accentColor: .green
        ),
        OnboardingPage(
            title: "Analyze Spending",
            description: "Visualize your spending patterns with beautiful charts and breakdowns.",
            imageName: "chart.pie.fill",
            accentColor: .purple
        ),
        OnboardingPage(
            title: "Global Currency Support",
            description: "Track your finances in over 60 currencies from around the world.",
            imageName: "dollarsign.circle",
            accentColor: .orange
        )
    ]
    
    var body: some View {
        ZStack {
            // Background color gradient
            LinearGradient(
                gradient: Gradient(colors: [Color.white, Color(UIColor.systemBackground)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack {
                // Skip button
                if !showGetStarted {
                    HStack {
                        Spacer()
                        Button("Skip") {
                            withAnimation {
                                showGetStarted = true
                            }
                        }
                        .padding()
                        .foregroundColor(.secondary)
                    }
                }
                
                // Content
                if showGetStarted {
                    getStartedView
                        .transition(.opacity.combined(with: .scale))
                } else {
                    TabView(selection: $currentPage) {
                        ForEach(0..<onboardingPages.count, id: \.self) { index in
                            pageView(for: onboardingPages[index])
                                .tag(index)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .animation(.easeInOut, value: currentPage)
                    
                    // Page indicator
                    HStack(spacing: 12) {
                        ForEach(0..<onboardingPages.count, id: \.self) { index in
                            Circle()
                                .fill(currentPage == index ? 
                                      onboardingPages[index].accentColor : Color.gray.opacity(0.3))
                                .frame(width: 10, height: 10)
                                .scaleEffect(currentPage == index ? 1.2 : 1.0)
                                .animation(.spring(), value: currentPage)
                        }
                    }
                    .padding(.bottom, 20)
                    
                    // Next button
                    Button {
                        withAnimation {
                            if currentPage < onboardingPages.count - 1 {
                                currentPage += 1
                            } else {
                                showGetStarted = true
                            }
                        }
                    } label: {
                        Text(currentPage < onboardingPages.count - 1 ? "Next" : "Get Started")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(width: 200, height: 50)
                            .background(onboardingPages[currentPage].accentColor)
                            .cornerRadius(15)
                            .shadow(color: onboardingPages[currentPage].accentColor.opacity(0.5), radius: 10, x: 0, y: 5)
                    }
                    .padding(.bottom, 50)
                }
            }
        }
    }
    
    // Page view for each onboarding page
    private func pageView(for page: OnboardingPage) -> some View {
        VStack(spacing: 20) {
            Spacer()
            
            // Icon with animated effect
            Image(systemName: page.imageName)
                .font(.system(size: 100))
                .foregroundColor(page.accentColor)
                .symbolEffect(.bounce, options: .repeating, value: currentPage)
                .padding()
                .background(
                    Circle()
                        .fill(page.accentColor.opacity(0.1))
                        .frame(width: 180, height: 180)
                )
                .padding(.bottom, 40)
            
            // Title with scaling animation
            Text(page.title)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
                .padding(.horizontal)
                .scaleEffect(currentPage == onboardingPages.firstIndex(where: { $0.title == page.title }) ?? 0 ? 1.0 : 0.8)
                .animation(.spring(response: 0.5, dampingFraction: 0.6), value: currentPage)
            
            // Description with fade animation
            Text(page.description)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal, 40)
                .padding(.top, 10)
                .opacity(currentPage == onboardingPages.firstIndex(where: { $0.title == page.title }) ?? 0 ? 1.0 : 0.5)
                .animation(.easeIn(duration: 0.3), value: currentPage)
            
            Spacer()
            Spacer()
        }
    }
    
    // Get started view with budget setup
    private var getStartedView: some View {
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
            
            Text("Welcome to Budget Planner!")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .padding(.top)
            
            Text("Your journey to financial wellness starts now")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal, 40)
            
            Spacer()
            
            Button {
                // Mark onboarding as completed
                AppSettings.shared.completeOnboarding()
                dismiss()
            } label: {
                Text("Get Started")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(width: 250, height: 60)
                    .background(Color.blue)
                    .cornerRadius(20)
                    .shadow(color: Color.blue.opacity(0.4), radius: 10, x: 0, y: 5)
            }
            .padding(.bottom, 60)
        }
    }
}

// Onboarding page model
struct OnboardingPage {
    let title: String
    let description: String
    let imageName: String
    let accentColor: Color
}

#Preview {
    OnboardingView()
} 