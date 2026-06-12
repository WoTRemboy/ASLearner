import Combine
import Foundation
import SwiftUI

@MainActor
final class LearningFlowViewModel: ObservableObject {
    @Published private(set) var module: LearningModule?
    @Published private(set) var nodes: [LearningNode] = []
    @Published private(set) var moduleProgress: Double = 0
    @Published var selectedNode: LearningNode?
    @Published var activeNode: LearningNode?
    @Published var isShowingSections = false

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

    var sections: [LearningSection] {
        [
            LearningSection(
                id: "section-1",
                title: "Section 1",
                subtitle: "Базовые жесты",
                progress: moduleProgress,
                completedCount: nodes.filter { $0.status == .completed }.count,
                totalCount: nodes.count,
                isLocked: false,
                isComingSoon: false
            ),
            LearningSection(
                id: "section-2",
                title: "Section 2",
                subtitle: "Диалоги и вежливость",
                progress: 0,
                completedCount: 0,
                totalCount: 12,
                isLocked: true,
                isComingSoon: false
            ),
            LearningSection(
                id: "section-3",
                title: "Section 3",
                subtitle: "Помощь и бытовые фразы",
                progress: 0,
                completedCount: 0,
                totalCount: 14,
                isLocked: true,
                isComingSoon: false
            ),
            LearningSection(
                id: "section-4",
                title: "Section 4",
                subtitle: "Эмоции и оценка",
                progress: 0,
                completedCount: 0,
                totalCount: 10,
                isLocked: true,
                isComingSoon: false
            ),
            LearningSection(
                id: "section-5",
                title: "Section 5",
                subtitle: "Coming soon...",
                progress: 0,
                completedCount: 0,
                totalCount: 0,
                isLocked: false,
                isComingSoon: true
            )
        ]
    }

    func loadModule() {
        module = service.modules().first { $0.id == moduleID }
        nodes = service.nodes(in: moduleID)
        moduleProgress = service.progress(for: moduleID)
    }

    func select(_ node: LearningNode) {
        selectedNode = node
    }

    func dismissSelectedNode() {
        selectedNode = nil
    }

    func showSections() {
        dismissSelectedNode()
        isShowingSections = true
    }

    func startSelectedNode() {
        guard let selectedNode, selectedNode.status != .locked else { return }
        activeNode = selectedNode
        dismissSelectedNode()
    }

    func startSelectedNodeAfterDetailDismissal() {
        guard let node = selectedNode, node.status != .locked else { return }

        withAnimation(.spring(response: 0.34, dampingFraction: 0.9)) {
            selectedNode = nil
        }

        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 180_000_000)
            activeNode = node
        }
    }

    @discardableResult
    func complete(_ node: LearningNode) -> LearningNode? {
        let completedNode = service.markNodeCompleted(node.id, in: moduleID)
        withAnimation(.spring(response: 0.45, dampingFraction: 0.82)) {
            loadModule()
        }

        selectedNode = nil
        return completedNode
    }

    func status(for node: LearningNode) -> LearningNodeStatus {
        nodes.first { $0.id == node.id }?.status ?? node.status
    }
}
