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
    @State private var isAnimating = false
    @State private var showGetStarted = false
    
    // Optional completion handler for when onboarding is finished
    var onComplete: (() -> Void)?
    
    let onboardingPages = [
        OnboardingPage(
            title: "Track All Your Finances In One Place",
            description: "Easily record and categorize your daily spending to stay on top of your finances with beautiful visualizations.",
            imageName: "chart.bar.xaxis",
            accentColor: .blue,
            animationType: .chart
        ),
        OnboardingPage(
            title: "Own Your Financial Journey",
            description: "Keep a detailed log of your financial goals and track your progress over time with smart budget management.",
            imageName: "arrow.up.forward.circle.fill",
            accentColor: .green,
            animationType: .budget
        ),
        OnboardingPage(
            title: "Welcome to Budget Planner",
            description: "The easiest and most efficient way to manage your money",
            imageName: "star.fill",
            accentColor: .orange,
            animationType: .testimonial,
            testimonial: Testimonial(
                text: "Exactly what I needed! Helped me save $350 in the first month!",
                rating: 5,
                username: "Happy User"
            )
        )
    ]
    
    var body: some View {
        ZStack {
            // Background gradient that matches the current page's accent color
            LinearGradient(
                gradient: Gradient(colors: [
                    onboardingPages[currentPage].accentColor.opacity(0.1),
                    Color(UIColor.systemBackground)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack {
                // Skip button removed
                
                // Content
                if showGetStarted {
                    getStartedView
                        .transition(.opacity.combined(with: .scale))
                } else {
                    TabView(selection: $currentPage) {
                        ForEach(0..<onboardingPages.count, id: \.self) { index in
                            pageView(for: onboardingPages[index])
                                .tag(index)
                                .onAppear {
                                    // Trigger animation when page appears
                                    isAnimating = true
                                }
                                .onDisappear {
                                    // Reset animation when page disappears
                                    isAnimating = false
                                }
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .animation(.easeInOut, value: currentPage)
                    
                    // Page indicator
                    HStack(spacing: 12) {
                        ForEach(0..<onboardingPages.count, id: \.self) { index in
                            Capsule()
                                .fill(currentPage == index ? 
                                      onboardingPages[index].accentColor : Color.gray.opacity(0.3))
                                .frame(width: currentPage == index ? 20 : 10, height: 10)
                                .animation(.spring(), value: currentPage)
                        }
                    }
                    .padding(.bottom, 20)
                    
                    // Continue button
                    Button {
                        withAnimation {
                            if currentPage < onboardingPages.count - 1 {
                                currentPage += 1
                            } else {
                                // If coordinator provided completion handler, use it
                                if let onComplete = onComplete {
                                    onComplete()
                                } else {
                                    showGetStarted = true
                                }
                            }
                        }
                    } label: {
                        Text("Continue")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(width: 300, height: 60)
                            .background(onboardingPages[currentPage].accentColor)
                            .cornerRadius(30)
                            .shadow(color: onboardingPages[currentPage].accentColor.opacity(0.5), radius: 10, x: 0, y: 5)
                    }
                    .padding(.bottom, 30)
                    
                    // Trusted by users text
                    Text("Trusted by 10,000+ Users")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .padding(.bottom)
                }
            }
        }
    }
    
    // Page view for each onboarding page
    private func pageView(for page: OnboardingPage) -> some View {
        VStack(spacing: 20) {
            // Title with dynamic font
            Text(page.title)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
                .padding(.top, 60)
                .opacity(isAnimating ? 1 : 0)
                .offset(y: isAnimating ? 0 : 20)
                .animation(.easeOut(duration: 0.5).delay(0.2), value: isAnimating)
            
            // Description with fade animation
            Text(page.description)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal, 30)
                .padding(.top, 10)
                .opacity(isAnimating ? 1 : 0)
                .offset(y: isAnimating ? 0 : 20)
                .animation(.easeOut(duration: 0.5).delay(0.4), value: isAnimating)
            
            Spacer()
            
            // Different animation types based on the page
            switch page.animationType {
            case .chart:
                BudgetChartAnimation(accentColor: page.accentColor)
            case .budget:
                BudgetPersonAnimation(accentColor: page.accentColor)
            case .testimonial:
                if let testimonial = page.testimonial {
                    TestimonialAnimation(testimonial: testimonial, accentColor: page.accentColor)
                }
            }
            
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
            .scaleEffect(isAnimating ? 1 : 0.8)
            .opacity(isAnimating ? 1 : 0)
            .animation(.spring(response: 0.5, dampingFraction: 0.6), value: isAnimating)
            .onAppear { isAnimating = true }
            
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
                // Mark onboarding as completed
                AppSettings.shared.completeOnboarding()
                dismiss()
            } label: {
                Text("Get Started")
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
    }
}

// Onboarding page model
struct OnboardingPage {
    let title: String
    let description: String
    let imageName: String
    let accentColor: Color
    let animationType: AnimationType
    var testimonial: Testimonial? = nil
    
    enum AnimationType {
        case chart
        case budget
        case testimonial
    }
}

// Testimonial model
struct Testimonial {
    let text: String
    let rating: Int
    let username: String
}

#Preview {
    OnboardingView()
} 