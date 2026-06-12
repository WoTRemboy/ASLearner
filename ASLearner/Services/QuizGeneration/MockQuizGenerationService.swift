import Foundation

struct MockQuizGenerationService: QuizGenerationServiceProtocol {
    func generateQuiz(topic: String, gestures: [GestureModel]) async -> [QuizQuestion] {
        try? await Task.sleep(nanoseconds: 350_000_000)

        let selectedGestures = Array(gestures.prefix(5))

        return selectedGestures.enumerated().map { index, gesture in
            switch index % 3 {
            case 0:
                return translationQuestion(for: gesture, allGestures: gestures)
            case 1:
                return gestureChoiceQuestion(for: gesture, allGestures: gestures)
            default:
                return performQuestion(for: gesture)
            }
        }
    }

    private func translationQuestion(for gesture: GestureModel, allGestures: [GestureModel]) -> QuizQuestion {
        let wrongAnswers = allGestures
            .filter { $0.id != gesture.id }
            .shuffled()
            .prefix(3)
            .map { QuizAnswer(title: $0.russianName, isCorrect: false) }

        let answers = ([QuizAnswer(title: gesture.russianName, isCorrect: true)] + wrongAnswers).shuffled()

        return QuizQuestion(
            type: .chooseTranslation,
            prompt: "Choose the Russian translation for \(gesture.englishName).",
            gesture: gesture.type,
            answers: answers,
            hint: "Think about the everyday context where this sign is used."
        )
    }

    private func gestureChoiceQuestion(for gesture: GestureModel, allGestures: [GestureModel]) -> QuizQuestion {
        let wrongAnswers = allGestures
            .filter { $0.id != gesture.id }
            .shuffled()
            .prefix(3)
            .map { QuizAnswer(title: $0.englishName, isCorrect: false) }

        let answers = ([QuizAnswer(title: gesture.englishName, isCorrect: true)] + wrongAnswers).shuffled()

        return QuizQuestion(
            type: .chooseGesture,
            prompt: "Which gesture matches “\(gesture.russianName)”?",
            gesture: gesture.type,
            answers: answers,
            hint: gesture.executionDescription
        )
    }

    private func performQuestion(for gesture: GestureModel) -> QuizQuestion {
        QuizQuestion(
            type: .performGesture,
            prompt: "Perform \(gesture.englishName) in front of the camera.",
            gesture: gesture.type,
            answers: [
                QuizAnswer(title: "Ready to perform", isCorrect: true)
            ],
            hint: gesture.executionDescription
        )
    }
}

