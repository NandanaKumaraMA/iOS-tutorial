import SwiftUI
import Combine

struct TapFrenzyView: View {
    // Add this to allow dismissing the view
    @Environment(\.dismiss) private var dismiss
    
    @State private var score: Int = 0
    @AppStorage("tapFrenzyHighScore") private var highScore: Int = 0
    @State private var timeRemaining: Int = 10
    @State private var gameActive: Bool = false
    @State private var gameOver: Bool = false
    @State private var isNewHighScore: Bool = false
    
    @State private var buttonColor: Color = Color(red: 0.2, green: 0.5, blue: 1.0)
    @State private var buttonOffset: CGSize = .zero

    let countdownTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    let twoSecondTimer = Timer.publish(every: 2, on: .main, in: .common).autoconnect()

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
        // Ensure the back button is white to match your dark theme
        .tint(.white)
        .onReceive(countdownTimer) { _ in
            guard gameActive else { return }
            if timeRemaining > 0 { timeRemaining -= 1 } else { endGame() }
        }
        .onReceive(twoSecondTimer) { _ in
            guard gameActive else { return }
            changeButtonProperties()
        }
    }

    var startView: some View {
        VStack(spacing: 30) {
            Text("TAP FRENZY")
                .font(.system(size: 42, weight: .black, design: .rounded))
                .foregroundColor(.white)
            
            if highScore > 0 {
                Text("🏆 Best: \(highScore)").font(.headline).foregroundColor(.yellow)
            }
            
            Button(action: startGame) { MenuButton(title: "START", color: .blue) }
        }
    }

    var gameOverView: some View {
        VStack(spacing: 24) {
            Text(isNewHighScore ? "🎉 NEW HIGH SCORE!" : "GAME OVER")
                .font(.system(size: 34, weight: .black, design: .rounded))
                .foregroundColor(isNewHighScore ? .yellow : .white)
            
            Text("\(score)")
                .font(.system(size: 72, weight: .black, design: .rounded))
                .foregroundColor(.white)
            
            if !isNewHighScore {
                Text("🏆 Best: \(highScore)").font(.headline).foregroundColor(.yellow)
            }
            
            VStack(spacing: 16) {
                Button(action: startGame) { MenuButton(title: "PLAY AGAIN", color: .blue) }
                
                // NEW: Main Menu Button
                Button(action: { dismiss() }) { MenuButton(title: "MAIN MENU", color: .gray) }
            }
        }
    }

    var gamePlayView: some View {
        VStack {
            HStack {
                Text("SCORE: \(score)").font(.title2.bold()).foregroundColor(.white)
                Spacer()
                Text("TIME: \(timeRemaining)s").font(.title2.bold()).foregroundColor(timeRemaining <= 3 ? .red : .white)
            }.padding()
            Spacer()
            
            let currentSize = max(60.0, 160.0 * (Double(timeRemaining) / 10.0))
            
            Button(action: handleTap) {
                Text("TAP!")
                    .font(.system(size: currentSize / 4.5, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .frame(width: currentSize, height: currentSize)
                    .background(Circle().fill(buttonColor).shadow(color: buttonColor.opacity(0.6), radius: 20))
            }
            .buttonStyle(TapButtonStyle())
            .offset(buttonOffset)
            .animation(.easeInOut, value: currentSize)
            Spacer()
        }
    }

    func startGame() {
        score = 0; timeRemaining = 10; isNewHighScore = false; gameOver = false; buttonColor = Color(red: 0.2, green: 0.5, blue: 1.0); buttonOffset = .zero; gameActive = true
    }
    func endGame() {
        gameActive = false; gameOver = true; buttonOffset = .zero
        if score > highScore { highScore = score; isNewHighScore = true }
    }
    func handleTap() {
        guard gameActive else { return }
        if buttonColor == .green { score += 2 }
        else if buttonColor == .gray { score -= 2 }
        else { score += 1 }
    }
    func changeButtonProperties() {
        let randomValue = Int.random(in: 1...100)
        let randomX = CGFloat.random(in: -100...100)
        let randomY = CGFloat.random(in: -180...180)
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
            buttonOffset = CGSize(width: randomX, height: randomY)
            if randomValue <= 25 { buttonColor = .green }
            else if randomValue <= 50 { buttonColor = .gray }
            else { buttonColor = Color(red: 0.2, green: 0.5, blue: 1.0) }
        }
    }
}

// Ensure this is defined in a place both files can access it (like ContentView or here)
struct TapButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.88 : 1.0)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}
