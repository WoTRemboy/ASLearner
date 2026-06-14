import Foundation
import SwiftUI
import Combine

enum LearningQuizPage: Identifiable, Equatable {
    case theory(LearningQuizTheoryCard)
    case practice
    case question(QuizQuestion)
    case result

    var id: String {
        switch self {
        case .theory(let card):
            "theory-\(card.id)"
        case .practice:
            "practice"
        case .question(let question):
            "question-\(question.id.uuidString)"
        case .result:
            "result"
        }
    }
}

struct LearningQuizTheoryCard: Identifiable, Equatable {
    let id: String
    let symbolName: String
    let title: String
    let text: String
    let notes: [String]
}

@MainActor
final class LearningQuizSessionViewModel: ObservableObject {
    let node: LearningNode
    let theoryCards: [LearningQuizTheoryCard]

    @Published var currentPageIndex = 0
    @Published var questions: [QuizQuestion] = []
    @Published var isGeneratingQuestions = true
    @Published var generationProgress = 0.0
    @Published var currentGenerationStep = 0
    @Published var selectedAnswers: [UUID: QuizAnswer] = [:]
    @Published var didPractice = false
    @Published var elapsedSeconds = 0
    @Published var resultPercentCounter = 0
    @Published var isShowingResultContent = false

    private var elapsedTask: Task<Void, Never>?
    private var resultCounterTask: Task<Void, Never>?

    init(node: LearningNode) {
        self.node = node
        self.theoryCards = LearningQuizSessionViewModel.makeTheoryCards(for: node)
    }

    deinit {
        elapsedTask?.cancel()
        resultCounterTask?.cancel()
    }

    var pages: [LearningQuizPage] {
        guard !isGeneratingQuestions else {
            return []
        }

        let questionPages = questions.map { LearningQuizPage.question($0) }
        return questionPages + [.practice, .result]
    }

    var currentPage: LearningQuizPage {
        guard !pages.isEmpty else { return .result }
        return pages[min(currentPageIndex, pages.count - 1)]
    }

    var isResultPage: Bool {
        currentPage == .result
    }

    var progress: Double {
        guard pages.count > 1 else { return 1 }
        return Double(currentPageIndex) / Double(pages.count - 1)
    }

    var quizScore: Int {
        selectedAnswers.values.filter(\.isCorrect).count * 10
    }

    var correctAnswersCount: Int {
        selectedAnswers.values.filter(\.isCorrect).count
    }

    var resultPercent: Int {
        guard !questions.isEmpty else { return 0 }
        return Int((Double(correctAnswersCount) / Double(questions.count)) * 100)
    }

    var timeString: String {
        formattedTime(elapsedSeconds)
    }

    var canMoveForward: Bool {
        switch currentPage {
        case .theory:
            true
        case .practice:
            didPractice
        case .question(let question):
            selectedAnswers[question.id] != nil
        case .result:
            true
        }
    }

    func generateQuestions(
        service: QuizGenerationServiceProtocol,
        gestures: [GestureModel],
        context: QuizGenerationContext
    ) async {
        guard questions.isEmpty else { return }

        await updateGenerationProgress(step: 0, progress: 0.16)
        await updateGenerationProgress(step: 1, progress: 0.34)
        await updateGenerationProgress(step: 2, progress: 0.58)

        let generatedQuestions = await service.generateQuiz(
            topic: node.title,
            gestures: gestures,
            context: quizContext(from: context)
        )

        await updateGenerationProgress(step: 3, progress: 0.92)

        withAnimation(.spring(response: 0.42, dampingFraction: 0.86)) {
            questions = generatedQuestions
            generationProgress = 1
            currentGenerationStep = 3
            isGeneratingQuestions = false
        }
    }

    func startTimer() {
        guard elapsedTask == nil else { return }
        elapsedTask = Task { @MainActor [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                guard !Task.isCancelled else { return }
                self?.elapsedSeconds += 1
            }
        }
    }

    func stopTimer() {
        elapsedTask?.cancel()
        elapsedTask = nil
    }

