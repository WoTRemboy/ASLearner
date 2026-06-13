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
}
