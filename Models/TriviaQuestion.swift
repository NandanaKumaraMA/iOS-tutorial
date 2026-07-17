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

// MARK: - Genre / Category
// Maps to Open Trivia DB's category IDs (https://opentdb.com/api_category.php).
// `id == nil` means "Any Category" — the category param is simply omitted from the request.
struct QuizCategory: Identifiable, Hashable {
    let id: Int?
    let name: String
    let icon: String
    
    static let any = QuizCategory(id: nil, name: "Any Category", icon: "sparkles")
    
    // A curated subset of the full ~32 Open Trivia DB categories, chosen to
    // cover a good spread without overwhelming the picker UI.
    static let all: [QuizCategory] = [
        .any,
        QuizCategory(id: 9,  name: "General Knowledge", icon: "brain.head.profile"),
        QuizCategory(id: 11, name: "Film",               icon: "film"),
        QuizCategory(id: 12, name: "Music",              icon: "music.note"),
        QuizCategory(id: 15, name: "Video Games",        icon: "gamecontroller"),
        QuizCategory(id: 17, name: "Science & Nature",   icon: "leaf"),
        QuizCategory(id: 21, name: "Sports",             icon: "sportscourt"),
        QuizCategory(id: 22, name: "Geography",          icon: "globe"),
        QuizCategory(id: 23, name: "History",            icon: "clock.arrow.circlepath"),
        QuizCategory(id: 27, name: "Animals",            icon: "pawprint")
    ]
}
