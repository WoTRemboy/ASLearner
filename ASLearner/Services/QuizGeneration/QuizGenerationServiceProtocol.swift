import Foundation

protocol QuizGenerationServiceProtocol {
    func generateQuiz(topic: String, gestures: [GestureModel]) async -> [QuizQuestion]
}

