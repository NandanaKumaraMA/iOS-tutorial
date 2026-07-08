import SwiftUI

struct HomeTab: View {
    // Animation States
    @State private var animateBackground = false
    @State private var floatIcon = false
    @State private var showButtons = false
    @State private var pulseGlow = false
    
    // High Score Persistence
    @AppStorage("tapFrenzyHighScore") private var tapFrenzyHighScore = 0
    @AppStorage("lightItUpHighScore") private var lightItUpHighScore = 0
    @AppStorage("quizRushHighScore") private var quizRushHighScore = 0
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black
                    .ignoresSafeArea()
                
                // Animated Neon Background
                ZStack {
                    Circle().fill(Color(red: 1.0, green: 0.0, blue: 0.9).opacity(0.55)).frame(width: 420, height: 420).blur(radius: 160)
                        .offset(x: animateBackground ? 130 : -170, y: animateBackground ? -180 : 120)
                        .animation(.easeInOut(duration: 7).repeatForever(autoreverses: true), value: animateBackground)
                    
                    Circle().fill(Color(red: 0.0, green: 0.85, blue: 1.0).opacity(0.55)).frame(width: 380, height: 380).blur(radius: 150)
                        .offset(x: animateBackground ? -170 : 170, y: animateBackground ? 170 : -170)
                        .animation(.easeInOut(duration: 9).repeatForever(autoreverses: true), value: animateBackground)
                    
                    Circle().fill(Color(red: 0.6, green: 0.0, blue: 1.0).opacity(0.45)).frame(width: 300, height: 300).blur(radius: 130)
                        .offset(x: animateBackground ? 60 : -60, y: animateBackground ? 260 : 300)
                        .animation(.easeInOut(duration: 11).repeatForever(autoreverses: true), value: animateBackground)
                }
                .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    // Hero Section
                    VStack(spacing: 18) {
                        Image(systemName: "gamecontroller.fill")
                            .font(.system(size: 76))
                            .foregroundStyle(LinearGradient(colors: [.cyan, .purple, .pink], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .shadow(color: .cyan.opacity(0.9), radius: 25, x: 0, y: 0)
                            .shadow(color: .pink.opacity(0.7), radius: 40, x: 0, y: 0)
                            .offset(y: floatIcon ? -15 : 10)
                            .animation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true), value: floatIcon)
                        
                        Text("GAME HUB")
                            .font(.system(size: 52, weight: .black, design: .rounded))
                            .foregroundStyle(LinearGradient(colors: [.cyan, .white, .pink], startPoint: .leading, endPoint: .trailing))
                            .shadow(color: .cyan.opacity(pulseGlow ? 0.9 : 0.4), radius: pulseGlow ? 22 : 8)
                            .shadow(color: .pink.opacity(pulseGlow ? 0.7 : 0.3), radius: pulseGlow ? 30 : 10)
                            .animation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true), value: pulseGlow)
                    }
                    .padding(.top, 50)
                    
                    // High Score Dashboard
                    HStack(spacing: 10) {
                        ScoreBadge(title: "TAP", score: tapFrenzyHighScore, glowColor: .blue)
                        ScoreBadge(title: "LIGHT", score: lightItUpHighScore, glowColor: .cyan)
                        ScoreBadge(title: "QUIZ", score: quizRushHighScore, glowColor: .green)
                    }
                    .padding(.horizontal)
                    
                    // Game Buttons
                    VStack(spacing: 22) {
                        NavigationLink(destination: ContentView()) { GameMenuButton(title: "Tap Frenzy", icon: "hand.tap.fill", gradientColors: [.blue, .cyan, .purple]) }
                        NavigationLink(destination: LightItUpView()) { GameMenuButton(title: "Light It Up", icon: "lightbulb.max.fill", gradientColors: [.cyan, .blue, .indigo]) }
                        NavigationLink(destination: QuizRushView()) { GameMenuButton(title: "Quiz Rush", icon: "questionmark.bubble.fill", gradientColors: [.green, .teal, .yellow]) }
                    }
                    .padding(.horizontal, 30)
                    .opacity(showButtons ? 1 : 0)
                    .animation(.easeOut(duration: 0.8).delay(0.2), value: showButtons)
                    
                    Spacer()
                }
            }
            .onAppear {
                animateBackground = true
                floatIcon = true
                showButtons = true
                pulseGlow = true
            }
        }
    }
}

struct ScoreBadge: View {
    let title: String
    let score: Int
    var glowColor: Color = .cyan
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.system(size: 11, weight: .heavy, design: .rounded))
                .foregroundColor(.white.opacity(0.55))
            Text("\(score)")
                .font(.system(size: 20, weight: .black, design: .rounded))
                .foregroundColor(.white)
                .shadow(color: glowColor.opacity(0.9), radius: 8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial.opacity(0.6))
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(glowColor.opacity(0.7), lineWidth: 1.5)
        )
        .shadow(color: glowColor.opacity(0.4), radius: 10)
    }
}

struct GameMenuButton: View {
    let title: String
    let icon: String
    let gradientColors: [Color]
    
    var body: some View {
        HStack(spacing: 20) {
            Image(systemName: icon)
                .font(.title)
                .foregroundStyle(LinearGradient(colors: gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing))
                .shadow(color: gradientColors.first?.opacity(0.9) ?? .white, radius: 10)
            Text(title.uppercased())
                .font(.title2).bold()
                .foregroundColor(.white)
            Spacer()
            Image(systemName: "chevron.right.circle.fill")
                .font(.title2)
                .foregroundStyle(LinearGradient(colors: gradientColors, startPoint: .leading, endPoint: .trailing))
        }
        .padding(22)
        .background(.ultraThinMaterial)
        .background(Color.black.opacity(0.35))
        .cornerRadius(25)
        .overlay(
            RoundedRectangle(cornerRadius: 25)
                .stroke(LinearGradient(colors: gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 2)
        )
        .shadow(color: gradientColors.first?.opacity(0.55) ?? .clear, radius: 18, x: 0, y: 8)
        .shadow(color: gradientColors.last?.opacity(0.4) ?? .clear, radius: 26, x: 0, y: 0)
    }
}
