import Foundation

enum LearningNodeType: String, CaseIterable, Hashable {
    case theoreticalLesson
    case gesturePractice
    case quiz
    case checkpoint

    var title: String {
        switch self {
        case .theoreticalLesson:
            "Theory"
        case .gesturePractice:
            "Practice"
        case .quiz:
            "Quiz"
        case .checkpoint:
            "Checkpoint"
        }
    }

    var symbolName: String {
        switch self {
        case .theoreticalLesson:
            "book.pages.fill"
        case .gesturePractice:
            "hand.raised.fill"
        case .quiz:
            "checklist.checked"
        case .checkpoint:
            "flag.checkered"
        }
    }
}

enum LearningNodeStatus: String, Hashable {
    case locked
    case available
    case completed
}

struct LearningNode: Identifiable, Hashable {
    let id: String
    let title: String
    let subtitle: String
    let type: LearningNodeType
    var status: LearningNodeStatus
    let order: Int
    let xpReward: Int
    let gestureId: GestureType?
    let quizId: String?
}

struct LearningModule: Identifiable, Hashable {
    let id: String
    let title: String
    let description: String
    var nodes: [LearningNode]
}

struct LearningSection: Identifiable, Hashable {
    let id: String
    let title: String
    let subtitle: String
    let progress: Double
    let completedCount: Int
    let totalCount: Int
    let isLocked: Bool
    let isComingSoon: Bool
}