    func simulatePractice() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
            didPractice = true
        }
    }

    func select(_ answer: QuizAnswer, for question: QuizQuestion) {
        guard selectedAnswers[question.id] == nil else { return }
        withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
            selectedAnswers[question.id] = answer
        }
    }

    func answerTint(_ answer: QuizAnswer, for question: QuizQuestion) -> Color {
        guard let selectedAnswer = selectedAnswers[question.id] else { return .clear }
        guard selectedAnswer.id == answer.id || answer.isCorrect else {
            return Color.gray.opacity(0.18)
        }
        return answer.isCorrect ? LiquidGlassTheme.success.opacity(0.28) : Color.red.opacity(0.28)
    }

    func showExplanation(for answer: QuizAnswer, question: QuizQuestion) -> Bool {
        selectedAnswers[question.id] != nil && answer.isCorrect
    }

    func moveForward() {
        guard canMoveForward, currentPageIndex < pages.count - 1 else { return }
        withAnimation(.spring(response: 0.42, dampingFraction: 0.86)) {
            currentPageIndex += 1
        }

        if isResultPage {
            stopTimer()
            startResultCounter()
        }
    }

    func startResultCounter() {
        resultCounterTask?.cancel()
        resultPercentCounter = 0
        isShowingResultContent = false

        resultCounterTask = Task { @MainActor [weak self] in
            try? await Task.sleep(nanoseconds: 350_000_000)

            while !Task.isCancelled {
                guard let self else { return }

                if self.resultPercentCounter < self.resultPercent {
                    withAnimation(.linear(duration: 0.006)) {
                        self.resultPercentCounter += 1
                    }
                    try? await Task.sleep(nanoseconds: 6_000_000)
                } else {
                    self.resultCounterTask = nil
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                        self.isShowingResultContent = true
                    }
                    return
                }
            }
        }
    }

    private func formattedTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let seconds = seconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    @MainActor
    private func updateGenerationProgress(step: Int, progress: Double) async {
        withAnimation(.spring(response: 0.42, dampingFraction: 0.84)) {
            currentGenerationStep = step
            generationProgress = progress
        }

        try? await Task.sleep(nanoseconds: 240_000_000)
    }

    private func quizContext(from baseContext: QuizGenerationContext) -> QuizGenerationContext {
        if let gestureType = node.gestureId {
            let gesture = GestureRepository.gesture(for: gestureType)
            let relatedMistakes = baseContext.mistakes.filter { $0.gesture == gestureType }
            let gestureMaterial = QuizStudyMaterial(
                id: "\(node.id)-gesture-material",
                title: "Жест «\(gesture.russianName)»",
                summary: "Жест «\(gesture.russianName)» нужно выполнять спокойно и держать руку в кадре, чтобы камера уверенно считала движение.",
                keyFacts: [
                    gesture.executionDescription,
                    "Жест «\(gesture.russianName)» используется для значения «\(gesture.russianName)».",
                    "Во время проверки рука должна оставаться в зоне камеры."
                ],
                area: .gestureExecution
            )

            return QuizGenerationContext(
                learnedGestures: [gesture],
                studyMaterials: [gestureMaterial],
                mistakes: relatedMistakes,
                completedLearningNodeIDs: baseContext.completedLearningNodeIDs.union([node.id])
            )
        }

        return baseContext
    }

    private static func makeTheoryCards(for node: LearningNode) -> [LearningQuizTheoryCard] {
        let gesture = node.gestureId.map { GestureRepository.gesture(for: $0) }
        let title = gesture?.englishName ?? "первые жесты"

        return [
            LearningQuizTheoryCard(
                id: "meaning",
                symbolName: gesture?.symbolName ?? "hand.raised.fill",
                title: "Перед тестом",
                text: "Повторите значение и движение, затем ответьте на короткую проверку. Сначала можно попробовать жест перед камерой.",
                notes: [
                    "Тема: \(title)",
                    "Следите за ладонью",
                    "Руки в кадре",
                    "Ответ после практики"
                ]
            )
        ]
    }

}
