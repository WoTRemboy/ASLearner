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
    let questions: [QuizQuestion]

    @Published var currentPageIndex = 0
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
        self.questions = LearningQuizSessionViewModel.makeQuestions(for: node)
    }

    deinit {
        elapsedTask?.cancel()
        resultCounterTask?.cancel()
    }

    var pages: [LearningQuizPage] {
        theoryCards.map { .theory($0) } + [.practice] + questions.map { .question($0) } + [.result]
    }

    var currentPage: LearningQuizPage {
        pages[min(currentPageIndex, pages.count - 1)]
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

    private static func makeQuestions(for node: LearningNode) -> [QuizQuestion] {
        if let gestureType = node.gestureId {
            let gesture = GestureRepository.gesture(for: gestureType)
            let wrongTranslationAnswers = GestureRepository.gestures
                .filter { $0.type != gesture.type }
                .shuffled()
                .prefix(3)
                .map { QuizAnswer(title: $0.russianName, isCorrect: false) }
            let wrongGestureAnswers = GestureRepository.gestures
                .filter { $0.type != gesture.type }
                .shuffled()
                .prefix(3)
                .map { QuizAnswer(title: $0.englishName, isCorrect: false) }

            return [
                QuizQuestion(
                    type: .chooseTranslation,
                    prompt: "Выберите значение жеста «\(gesture.englishName)».",
                    gesture: gesture.type,
                    answers: ([QuizAnswer(title: gesture.russianName, isCorrect: true)] + wrongTranslationAnswers).shuffled(),
                    hint: gesture.executionDescription
                ),
                QuizQuestion(
                    type: .chooseGesture,
                    prompt: "Какой жест вы только что тренировали?",
                    gesture: gesture.type,
                    answers: ([QuizAnswer(title: gesture.englishName, isCorrect: true)] + wrongGestureAnswers).shuffled(),
                    hint: "Вспомните жест со страницы практики."
                )
            ]
        }

        return [
            QuizQuestion(
                type: .chooseGesture,
                prompt: "Какой набор относится к первому модулю?",
                gesture: nil,
                answers: [
                    QuizAnswer(title: "Да, нет, привет, спасибо", isCorrect: true),
                    QuizAnswer(title: "Помощь, плохо, учиться, пожалуйста", isCorrect: false),
                    QuizAnswer(title: "Хорошо, плохо, я люблю тебя, учиться", isCorrect: false),
                    QuizAnswer(title: "Пожалуйста, помощь, хорошо, плохо", isCorrect: false)
                ],
                hint: "Вспомните жесты из текущего маршрута."
            ),
            QuizQuestion(
                type: .chooseTranslation,
                prompt: "Зачем нужна страница практики?",
                gesture: nil,
                answers: [
                    QuizAnswer(title: "Попробовать жест перед ответом", isCorrect: true),
                    QuizAnswer(title: "Полностью пропустить распознавание", isCorrect: false),
                    QuizAnswer(title: "Открыть настройки профиля", isCorrect: false),
                    QuizAnswer(title: "Сбросить прогресс курса", isCorrect: false)
                ],
                hint: "Маршрут чередует короткую теорию и действие."
            )
        ]
    }
}
