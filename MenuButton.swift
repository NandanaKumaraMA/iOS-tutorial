import SwiftUI

struct MenuButton: View {
    let title: String
    let color: Color

    var body: some View {
        Text(title)
            .font(.title3.bold())
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(color)
            .cornerRadius(16)
            .shadow(color: color.opacity(0.5), radius: 10, x: 0, y: 6)
    }
}
