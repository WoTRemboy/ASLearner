import Foundation

protocol GamificationServiceProtocol {
    func allAchievements(progress: UserProgressModel) -> [AchievementModel]
    func awardCorrectGesture(_ gesture: GestureType, progress: UserProgressModel, lessonID: String?) -> GamificationUpdate
    func awardQuiz(correctAnswers: Int, totalQuestions: Int, progress: UserProgressModel) -> GamificationUpdate
}

