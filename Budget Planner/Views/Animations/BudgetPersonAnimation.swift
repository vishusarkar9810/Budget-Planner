//
//  BudgetPersonAnimation.swift
//  Budget Planner
//
//  Created for enhanced onboarding
//

import SwiftUI

struct BudgetPersonAnimation: View {
    @State private var isAnimating = false
    @State private var showIcons = false
    @State private var pulseEffect = false
    
    let accentColor: Color
    
    // Financial icons and their positions
    let icons = [
        (name: "dollarsign.circle.fill", offset: CGPoint(x: 80, y: -60)),
        (name: "creditcard.fill", offset: CGPoint(x: -80, y: -40)),
        (name: "chart.pie.fill", offset: CGPoint(x: 70, y: 20)),
        (name: "arrow.up.arrow.down.circle.fill", offset: CGPoint(x: -70, y: 40)),
        (name: "star.fill", offset: CGPoint(x: 90, y: 80)),
        (name: "house.fill", offset: CGPoint(x: -90, y: -80))
    ]
    
    var body: some View {
        ZStack {
            // Figure outline
            PersonShape()
                .stroke(Color.white, lineWidth: 3)
                .frame(width: 180, height: 280)
                .opacity(isAnimating ? 1 : 0)
                .scaleEffect(isAnimating ? 1 : 0.8)
                .animation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.3), value: isAnimating)
            
            // Budget/finance icons surrounding the figure
            ForEach(0..<icons.count, id: \.self) { i in
                Image(systemName: icons[i].name)
                    .font(.system(size: 40))
                    .foregroundColor(accentColor)
                    .offset(x: showIcons ? icons[i].offset.x : 0,
                            y: showIcons ? icons[i].offset.y : 0)
                    .scaleEffect(pulseEffect ? 1.1 : 1.0)
                    .opacity(showIcons ? 1 : 0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.5 + Double(i) * 0.1), value: showIcons)
                    .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: pulseEffect)
            }
            
            // Center dollar sign
            Image(systemName: "dollarsign.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(accentColor.opacity(0.8))
                .scaleEffect(pulseEffect ? 1.2 : 1.0)
                .opacity(isAnimating ? 0.6 : 0)
                .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: pulseEffect)
                .animation(.easeIn.delay(0.3), value: isAnimating)
        }
        .frame(height: 300)
        .onAppear {
            // Start animation sequence
            withAnimation {
                isAnimating = true
            }
            
            // Show icons with delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                withAnimation {
                    showIcons = true
                }
            }
            
            // Start pulse effect with delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                pulseEffect = true
            }
        }
        .onDisappear {
            // Reset animation state
            isAnimating = false
            showIcons = false
            pulseEffect = false
        }
    }
}

// Custom person silhouette shape
struct PersonShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Scale factors for drawing
        let width = rect.width
        let height = rect.height
        
        // Head
        let headRadius = width * 0.2
        path.addEllipse(in: CGRect(
            x: width * 0.5 - headRadius,
            y: height * 0.1,
            width: headRadius * 2,
            height: headRadius * 2
        ))
        
        // Body
        path.move(to: CGPoint(x: width * 0.5, y: height * 0.1 + headRadius * 2))
        path.addLine(to: CGPoint(x: width * 0.5, y: height * 0.6))
        
        // Arms
        path.move(to: CGPoint(x: width * 0.3, y: height * 0.3))
        path.addLine(to: CGPoint(x: width * 0.5, y: height * 0.35))
        path.addLine(to: CGPoint(x: width * 0.7, y: height * 0.3))
        
        // Legs
        path.move(to: CGPoint(x: width * 0.5, y: height * 0.6))
        path.addLine(to: CGPoint(x: width * 0.35, y: height * 0.9))
        
        path.move(to: CGPoint(x: width * 0.5, y: height * 0.6))
        path.addLine(to: CGPoint(x: width * 0.65, y: height * 0.9))
        
        return path
    }
}

#Preview {
    ZStack {
        Color.black.opacity(0.1).ignoresSafeArea()
        BudgetPersonAnimation(accentColor: .green)
    }
} 