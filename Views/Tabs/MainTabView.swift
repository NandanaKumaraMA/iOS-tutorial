
import SwiftUI


// The root shell for the app. Each tab owns its own NavigationStack
// (declared inside HomeTab / StatsTab / MapTab / SettingsTab already),
// so pushing a game from Home doesn't affect the other tabs.
struct MainTabView: View {
    var body: some View {
        TabView {
            HomeTab()
                .tabItem {
                    Label("Home", systemImage: "gamecontroller.fill")
                }

            StatsTab()
                .tabItem {
                    Label("Stats", systemImage: "chart.bar.fill")
                }

            MapTab()
                .tabItem {
                    Label("Map", systemImage: "map.fill")
                }

            SettingsTab()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
        .tint(.cyan)
        .preferredColorScheme(.dark)
    }
}

#Preview {
    MainTabView()
        .environmentObject(SessionManager())
        .environmentObject(LocationService())
}
