import Foundation

struct AppContainer {
    let gestureRecognitionService: GestureRecognitionServiceProtocol
    let quizGenerationService: QuizGenerationServiceProtocol
    let gamificationService: GamificationServiceProtocol
    let localLLMService: LocalLLMServiceProtocol

    static let demo: AppContainer = {
        let runtime: LlamaCppRuntimeProtocol = (try? LlamaCppRuntime(modelName: "Qwen3-0.6B-Q8_0")) ?? UnavailableLlamaCppRuntime()
        let localLLMService = LlamaCppLocalLLMService(runtime: runtime)

        return AppContainer(
            gestureRecognitionService: MediaPipeGestureRecognitionService(),
            quizGenerationService: AdaptiveQuizGenerationService(localLLMService: localLLMService),
            gamificationService: MockGamificationService(),
            localLLMService: localLLMService
        )
    }()
}
