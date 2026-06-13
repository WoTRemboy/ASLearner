import Foundation

struct MockLocalLLMService: LocalLLMServiceProtocol {
    func generateHint(for gesture: GestureType) async -> String {
        let model = GestureRepository.gesture(for: gesture)
        return "Подсказка: сначала зафиксируйте форму ладони, затем повторите движение медленно. \(model.executionDescription)"
    }

    func generateQuiz(topic: String) async -> String {
        "Локально сгенерирован короткий тест по теме «\(topic)»: перевод, распознавание и практика с камерой."
    }
}
