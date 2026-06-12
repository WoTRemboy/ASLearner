import SwiftUI

struct LearningGesturePracticeView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appViewModel: AppViewModel

    let node: LearningNode
    let onComplete: () -> Void

    @State private var didRecognizeGesture = false

    var body: some View {
        ZStack {
            LiquidGlassBackground()

            ScrollView {
                VStack(spacing: 18) {
                    LearningStepHeader(node: node)

                    LiquidGlassCard {
                        VStack(spacing: 16) {
                            cameraPlaceholder

                            VStack(spacing: 6) {
                                Text(gesture.englishName)
                                    .font(Font.title2(.bold))
                                    .foregroundStyle(LiquidGlassTheme.foreground)

                                Text(gesture.executionDescription)
                                    .font(Font.body())
                                    .foregroundStyle(LiquidGlassTheme.mutedForeground)
                                    .multilineTextAlignment(.center)
                            }

                            if didRecognizeGesture {
                                Label(Texts.LearningFlowPage.gestureAccepted, systemImage: "checkmark.seal.fill")
                                    .font(Font.caption(.semibold))
                                    .foregroundStyle(LiquidGlassTheme.success)
                                    .multilineTextAlignment(.center)
                            }
                        }
                    }

                    LiquidGlassButton(title: Texts.LearningFlowPage.simulateGesture, systemImage: "camera.viewfinder") {
                        withAnimation(.spring(response: 0.42, dampingFraction: 0.8)) {
                            didRecognizeGesture = true
                        }
                    }

                    LiquidGlassButton(title: Texts.LearningFlowPage.complete, systemImage: "checkmark.circle.fill", tint: LiquidGlassTheme.success) {
                        onComplete()
                        dismiss()
                    }
                    .disabled(!didRecognizeGesture)
                    .opacity(didRecognizeGesture ? 1 : 0.45)
                }
                .padding(20)
            }
        }
        .navigationTitle(node.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var gesture: GestureModel {
        appViewModel.gesture(for: node.gestureId ?? .hello)
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
