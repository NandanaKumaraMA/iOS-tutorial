
import SwiftUI

struct ResultView: View {
    let score: Int
    let highScore: Int
    let gameMode: GameMode
    let onPlayAgain: () -> Void
    let onMainMenu: () -> Void
    
    // The share string required by the Week 4 brief
    var shareText: String {
        "I just scored \(score) on \(gameMode.rawValue) — beat that!"
    }
    
    var body: some View {
        VStack(spacing: 25) {
            Image(systemName: "trophy.fill")
                .font(.system(size: 70))
                .foregroundStyle(LinearGradient(colors: [.yellow, .orange, .pink], startPoint: .top, endPoint: .bottom))
                .shadow(color: .orange.opacity(0.8), radius: 20)

            Text("GAME OVER")
                .font(.system(size: 32, weight: .black, design: .rounded))
                .foregroundColor(.white)
                .shadow(color: .pink.opacity(0.6), radius: 12)

            VStack(spacing: 5) {
                Text("Final Score").font(.subheadline).foregroundColor(.white.opacity(0.7))
                Text("\(score)")
                    .font(.system(size: 60, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .cyan.opacity(0.7), radius: 14)
            }
            
            Text(score >= highScore ? "🏆 New High Score!" : "Best: \(highScore)")
                .font(.headline)
                .foregroundColor(score >= highScore ? .yellow : .white.opacity(0.5))

            VStack(spacing: 15) {
                // ShareLink implementation
                ShareLink(item: shareText) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("Share Score")
                    }
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.blue.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(16)
                }
                
                Button(action: onPlayAgain) {
                    Text("Play Again")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(LinearGradient(colors: [.cyan, .purple, .pink], startPoint: .leading, endPoint: .trailing))
                        .foregroundColor(.white)
                        .cornerRadius(16)
                        .shadow(color: .purple.opacity(0.6), radius: 15)
                }
                
                Button(action: onMainMenu) {
                    Text("Main Menu")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(.ultraThinMaterial)
                        .foregroundColor(.white)
                        .cornerRadius(16)
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(.white.opacity(0.3), lineWidth: 1))
                }
            }
        }
        .padding(40)
        .background(.ultraThinMaterial)
        .background(Color.black.opacity(0.5))
        .cornerRadius(30)
        .overlay(RoundedRectangle(cornerRadius: 30).stroke(LinearGradient(colors: [.cyan, .pink], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 2))
        .shadow(color: .purple.opacity(0.4), radius: 30)
        .padding(.horizontal, 30)
    }
}
