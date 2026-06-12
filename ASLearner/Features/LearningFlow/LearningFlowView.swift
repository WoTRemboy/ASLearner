import SwiftUI

struct LearningFlowView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @StateObject private var viewModel = LearningFlowViewModel()

    var body: some View {
        ZStack {
            LiquidGlassBackground()

            ScrollView {
                VStack(spacing: 24) {
                    if let module = viewModel.module {
                        ModuleHeaderCard(module: module, progress: viewModel.moduleProgress)
                            .padding(.horizontal, 20)
                    }

                    LearningPathView(
                        nodes: viewModel.nodes,
                        currentNodeID: viewModel.currentAvailableNodeID
                    ) { node in
                        viewModel.select(node)
                    }
                    .padding(.horizontal, 10)
                }
                .padding(.top, 8)
                .padding(.bottom, 32)
            }
        }
        .navigationTitle(Texts.LearningFlowPage.title)
        .navigationBarTitleDisplayMode(.large)
        .navigationDestination(item: $viewModel.selectedNode) { node in
            LearningNodeDestinationView(node: node) {
                if let completedNode = viewModel.complete(node) {
                    appViewModel.applyLearningNodeAward(completedNode)
                }
            }
        }
    }
}

private struct LearningPathView: View {
    let nodes: [LearningNode]
    let currentNodeID: String?
    let onSelect: (LearningNode) -> Void

    var body: some View {
        ZStack {
            LearningPathLine()
                .padding(.vertical, 52)

            VStack(spacing: 16) {
                ForEach(Array(nodes.enumerated()), id: \.element.id) { index, node in
                    LearningNodeRow(
                        node: node,
                        isLeftAligned: index.isMultiple(of: 2),
                        isCurrent: currentNodeID == node.id
                    ) {
                        onSelect(node)
                    }
                }
            }
        }
    }
}

private struct LearningNodeRow: View {
    let node: LearningNode
    let isLeftAligned: Bool
    let isCurrent: Bool
    let onSelect: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            if isLeftAligned {
                nodeCluster
                    .frame(maxWidth: .infinity, alignment: .trailing)
                Spacer()
                    .frame(width: 42)
                Color.clear
                    .frame(maxWidth: .infinity)
            } else {
                Color.clear
                    .frame(maxWidth: .infinity)
                Spacer()
                    .frame(width: 42)
                nodeCluster
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .frame(minHeight: 118)
    }

    private var nodeCluster: some View {
        VStack(spacing: 10) {
            LearningNodeCircle(node: node, isCurrent: isCurrent, action: onSelect)
            LearningNodeLabel(node: node)
        }
    }
}
