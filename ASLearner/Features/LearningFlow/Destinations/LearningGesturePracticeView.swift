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
    let onComplete: () -> Void

    @State private var didRecognizeGesture = false
    @State private var cameraStopRequest = 0
    @State private var pendingCameraStopAction: GesturePracticeCameraStopAction?

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
            if session.isResultPage {
                LearningTaskResultButton {
                    onComplete()
                    dismiss()
                }
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
                switch session.currentPageIndex {
                case 0:
                    LearningTaskReferencePage(
                        node: node,
                        symbolName: gesture.symbolName,
                        title: "Prepare \(gesture.englishName)",
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
                        title: "Practice",
                        value: "\(node.xpReward) XP",
                        timeString: session.timeString,
                        systemImage: "hand.raised.fill"
                    )
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

                Text(gesture.executionDescription)
                    .font(.title3)
                    .fontWeight(.medium)
                    .lineSpacing(4)
                    .foregroundStyle(LiquidGlassTheme.mutedForeground)
                    .fixedSize(horizontal: false, vertical: true)

                if didRecognizeGesture {
                    Label(Texts.LearningFlowPage.gestureAccepted, systemImage: "checkmark.seal.fill")
                        .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(LiquidGlassTheme.success)
                    .transition(.blurReplace)
                }
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
}
