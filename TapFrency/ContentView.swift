import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.07, green: 0.07, blue: 0.12).ignoresSafeArea()
                
                VStack(spacing: 40) {
                    Text("GAME CENTER")
                        .font(.system(size: 42, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                    
                    VStack(spacing: 20) {
                        NavigationLink(destination: TapFrenzyView()) {
                            MenuButton(title: "TAP FRENZY", color: .blue)
                        }
                        
                        NavigationLink(destination: LightItUpView()) {
                            MenuButton(title: "LIGHT IT UP", color: .purple)
                        }
                    }
                }
            }
        }
    }
}

struct MenuButton: View {
    let title: String
    let color: Color
    
    var body: some View {
        Text(title)
            .font(.system(size: 24, weight: .bold, design: .rounded))
            .foregroundColor(.white)
            .frame(width: 250, height: 70)
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: color.opacity(0.5), radius: 10, y: 5)
    }
}

#Preview {
    ContentView()
}
