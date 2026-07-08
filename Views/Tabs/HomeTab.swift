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
                        NavigationLink(destination: TapFrenzyView()) { GameMenuButton(title: "Tap Frenzy", icon: "hand.tap.fill", gradientColors: [.blue, .cyan, .purple]) }
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


