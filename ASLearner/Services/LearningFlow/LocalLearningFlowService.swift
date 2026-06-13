import Foundation

final class LocalLearningFlowService: LearningFlowServiceProtocol {
    private var storedModules: [LearningModule]

    init(modules: [LearningModule] = LocalLearningFlowService.defaultModules) {
        self.storedModules = modules
    }

    func modules() -> [LearningModule] {
        storedModules
    }

    func nodes(in moduleID: String) -> [LearningNode] {
        module(for: moduleID)?.nodes.sorted { $0.order < $1.order } ?? []
    }

    func currentAvailableNode(in moduleID: String) -> LearningNode? {
        nodes(in: moduleID)
            .first { $0.status == .available }
    }

    @discardableResult
    func markNodeCompleted(_ nodeID: String, in moduleID: String) -> LearningNode? {
        guard let moduleIndex = storedModules.firstIndex(where: { $0.id == moduleID }),
              let nodeIndex = storedModules[moduleIndex].nodes.firstIndex(where: { $0.id == nodeID }) else {
            return nil
        }

        guard storedModules[moduleIndex].nodes[nodeIndex].status != .locked else {
            return nil
        }

        storedModules[moduleIndex].nodes[nodeIndex].status = .completed
        unlockNextNode(after: nodeIndex, in: moduleIndex)

        return storedModules[moduleIndex].nodes[nodeIndex]
    }

    func progress(for moduleID: String) -> Double {
        let moduleNodes = nodes(in: moduleID)
        guard !moduleNodes.isEmpty else { return 0 }

        let completedCount = moduleNodes.filter { $0.status == .completed }.count
        return Double(completedCount) / Double(moduleNodes.count)
    }

    private func module(for moduleID: String) -> LearningModule? {
        storedModules.first { $0.id == moduleID }
    }

    private func unlockNextNode(after nodeIndex: Int, in moduleIndex: Int) {
        let nextIndex = nodeIndex + 1
        guard storedModules[moduleIndex].nodes.indices.contains(nextIndex),
              storedModules[moduleIndex].nodes[nextIndex].status == .locked else {
            return
        }

        storedModules[moduleIndex].nodes[nextIndex].status = .available
    }
}

extension LocalLearningFlowService {
    static let defaultModules: [LearningModule] = [
        LearningModule(
            id: "basic-gestures",
            title: "Базовые жесты",
            description: "Первые слова и простые жесты для начала общения",
            nodes: [
                LearningNode(
                    id: "basic-01-theory-sign-language",
                    title: "Что такое жестовый язык",
                    subtitle: "Короткое введение в визуальное общение",
                    type: .theoreticalLesson,
                    status: .available,
                    order: 1,
                    xpReward: 10,
                    gestureId: nil,
                    quizId: nil
                ),
                LearningNode(
                    id: "basic-02-practice-hello",
                    title: "Жест Hello",
                    subtitle: "Покажи приветствие перед камерой",
                    type: .gesturePractice,
                    status: .locked,
                    order: 2,
                    xpReward: 25,
                    gestureId: .hello,
                    quizId: nil
                ),
                LearningNode(
                    id: "basic-03-quiz-hello",
                    title: "Проверь: Hello",
                    subtitle: "Закрепи значение первого жеста",
                    type: .quiz,
                    status: .locked,
                    order: 3,
                    xpReward: 15,
                    gestureId: .hello,
                    quizId: "quiz-hello"
                ),
                LearningNode(
                    id: "basic-04-theory-camera",
                    title: "Как правильно держать руки в кадре",
                    subtitle: "Поза, свет и границы кадра",
                    type: .theoreticalLesson,
                    status: .locked,
                    order: 4,
                    xpReward: 10,
                    gestureId: nil,
                    quizId: nil
                ),
                LearningNode(
                    id: "basic-05-practice-thank-you",
                    title: "Жест Thank you",
                    subtitle: "Отработай благодарность",
                    type: .gesturePractice,
                    status: .locked,
                    order: 5,
                    xpReward: 25,
                    gestureId: .thankYou,
                    quizId: nil
                ),
                LearningNode(
                    id: "basic-06-quiz-thank-you",
                    title: "Проверь: Thank you",
                    subtitle: "Выбери правильный перевод",
                    type: .quiz,
                    status: .locked,
                    order: 6,
                    xpReward: 15,
                    gestureId: .thankYou,
                    quizId: "quiz-thank-you"
                ),
                LearningNode(
                    id: "basic-07-practice-yes",
                    title: "Жест Yes",
                    subtitle: "Подтверждение в диалоге",
                    type: .gesturePractice,
                    status: .locked,
                    order: 7,
                    xpReward: 25,
                    gestureId: .yes,
                    quizId: nil
                ),
                LearningNode(
                    id: "basic-08-practice-no",
                    title: "Жест No",
                    subtitle: "Отрицание в диалоге",
                    type: .gesturePractice,
                    status: .locked,
                    order: 8,
                    xpReward: 25,
                    gestureId: .no,
                    quizId: nil
                ),
                LearningNode(
                    id: "basic-09-mini-quiz",
                    title: "Мини-тест: первые жесты",
                    subtitle: "Hello, Thank you, Yes и No",
                    type: .quiz,
                    status: .locked,
                    order: 9,
                    xpReward: 20,
                    gestureId: nil,
                    quizId: "quiz-first-gestures"
                ),
                LearningNode(
                    id: "basic-10-checkpoint",
                    title: "Итог модуля",
                    subtitle: "Финальная проверка базовых жестов",
                    type: .checkpoint,
                    status: .locked,
                    order: 10,
                    xpReward: 40,
                    gestureId: nil,
                    quizId: "checkpoint-basic-gestures"
                )
            ]
        )
    ]
}
