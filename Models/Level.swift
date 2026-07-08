import SwiftUI
// MARK: - Model
// Ensure you have a Card.swift file with this struct:
// struct Card: Identifiable {
//     let id: Int
//     var isLit: Bool = false
// }

enum Level: Int {
    case l1 = 1, l2, l3, l4
    
    // Level Progression Rules[cite: 2]
    var cardCount: Int {
        switch self {
        case .l1: return 3
        case .l2: return 4
        case .l3: return 6
        case .l4: return 9
        }
    }
    
    // Lit Window Speeds: Decreasing the time increases the speed[cite: 2]
    var litWindow: Double {
        switch self {
        case .l1: return 1.5  // L1: Slowest
        case .l2: return 1.2  // L2: Faster
        case .l3: return 1.0  // L3: Even faster
        case .l4: return 0.8  // L4: Fastest
        }
    }
    
    // Number of cards to light up simultaneously[cite: 2]
    var concurrentLit: Int {
        switch self {
        case .l4: return 2
        default: return 1
        }
    }
    
    // Grid layout formatting[cite: 2]
    var columns: Int {
        switch self {
        case .l2: return 2 // 2x2 grid for 4 cards
        default: return 3  // 3 columns for 3, 6, and 9 cards
        }
    }
}
