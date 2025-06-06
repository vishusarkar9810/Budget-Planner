//
//  TestimonialAnimation.swift
//  Budget Planner
//
//  Created for enhanced onboarding
//

import SwiftUI

struct TestimonialAnimation: View {
    @State private var isAnimating = false
    @State private var showStars = false
    @State private var showQuote = false
    @State private var rotateLeaves = false
    
    let testimonial: Testimonial
    let accentColor: Color
    
    var body: some View {
        VStack(spacing: 20) {
            // User photo or avatar with pulsing border
            ZStack {
                // Pulsing circle
                Circle()
                    .fill(accentColor.opacity(0.2))
                    .frame(width: 110, height: 110)
                    .scaleEffect(rotateLeaves ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: rotateLeaves)
                
                // Avatar circle
                Circle()
                    .fill(Color.white.opacity(0.9))
                    .frame(width: 100, height: 100)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.system(size: 50))
                            .foregroundColor(accentColor)
                    )
                    .shadow(color: accentColor.opacity(0.3), radius: 5, x: 0, y: 2)
            }
            .opacity(isAnimating ? 1 : 0)
            .scaleEffect(isAnimating ? 1 : 0.5)
            .animation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.3), value: isAnimating)
            
            // Laurel wreath with "Perfect!" text
            ZStack {
                // Laurel leaves
                HStack(spacing: 60) {
                    Image(systemName: "laurel.leading")
                        .font(.title)
                        .foregroundColor(.yellow)
                        .rotationEffect(.degrees(rotateLeaves ? -5 : 0))
                        .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: rotateLeaves)
                    
                    Image(systemName: "laurel.trailing")
                        .font(.title)
                        .foregroundColor(.yellow)
                        .rotationEffect(.degrees(rotateLeaves ? 5 : 0))
                        .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: rotateLeaves)
                }
                .opacity(isAnimating ? 1 : 0)
                .animation(.easeIn.delay(0.5), value: isAnimating)
                
                // Perfect! text
                Text("Perfect!")
                    .font(.title2)
                    .fontWeight(.medium)
                    .italic()
                    .opacity(isAnimating ? 1 : 0)
                    .animation(.easeIn.delay(0.6), value: isAnimating)
            }
            
            // Star rating with sequential animation
            HStack(spacing: 8) {
                ForEach(0..<testimonial.rating, id: \.self) { i in
                    Image(systemName: "star.fill")
                        .font(.title3)
                        .foregroundColor(.yellow)
                        .opacity(showStars ? 1 : 0)
                        .scaleEffect(showStars ? 1 : 0.1)
                        .animation(.spring(response: 0.4, dampingFraction: 0.7).delay(0.7 + Double(i) * 0.1), value: showStars)
                }
            }
            
            // Testimonial text with typing animation
            Text("\"\(testimonial.text)\"")
                .font(.body)
                .italic()
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .opacity(showQuote ? 1 : 0)
                .animation(.easeIn.delay(1.2), value: showQuote)
            
            // Username with fade in
            Text("- \(testimonial.username)")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.top, 5)
                .opacity(showQuote ? 0.8 : 0)
                .animation(.easeIn.delay(1.5), value: showQuote)
        }
        .padding(.vertical, 30)
        .onAppear {
            // Start animation sequence
            withAnimation {
                isAnimating = true
            }
            
            // Show stars with delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                withAnimation {
                    showStars = true
                }
            }
            
            // Show quote with delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                withAnimation {
                    showQuote = true
                }
            }
            
            // Start rotating leaves animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                rotateLeaves = true
            }
        }
        .onDisappear {
            // Reset animation state
            isAnimating = false
            showStars = false
            showQuote = false
            rotateLeaves = false
        }
    }
}

#Preview {
    ZStack {
        Color.black.opacity(0.1).ignoresSafeArea()
        TestimonialAnimation(
            testimonial: Testimonial(
                text: "Exactly what I needed! Helped me save $350 in the first month!",
                rating: 5,
                username: "Happy User"
            ),
            accentColor: .orange
        )
    }
} 