
import SwiftUI

class SessionManager: ObservableObject {
    @Published var sessions: [GameSession] = []
    private let defaultsKey = "savedGameSessions"

    init() {
        loadSessions()
    }

    func saveSession(mode: GameMode, score: Int, lat: Double, lon: Double) {
        let newSession = GameSession(mode: mode, score: score, latitude: lat, longitude: lon)
        sessions.append(newSession)
        persist()
    }

    private func persist() {
        if let encoded = try? JSONEncoder().encode(sessions) {
            UserDefaults.standard.set(encoded, forKey: defaultsKey)
        }
    }

    private func loadSessions() {
        if let data = UserDefaults.standard.data(forKey: defaultsKey),
           let decoded = try? JSONDecoder().decode([GameSession].self, from: data) {
            sessions = decoded
        }
    }
    
    func resetStats() {
        sessions.removeAll()
        persist()
    }
}
