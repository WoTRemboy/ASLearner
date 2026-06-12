import SwiftUI

struct LearningFlowView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @StateObject private var viewModel = LearningFlowViewModel()
    @Namespace private var namespace

    private let sectionsTransitionID = "learning-sections"

    var body: some View {
        ZStack {
            LiquidGlassBackground()
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.86)) {
                        viewModel.dismissSelectedNode()
                    }
                }

            ScrollView {
                VStack(spacing: 24) {
                    if let module = viewModel.module {
                        ModuleHeaderCard(
                            module: module,
                            transitionID: sectionsTransitionID,
                            namespace: namespace
                        ) {
                            viewModel.showSections()
                        }
                            .padding(.horizontal, 20)
                    }

                    LearningPathView(
                        nodes: viewModel.nodes,
                        currentNodeID: viewModel.currentAvailableNodeID,
                        selectedNodeID: viewModel.selectedNode?.id,
                        namespace: namespace
                    ) { node in
                        withAnimation(.spring(response: 0.42, dampingFraction: 0.84)) {
                            viewModel.select(node)
                        }
                    } onDismiss: {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.86)) {
                            viewModel.dismissSelectedNode()
                        }
                    }
                    .padding(.horizontal, 10)
                }
                .padding(.top, 8)
                .padding(.bottom, viewModel.selectedNode == nil ? 120 : 300)
                .background {
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.86)) {
                                viewModel.dismissSelectedNode()
                            }
                        }
                }
            }
        }
        .navigationTitle(Texts.LearningFlowPage.title)
        .navigationBarTitleDisplayMode(.large)
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 10) {
                if let selectedNode = viewModel.selectedNode {
                    LearningNodeDetailCard(node: selectedNode) {
                        viewModel.startSelectedNodeAfterDetailDismissal()
                    }
                    .background(.clear)
                }

                if viewModel.module != nil {
                    ModuleProgressDock(progress: viewModel.moduleProgress)
                }
            }
            .padding(.bottom, 8)
        }
        .fullScreenCover(item: $viewModel.activeNode) { node in
            LearningNodeFullScreenView(node: node, namespace: namespace) {
                if let completedNode = viewModel.complete(node) {
                    appViewModel.applyLearningNodeAward(completedNode)
                }
            }
        }
        .fullScreenCover(isPresented: $viewModel.isShowingSections) {
            LearningSectionsView(
                sections: viewModel.sections,
                transitionID: sectionsTransitionID,
                namespace: namespace
            )
        }
    }
}

private struct LearningNodeFullScreenView: View {
    @Environment(\.dismiss) private var dismiss

    let node: LearningNode
    let namespace: Namespace.ID
    let onComplete: () -> Void

    var body: some View {
        NavigationStack {
            LearningNodeDestinationView(node: node, onComplete: onComplete)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                        }
                        .accessibilityLabel(Texts.LearningFlowPage.close)
                    }
                }
        }
        .navigationTransition(
            .zoom(sourceID: node.id, in: namespace)
        )
    }
}

private struct LearningPathView: View {
    let nodes: [LearningNode]
    let currentNodeID: String?
    let selectedNodeID: String?
    let namespace: Namespace.ID
    let onSelect: (LearningNode) -> Void
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture(perform: onDismiss)

            LearningPathLine()
                .padding(.vertical, 52)

            VStack(spacing: 16) {
                ForEach(Array(nodes.enumerated()), id: \.element.id) { index, node in
                    LearningNodeRow(
                        node: node,
                        isLeftAligned: index.isMultiple(of: 2),
                        isCurrent: currentNodeID == node.id,
                        isSelected: selectedNodeID == node.id,
                        namespace: namespace
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
    let isSelected: Bool
    let namespace: Namespace.ID
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
        .frame(minHeight: 104)
    }

    private var nodeCluster: some View {
        LearningNodeCircle(
            node: node,
            isCurrent: isCurrent,
            isSelected: isSelected,
            namespace: namespace,
            action: onSelect
        )
    }
}
