//
//  BudgetCategory.swift
//  Budget Planner
//
//  Created on Phase 1
//

import Foundation
import SwiftUI

enum BudgetCategory: String, CaseIterable, Identifiable, Codable {
    case food
    case transportation
    case entertainment
    case shopping
    case utilities
    case health
    case other
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .food: return "fork.knife"
        case .transportation: return "car.fill"
        case .entertainment: return "film.fill"
        case .shopping: return "bag.fill"
        case .utilities: return "bolt.fill"
        case .health: return "heart.fill"
        case .other: return "ellipsis.circle.fill"
        }
    }
    
    var displayName: String {
        rawValue.capitalized
    }
    
    var color: Color {
        switch self {
        case .food: return .green
        case .transportation: return .blue
        case .entertainment: return .purple
        case .shopping: return .orange
        case .utilities: return .yellow
        case .health: return .red
        case .other: return .gray
        }
    }
} 