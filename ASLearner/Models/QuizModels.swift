import Foundation

enum QuizType: String, CaseIterable, Identifiable {
    case chooseTranslation
    case chooseGesture
    case performGesture

    var id: String { rawValue }

    var title: String {
        switch self {
        case .chooseTranslation:
            "Translation"
        case .chooseGesture:
            "Gesture"
        case .performGesture:
            "Camera"
        }
    }
}

struct QuizAnswer: Identifiable, Hashable {
    let id: UUID
    let title: String
    let isCorrect: Bool

    init(id: UUID = UUID(), title: String, isCorrect: Bool) {
        self.id = id
        self.title = title
        self.isCorrect = isCorrect
    }
}

struct QuizQuestion: Identifiable, Hashable {
    let id: UUID
    let type: QuizType
    let prompt: String
    let gesture: GestureType?
    let answers: [QuizAnswer]
    let hint: String

    init(id: UUID = UUID(), type: QuizType, prompt: String, gesture: GestureType?, answers: [QuizAnswer], hint: String) {
        self.id = id
        self.type = type
        self.prompt = prompt
        self.gesture = gesture
        self.answers = answers
        self.hint = hint
    }

    var correctAnswer: QuizAnswer? {
        answers.first(where: \.isCorrect)
    }
}

struct QuizScore: Identifiable, Hashable {
    let id = UUID()
    let date: Date
    let correctAnswers: Int
    let totalQuestions: Int

    var percentage: Double {
        guard totalQuestions > 0 else { return 0 }
        return Double(correctAnswers) / Double(totalQuestions)
    }
}

