//
//  BudgetCategory.swift
//  Budget Planner
//
//  Created on Phase 1
//

import Foundation
import SwiftUI

enum BudgetCategory: String, CaseIterable, Identifiable, Codable {
    // Essential living expenses
    case housing
    case utilities
    case groceries
    case transportation
    
    // Food and dining
    case restaurants
    case coffee
    case fastFood
    
    // Personal care
    case health
    case fitness
    case beauty
    case clothing
    
    // Leisure and entertainment
    case entertainment
    case travel
    case shopping
    case hobbies
    case subscriptions
    
    // Financial
    case education
    case savings
    case investments
    case insurance
    case taxes
    case loans
    case childcare
    case gifts
    case charity
    
    // Other
    case other
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        // Essential living expenses
        case .housing: return "house.fill"
        case .utilities: return "bolt.fill"
        case .groceries: return "cart.fill"
        case .transportation: return "car.fill"
            
        // Food and dining
        case .restaurants: return "fork.knife"
        case .coffee: return "cup.and.saucer.fill"
        case .fastFood: return "takeoutbag.and.cup.and.straw.fill"
            
        // Personal care
        case .health: return "heart.fill"
        case .fitness: return "figure.run"
        case .beauty: return "scissors"
        case .clothing: return "tshirt.fill"
            
        // Leisure and entertainment
        case .entertainment: return "film.fill"
        case .travel: return "airplane"
        case .shopping: return "bag.fill"
        case .hobbies: return "gamecontroller.fill"
        case .subscriptions: return "play.rectangle.fill"
            
        // Financial
        case .education: return "book.fill"
        case .savings: return "banknote.fill"
        case .investments: return "chart.line.uptrend.xyaxis"
        case .insurance: return "lock.shield.fill"
        case .taxes: return "doc.text.fill"
        case .loans: return "building.columns.fill"
        case .childcare: return "figure.and.child.holdinghands"
        case .gifts: return "gift.fill"
        case .charity: return "hand.raised.fill"
            
        // Other
        case .other: return "ellipsis.circle.fill"
        }
    }
    
    var displayName: String {
        rawValue.capitalized
    }
    
    var color: Color {
        switch self {
        // Essential living expenses - blues
        case .housing: return .blue
        case .utilities: return Color(red: 0.3, green: 0.5, blue: 0.9)
        case .groceries: return Color(red: 0.0, green: 0.7, blue: 0.8)
        case .transportation: return Color(red: 0.4, green: 0.6, blue: 1.0)
            
        // Food and dining - greens
        case .restaurants: return .green
        case .coffee: return Color(red: 0.3, green: 0.8, blue: 0.5)
        case .fastFood: return Color(red: 0.5, green: 0.9, blue: 0.3)
            
        // Personal care - reds/pinks
        case .health: return .red
        case .fitness: return Color(red: 0.9, green: 0.4, blue: 0.3)
        case .beauty: return .pink
        case .clothing: return Color(red: 1.0, green: 0.3, blue: 0.5)
            
        // Leisure and entertainment - purples
        case .entertainment: return .purple
        case .travel: return Color(red: 0.7, green: 0.3, blue: 0.8)
        case .shopping: return .orange
        case .hobbies: return Color(red: 0.5, green: 0.2, blue: 0.8)
        case .subscriptions: return Color(red: 0.6, green: 0.4, blue: 0.9)
            
        // Financial - yellows/oranges
        case .education: return Color(red: 0.9, green: 0.7, blue: 0.1)
        case .savings: return Color(red: 0.8, green: 0.8, blue: 0.2)
        case .investments: return Color(red: 0.6, green: 0.8, blue: 0.1)
        case .insurance: return Color(red: 1.0, green: 0.8, blue: 0.0)
        case .taxes: return Color(red: 0.9, green: 0.6, blue: 0.1)
        case .loans: return Color(red: 0.8, green: 0.5, blue: 0.2)
        case .childcare: return Color(red: 0.7, green: 0.5, blue: 0.9)
        case .gifts: return Color(red: 0.9, green: 0.5, blue: 0.7)
        case .charity: return Color(red: 0.5, green: 0.7, blue: 0.9)
            
        // Other
        case .other: return .gray
        }
    }
} 