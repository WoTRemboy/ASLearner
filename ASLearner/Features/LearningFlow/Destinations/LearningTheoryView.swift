import SwiftUI

struct LearningTheoryView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var session: LearningTaskSessionViewModel
    @State private var streakUpdate: DayStreakUpdate?
    @State private var canContinueAfterStreak = false
    @State private var didApplyCompletion = false

    let node: LearningNode
    let onComplete: () -> DayStreakUpdate?

    private let infoBlocks: [TheoryBlock]

    init(node: LearningNode, onComplete: @escaping () -> DayStreakUpdate?) {
        let blocks = LearningTheoryView.makeInfoBlocks(for: node)
        self.node = node
        self.onComplete = onComplete
        self.infoBlocks = blocks
        self._session = StateObject(wrappedValue: LearningTaskSessionViewModel(pageCount: blocks.count + 1))
    }

    var body: some View {
        ZStack {
            LiquidGlassBackground()
            animatedPageContent
        }
        .safeAreaInset(edge: .top) {
            LearningTaskProgressBar(progress: session.progress)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
        }
        .safeAreaInset(edge: .bottom) {
            if streakUpdate != nil {
                LearningTaskResultButton(
                    title: Texts.LearningFlowPage.continueButton,
                    isEnabled: canContinueAfterStreak
                ) {
                    dismiss()
                }
            } else if session.isResultPage {
                LearningTaskResultButton(
                    title: Texts.LearningFlowPage.completeLesson,
                    isEnabled: session.isShowingResultContent,
                    action: completeTask
                )
            } else {
                LearningTaskBottomControls(
                    timeString: session.timeString,
                    elapsedSeconds: session.elapsedSeconds,
                    canMoveForward: true,
                    close: { dismiss() },
                    moveForward: { session.moveForward(canMoveForward: true) }
                )
            }
        }
        .navigationTitle(node.title)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            session.startTimer()
        }
        .onDisappear {
            session.stopTimer()
        }
    }

    private var animatedPageContent: some View {
        ZStack {
            ForEach([session.currentPageID], id: \.self) { _ in
                pageContent
                    .transition(
                        .asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        )
                    )
            }
        }
        .animation(.spring(response: 0.42, dampingFraction: 0.86), value: session.currentPageID)
    }

    @ViewBuilder
    private var pageContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 22) {
                if let streakUpdate {
                    LearningStreakCelebrationPage(update: streakUpdate) {
                        withAnimation(.spring(response: 0.34, dampingFraction: 0.78)) {
                            canContinueAfterStreak = true
                        }
                    }
                } else if session.isResultPage {
                    LearningTaskResultPage(
                        percent: session.resultPercentCounter,
                        isShowingContent: session.isShowingResultContent,
                        title: "Lesson",
                        value: "\(node.xpReward) XP",
                        timeString: session.timeString,
                        systemImage: "book.pages.fill"
                    )
                } else {
                    let block = infoBlocks[min(session.currentPageIndex, infoBlocks.count - 1)]
                    LearningTaskReferencePage(
                        node: node,
                        symbolName: block.symbolName,
                        title: block.title,
                        text: block.text,
                        notes: block.notes
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .scrollBounceBehavior(.basedOnSize, axes: [.vertical])
    }

    private func completeTask() {
        guard !didApplyCompletion else {
            dismiss()
            return
        }

        didApplyCompletion = true

        if let update = onComplete() {
            canContinueAfterStreak = false
            withAnimation(.spring(response: 0.42, dampingFraction: 0.86)) {
                streakUpdate = update
            }
        } else {
            dismiss()
        }
    }

    private static func makeInfoBlocks(for node: LearningNode) -> [TheoryBlock] {
        if node.id.contains("camera") {
            return [
                TheoryBlock(
                    symbolName: "viewfinder",
                    title: "Keep hands visible",
                    text: "Place both hands inside the camera frame before starting recognition. The model needs a clear view of wrists, palms and fingers.",
                    notes: ["Hands in frame", "Shoulders relaxed", "No fast cuts"]
                ),
                TheoryBlock(
                    symbolName: "light.max.fill",
                    title: "Use good lighting",
                    text: "A bright and even light source helps computer vision detect key points more reliably and lowers false negatives.",
                    notes: ["Face the light", "Avoid backlight", "Plain background"]
                ),
                TheoryBlock(
                    symbolName: "hand.raised.fill",
                    title: "Move smoothly",
                    text: "Perform the gesture slowly first, then repeat it with natural speed. The prototype is tuned for readable demonstration movement.",
                    notes: ["Slow first", "Repeat once", "Natural tempo"]
                )
            ]
        }

        return [
            TheoryBlock(
                symbolName: "hand.wave.fill",
                title: "Visual language",
                text: "Sign language uses hands, facial expression and body position to communicate meaning. The app starts with simple everyday gestures.",
                notes: ["Hands", "Expression", "Body position"]
            ),
            TheoryBlock(
                symbolName: "person.2.fill",
                title: "Context matters",
                text: "The same movement can be understood better when it is practiced in short everyday dialogs and linked to a clear translation.",
                notes: ["Meaning", "Dialog", "Translation"]
            ),
            TheoryBlock(
                symbolName: "camera.viewfinder",
                title: "Learn by doing",
                text: "The learning path alternates short cards, camera practice and checks so the gesture is tried immediately after the explanation.",
                notes: ["Short theory", "Practice next", "Instant check"]
            )
        ]
    }
}

private struct TheoryBlock {
    let symbolName: String
    let title: String
    let text: String
    let notes: [String]
}
