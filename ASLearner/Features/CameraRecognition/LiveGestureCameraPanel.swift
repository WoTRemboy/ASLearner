import SwiftUI

struct LiveGestureCameraPanel: View {
    private let completionConfidenceThreshold = GestureRecognitionConfiguration.mediaPipeDefault.exerciseCompletionThreshold

    @EnvironmentObject private var appViewModel: AppViewModel
    @StateObject private var recognitionViewModel: LiveGestureRecognitionViewModel
    @State private var didNotifyRecognized = false
    @State private var handledStopRequest = 0

    let gesture: GestureModel
    let stopRequest: Int
    let onRecognized: () -> Void
    let onStopCompleted: () -> Void

    init(
        gesture: GestureModel,
        stopRequest: Int = 0,
        onRecognized: @escaping () -> Void,
        onStopCompleted: @escaping () -> Void = {}
    ) {
        self.gesture = gesture
        self.stopRequest = stopRequest
        self.onRecognized = onRecognized
        self.onStopCompleted = onStopCompleted
        _recognitionViewModel = StateObject(wrappedValue: LiveGestureRecognitionViewModel(targetGesture: gesture.type))
    }

    var body: some View {
        VStack(spacing: 14) {
            cameraPreview

            if didNotifyRecognized {
                acceptedGestureMessage
                    .transition(.move(edge: .top).combined(with: .opacity))
            }

            Button {
                recognitionViewModel.toggleScanning()
            } label: {
                Label {
                    Text(recognitionViewModel.actionTitle)
                        .contentTransition(.numericText())
                } icon: {
                    Image(systemName: recognitionViewModel.isScanning ? "stop.circle.fill" : "viewfinder")
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .foregroundStyle(.white)
            }
            .buttonStyle(.glassProminent)
            .tint(recognitionViewModel.isScanning ? LiquidGlassTheme.warning : LiquidGlassTheme.accent)
            .disabled(recognitionViewModel.isPreparing)
            .opacity(recognitionViewModel.isPreparing ? 0.72 : 1)
            .animation(.spring(response: 0.34, dampingFraction: 0.82), value: recognitionViewModel.actionTitle)
        }
        .animation(.spring(response: 0.36, dampingFraction: 0.84), value: didNotifyRecognized)
        .onAppear {
            recognitionViewModel.configure(service: appViewModel.container.gestureRecognitionService)
        }
        .onDisappear {
            recognitionViewModel.stop()
        }
        .onChange(of: recognitionViewModel.result) { _, newValue in
            handleRecognitionResult(newValue)
        }
        .onChange(of: stopRequest) { _, newValue in
            handleStopRequest(newValue)
        }
    }

    private var cameraPreview: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.black.opacity(0.24))
                .aspectRatio(4 / 3, contentMode: .fit)
                .overlay {
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(Color.white.opacity(0.22), lineWidth: 1)
                }

            CameraPreviewView(session: recognitionViewModel.cameraSession)
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                .opacity(recognitionViewModel.errorMessage == nil ? 1 : 0.16)

            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.28), style: StrokeStyle(lineWidth: 2, dash: [10, 8]))
                .padding(38)
                .allowsHitTesting(false)

            VStack {
                HStack {
                    Label(recognitionViewModel.errorMessage == nil ? Texts.CameraPage.livePreview : Texts.CameraPage.cameraUnavailable, systemImage: "camera.metering.center.weighted")
                        .font(.caption.bold())
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 7)
                        .background(Color.black.opacity(0.28), in: Capsule())
                    Spacer()
                }

                Spacer()

                VStack(spacing: 8) {
                    Label(statusTitle, systemImage: statusSymbol)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(statusColor)

                    Text(recognitionViewModel.feedback)
                        .font(.caption.weight(.medium))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white)
                        .lineLimit(2)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .background(Color.black.opacity(0.24), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
            .padding(14)
        }
    }

    private var acceptedGestureMessage: some View {
        Label(Texts.LearningFlowPage.gestureAccepted, systemImage: "checkmark.seal.fill")
            .font(.system(size: 16, weight: .semibold))
            .foregroundStyle(LiquidGlassTheme.success)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .padding(.horizontal, 14)
            .glassEffect(.regular.tint(LiquidGlassTheme.success.opacity(0.16)), in: .rect(cornerRadius: 18))
    }

    private var statusTitle: String {
        guard let result = recognitionViewModel.result else {
            return Texts.CameraPage.waiting
        }

        return "\(result.gestureName) • \(Int(result.confidence * 100))%"
    }

    private var statusSymbol: String {
        switch recognitionViewModel.result?.status {
        case .recognized:
            return "checkmark.seal.fill"
        case .lowConfidence:
            return "exclamationmark.triangle.fill"
        case .notDetected:
            return "hand.raised.slash.fill"
        case nil:
            return "waveform"
        }
    }

    private var statusColor: Color {
        switch recognitionViewModel.result?.status {
        case .recognized:
            return LiquidGlassTheme.success
        case .lowConfidence:
            return LiquidGlassTheme.warning
        case .notDetected:
            return LiquidGlassTheme.secondaryAccent
        case nil:
            return .white
        }
    }

    private func handleRecognitionResult(_ result: GestureRecognitionResult?) {
        guard let result,
              result.status == .recognized,
              result.confidence >= completionConfidenceThreshold,
              !didNotifyRecognized else {
            return
        }

        didNotifyRecognized = true

        withAnimation(.spring(response: 0.38, dampingFraction: 0.82)) {
            onRecognized()
        }
    }

    private func handleStopRequest(_ request: Int) {
        guard request > handledStopRequest else { return }
        handledStopRequest = request
        recognitionViewModel.stopBeforeTransition(completion: onStopCompleted)
    }
}
