import Foundation

struct AppContainer {
    let gestureRecognitionService: GestureRecognitionServiceProtocol
    let quizGenerationService: QuizGenerationServiceProtocol
    let gamificationService: GamificationServiceProtocol
    let localLLMService: LocalLLMServiceProtocol

    static let demo = AppContainer(
        gestureRecognitionService: MediaPipeGestureRecognitionService(),
        quizGenerationService: MockQuizGenerationService(),
        gamificationService: MockGamificationService(),
        localLLMService: MockLocalLLMService()
    )
}
