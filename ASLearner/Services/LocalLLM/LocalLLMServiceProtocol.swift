import Foundation

struct LocalLLMQuizRequest {
    let topic: String
    let quizType: QuizType
    let targetGesture: GestureModel?
    let studyMaterial: QuizStudyMaterial?
    let relatedMistake: QuizMistakeRecord?
    let learnedGestures: [GestureModel]
    let correctAnswer: String
    let wrongAnswers: [String]
}

struct LocalLLMQuizDraft: Codable, Equatable {
    let prompt: String
    let correctAnswer: String?
    let wrongAnswers: [String]?
    let hint: String
}

protocol LocalLLMServiceProtocol {
    func generateHint(for gesture: GestureType) async -> String
    func generateQuiz(topic: String) async -> String
    func generateQuizQuestionDraft(for request: LocalLLMQuizRequest) async -> LocalLLMQuizDraft?
}
