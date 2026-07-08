import SwiftUI
import Combine

struct LightItUpView: View {
    @StateObject private var viewModel = LightItUpViewModel()
    @Environment(\.dismiss) private var dismiss
    
    // 1. Inject the SessionManager to save data
    @EnvironmentObject var sessionManager: SessionManager
    @EnvironmentObject var locationService: LocationService // Add this!
    @AppStorage("lightItUpHighScore") private var highScore = 0

    private var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 14), count: viewModel.currentLevel.columns)
    }

    var body: some View {
        ZStack {
            Color(red: 0.05, green: 0.02, blue: 0.1)
                .ignoresSafeArea()

            VStack {
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
                    // 2. Replaced the old Game Over screen with our shared ResultView
                    ResultView(
                        score: viewModel.score,
                        highScore: highScore,
                        gameMode: .lightItUp,
                        onPlayAgain: { viewModel.startGame() },
                        onMainMenu: { dismiss() }
                    )
                } else {
                    gamePlayView
                }
            }
            
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
        // 3. Automatically save the session when the game ends
        .onChange(of: viewModel.isGameOver) { isOver in
            if isOver {
                if viewModel.score > highScore { highScore = viewModel.score }
                // Latitude and Longitude are 0.0 until we build the MapTab
                sessionManager.saveSession(mode: .lightItUp, score: viewModel.score, lat: 0.0, lon: 0.0)
            }
        }
    }

    // MARK: - GamePlay View
    var gamePlayView: some View {
        VStack(spacing: 25) {
            HStack {
                VStack(alignment: .leading) {
                    Text("SCORE").font(.caption).foregroundColor(.gray)
                    Text("\(viewModel.score)").font(.title2).bold().foregroundColor(.white)
                }
                Spacer()
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

            Text("\(viewModel.timeRemaining)s")
                .font(.headline)
                .foregroundColor(.orange)
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(.ultraThinMaterial)
                .cornerRadius(20)

            Spacer()

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
