import SwiftUI
import Combine

// MARK: - Models
struct TriviaResponse: Codable {
    let response_code: Int? // Added this just to be safe
    let results: [TriviaResult]
}

struct TriviaResult: Codable {
    let question: String
    let correct_answer: String
    let incorrect_answers: [String]
}

// A mapped model specifically for the UI so answers are pre-shuffled
struct QuizQuestion: Identifiable {
    let id = UUID()
    let text: String
    let correctAnswer: String
    let answers: [String]
    
    init(from apiResult: TriviaResult) {
        // Decode the Base64 strings sent by the API
        self.text = apiResult.question.base64Decoded
        self.correctAnswer = apiResult.correct_answer.base64Decoded
        
        var allAnswers = apiResult.incorrect_answers.map { $0.base64Decoded }
        allAnswers.append(self.correctAnswer)
        self.answers = allAnswers.shuffled() // 4 shuffled answer buttons per question
    }
}
