
import SwiftUI
import Charts // Required for the Bar Chart

struct StatsTab: View {
    @EnvironmentObject var sessionManager: SessionManager
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.05, green: 0.05, blue: 0.1).ignoresSafeArea()
                
                if sessionManager.sessions.isEmpty {
                    VStack(spacing: 15) {
                        Image(systemName: "chart.bar.xaxis")
                            .font(.system(size: 60))
                            .foregroundColor(.gray.opacity(0.5))
                        Text("No Games Played Yet")
                            .font(.headline)
                            .foregroundColor(.gray)
                        Text("Play a game to see your stats!")
                            .font(.subheadline)
                            .foregroundColor(.gray.opacity(0.7))
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 25) {
                            // 1. Summary Cards
                            HStack {
                                StatSummaryCard(title: "Total Games", value: "\(sessionManager.sessions.count)", color: .blue)
                                StatSummaryCard(title: "Highest Score", value: "\(sessionManager.sessions.map { $0.score }.max() ?? 0)", color: .orange)
                            }
                            .padding(.horizontal)
                            
                            // 2. Bar Chart Section
                            VStack(alignment: .leading) {
                                Text("Scores by Game Mode")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(.horizontal)
                                
                                Chart {
                                    ForEach(sessionManager.sessions) { session in
                                        BarMark(
                                            x: .value("Game Mode", session.mode.rawValue),
                                            y: .value("Score", session.score)
                                        )
                                        .foregroundStyle(by: .value("Mode", session.mode.rawValue))
                                    }
                                }
                                .chartForegroundStyleScale([
                                    "Tap Frenzy": .blue,
                                    "Light It Up": .orange,
                                    "Quiz Rush": .green
                                ])
                                .frame(height: 220)
                                .padding()
                                .background(Color.white.opacity(0.05))
                                .cornerRadius(16)
                                .padding(.horizontal)
                            }
                            
                            // 3. Recent Sessions List
                            VStack(alignment: .leading) {
                                Text("Recent Sessions")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(.horizontal)
                                
                                ForEach(sessionManager.sessions.reversed().prefix(10)) { session in
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(session.mode.rawValue)
                                                .font(.headline)
                                                .foregroundColor(.white)
                                            Text(session.timestamp, style: .date)
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                        Spacer()
                                        Text("\(session.score)")
                                            .font(.title3)
                                            .bold()
                                            .foregroundColor(color(for: session.mode))
                                    }
                                    .padding()
                                    .background(Color.white.opacity(0.05))
                                    .cornerRadius(12)
                                    .padding(.horizontal)
                                }
                            }
                        }
                        .padding(.vertical)
                    }
                }
            }
            .navigationTitle("Statistics")
            .preferredColorScheme(.dark)
        }
    }
    
    // Helper to color-code the list
    func color(for mode: GameMode) -> Color {
        switch mode {
        case .tapFrenzy: return .blue
        case .lightItUp: return .orange
        case .quizRush: return .green
        }
    }
}

struct StatSummaryCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title).font(.caption).foregroundColor(.gray)
            Text(value).font(.title).bold().foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(color.opacity(0.3), lineWidth: 1))
    }
}
