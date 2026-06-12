import SwiftUI

struct LearningNodeDestinationView: View {
    let node: LearningNode
    let onComplete: () -> Void

    var body: some View {
        switch node.type {
        case .theoreticalLesson:
            LearningTheoryView(node: node, onComplete: onComplete)
        case .gesturePractice:
            LearningGesturePracticeView(node: node, onComplete: onComplete)
        case .quiz:
            LearningQuizStepView(node: node, onComplete: onComplete)
        case .checkpoint:
            LearningCheckpointView(node: node, onComplete: onComplete)
        }
    }
}
