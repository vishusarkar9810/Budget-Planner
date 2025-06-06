//
//  BudgetChartAnimation.swift
//  Budget Planner
//
//  Created for enhanced onboarding
//

import SwiftUI

struct BudgetChartAnimation: View {
    @State private var isAnimating = false
    @State private var showSavings = false
    
    let accentColor: Color
    let barHeights: [CGFloat] = [100, 70, 150, 60, 120]
    let months = ["Jan", "Feb", "Mar", "Apr", "May"]
    
    var body: some View {
        ZStack {
            // Phone outline
            RoundedRectangle(cornerRadius: 30)
                .stroke(Color.white, lineWidth: 3)
                .frame(width: 200, height: 380)
                .opacity(isAnimating ? 1 : 0)
                .scaleEffect(isAnimating ? 1 : 0.8)
                .animation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.3), value: isAnimating)
            
            // Screen content
            VStack(spacing: 15) {
                // Header
                Text("Monthly Budget")
                    .font(.headline)
                    .opacity(isAnimating ? 1 : 0)
                    .animation(.easeIn.delay(0.5), value: isAnimating)
                
                // Chart
                HStack(spacing: 12) {
                    ForEach(0..<5) { i in
                        VStack {
                            Spacer()
                            // Bar
                            RoundedRectangle(cornerRadius: 5)
                                .fill(accentColor.opacity(0.8))
                                .frame(width: 20, height: isAnimating ? barHeights[i] : 0)
                                .animation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.6 + Double(i) * 0.1), value: isAnimating)
                            
                            // Month label
                            Text(months[i])
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .opacity(isAnimating ? 1 : 0)
                                .animation(.easeIn.delay(1.0 + Double(i) * 0.1), value: isAnimating)
                        }
                        .frame(height: 150)
                    }
                }
                
                // Stats
                if showSavings {
                    Text("$1,250 saved")
                        .font(.subheadline)
                        .foregroundColor(accentColor)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 20)
                        .background(accentColor.opacity(0.1))
                        .cornerRadius(20)
                        .transition(.scale.combined(with: .opacity))
                }
                
                // Percentage change
                HStack {
                    Image(systemName: "arrow.up")
                        .foregroundColor(.green)
                    Text("+23%")
                        .foregroundColor(.green)
                        .font(.caption.bold())
                    Text("vs last month")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .opacity(isAnimating && showSavings ? 1 : 0)
                .animation(.easeIn.delay(1.5), value: showSavings)
            }
            .padding(20)
            .background(Color(UIColor.systemBackground))
            .cornerRadius(25)
            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
            .frame(width: 180, height: 360)
        }
        .onAppear {
            // Start animation sequence
            withAnimation {
                isAnimating = true
            }
            
            // Show savings with delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                withAnimation {
                    showSavings = true
                }
            }
        }
        .onDisappear {
            // Reset animation state
            isAnimating = false
            showSavings = false
        }
    }
}

#Preview {
    ZStack {
        Color.black.opacity(0.1).ignoresSafeArea()
        BudgetChartAnimation(accentColor: .blue)
    }
} 