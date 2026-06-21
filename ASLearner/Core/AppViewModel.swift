import Foundation
import Combine

final class AppViewModel: ObservableObject {
    let container: AppContainer
    let gestures: [GestureModel]
    let lessons: [LessonModel]

    @Published var hasCompletedOnboarding: Bool {
        didSet {
            UserDefaults.standard.set(hasCompletedOnboarding, forKey: Texts.UserDefaults.skipOnboarding)
        }
    }
    @Published var progress: UserProgressModel
    @Published var latestUpdate: GamificationUpdate?

    init(container: AppContainer = .demo) {
        self.container = container
        self.gestures = GestureRepository.gestures
        self.lessons = GestureRepository.lessons
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: Texts.UserDefaults.skipOnboarding)
        self.progress = .demo
        self.progress.quizMistakes = Self.loadPersistedQuizMistakes()
    }

    var achievements: [AchievementModel] {
        container.gamificationService.allAchievements(progress: progress)
    }

    var completedLessonRatio: Double {
        guard !lessons.isEmpty else { return 0 }
        return Double(progress.completedLessonIDs.count) / Double(lessons.count)
    }

    var averageQuizScore: Double {
        guard !progress.quizScores.isEmpty else { return 0 }
        let total = progress.quizScores.map(\.percentage).reduce(0, +)
        return total / Double(progress.quizScores.count)
    }

    var quizGenerationContext: QuizGenerationContext {
        let completedNodes = LocalLearningFlowService.defaultModules
            .flatMap(\.nodes)
            .filter { progress.completedLearningNodeIDs.contains($0.id) }
        let learnedGestureTypes = Set(
            completedNodes.compactMap(\.gestureId) + Array(progress.recognizedGestures)
        )
        let learnedGestures = gestures.filter { learnedGestureTypes.contains($0.type) }
        let studyMaterials = completedNodes
            .filter { $0.type == .theoreticalLesson }
            .map(Self.studyMaterial(for:))

        return QuizGenerationContext(
            learnedGestures: learnedGestures,
            studyMaterials: studyMaterials,
            mistakes: progress.quizMistakes,
            completedLearningNodeIDs: progress.completedLearningNodeIDs
        )
    }

    func completeOnboarding() {
        hasCompletedOnboarding = true
    }

    func gesture(for type: GestureType) -> GestureModel {
        GestureRepository.gesture(for: type)
    }

    @discardableResult
    func applyGestureAward(for gesture: GestureType, lessonID: String?) -> GamificationUpdate {
        let update = container.gamificationService.awardCorrectGesture(gesture, progress: progress, lessonID: lessonID)
        progress = update.updatedProgress
        latestUpdate = update
        presentAchievementToasts(from: update)
        return update
    }

    @discardableResult
    func applyQuizAward(correctAnswers: Int, totalQuestions: Int) -> GamificationUpdate {
        let update = container.gamificationService.awardQuiz(correctAnswers: correctAnswers, totalQuestions: totalQuestions, progress: progress)
        progress = update.updatedProgress
        latestUpdate = update
        presentAchievementToasts(from: update)
        return update
    }

    func recordQuizAttempt(questions: [QuizQuestion], selectedAnswerIDs: [UUID: UUID]) {
        let mistakes = questions.compactMap { question -> QuizMistakeRecord? in
            let selectedAnswer = selectedAnswerIDs[question.id].flatMap { selectedID in
                question.answers.first { $0.id == selectedID }
            }

            guard selectedAnswer?.isCorrect != true else { return nil }

            return QuizMistakeRecord(
                gesture: question.gesture,
                knowledgeArea: question.knowledgeArea,
                questionPrompt: question.prompt,
                selectedAnswerTitle: selectedAnswer?.title ?? "Нет ответа",
                correctAnswerTitle: question.correctAnswer?.title ?? "Верный ответ не найден",
                sourceNodeID: question.sourceNodeID
            )
        }

        mergeQuizMistakes(mistakes)
    }

    func recordQuizAttempt(questions: [QuizQuestion], selectedAnswers: [UUID: QuizAnswer]) {
        let answerIDs = selectedAnswers.mapValues(\.id)
        recordQuizAttempt(questions: questions, selectedAnswerIDs: answerIDs)
    }

    @discardableResult
    func applyLearningNodeAward(_ node: LearningNode) -> GamificationUpdate {
        let update = container.gamificationService.awardLearningNode(node, progress: progress)
        progress = update.updatedProgress
        latestUpdate = update
        presentAchievementToasts(from: update)
        return update
    }

    private func presentAchievementToasts(from update: GamificationUpdate) {
        guard !update.unlockedAchievements.isEmpty else { return }

        for achievement in update.unlockedAchievements {
            AchievementToastCenter.shared.present(achievement: achievement)
        }
    }

    private func mergeQuizMistakes(_ mistakes: [QuizMistakeRecord]) {
        guard !mistakes.isEmpty else { return }

        for mistake in mistakes {
            if let index = progress.quizMistakes.firstIndex(where: { existing in
                existing.gesture == mistake.gesture &&
                existing.knowledgeArea == mistake.knowledgeArea &&
                existing.correctAnswerTitle == mistake.correctAnswerTitle
            }) {
                progress.quizMistakes[index].attempts += 1
                progress.quizMistakes[index].lastMistakeDate = .now
                progress.quizMistakes[index].selectedAnswerTitle = mistake.selectedAnswerTitle
                progress.quizMistakes[index].questionPrompt = mistake.questionPrompt
            } else {
                progress.quizMistakes.append(mistake)
            }
        }

        progress.quizMistakes = Array(
            progress.quizMistakes
                .sorted { $0.priorityScore > $1.priorityScore }
                .prefix(24)
        )
        persistQuizMistakes()
    }

    private func persistQuizMistakes() {
        guard let data = try? JSONEncoder().encode(progress.quizMistakes) else { return }
        UserDefaults.standard.set(data, forKey: Texts.UserDefaults.quizMistakes)
    }

    private static func loadPersistedQuizMistakes() -> [QuizMistakeRecord] {
        guard let data = UserDefaults.standard.data(forKey: Texts.UserDefaults.quizMistakes),
              let mistakes = try? JSONDecoder().decode([QuizMistakeRecord].self, from: data) else {
            return []
        }

        return mistakes
    }

    nonisolated private static func studyMaterial(for node: LearningNode) -> QuizStudyMaterial {
        if node.id.contains("camera") {
            return QuizStudyMaterial(
                id: node.id,
                title: node.title,
                summary: "Перед распознаванием руки должны быть в кадре, фон спокойный, освещение ровное, движения плавные.",
                keyFacts: [
                    "Держите руки в области камеры",
                    "Используйте ровное освещение спереди",
                    "Выполняйте жест плавно и без резких движений"
                ],
                area: .cameraFraming
            )
        }

        return QuizStudyMaterial(
            id: node.id,
            title: node.title,
            summary: "Жестовый язык передаёт смысл через руки, мимику и положение тела. Контекст помогает запоминать перевод.",
            keyFacts: [
                "Смысл передаётся руками, мимикой и положением тела",
                "Контекст помогает запомнить жест",
                "Практика сразу после теории закрепляет движение"
            ],
            area: .signLanguageBasics
        )
    }
}
