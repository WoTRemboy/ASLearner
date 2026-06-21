import Foundation

struct MockQuizGenerationService: QuizGenerationServiceProtocol {
    func generateQuiz(topic: String, gestures: [GestureModel], context: QuizGenerationContext) async -> [QuizQuestion] {
        try? await Task.sleep(nanoseconds: 350_000_000)

        let selectedGestures = Array((context.learnedGestures.isEmpty ? gestures : context.learnedGestures).prefix(5))
        guard !selectedGestures.isEmpty else { return [] }

        let targetQuestionCount = max(3, selectedGestures.count)
        return (0..<targetQuestionCount).map { index in
            let gesture = selectedGestures[index % selectedGestures.count]
            return index.isMultiple(of: 2) ? executionQuestion(for: gesture) : usageQuestion(for: gesture)
        }
    }

    private func executionQuestion(for gesture: GestureModel) -> QuizQuestion {
        QuizQuestion(
            type: .chooseGesture,
            prompt: "Как лучше выполнить жест «\(gesture.russianName)»?",
            gesture: gesture.type,
            answers: semanticAnswers(
                correct: gesture.executionDescription,
                wrong: [
                    "Спрятать руку за корпусом и выполнить движение вне кадра.",
                    "Сделать резкий случайный взмах без фиксированной формы ладони.",
                    "Закрыть ладонь второй рукой во время движения."
                ]
            ),
            hint: "Обратите внимание на форму ладони и направление движения.",
            knowledgeArea: .gestureExecution
        )
    }

    private func usageQuestion(for gesture: GestureModel) -> QuizQuestion {
        QuizQuestion(
            type: .chooseTranslation,
            prompt: "Когда уместно использовать жест «\(gesture.russianName)»?",
            gesture: gesture.type,
            answers: semanticAnswers(
                correct: usageAnswer(for: gesture),
                wrong: GestureRepository.gestures
                    .filter { $0.type != gesture.type }
                    .prefix(3)
                    .map(usageAnswer(for:))
            ),
            hint: "Вспомните не название, а коммуникативную задачу жеста.",
            knowledgeArea: .gestureMeaning
        )
    }

    private func semanticAnswers(correct: String, wrong: [String]) -> [QuizAnswer] {
        ([QuizAnswer(title: correct, isCorrect: true)] + wrong.prefix(3).map { QuizAnswer(title: $0, isCorrect: false) }).shuffled()
    }

    private func usageAnswer(for gesture: GestureModel) -> String {
        switch gesture.type {
        case .yes:
            "Чтобы подтвердить согласие или ответить утвердительно."
        case .no:
            "Чтобы вежливо показать отрицательный ответ или отказ."
        case .hello:
            "Чтобы начать общение и поприветствовать собеседника."
        case .thankYou:
            "Чтобы выразить благодарность после помощи или ответа."
        default:
            "Чтобы передать значение «\(gesture.russianName)» в коротком сообщении."
        }
    }
}
