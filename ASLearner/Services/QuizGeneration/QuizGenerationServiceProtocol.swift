import Foundation

protocol QuizGenerationServiceProtocol {
    func generateQuiz(topic: String, gestures: [GestureModel], context: QuizGenerationContext) async -> [QuizQuestion]
}

extension QuizGenerationServiceProtocol {
    func generateQuiz(topic: String, gestures: [GestureModel]) async -> [QuizQuestion] {
        await generateQuiz(topic: topic, gestures: gestures, context: .empty)
    }
}
