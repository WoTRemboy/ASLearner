import SwiftUI

struct LearningGesturePracticeView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appViewModel: AppViewModel
    @StateObject private var session = LearningTaskSessionViewModel(pageCount: 3)

    let node: LearningNode
    let onComplete: () -> Void

    @State private var didRecognizeGesture = false

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
                    canMoveForward: canMoveForward,
                    close: { dismiss() },
                    moveForward: { session.moveForward(canMoveForward: canMoveForward) }
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
            cameraPlaceholder

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

            Button {
                withAnimation(.spring(response: 0.42, dampingFraction: 0.8)) {
                    didRecognizeGesture = true
                }
            } label: {
                Label(Texts.LearningFlowPage.simulateGesture, systemImage: "camera.viewfinder")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
            }
            .buttonStyle(.glassProminent)
            .tint(didRecognizeGesture ? LiquidGlassTheme.success : LiquidGlassTheme.accent)
        }
    }

    private var cameraPlaceholder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(Color.black.opacity(0.22))
                .overlay {
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .stroke(Color.white.opacity(0.22), lineWidth: 1)
                }
                .aspectRatio(4 / 3, contentMode: .fit)

            VStack(spacing: 12) {
                Image(systemName: didRecognizeGesture ? "checkmark.circle.fill" : "camera.viewfinder")
                    .font(.system(size: 52, weight: .semibold))
                    .foregroundStyle(didRecognizeGesture ? LiquidGlassTheme.success : LiquidGlassTheme.accent)

                Text(didRecognizeGesture ? "Recognized \(gesture.englishName)" : Texts.CameraPage.mockPreview)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
            }
        }
    }
}
