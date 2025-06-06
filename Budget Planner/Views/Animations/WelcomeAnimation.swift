//
//  WelcomeAnimation.swift
//  Budget Planner
//
//  Created for enhanced onboarding
//

import SwiftUI

struct WelcomeAnimation: View {
    @Binding var isAnimationComplete: Bool
    @State private var showTitle = false
    @State private var showDescription = false
    @State private var showButton = false
    @State private var showStars = false
    @State private var showLaurels = false
    @State private var showTrustedText = false
    
    var body: some View {
        ZStack {
            // Background color
            Color(UIColor(red: 0.99, green: 0.96, blue: 0.89, alpha: 1.0))
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Skip button removed
                
                Spacer()
                
                // Main content
                VStack(spacing: 20) {
                    // Title with fade in
                    if showTitle {
                        Text("Welcome to Budget Planner")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                    
                    // Description with typing effect
                    if showDescription {
                        Text("The easiest and most efficient way to manage your money")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                            .transition(.opacity)
                    }
                }
                
                Spacer()
                
                // Testimonial
                VStack(spacing: 16) {
                    // Laurel wreath with "Perfect!" text
                    if showLaurels {
                        HStack(spacing: 60) {
                            Image(systemName: "laurel.leading")
                                .font(.title)
                                .foregroundColor(.yellow)
                            
                            Image(systemName: "laurel.trailing")
                                .font(.title)
                                .foregroundColor(.yellow)
                        }
                        .overlay(
                            Text("Perfect!")
                                .font(.title2)
                                .fontWeight(.medium)
                                .italic()
                        )
                        .transition(.scale.combined(with: .opacity))
                    }
                    
                    // Testimonial quote
                    if showStars {
                        VStack(spacing: 10) {
                            // Star rating
                            HStack(spacing: 5) {
                                ForEach(0..<5, id: \.self) { i in
                                    Image(systemName: "star.fill")
                                        .foregroundColor(.yellow)
                                        .font(.headline)
                                        .transition(.scale.combined(with: .opacity))
                                }
                            }
                            
                            // Quote
                            Text("\"Exactly what I needed! Helped me save $350 in the first month!\"")
                                .italic()
                                .multilineTextAlignment(.center)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 30)
                                .transition(.opacity)
                        }
                    }
                }
                
                Spacer()
                
                // Pagination dots
                if showStars {
                    HStack(spacing: 8) {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                        
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                        
                        Capsule()
                            .fill(Color.orange)
                            .frame(width: 20, height: 8)
                    }
                    .transition(.opacity)
                }
                
                // Continue button
                if showButton {
                    Button {
                        withAnimation {
                            isAnimationComplete = true
                        }
                    } label: {
                        Text("Continue")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(width: 300, height: 60)
                            .background(Color.orange)
                            .cornerRadius(30)
                            .shadow(color: Color.orange.opacity(0.3), radius: 10, x: 0, y: 5)
                    }
                    .padding(.vertical, 20)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                
                // Trusted by users text
                if showTrustedText {
                    Text("Trusted by 10,000+ Users")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 10)
                        .transition(.opacity)
                }
                
                Spacer().frame(height: 20)
            }
        }
        .onAppear {
            // Sequence the animations
            startAnimationSequence()
        }
    }
    
    private func startAnimationSequence() {
        // Title animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeInOut(duration: 0.8)) {
                showTitle = true
            }
        }
        
        // Description animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.easeInOut(duration: 0.8)) {
                showDescription = true
            }
        }
        
        // Laurel animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                showLaurels = true
            }
        }
        
        // Stars and quote animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.3) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                showStars = true
            }
        }
        
        // Button animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.8) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                showButton = true
            }
        }
        
        // Trusted text animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.3) {
            withAnimation(.easeInOut(duration: 0.5)) {
                showTrustedText = true
            }
        }
    }
}

#Preview {
    WelcomeAnimation(isAnimationComplete: .constant(false))
} 