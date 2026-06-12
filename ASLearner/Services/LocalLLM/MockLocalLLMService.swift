import Foundation

struct MockLocalLLMService: LocalLLMServiceProtocol {
    func generateHint(for gesture: GestureType) async -> String {
        let model = GestureRepository.gesture(for: gesture)
        return "Local hint: focus on the hand shape first, then repeat the motion slowly. \(model.executionDescription)"
    }

    func generateQuiz(topic: String) async -> String {
        "Generated locally: a short adaptive quiz about \(topic) with translation, recognition, and camera practice tasks."
    }
}

