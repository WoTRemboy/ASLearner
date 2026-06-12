import Foundation

struct UserProgressModel: Equatable {
    var xp: Int
    var level: Int
    var streak: Int
    var completedLessonIDs: Set<String>
    var recognizedGestures: Set<GestureType>
    var quizScores: [QuizScore]
    var unlockedAchievementIDs: Set<String>

    static let demo = UserProgressModel(
        xp: 80,
        level: 1,
        streak: 3,
        completedLessonIDs: ["basics-hello"],
        recognizedGestures: [.hello],
        quizScores: [
            QuizScore(date: .now.addingTimeInterval(-86_400), correctAnswers: 3, totalQuestions: 5)
        ],
        unlockedAchievementIDs: ["first-lesson"]
    )

    var levelProgress: Double {
        Double(xp % 100) / 100
    }

    var nextLevelXP: Int {
        ((level - 1) * 100) + 100
    }
}

struct AchievementModel: Identifiable, Hashable {
    let id: String
    let title: String
    let description: String
    let symbolName: String
    var isUnlocked: Bool
}

struct GamificationUpdate {
    let updatedProgress: UserProgressModel
    let gainedXP: Int
    let didLevelUp: Bool
    let unlockedAchievements: [AchievementModel]
    let message: String
}

struct LessonModel: Identifiable, Hashable {
    let id: String
    let title: String
    let subtitle: String
    let gestureTypes: [GestureType]
    let estimatedMinutes: Int
    let accentSymbolName: String
}

