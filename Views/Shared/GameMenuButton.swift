import SwiftUI

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
