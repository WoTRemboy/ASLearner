import Combine
import Foundation
import SwiftUI

@MainActor
final class LearningFlowViewModel: ObservableObject {
    @Published private(set) var module: LearningModule?
    @Published private(set) var nodes: [LearningNode] = []
    @Published private(set) var moduleProgress: Double = 0
    @Published var selectedNode: LearningNode?

    private let service: LearningFlowServiceProtocol
    private let moduleID: String

    init(
        service: LearningFlowServiceProtocol? = nil,
        moduleID: String = "basic-gestures"
    ) {
        self.service = service ?? LocalLearningFlowService()
        self.moduleID = moduleID
        loadModule()
    }

    var currentAvailableNodeID: String? {
        service.currentAvailableNode(in: moduleID)?.id
    }

    func loadModule() {
        module = service.modules().first { $0.id == moduleID }
        nodes = service.nodes(in: moduleID)
        moduleProgress = service.progress(for: moduleID)
    }

    func select(_ node: LearningNode) {
        guard node.status != .locked else { return }
        selectedNode = node
    }

    @discardableResult
    func complete(_ node: LearningNode) -> LearningNode? {
        let completedNode = service.markNodeCompleted(node.id, in: moduleID)
        withAnimation(.spring(response: 0.45, dampingFraction: 0.82)) {
            loadModule()
        }
        return completedNode
    }

    func status(for node: LearningNode) -> LearningNodeStatus {
        nodes.first { $0.id == node.id }?.status ?? node.status
    }
}
