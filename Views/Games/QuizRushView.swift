import SwiftUI
import Combine
internal import CoreLocation



// NEW HELPER: Fast Base64 decoding (Avoids the Simulator freezing bug)
extension String {
    var base64Decoded: String {
        guard let data = Data(base64Encoded: self),
              let decodedString = String(data: data, encoding: .utf8) else {
            return self
        }
        return decodedString
    }
}



// MARK: - View
struct QuizRushView: View {
    @StateObject private var viewModel = QuizRushViewModel()
    @Environment(\.dismiss) private var dismiss
    
    @EnvironmentObject var sessionManager: SessionManager
    @EnvironmentObject var locationService: LocationService
    
    @AppStorage("quizRushHighScore") private var highScore = 0
    
    private let gridColumns = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        ZStack {
            // Background
            Color(red: 0.05, green: 0.05, blue: 0.1)
                .ignoresSafeArea()
            
            // Background flash on answer
            if let feedback = viewModel.answerFeedback {
                (feedback ? Color.green : Color.red).opacity(0.2)
                    .ignoresSafeArea()
                    .transition(.opacity)
            }
            
            VStack {
                // Top Navigation Bar
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left.circle.fill")
                            .font(.title)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    Spacer()
                    Text("QUIZ RUSH")
                        .font(.headline)
                        .bold()
                        .foregroundColor(.purple)
                    Spacer()
                    Image(systemName: "circle").opacity(0)
                }
                .padding()
                
                // Content based on ViewState
                switch viewModel.state {
                case .selectingGenre: // Pick a topic before the round starts
                    genreSelectionView
                    
                case .loading: // Loading state during fetch
                    Spacer()
                    ProgressView()
                        .scaleEffect(2)
                        .tint(.purple)
                    Text("Fetching \(viewModel.selectedCategory.name) Trivia...")
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.top, 20)
                    Spacer()
                    
                case .failed: // Graceful error state on network failure
                    Spacer()
                    Image(systemName: "wifi.exclamationmark")
                        .font(.system(size: 60))
                        .foregroundColor(.red)
                    Text("Network Error")
                        .font(.title2).bold().foregroundColor(.white)
                        .padding(.top)
                    Text("Could not reach Open Trivia DB.")
                        .foregroundColor(.gray)
                    
                    Button {
                        Task { await viewModel.loadQuestions() }
                    } label: {
                        Text("Retry")
                            .bold()
                            .padding()
                            .frame(maxWidth: 200)
                            .background(Color.purple)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .padding(.top, 20)
                    
                    Button {
                        viewModel.changeGenre()
                    } label: {
                        Text("Choose a Different Genre")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding(.top, 10)
                    Spacer()
                    
                case .loaded:
                    if viewModel.isGameOver {
                        // Shared ResultView (score, high score, share, play again, main menu)
                        ResultView(
                            score: viewModel.score,
                            highScore: highScore,
                            gameMode: .quizRush,
                            onPlayAgain: { Task { await viewModel.loadQuestions() } },
                            onMainMenu: { dismiss() }
                        )
                    } else {
                        gamePlayView
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .tabBar) // Full-screen gameplay, no tab bar peeking through
        // Automatically save the session (and update high score) when the round ends
        .onChange(of: viewModel.isGameOver) { isOver in
            if isOver {
                if viewModel.score > highScore { highScore = viewModel.score }
                sessionManager.saveSession(
                    mode: .quizRush,
                    score: viewModel.score,
                    lat: locationService.location?.latitude ?? 0.0,
                    lon: locationService.location?.longitude ?? 0.0
                )
            }
        }
    }
    
    // MARK: - Genre Selection View
    var genreSelectionView: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(spacing: 8) {
                    Image(systemName: "questionmark.bubble.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(LinearGradient(colors: [.green, .teal, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                    Text("Choose a Genre")
                        .font(.title2).bold()
                        .foregroundColor(.white)
                    Text("Pick a topic for this round's 10 questions")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.top, 10)
                .padding(.bottom, 10)
                
                LazyVGrid(columns: gridColumns, spacing: 16) {
                    ForEach(QuizCategory.all) { category in
                        Button {
                            viewModel.selectGenre(category)
                        } label: {
                            VStack(spacing: 10) {
                                Image(systemName: category.icon)
                                    .font(.title)
                                    .foregroundColor(.purple)
                                Text(category.name)
                                    .font(.subheadline).bold()
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                    .lineLimit(2)
                                    .minimumScaleFactor(0.8)
                            }
                            .frame(maxWidth: .infinity, minHeight: 100)
                            .padding(.vertical, 16)
                            .padding(.horizontal, 8)
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(16)
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(.purple.opacity(0.4), lineWidth: 1))
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
        }
    }
    
    // MARK: - GamePlay View
    var gamePlayView: some View {
        VStack(spacing: 25) {
            // Stats Row
            HStack {
                VStack(alignment: .leading) {
                    Text("SCORE").font(.caption).foregroundColor(.gray)
                    Text("\(viewModel.score)").font(.title2).bold().foregroundColor(.white)
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("STREAK").font(.caption).foregroundColor(.orange)
                    Text("\(viewModel.streak) 🔥").font(.title2).bold().foregroundColor(.orange)
                }
            }
            .padding(.horizontal)
            
            // Progress Indicator
            VStack(spacing: 6) {
                Text("Question \(viewModel.currentIndex + 1) of 10")
                    .font(.headline)
                    .foregroundColor(.purple)
                Text(viewModel.selectedCategory.name.uppercased())
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white.opacity(0.4))
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(.ultraThinMaterial)
            .cornerRadius(20)
            
            Spacer()
            
            // Question Card
            Text(viewModel.questions[viewModel.currentIndex].text)
                .font(.title2)
                .bold()
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity, minHeight: 150)
                .background(Color.white.opacity(0.05))
                .cornerRadius(20)
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(.white.opacity(0.1), lineWidth: 1))
                .padding(.horizontal)
                .offset(x: viewModel.shakeOffset) // Shake animation modifier
            
            Spacer()
            
            // 4 Answer Buttons
            VStack(spacing: 15) {
                ForEach(viewModel.questions[viewModel.currentIndex].answers, id: \.self) { answer in
                    Button {
                        viewModel.checkAnswer(answer)
                    } label: {
                        Text(answer)
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(buttonColor(for: answer))
                            .foregroundColor(.white)
                            .cornerRadius(15)
                    }
                    .disabled(viewModel.answerFeedback != nil) // Prevent multi-tapping
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 30)
        }
    }
    
    // Logic to highlight buttons during feedback delay
    func buttonColor(for answer: String) -> Color {
        guard let feedback = viewModel.answerFeedback else {
            return Color.white.opacity(0.1) // Default state
        }
        
        let isCorrectAnswer = answer == viewModel.questions[viewModel.currentIndex].correctAnswer
        
        if isCorrectAnswer {
            return .green // Green flash on correct
        } else if !feedback {
            return .red.opacity(0.6) // Red on wrong
        }
        
        return Color.white.opacity(0.1)
    }
}

#Preview {
    NavigationStack {
        QuizRushView()
            .environmentObject(SessionManager())
            .environmentObject(LocationService())
    }
}
