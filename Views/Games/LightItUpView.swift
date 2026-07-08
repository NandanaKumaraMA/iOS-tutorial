import SwiftUI
import Combine

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



// MARK: - View
struct LightItUpView: View {
    @StateObject private var viewModel = LightItUpViewModel()
    @Environment(\.dismiss) private var dismiss

    // Persist score based on mode[cite: 2]
    @AppStorage("lightItUpHighScore") private var highScore = 0

    // Dynamic grid layout
    private var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 14), count: viewModel.currentLevel.columns)
    }

    var body: some View {
        ZStack {
            Color(red: 0.05, green: 0.02, blue: 0.1)
                .ignoresSafeArea()

            VStack {
                // Top Navigation Bar
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left.circle.fill")
                            .font(.title)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    Spacer()
                    Text("LIGHT IT UP")
                        .font(.headline)
                        .bold()
                        .foregroundColor(.orange)
                    Spacer()
                    Image(systemName: "circle").opacity(0)
                }
                .padding()

                if viewModel.isGameOver {
                    gameOverView
                } else {
                    gamePlayView
                }
            }
            
            // Level-Up Flash Overlay
            if viewModel.showLevelUp && !viewModel.isGameOver {
                VStack {
                    Text("LEVEL \(viewModel.currentLevel.rawValue)")
                        .font(.system(size: 64, weight: .black, design: .rounded))
                        .italic()
                        .foregroundColor(.white)
                        .shadow(color: .orange, radius: 20, x: 0, y: 0)
                        .shadow(color: .pink, radius: 40, x: 0, y: 0)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.ultraThinMaterial.opacity(0.8))
                .transition(.scale.combined(with: .opacity))
                .zIndex(1)
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear { viewModel.startGame() }
        .onDisappear { viewModel.stopGame() }
    }

    // MARK: - GamePlay View
    var gamePlayView: some View {
        VStack(spacing: 25) {
            // Stats Row
            HStack {
                VStack(alignment: .leading) {
                    Text("SCORE").font(.caption).foregroundColor(.gray)
                    Text("\(viewModel.score)").font(.title2).bold().foregroundColor(.white)
                }
                Spacer()
                
                // Visible Current Level Indicator
                VStack {
                    Text("LEVEL").font(.caption).foregroundColor(.orange)
                    Text("\(viewModel.currentLevel.rawValue)").font(.title2).bold().foregroundColor(.orange)
                }
                
                Spacer()
                VStack(alignment: .trailing) {
                    Text("STREAK").font(.caption).foregroundColor(.orange)
                    Text("\(viewModel.streak) 🔥").font(.title2).bold().foregroundColor(.orange)
                }
            }
            .padding(.horizontal)

            // Countdown
            Text("\(viewModel.timeRemaining)s")
                .font(.headline)
                .foregroundColor(.orange)
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(.ultraThinMaterial)
                .cornerRadius(20)

            Spacer()

            // Dynamic Tile Grid
            LazyVGrid(columns: columns, spacing: 14) {
                ForEach(viewModel.cards) { card in
                    TileView(
                        isLit: card.isLit,
                        isMissed: viewModel.missedTap == card.id
                    )
                    .onTapGesture {
                        viewModel.tapCard(card)
                    }
                }
            }
            .padding(.horizontal, 24)

            Spacer()
        }
    }

    // MARK: - Game Over View
    var gameOverView: some View {
        VStack(spacing: 20) {
            Spacer()
            Text("TIME'S UP!")
                .font(.system(size: 32, weight: .black, design: .rounded))
                .foregroundColor(.orange)

            if viewModel.score > highScore {
                let _ = DispatchQueue.main.async { highScore = viewModel.score }
                Text("🏆 New High Score!").foregroundColor(.yellow)
            }

            Text("Final Score")
                .foregroundColor(.gray)
            Text("\(viewModel.score)")
                .font(.system(size: 60, weight: .black, design: .rounded))
                .foregroundColor(.white)

            Spacer()

            Button {
                viewModel.startGame()
            } label: {
                Text("Play Again")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(LinearGradient(colors: [.orange, .red, .pink], startPoint: .leading, endPoint: .trailing))
                    .foregroundColor(.white)
                    .cornerRadius(16)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
    }
}

// MARK: - Tile
struct TileView: View {
    let isLit: Bool
    let isMissed: Bool

    var body: some View {
        RoundedRectangle(cornerRadius: 18)
            .fill(
                isLit
                    ? AnyShapeStyle(LinearGradient(colors: [.orange, .red, .pink], startPoint: .topLeading, endPoint: .bottomTrailing))
                    : AnyShapeStyle(Color.white.opacity(0.06))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(isMissed ? Color.red : Color.white.opacity(0.1), lineWidth: isMissed ? 2 : 1)
            )
            .overlay(
                Image(systemName: "lightbulb.max.fill")
                    .font(.title2)
                    .foregroundColor(.white.opacity(isLit ? 0.9 : 0.15))
            )
            .frame(height: 90)
            .shadow(color: isLit ? .orange.opacity(0.6) : .clear, radius: 12)
            .scaleEffect(isMissed ? 0.94 : (isLit ? 1.05 : 1.0))
            .animation(.easeOut(duration: 0.15), value: isLit)
            .animation(.easeOut(duration: 0.15), value: isMissed)
    }
}

#Preview {
    NavigationStack {
        LightItUpView()
    }
}
