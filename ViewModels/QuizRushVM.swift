
import SwiftUI
import Combine

// MARK: - ViewModel
enum ViewState {
    case loading, loaded, failed
}

@MainActor
class QuizRushViewModel: ObservableObject {
    @Published var state: ViewState = .loading
    @Published var questions: [QuizQuestion] = []
    @Published var currentIndex = 0
    @Published var score = 0
    @Published var streak = 0
    @Published var isGameOver = false
    
    // Polish states
    @Published var answerFeedback: Bool? = nil // true = correct, false = wrong
    @Published var shakeOffset: CGFloat = 0
    
    // Use async/await and URLSession to pull questions
    func loadQuestions() async {
        state = .loading
        do {
            // UPDATED URL: Using Base64 encoding to avoid HTML formatting bugs
            let url = URL(string: "https://opentdb.com/api.php?amount=10&type=multiple&encode=base64")!
            let (data, _) = try await URLSession.shared.data(from: url)
            
            let decodedResponse = try JSONDecoder().decode(TriviaResponse.self, from: data)
            
            // Handle API rate limits (returns 0 questions if requested too fast)
            if decodedResponse.results.isEmpty {
                print("API returned 0 questions. Rate limited.")
                self.state = .failed
                return
            }
            
            self.questions = decodedResponse.results.map { QuizQuestion(from: $0) }
            self.resetGameStats()
            self.state = .loaded
            
        } catch {
            print("❌ Failed to load or decode questions: \(error)")
            self.state = .failed
        }
    }
    
    func resetGameStats() {
        currentIndex = 0
        score = 0
        streak = 0
        isGameOver = false
        answerFeedback = nil
    }
    
    func checkAnswer(_ answer: String) {
        guard currentIndex < questions.count, answerFeedback == nil else { return }
        let isCorrect = answer == questions[currentIndex].correctAnswer
        
        if isCorrect {
            // Correct tap -> score + advance
            // Streak tracked - consecutive correct answers give bonus points
            score += 10 + (streak * 5)
            streak += 1
            answerFeedback = true
            
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        } else {
            // Wrong tap -> small penalty, still advances
            score = max(0, score - 5)
            streak = 0
            answerFeedback = false
            
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
            
            // Red shake on wrong
            withAnimation(.linear(duration: 0.1)) { self.shakeOffset = 10 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.linear(duration: 0.1)) { self.shakeOffset = -10 }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.linear(duration: 0.1)) { self.shakeOffset = 0 }
            }
        }
        
        // Pause briefly to show the green flash/red shake, then advance
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            self.answerFeedback = nil
            if self.currentIndex < self.questions.count - 1 {
                self.currentIndex += 1
            } else {
                self.isGameOver = true
            }
        }
    }
}
