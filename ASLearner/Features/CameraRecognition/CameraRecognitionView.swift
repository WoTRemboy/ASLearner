import SwiftUI

struct CameraRecognitionView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    let targetGesture: GestureType
    let lessonID: String?

    @StateObject private var recognitionViewModel: LiveGestureRecognitionViewModel
    @State private var didAward = false

    init(targetGesture: GestureType, lessonID: String?) {
        self.targetGesture = targetGesture
        self.lessonID = lessonID
        _recognitionViewModel = StateObject(wrappedValue: LiveGestureRecognitionViewModel(targetGesture: targetGesture))
    }

    private var target: GestureModel {
        appViewModel.gesture(for: targetGesture)
    }

    var body: some View {
        ZStack {
            LiquidGlassBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    cameraPreview
                        .padding(.horizontal, 20)

                    recognitionPanel
                        .padding(.horizontal, 20)

                    LiquidGlassButton(
                        title: recognitionViewModel.actionTitle,
                        systemImage: recognitionViewModel.isScanning ? "stop.circle.fill" : "viewfinder",
                        tint: recognitionViewModel.isScanning ? LiquidGlassTheme.warning : LiquidGlassTheme.accent
                    ) {
                        recognitionViewModel.toggleScanning()
                    }
                    .disabled(recognitionViewModel.isPreparing)
                    .opacity(recognitionViewModel.isPreparing ? 0.72 : 1)
                    .padding(.horizontal, 20)

                    if recognitionViewModel.errorMessage != nil {
                        Button {
                            recognitionViewModel.runFallbackRecognition()
                        } label: {
                            Label(Texts.CameraPage.fallbackRecognition, systemImage: "wand.and.sparkles")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 15)
                        }
                        .buttonStyle(.glassProminent)
                        .tint(LiquidGlassTheme.secondaryAccent)
                        .padding(.horizontal, 20)
                    }
                }
                .padding(.bottom, 28)
            }
            .scrollBounceBehavior(.basedOnSize, axes: [.vertical])
        }
        .navigationTitle(Texts.CameraPage.title)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            recognitionViewModel.configure(service: appViewModel.container.gestureRecognitionService)
        }
        .onDisappear {
            recognitionViewModel.stop()
        }
        .onChange(of: recognitionViewModel.result) { _, newValue in
            handleRecognitionResult(newValue)
        }
    }

    private var cameraPreview: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(Color.clear)
                .frame(height: 360)
                .glassEffect(.regular.interactive().tint(LiquidGlassTheme.glassTint), in: .rect(cornerRadius: 32))
                .overlay {
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .stroke(Color.white.opacity(0.32), lineWidth: 1)
                }

            CameraPreviewView(session: recognitionViewModel.cameraSession)
                .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                .opacity(recognitionViewModel.errorMessage == nil ? 1 : 0.16)

            VStack(spacing: 20) {
                ZStack {
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(Color.white.opacity(0.32), style: StrokeStyle(lineWidth: 2, dash: [10, 8]))
                        .frame(width: 220, height: 220)

                    Image(systemName: "hand.raised.fingers.spread.fill")
                        .font(.system(size: 82, weight: .semibold))
                        .foregroundStyle(recognitionViewModel.isScanning ? LiquidGlassTheme.warning : LiquidGlassTheme.accent)
                        .symbolEffect(.pulse, value: recognitionViewModel.isScanning)
                        .opacity(recognitionViewModel.isScanning ? 0.22 : 0.82)
                }

                Text(recognitionViewModel.feedback)
                    .font(.subheadline.weight(.medium))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(LiquidGlassTheme.foreground)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 10)
                    .background(.black.opacity(0.18), in: Capsule())
            }

            VStack {
                HStack {
                    Label(recognitionViewModel.errorMessage == nil ? Texts.CameraPage.livePreview : Texts.CameraPage.cameraUnavailable, systemImage: "camera.metering.center.weighted")
                        .font(.caption.bold())
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 7)
                        .background(Color.black.opacity(0.22), in: Capsule())
                    Spacer()
                }
                Spacer()
            }
            .padding(18)
        }
    }

    private var recognitionPanel: some View {
        LiquidGlassCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text(Texts.CameraPage.result)
                        .font(.headline)
                        .foregroundStyle(LiquidGlassTheme.foreground)
                    Spacer()
                    Text(recognitionViewModel.result?.status.title ?? Texts.CameraPage.waiting)
                        .font(.caption.bold())
                        .foregroundStyle(statusColor)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 7)
                        .background(statusColor.opacity(0.14), in: Capsule())
                }

                HStack(spacing: 12) {
                    RecognitionMetric(title: Texts.CameraPage.gesture, value: recognitionViewModel.result?.gestureName ?? target.englishName, systemImage: target.symbolName, tint: LiquidGlassTheme.accent)
                    RecognitionMetric(title: Texts.CameraPage.confidence, value: confidenceText, systemImage: "gauge.with.dots.needle.67percent", tint: statusColor)
                }

                if let update = appViewModel.latestUpdate, didAward {
                    Text("+\(update.gainedXP) XP • \(update.message)")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(LiquidGlassTheme.success)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }

    private var confidenceText: String {
        guard let confidence = recognitionViewModel.result?.confidence else { return "--" }
        return "\(Int(confidence * 100))%"
    }

    private var statusColor: Color {
        switch recognitionViewModel.result?.status {
        case .recognized:
            LiquidGlassTheme.success
        case .lowConfidence:
            LiquidGlassTheme.warning
        case .notDetected:
            LiquidGlassTheme.secondaryAccent
        case nil:
            LiquidGlassTheme.mutedForeground
        }
    }

    private func handleRecognitionResult(_ recognitionResult: GestureRecognitionResult?) {
        guard recognitionResult?.status == .recognized, !didAward else { return }

        appViewModel.applyGestureAward(for: targetGesture, lessonID: lessonID)

        withAnimation(.spring(response: 0.42, dampingFraction: 0.82)) {
            didAward = true
        }
    }
}

private struct RecognitionMetric: View {
    let title: String
    let value: String
    let systemImage: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: systemImage)
                .font(.headline)
                .foregroundStyle(tint)
            Text(value)
                .font(.headline.bold())
                .foregroundStyle(LiquidGlassTheme.foreground)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
            Text(title)
                .font(.caption)
                .foregroundStyle(LiquidGlassTheme.mutedForeground)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.white.opacity(0.10), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}
