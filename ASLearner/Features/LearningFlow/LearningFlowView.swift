import SwiftUI

struct LearningFlowView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @StateObject private var viewModel = LearningFlowViewModel()
    @Namespace private var namespace
    @State private var shouldShowCurrentLessonButton = false

    private let sectionsTransitionID = "learning-sections"

    var body: some View {
        ScrollViewReader { proxy in
            ZStack {
                LiquidGlassBackground()
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.86)) {
                            viewModel.dismissSelectedNode()
                        }
                    }

                ScrollView(showsIndicators: false) {
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
                .coordinateSpace(name: LearningFlowLayout.scrollCoordinateSpace)
                .onPreferenceChange(CurrentLearningNodeMinYPreferenceKey.self) { minY in
                    withAnimation(.spring(response: 0.32, dampingFraction: 0.88)) {
                        shouldShowCurrentLessonButton = (minY ?? 120) < 20
                    }
                }
            }
            .navigationTitle(Texts.LearningFlowPage.title)
            .navigationBarTitleDisplayMode(.large)
            .safeAreaInset(edge: .bottom) {
                VStack(spacing: 8) {
                    if let selectedNode = viewModel.selectedNode {
                        LearningNodeDetailCard(node: selectedNode) {
                            viewModel.startSelectedNodeAfterDetailDismissal()
                        }
                        .background(.clear)
                    }

                    if shouldShowCurrentLessonButton {
                        CurrentLessonButton {
                            scrollToCurrentNode(using: proxy)
                        }
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }

                    if viewModel.module != nil {
                        ModuleProgressDock(progress: viewModel.moduleProgress)
                    }
                }
                .padding(.bottom, 8)
            }
            .onAppear {
                scrollToCurrentNode(using: proxy, animated: false, delay: 180_000_000)
            }
            .onChange(of: viewModel.currentAvailableNodeID) {
                scrollToCurrentNode(using: proxy, delay: 260_000_000)
            }
            .fullScreenCover(item: $viewModel.activeNode, onDismiss: {
                scrollToCurrentNode(using: proxy, delay: 220_000_000)
            }) { node in
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

    private func scrollToCurrentNode(
        using proxy: ScrollViewProxy,
        animated: Bool = true,
        delay: UInt64 = 0
    ) {
        guard let currentNodeID = viewModel.currentAvailableNodeID else { return }

        Task { @MainActor in
            if delay > 0 {
                try? await Task.sleep(nanoseconds: delay)
            }

            if animated {
                withAnimation(.spring(response: 0.52, dampingFraction: 0.86)) {
                    proxy.scrollTo(currentNodeID, anchor: .center)
                }
            } else {
                proxy.scrollTo(currentNodeID, anchor: .center)
            }
        }
    }
}

private enum LearningFlowLayout {
    static let scrollCoordinateSpace = "LearningFlowScrollCoordinateSpace"
}

private struct CurrentLearningNodeMinYPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat?

    static func reduce(value: inout CGFloat?, nextValue: () -> CGFloat?) {
        value = nextValue() ?? value
    }
}

private struct CurrentLessonButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(Texts.LearningFlowPage.currentLesson, systemImage: "arrow.up.circle.fill")
                .font(Font.caption(.bold))
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .foregroundStyle(.white)
                .background(LiquidGlassTheme.accent, in: Capsule())
                .overlay {
                    Capsule()
                        .stroke(Color.white.opacity(0.42), lineWidth: 1)
                }
                .shadow(color: LiquidGlassTheme.accent.opacity(0.28), radius: 16, x: 0, y: 8)
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, alignment: .trailing)
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
        .id(node.id)
        .background {
            if isCurrent {
                GeometryReader { proxy in
                    Color.clear.preference(
                        key: CurrentLearningNodeMinYPreferenceKey.self,
                        value: proxy.frame(in: .named(LearningFlowLayout.scrollCoordinateSpace)).minY
                    )
                }
            }
        }
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
