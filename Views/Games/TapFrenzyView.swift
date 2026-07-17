import SwiftUI
import Combine
internal import CoreLocation

struct TapFrenzyView: View {
    // Inject the SessionManager and LocationService
    @EnvironmentObject var sessionManager: SessionManager
    @EnvironmentObject var locationService: LocationService
    
    @Environment(\.dismiss) private var dismiss

    @State private var score = 0
    @State private var timeRemaining = 10
    @State private var gameOver = false

    @State private var buttonPosition = CGPoint(x: 200, y: 400)
    @State private var buttonSize: CGFloat = 200
    
    @AppStorage("tapFrenzyHighScore") private var highScore = 0

    let moveButtonTimer = Timer.publish(every: 2, on: .main, in: .common).autoconnect()
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Neon Background
                ZStack {
                    Color.black.ignoresSafeArea()
                    Circle().fill(Color.pink.opacity(0.35)).frame(width: 400, height: 400).blur(radius: 150)
                        .offset(x: -140, y: -220)
                    Circle().fill(Color.cyan.opacity(0.3)).frame(width: 350, height: 350).blur(radius: 140)
                        .offset(x: 150, y: 260)
                }
                .ignoresSafeArea()

                VStack {
                    HStack(spacing: 15) {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "chevron.left.circle.fill")
                                .font(.system(size: 40))
                                .foregroundStyle(.white.opacity(0.85), .ultraThinMaterial)
                                .shadow(color: .cyan.opacity(0.7), radius: 10)
                        }
                        
                        // Only show the score/timer cards during active play so they
                        // don't overlap the Game Over card once the round ends.
                        if !gameOver {
                            statCard(icon: "trophy.fill", title: "SCORE", value: "\(score)", color: .orange)
                            statCard(icon: "timer", title: "TIME", value: "\(timeRemaining)", color: .cyan)
                        }
                    }
                    .padding(.horizontal)
                    Spacer()
                }
                .padding(.top)

                if !gameOver {
                    Button {
                        //let generator = UIImpactFeedbackGenerator(style: .medium)
                        //generator.impactOccurred()
                       HapticsManager.impact()
                        score += 1
                    } label: {
                        ZStack {
                            Circle()
                                .fill(RadialGradient(gradient: Gradient(colors: [.pink, .purple, .red.opacity(0.9)]), center: .topLeading, startRadius: 10, endRadius: buttonSize))
                            Circle()
                                .strokeBorder(LinearGradient(colors: [.cyan, .white.opacity(0.7), .pink], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 5)
                            Text("TAP")
                                .font(.system(size: buttonSize * 0.25, weight: .black, design: .rounded))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.3), radius: 2, y: 2)
                        }
                        .frame(width: buttonSize, height: buttonSize)
                        .shadow(color: .pink.opacity(0.8), radius: 30, y: 0)
                        .shadow(color: .cyan.opacity(0.5), radius: 45, y: 0)
                    }
                    .position(buttonPosition)
                    .disabled(gameOver) // Timer hits zero → button disables

                } else {
                    // Use the unified ResultView
                    ResultView(
                        score: score,
                        highScore: highScore,
                        gameMode: .tapFrenzy,
                        onPlayAgain: { restartGame(in: geometry) },
                        onMainMenu: { dismiss() }
                    )
                }
            }
            .navigationBarBackButtonHidden(true)
            .toolbar(.hidden, for: .tabBar) // Full-screen gameplay, no tab bar peeking through
            .onAppear {
                buttonPosition = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            }
            .onReceive(timer) { _ in
                guard timeRemaining > 0 else {
                    // Game Over Logic
                    if !gameOver {
                        gameOver = true
                        if score > highScore { highScore = score }
                        
                        // Save the session with the player's real location (if available)
                        sessionManager.saveSession(
                            mode: .tapFrenzy,
                            score: score,
                            lat: locationService.location?.latitude ?? 0.0,
                            lon: locationService.location?.longitude ?? 0.0
                        )
                    }
                    return
                }
                timeRemaining -= 1
                // Shrinking Button challenge: size scales down smoothly as time runs out,
                // hitting its smallest size right as the timer reaches zero.
                withAnimation(.easeInOut(duration: 1.0)) {
                    buttonSize = 50 + CGFloat(timeRemaining) * 15
                }
            }
            .onReceive(moveButtonTimer) { _ in
                if !gameOver {
                    let x = CGFloat.random(in: 60...(geometry.size.width - 60))
                    let y = CGFloat.random(in: 180...(geometry.size.height - 150))
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                        buttonPosition = CGPoint(x: x, y: y)
                    }
                }
            }
        }
    }

    func statCard(icon: String, title: String, value: String, color: Color) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .shadow(color: color.opacity(0.9), radius: 8)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.system(size: 10, weight: .bold)).foregroundColor(.white.opacity(0.6))
                Text(value).font(.system(size: 20, weight: .black, design: .rounded)).foregroundColor(.white)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.ultraThinMaterial)
        .background(Color.black.opacity(0.3))
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(color.opacity(0.6), lineWidth: 1.5))
        .shadow(color: color.opacity(0.3), radius: 10)
    }

    func restartGame(in geometry: GeometryProxy) {
        score = 0
        timeRemaining = 10
        gameOver = false
        buttonSize = 200
        buttonPosition = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
    }
}
