import SwiftUI
import Combine

// MARK: - Model
// (Card struct lives in Card.swift — id + isLit)

// MARK: - ViewModel
@MainActor
class LightItUpViewModel: ObservableObject {
    @Published var cards: [Card] = (0..<9).map { Card(id: $0) }
    @Published var score = 0
    @Published var streak = 0
    @Published var timeRemaining = 30
    @Published var isGameOver = false
    @Published var missedTap: Int? = nil // card id that flashes red on a bad tap

    private var gameTimer: AnyCancellable?
    private var spawnTimer: AnyCancellable?
    private var litExpirations: [Int: DispatchWorkItem] = [:]

    func startGame() {
        cards = (0..<9).map { Card(id: $0) }
        score = 0
        streak = 0
        timeRemaining = 30
        isGameOver = false
        missedTap = nil
        litExpirations.values.forEach { $0.cancel() }
        litExpirations.removeAll()

        gameTimer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }

        spawnTimer = Timer.publish(every: 0.85, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.spawnLitCard()
            }
    }

    private func tick() {
        guard timeRemaining > 0 else { return }
        timeRemaining -= 1
        if timeRemaining == 0 {
            endGame()
        }
    }

    private func spawnLitCard() {
        let unlit = cards.indices.filter { !cards[$0].isLit }
        guard let index = unlit.randomElement() else { return }
        cards[index].isLit = true

        let id = cards[index].id
        let expireWork = DispatchWorkItem { [weak self] in
            guard let self else { return }
            if let idx = self.cards.firstIndex(where: { $0.id == id }) {
                self.cards[idx].isLit = false
            }
            self.litExpirations[id] = nil
        }
        litExpirations[id] = expireWork
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1, execute: expireWork)
    }

    func tapCard(_ card: Card) {
        guard !isGameOver, let index = cards.firstIndex(where: { $0.id == card.id }) else { return }

        if cards[index].isLit {
            // Successful tap
            score += 10 + (streak * 2)
            streak += 1
            cards[index].isLit = false
            litExpirations[card.id]?.cancel()
            litExpirations[card.id] = nil

            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        } else {
            // Missed tap on a dark tile
            score = max(0, score - 3)
            streak = 0

            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)

            missedTap = card.id
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                if self?.missedTap == card.id {
                    self?.missedTap = nil
                }
            }
        }
    }

    private func endGame() {
        gameTimer?.cancel()
        spawnTimer?.cancel()
        litExpirations.values.forEach { $0.cancel() }
        litExpirations.removeAll()
        cards = cards.map { Card(id: $0.id, isLit: false) }
        isGameOver = true
    }

    func stopGame() {
        gameTimer?.cancel()
        spawnTimer?.cancel()
        litExpirations.values.forEach { $0.cancel() }
        litExpirations.removeAll()
    }
}

// MARK: - View
struct LightItUpView: View {
    @StateObject private var viewModel = LightItUpViewModel()
    @Environment(\.dismiss) private var dismiss

    @AppStorage("lightItUpHighScore") private var highScore = 0

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 14), count: 3)

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

            // Tile Grid
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
            .scaleEffect(isMissed ? 0.94 : 1.0)
            .animation(.easeOut(duration: 0.15), value: isLit)
            .animation(.easeOut(duration: 0.15), value: isMissed)
    }
}

#Preview {
    NavigationStack {
        LightItUpView()
    }
}
