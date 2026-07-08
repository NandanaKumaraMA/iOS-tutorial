
import SwiftUI
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
