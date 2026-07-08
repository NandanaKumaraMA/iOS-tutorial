import SwiftUI
import Combine
// MARK: - ViewModel
@MainActor
class LightItUpViewModel: ObservableObject {
    @Published var currentLevel: Level = .l1
    @Published var cards: [Card] = []
    @Published var score = 0
    @Published var streak = 0
    @Published var timeRemaining = 60 // 60-second round[cite: 2]
    @Published var isGameOver = false
    @Published var missedTap: Int? = nil
    
    // Controls the highlighted level flash overlay
    @Published var showLevelUp: Bool = false

    private var gameTimer: AnyCancellable?
    private var spawnTimer: AnyCancellable?
    private var litExpirations: [Int: DispatchWorkItem] = [:]

    func startGame() {
        score = 0
        streak = 0
        timeRemaining = 60
        isGameOver = false
        missedTap = nil
        showLevelUp = false
        
        litExpirations.values.forEach { $0.cancel() }
        litExpirations.removeAll()

        // Start at Level 1
        changeLevel(to: .l1)

        gameTimer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
    }

    private func tick() {
        guard timeRemaining > 0 else { return }
        timeRemaining -= 1
        
        // Progress levels automatically based on remaining time[cite: 2]
        var newLevel = currentLevel
        if timeRemaining <= 15 {
            newLevel = .l4 // 45s - 60s elapsed
        } else if timeRemaining <= 30 {
            newLevel = .l3 // 30s - 45s elapsed
        } else if timeRemaining <= 45 {
            newLevel = .l2 // 15s - 30s elapsed
        }
        
        if newLevel != currentLevel {
            changeLevel(to: newLevel)
        }

        if timeRemaining == 0 {
            endGame()
        }
    }
    
    private func changeLevel(to level: Level) {
        withAnimation(.spring()) {
            currentLevel = level
            
            // Expand the grid by adding new cards to preserve existing lit cards
            let currentCount = cards.count
            if level.cardCount > currentCount {
                cards.append(contentsOf: (currentCount..<level.cardCount).map { Card(id: $0) })
            }
        }
        
        // Trigger the Level Highlight Flash
        withAnimation(.easeInOut(duration: 0.3)) {
            showLevelUp = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { [weak self] in
            withAnimation(.easeInOut(duration: 0.5)) {
                self?.showLevelUp = false
            }
        }
        
        // Restart the timer with the new, faster speed[cite: 2]
        restartSpawnTimer()
    }
    
    private func restartSpawnTimer() {
        spawnTimer?.cancel()
        
        // Initial spawn on level change
        spawnLitCard()
        
        // Tick at the current lit-window interval (Speed increases as litWindow decreases)[cite: 2]
        spawnTimer = Timer.publish(every: currentLevel.litWindow, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.spawnLitCard()
            }
    }

    private func spawnLitCard() {
        let unlit = cards.indices.filter { !cards[$0].isLit }
        guard !unlit.isEmpty else { return }
        
        // Pick random cards based on level requirements[cite: 2]
        let neededCards = currentLevel.concurrentLit
        let chosenIndices = unlit.shuffled().prefix(neededCards)
        
        for index in chosenIndices {
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
            
            // The expiration time is also strictly tied to the faster litWindow[cite: 2]
            DispatchQueue.main.asyncAfter(deadline: .now() + currentLevel.litWindow, execute: expireWork)
        }
    }

    func tapCard(_ card: Card) {
        guard !isGameOver, let index = cards.firstIndex(where: { $0.id == card.id }) else { return }

        if cards[index].isLit {
            // Successful tap (+1 as requested)
            score += 1
            streak += 1
            cards[index].isLit = false
            litExpirations[card.id]?.cancel()
            litExpirations[card.id] = nil

            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        } else {
            // Missed tap on a dark tile (Reduces score, floor at 0)
            score = max(0, score - 1)
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
