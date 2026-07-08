
import SwiftUI
import MapKit

struct MapTab: View {
    @EnvironmentObject var sessionManager: SessionManager
    
    var body: some View {
        NavigationStack {
            Map {
                ForEach(sessionManager.sessions) { session in
                    // Only show pins if we have a valid location
                    if session.latitude != 0.0 && session.longitude != 0.0 {
                        Marker(session.mode.rawValue, coordinate: CLLocationCoordinate2D(latitude: session.latitude, longitude: session.longitude))
                            .tint(color(for: session.mode))
                    }
                }
            }
            .navigationTitle("Global Leaderboard")
            .preferredColorScheme(.dark)
        }
    }
    
    func color(for mode: GameMode) -> Color {
        switch mode {
        case .tapFrenzy: return .blue
        case .lightItUp: return .orange
        case .quizRush: return .green
        }
    }
}
