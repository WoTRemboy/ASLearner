import SwiftUI

private enum GesturePracticeCameraStopAction {
    case advance
    case dismiss
}

struct LearningGesturePracticeView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appViewModel: AppViewModel
    @StateObject private var session = LearningTaskSessionViewModel(pageCount: 3)

    let node: LearningNode
    let onComplete: () -> DayStreakUpdate?

    @State private var didRecognizeGesture = false
    @State private var cameraStopRequest = 0
    @State private var pendingCameraStopAction: GesturePracticeCameraStopAction?
    @State private var streakUpdate: DayStreakUpdate?
    @State private var canContinueAfterStreak = false
    @State private var didApplyCompletion = false

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
                    isEnabled: session.isShowingResultContent,
                    action: completeTask
                )
            } else {
                LearningTaskBottomControls(
                    timeString: session.timeString,
                    elapsedSeconds: session.elapsedSeconds,
                    canMoveForward: canMoveForward && pendingCameraStopAction == nil,
                    close: {
                        requestCameraStop(.dismiss)
                    },
                    moveForward: advanceAfterCameraStops
                )
            }
        }
        .navigationTitle(node.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if shouldShowSkipButton {
                ToolbarItem(placement: .topBarTrailing) {
                    SkipGestureToolbarButton {
                        withAnimation(.spring(response: 0.38, dampingFraction: 0.82)) {
                            didRecognizeGesture = true
                        }
                    }
                }
            }
        }
        .onAppear {
            session.startTimer()
        }
        .onDisappear {
            session.stopTimer()
        }
    }

    private var canMoveForward: Bool {
        switch session.currentPageIndex {
        case 0:
            true
        case 1:
            didRecognizeGesture
        default:
            true
        }
    }

    private var gesture: GestureModel {
        appViewModel.gesture(for: node.gestureId ?? .hello)
    }

    private var shouldShowSkipButton: Bool {
        session.currentPageIndex == 1 && !didRecognizeGesture && streakUpdate == nil
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
                } else {
                    switch session.currentPageIndex {
                case 0:
                    LearningTaskReferencePage(
                        node: node,
                        symbolName: gesture.symbolName,
                        title: "Схема жеста «\(gesture.englishName)»",
                        text: gesture.executionDescription,
                        notes: [
                            gesture.russianName,
                            gesture.difficulty.rawValue,
                            gesture.category
                        ]
                    )
                case 1:
                    practicePage
                default:
                    LearningTaskResultPage(
                        percent: session.resultPercentCounter,
                        isShowingContent: session.isShowingResultContent,
                        title: "Практика",
                        value: "\(node.xpReward) XP",
                        timeString: session.timeString,
                        systemImage: "hand.raised.fill"
                    )
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .scrollBounceBehavior(.basedOnSize, axes: [.vertical])
    }

    private var practicePage: some View {
        VStack(alignment: .leading, spacing: 22) {
            LiveGestureCameraPanel(
                gesture: gesture,
                stopRequest: cameraStopRequest
            ) {
                didRecognizeGesture = true
            } onStopCompleted: {
                performPendingCameraStopAction()
            }

            VStack(alignment: .leading, spacing: 10) {
                Text(gesture.englishName)
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(LiquidGlassTheme.foreground)

                if Image.GestureScheme.assetName(for: gesture.type) != nil {
                    GestureSchemeImageView(gesture: gesture.type, widthRatio: 0.62, maxSide: 280)
                        .padding(.vertical, 6)
                }

                Text(gesture.executionDescription)
                    .font(.title3)
                    .fontWeight(.medium)
                    .lineSpacing(4)
                    .foregroundStyle(LiquidGlassTheme.mutedForeground)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private func advanceAfterCameraStops() {
        guard canMoveForward, pendingCameraStopAction == nil else { return }

        if session.currentPageIndex == 1 {
            requestCameraStop(.advance)
        } else {
            session.moveForward(canMoveForward: canMoveForward)
        }
    }

    private func requestCameraStop(_ action: GesturePracticeCameraStopAction) {
        guard session.currentPageIndex == 1 else {
            perform(action)
            return
        }

        pendingCameraStopAction = action
        cameraStopRequest += 1
    }

    private func performPendingCameraStopAction() {
        guard let action = pendingCameraStopAction else { return }
        pendingCameraStopAction = nil
        perform(action)
    }

    private func perform(_ action: GesturePracticeCameraStopAction) {
        switch action {
        case .advance:
            session.moveForward(canMoveForward: canMoveForward)
        case .dismiss:
            dismiss()
        }
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
}
