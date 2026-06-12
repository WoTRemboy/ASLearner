import Foundation

protocol LocalLLMServiceProtocol {
    func generateHint(for gesture: GestureType) async -> String
    func generateQuiz(topic: String) async -> String
}

