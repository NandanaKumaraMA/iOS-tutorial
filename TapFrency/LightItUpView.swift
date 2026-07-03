import SwiftUI
import Combine

struct Card: Identifiable {
    let id: Int
    var isLit: Bool = false
}


enum GameLevel {
    case l1, l2, l3, l4
    
    var cardCount: Int {
        switch self { case .l1: return 3; case .l2: return 4; case .l3: return 6; case .l4: return 9 }
    }
    var columns: [GridItem] {
        let flex = GridItem(.flexible(), spacing: 15)
        switch self {
        case .l1: return [flex, flex, flex]
        case .l2: return [flex, flex]
        case .l3: return [flex, flex]
        case .l4: return [flex, flex, flex]
        }
    }
    var interval: Double {
        switch self { case .l1: return 1.5; case .l2: return 1.2; case .l3: return 1.0; case .l4: return 0.8 }
    }
    var litCount: Int {
        switch self { case .l4: return 2; default: return 1 }
    }
}

struct LightItUpView: View {
    @State private var score: Int = 0
    @AppStorage("lightItUpHighScore") private var highScore: Int = 0
    @State private var timeRemaining: Int = 60
    @State private var gameActive: Bool = false
    @State private var gameOver: Bool = false
    @State private var isNewHighScore: Bool = false
    
    @State private var cards: [Card] = []
    @State private var currentLevel: GameLevel = .l1
    @State private var elapsedLitTime: Double = 0.0

    let gameTimer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            Color(red: 0.07, green: 0.07, blue: 0.12).ignoresSafeArea()

            if gameOver {
                gameOverView
            } else if !gameActive {
                startView
            } else {
                gamePlayView
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onReceive(gameTimer) { _ in
            guard gameActive else { return }
            
            elapsedLitTime += 0.1
            if elapsedLitTime >= 1.0 {
                timeRemaining -= 1
                updateLevelProgression()
            }
            
            if elapsedLitTime.truncatingRemainder(dividingBy: 1.0) == 0 || elapsedLitTime >= currentLevel.interval {
                 if elapsedLitTime >= currentLevel.interval {
                     refreshLitCards()
                     elapsedLitTime = 0.0
                 }
            }
            
            if timeRemaining <= 0 { endGame() }
        }
    }

    var startView: some View {
        VStack(spacing: 30) {
            Text("LIGHT IT UP").font(.system(size: 42, weight: .black, design: .rounded)).foregroundColor(.white)
            Text("Tap the lit cards before\nthey go dark!").multilineTextAlignment(.center).foregroundColor(.gray)
            if highScore > 0 { Text("🏆 Best: \(highScore)").font(.headline).foregroundColor(.yellow) }
            Button(action: startGame) { MenuButton(title: "START", color: .purple) }
        }
    }

    var gameOverView: some View {
        VStack(spacing: 24) {
            Text(isNewHighScore ? "🎉 NEW HIGH SCORE!" : "ROUND OVER").font(.system(size: 34, weight: .black, design: .rounded)).foregroundColor(isNewHighScore ? .yellow : .white)
            Text("\(score)").font(.system(size: 72, weight: .black, design: .rounded)).foregroundColor(.white)
            if !isNewHighScore { Text("🏆 Best: \(highScore)").font(.headline).foregroundColor(.yellow) }
            Button(action: startGame) { MenuButton(title: "PLAY AGAIN", color: .purple) }
        }
    }

    var gamePlayView: some View {
        VStack {
            HStack {
                Text("SCORE: \(score)").font(.title2.bold()).foregroundColor(.white)
                Spacer()
                Text("TIME: \(timeRemaining)s").font(.title2.bold()).foregroundColor(timeRemaining <= 10 ? .red : .white)
            }.padding(.horizontal, 30).padding(.top, 20)
            
            Spacer()
            
            LazyVGrid(columns: currentLevel.columns, spacing: 15) {
                ForEach(cards) { card in
                    Button(action: { handleCardTap(card) }) {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(card.isLit ? Color.purple : Color.white.opacity(0.1))
                            .aspectRatio(1.0, contentMode: .fit)
                            .shadow(color: card.isLit ? Color.purple.opacity(0.8) : .clear, radius: 15)
                            .scaleEffect(card.isLit ? 1.05 : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: card.isLit)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(30)
            
            Spacer()
        }
    }

    func startGame() {
        score = 0; timeRemaining = 60; isNewHighScore = false; gameOver = false; currentLevel = .l1; elapsedLitTime = 0.0
        setupGrid()
        gameActive = true
    }
    
    func endGame() {
        gameActive = false; gameOver = true
        if score > highScore { highScore = score; isNewHighScore = true }
    }
    
    func setupGrid() {
        cards = (0..<currentLevel.cardCount).map { Card(id: $0, isLit: false) }
        refreshLitCards()
    }
    
    func updateLevelProgression() {
        let oldLevel = currentLevel
        
        if timeRemaining > 45 { currentLevel = .l1 }
        else if timeRemaining > 30 { currentLevel = .l2 }
        else if timeRemaining > 15 { currentLevel = .l3 }
        else { currentLevel = .l4 }
        
        if oldLevel != currentLevel { setupGrid() }
    }
    
    func refreshLitCards() {
        for i in 0..<cards.count { cards[i].isLit = false }
        
        var indices = Array(0..<cards.count)
        indices.shuffle()
        
        withAnimation {
            for i in 0..<min(currentLevel.litCount, cards.count) {
                cards[indices[i]].isLit = true
            }
        }
    }

    func handleCardTap(_ card: Card) {
        guard gameActive else { return }
        
        if card.isLit {
            score += 10
            if let index = cards.firstIndex(where: { $0.id == card.id }) {
                withAnimation { cards[index].isLit = false }
            }
        } else {
            score -= 5
        }
    }
}

#Preview {
    LightItUpView()
}
