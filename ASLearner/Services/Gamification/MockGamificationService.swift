import Foundation

struct MockGamificationService: GamificationServiceProtocol {
    private let achievementTemplates: [AchievementModel] = [
        AchievementModel(id: "first-lesson", title: "First lesson", description: "Complete the first learning step.", symbolName: "flag.checkered", isUnlocked: false),
        AchievementModel(id: "first-recognition", title: "First recognition", description: "Correctly perform a gesture in camera mode.", symbolName: "camera.viewfinder", isUnlocked: false),
        AchievementModel(id: "five-gestures", title: "Gesture collector", description: "Recognize five unique gestures.", symbolName: "hand.raised.fill", isUnlocked: false),
        AchievementModel(id: "level-two", title: "Level up", description: "Reach level 2 through practice.", symbolName: "arrow.up.circle.fill", isUnlocked: false),
        AchievementModel(id: "quiz-master", title: "Quiz master", description: "Score at least 80% in a generated quiz.", symbolName: "brain.head.profile", isUnlocked: false)
    ]

    func allAchievements(progress: UserProgressModel) -> [AchievementModel] {
        achievementTemplates.map { template in
            var updated = template
            updated.isUnlocked = progress.unlockedAchievementIDs.contains(template.id)
            return updated
        }
    }

    func awardCorrectGesture(_ gesture: GestureType, progress: UserProgressModel, lessonID: String?) -> GamificationUpdate {
        var updatedProgress = progress
        let oldLevel = updatedProgress.level
        let gainedXP = 25

        updatedProgress.xp += gainedXP
        updatedProgress.level = (updatedProgress.xp / 100) + 1
        updatedProgress.recognizedGestures.insert(gesture)

        if let lessonID {
            updatedProgress.completedLessonIDs.insert(lessonID)
        }

        let unlocked = unlockAchievements(for: updatedProgress)
        updatedProgress.unlockedAchievementIDs.formUnion(unlocked.map(\.id))

        return GamificationUpdate(
            updatedProgress: updatedProgress,
            gainedXP: gainedXP,
            didLevelUp: updatedProgress.level > oldLevel,
            unlockedAchievements: unlocked,
            message: "Great work. Gesture accepted and progress updated."
        )
    }

    func awardQuiz(correctAnswers: Int, totalQuestions: Int, progress: UserProgressModel) -> GamificationUpdate {
        var updatedProgress = progress
        let oldLevel = updatedProgress.level
        let gainedXP = max(10, correctAnswers * 12)
        let score = QuizScore(date: .now, correctAnswers: correctAnswers, totalQuestions: totalQuestions)

        updatedProgress.xp += gainedXP
        updatedProgress.level = (updatedProgress.xp / 100) + 1
        updatedProgress.quizScores.append(score)

        let unlocked = unlockAchievements(for: updatedProgress)
        updatedProgress.unlockedAchievementIDs.formUnion(unlocked.map(\.id))

        return GamificationUpdate(
            updatedProgress: updatedProgress,
            gainedXP: gainedXP,
            didLevelUp: updatedProgress.level > oldLevel,
            unlockedAchievements: unlocked,
            message: "Quiz completed with \(correctAnswers)/\(totalQuestions) correct answers."
        )
    }

    func awardLearningNode(_ node: LearningNode, progress: UserProgressModel) -> GamificationUpdate {
        var updatedProgress = progress
        let oldLevel = updatedProgress.level
        let isAlreadyCompleted = updatedProgress.completedLearningNodeIDs.contains(node.id)
        let gainedXP = isAlreadyCompleted ? 0 : node.xpReward

        if !isAlreadyCompleted {
            updatedProgress.xp += gainedXP
            updatedProgress.level = (updatedProgress.xp / 100) + 1
            updatedProgress.completedLearningNodeIDs.insert(node.id)
            updatedProgress.completedLessonIDs.insert(node.id)

            if let gesture = node.gestureId, node.type == .gesturePractice {
                updatedProgress.recognizedGestures.insert(gesture)
            }

            if node.type == .quiz || node.type == .checkpoint {
                updatedProgress.quizScores.append(QuizScore(date: .now, correctAnswers: 1, totalQuestions: 1))
            }
        }

        let unlocked = unlockAchievements(for: updatedProgress)
        updatedProgress.unlockedAchievementIDs.formUnion(unlocked.map(\.id))

        return GamificationUpdate(
            updatedProgress: updatedProgress,
            gainedXP: gainedXP,
            didLevelUp: updatedProgress.level > oldLevel,
            unlockedAchievements: unlocked,
            message: isAlreadyCompleted ? "Step is already completed." : "Learning step completed. Progress updated."
        )
    }

    private func unlockAchievements(for progress: UserProgressModel) -> [AchievementModel] {
        achievementTemplates.compactMap { template in
            guard !progress.unlockedAchievementIDs.contains(template.id) else { return nil }

            let shouldUnlock: Bool
            switch template.id {
            case "first-lesson":
                shouldUnlock = !progress.completedLessonIDs.isEmpty
            case "first-recognition":
                shouldUnlock = !progress.recognizedGestures.isEmpty
            case "five-gestures":
                shouldUnlock = progress.recognizedGestures.count >= 5
            case "level-two":
                shouldUnlock = progress.level >= 2
            case "quiz-master":
                shouldUnlock = progress.quizScores.contains { $0.percentage >= 0.8 }
            default:
                shouldUnlock = false
            }

            guard shouldUnlock else { return nil }
            var unlocked = template
            unlocked.isUnlocked = true
            return unlocked
        }
    }
}
