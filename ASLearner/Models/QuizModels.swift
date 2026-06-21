import Foundation

enum QuizType: String, CaseIterable, Identifiable {
    case chooseTranslation
    case chooseGesture
    case performGesture
    case theory

    var id: String { rawValue }

    var title: String {
        switch self {
        case .chooseTranslation:
            "Перевод"
        case .chooseGesture:
            "Жест"
        case .performGesture:
            "Камера"
        case .theory:
            "Теория"
        }
    }
}

enum QuizKnowledgeArea: String, Codable, Hashable {
    case gestureMeaning
    case gestureExecution
    case cameraFraming
    case signLanguageBasics

    var title: String {
        switch self {
        case .gestureMeaning:
            "значение жеста"
        case .gestureExecution:
            "выполнение жеста"
        case .cameraFraming:
            "работа с камерой"
        case .signLanguageBasics:
            "основы жестового языка"
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
    let knowledgeArea: QuizKnowledgeArea
    let sourceNodeID: String?

    init(
        id: UUID = UUID(),
        type: QuizType,
        prompt: String,
        gesture: GestureType?,
        answers: [QuizAnswer],
        hint: String,
        knowledgeArea: QuizKnowledgeArea? = nil,
        sourceNodeID: String? = nil
    ) {
        self.id = id
        self.type = type
        self.prompt = prompt
        self.gesture = gesture
        self.answers = answers
        self.hint = hint
        self.knowledgeArea = knowledgeArea ?? QuizQuestion.defaultKnowledgeArea(for: type)
        self.sourceNodeID = sourceNodeID
    }

    var correctAnswer: QuizAnswer? {
        answers.first(where: \.isCorrect)
    }

    private static func defaultKnowledgeArea(for type: QuizType) -> QuizKnowledgeArea {
        switch type {
        case .chooseTranslation:
            .gestureMeaning
        case .chooseGesture, .performGesture:
            .gestureExecution
        case .theory:
            .signLanguageBasics
        }
    }
}

struct QuizStudyMaterial: Identifiable, Hashable {
    let id: String
    let title: String
    let summary: String
    let keyFacts: [String]
    let area: QuizKnowledgeArea
}

struct QuizMistakeRecord: Identifiable, Hashable, Codable {
    let id: UUID
    let gesture: GestureType?
    let knowledgeArea: QuizKnowledgeArea
    var questionPrompt: String
    var selectedAnswerTitle: String
    let correctAnswerTitle: String
    let sourceNodeID: String?
    var attempts: Int
    var lastMistakeDate: Date

    init(
        id: UUID = UUID(),
        gesture: GestureType?,
        knowledgeArea: QuizKnowledgeArea,
        questionPrompt: String,
        selectedAnswerTitle: String,
        correctAnswerTitle: String,
        sourceNodeID: String?,
        attempts: Int = 1,
        lastMistakeDate: Date = .now
    ) {
        self.id = id
        self.gesture = gesture
        self.knowledgeArea = knowledgeArea
        self.questionPrompt = questionPrompt
        self.selectedAnswerTitle = selectedAnswerTitle
        self.correctAnswerTitle = correctAnswerTitle
        self.sourceNodeID = sourceNodeID
        self.attempts = attempts
        self.lastMistakeDate = lastMistakeDate
    }

    var priorityScore: Double {
        Double(attempts) + max(0, 1 - Date().timeIntervalSince(lastMistakeDate) / 86_400)
    }
}

struct QuizGenerationContext {
    let learnedGestures: [GestureModel]
    let studyMaterials: [QuizStudyMaterial]
    let mistakes: [QuizMistakeRecord]
    let completedLearningNodeIDs: Set<String>

    static let empty = QuizGenerationContext(
        learnedGestures: [],
        studyMaterials: [],
        mistakes: [],
        completedLearningNodeIDs: []
    )
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
