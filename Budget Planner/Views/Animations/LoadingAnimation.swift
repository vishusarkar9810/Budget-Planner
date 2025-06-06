//
//  LoadingAnimation.swift
//  Budget Planner
//
//  Created for enhanced onboarding
//

import SwiftUI

struct LoadingAnimation: View {
    @Binding var isComplete: Bool
    @State private var opacity = 0.0
    @State private var scale = 0.8
    @State private var rotation = 0.0
    
    let accentColor: Color
    let duration: Double
    let onComplete: () -> Void
    
    init(isComplete: Binding<Bool>, accentColor: Color = .blue, duration: Double = 2.0, onComplete: @escaping () -> Void = {}) {
        self._isComplete = isComplete
        self.accentColor = accentColor
        self.duration = duration
        self.onComplete = onComplete
    }
    
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .fill(accentColor.opacity(0.1))
                .frame(width: 120, height: 120)
                .scaleEffect(scale)
                .opacity(opacity)
            
            // Rotating circle
            Circle()
                .trim(from: 0, to: 0.8)
                .stroke(accentColor, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                .frame(width: 100, height: 100)
                .rotationEffect(.degrees(rotation))
                .opacity(opacity)
            
            // Dollar sign
            Image(systemName: "dollarsign.circle.fill")
                .font(.system(size: 40))
                .foregroundColor(accentColor)
                .opacity(opacity)
                .scaleEffect(scale)
        }
        .onAppear {
            // Start animations
            withAnimation(.easeIn(duration: 0.5)) {
                opacity = 1.0
                scale = 1.0
            }
            
            // Start rotation
            withAnimation(.linear(duration: duration).repeatCount(1, autoreverses: false)) {
                rotation = 360
            }
            
            // Set timer to complete
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                withAnimation {
                    isComplete = true
                    onComplete()
                }
            }
        }
    }
}

// Extension for creating a circle that fills up over time
struct CircularProgressView: View {
    let progress: Double
    let color: Color
    let lineWidth: CGFloat
    
    var body: some View {
        Circle()
            .trim(from: 0, to: CGFloat(min(progress, 1.0)))
            .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
            .rotationEffect(.degrees(-90))
            .animation(.linear, value: progress)
    }
}

#Preview {
    ZStack {
        Color.black.opacity(0.1).ignoresSafeArea()
        LoadingAnimation(isComplete: .constant(false))
    }
}