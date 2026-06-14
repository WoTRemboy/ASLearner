import Foundation

struct MockLocalLLMService: LocalLLMServiceProtocol {
    func generateHint(for gesture: GestureType) async -> String {
        let model = GestureRepository.gesture(for: gesture)
        return "Подсказка: сначала зафиксируйте форму ладони, затем повторите движение медленно. \(model.executionDescription)"
    }

    func generateQuiz(topic: String) async -> String {
        "Локально сгенерирован короткий тест по теме «\(topic)»: перевод, распознавание и практика с камерой."
    }

    func generateQuizQuestionDraft(for request: LocalLLMQuizRequest) async -> LocalLLMQuizDraft? {
        LocalLLMQuizDraft(
            prompt: fallbackPrompt(for: request),
            correctAnswer: request.correctAnswer,
            wrongAnswers: Array(request.wrongAnswers.prefix(3)),
            hint: request.targetGesture?.executionDescription ?? request.studyMaterial?.summary ?? "Вспомните материал из уже пройденных шагов."
        )
    }

    private func fallbackPrompt(for request: LocalLLMQuizRequest) -> String {
        if let gesture = request.targetGesture {
            switch request.quizType {
            case .chooseTranslation:
                return "Какая ситуация лучше всего подходит для жеста «\(gesture.russianName)»?"
            case .chooseGesture:
                return "Как нужно выполнить жест «\(gesture.russianName)», чтобы камера считала его уверенно?"
            case .performGesture:
                return "Покажите жест «\(gesture.russianName)» перед камерой."
            case .theory:
                return "Что важно учитывать при распознавании жеста «\(gesture.russianName)»?"
            }
        }

        return "Какое утверждение верно по теме «\(request.studyMaterial?.title ?? request.topic)»?"
    }
}
