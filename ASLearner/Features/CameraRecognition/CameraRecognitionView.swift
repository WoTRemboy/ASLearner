import SwiftUI

struct CameraRecognitionView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    let targetGesture: GestureType
    let lessonID: String?

    @State private var result: GestureRecognitionResult?
    @State private var isScanning = false
    @State private var feedback = Texts.CameraPage.initialFeedback
    @State private var didAward = false

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
                        title: isScanning ? Texts.CameraPage.scanning : Texts.CameraPage.runRecognition,
                        systemImage: isScanning ? "waveform" : "viewfinder",
                        tint: isScanning ? LiquidGlassTheme.warning : LiquidGlassTheme.accent
                    ) {
                        runRecognition()
                    }
                    .disabled(isScanning)
                    .opacity(isScanning ? 0.72 : 1)
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 28)
            }
            .scrollBounceBehavior(.basedOnSize, axes: [.vertical])
        }
        .navigationTitle(Texts.CameraPage.title)
        .navigationBarTitleDisplayMode(.inline)
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

            VStack(spacing: 20) {
                ZStack {
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(Color.white.opacity(0.32), style: StrokeStyle(lineWidth: 2, dash: [10, 8]))
                        .frame(width: 220, height: 220)

                    Image(systemName: "hand.raised.fingers.spread.fill")
                        .font(.system(size: 82, weight: .semibold))
                        .foregroundStyle(isScanning ? LiquidGlassTheme.warning : LiquidGlassTheme.accent)
                        .symbolEffect(.pulse, value: isScanning)
                }

                Text(feedback)
                    .font(.subheadline.weight(.medium))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(LiquidGlassTheme.foreground)
                    .padding(.horizontal, 18)
            }

            VStack {
                HStack {
                    Label(Texts.CameraPage.mockPreview, systemImage: "camera.metering.center.weighted")
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
                    Text(result?.status.title ?? Texts.CameraPage.waiting)
                        .font(.caption.bold())
                        .foregroundStyle(statusColor)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 7)
                        .background(statusColor.opacity(0.14), in: Capsule())
                }

                HStack(spacing: 12) {
                    RecognitionMetric(title: Texts.CameraPage.gesture, value: result?.gestureName ?? target.englishName, systemImage: target.symbolName, tint: LiquidGlassTheme.accent)
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
        guard let confidence = result?.confidence else { return "--" }
        return "\(Int(confidence * 100))%"
    }

    private var statusColor: Color {
        switch result?.status {
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

    private func runRecognition() {
        guard !isScanning else { return }
        isScanning = true
        feedback = Texts.CameraPage.analyzing

        Task {
            let recognitionResult = await appViewModel.container.gestureRecognitionService.recognize(target: targetGesture)
            result = recognitionResult
            isScanning = false

            switch recognitionResult.status {
            case .recognized:
                feedback = Texts.CameraPage.accepted
                if !didAward {
                    appViewModel.applyGestureAward(for: targetGesture, lessonID: lessonID)
                    didAward = true
                }
            case .lowConfidence:
                feedback = Texts.CameraPage.lowConfidence
            case .notDetected:
                feedback = Texts.CameraPage.notDetected
            }
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
