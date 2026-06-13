import AVFoundation
import Combine
import Foundation

@MainActor
final class LiveGestureRecognitionViewModel: ObservableObject {
    let cameraProvider = CameraFrameProvider()

    @Published private(set) var result: GestureRecognitionResult?
    @Published private(set) var feedback = Texts.CameraPage.initialFeedback
    @Published private(set) var isScanning = false
    @Published private(set) var isPreparing = false
    @Published private(set) var errorMessage: String?

    private let targetGesture: GestureType
    private var recognitionService: GestureRecognitionServiceProtocol?
    private var isProcessingFrame = false
    private var lastFrameDate = Date.distantPast
    private var recognitionGeneration = 0
    private let minimumFrameInterval: TimeInterval = 0.2

    init(targetGesture: GestureType) {
        self.targetGesture = targetGesture
    }

    var cameraSession: AVCaptureSession {
        cameraProvider.session
    }

    var actionTitle: String {
        if isPreparing {
            return Texts.CameraPage.preparingCamera
        }

        return isScanning ? Texts.CameraPage.stopRecognition : Texts.CameraPage.startLiveRecognition
    }

    func configure(service: GestureRecognitionServiceProtocol) {
        guard recognitionService == nil else { return }

        recognitionService = service
        cameraProvider.frameHandler = { [weak self] sampleBuffer in
            Task { @MainActor [weak self] in
                self?.handle(sampleBuffer: sampleBuffer)
            }
        }
    }

    func toggleScanning() {
        isScanning ? stop() : start()
    }

    func start() {
        guard let recognitionService else { return }

        recognitionGeneration += 1
        isPreparing = true
        errorMessage = nil
        feedback = Texts.CameraPage.preparingCamera
        let generation = recognitionGeneration

        Task {
            do {
                try await recognitionService.startSession(target: targetGesture)

                await MainActor.run {
                    guard self.recognitionGeneration == generation else { return }
                    self.isPreparing = false
                    self.isScanning = true
                    self.feedback = Texts.CameraPage.liveAnalyzing
                    self.cameraProvider.requestAccessAndStart()
                }
            } catch {
                await MainActor.run {
                    guard self.recognitionGeneration == generation else { return }
                    self.isPreparing = false
                    self.isScanning = false
                    self.errorMessage = error.localizedDescription
                    self.feedback = error.localizedDescription
                }
            }
        }
    }

    func stop() {
        recognitionGeneration += 1
        isScanning = false
        isPreparing = false
        isProcessingFrame = false
        feedback = result == nil ? Texts.CameraPage.initialFeedback : feedback
        cameraProvider.stop()
        recognitionService?.stopSession()
    }

    func stopBeforeTransition(completion: @escaping () -> Void) {
        recognitionGeneration += 1
        isScanning = false
        isPreparing = false
        isProcessingFrame = false
        feedback = result == nil ? Texts.CameraPage.initialFeedback : feedback

        cameraProvider.stop { [weak self] in
            self?.recognitionService?.stopSession()
            completion()
        }
    }

    func runFallbackRecognition() {
        guard let recognitionService, !isPreparing else { return }

        isPreparing = true
        feedback = Texts.CameraPage.analyzing

        Task {
            let fallbackResult = await recognitionService.recognize(target: targetGesture)

            await MainActor.run {
                self.isPreparing = false
                self.apply(fallbackResult)
            }
        }
    }

    private func handle(sampleBuffer: CMSampleBuffer) {
        guard isScanning, !isProcessingFrame else { return }

        let now = Date()
        guard now.timeIntervalSince(lastFrameDate) >= minimumFrameInterval else { return }

        isProcessingFrame = true
        lastFrameDate = now

        let frame = GestureRecognitionFrame(sampleBuffer: sampleBuffer)
        let target = targetGesture
        let generation = recognitionGeneration

        Task {
            let frameResult = await recognitionService?.recognize(frame: frame, target: target)

            await MainActor.run {
                guard self.recognitionGeneration == generation, self.isScanning else {
                    self.isProcessingFrame = false
                    return
                }

                if let frameResult {
                    self.apply(frameResult)
                }

                self.isProcessingFrame = false
            }
        }
    }

    private func apply(_ recognitionResult: GestureRecognitionResult) {
        result = recognitionResult

        switch recognitionResult.status {
        case .recognized:
            feedback = Texts.CameraPage.accepted
        case .lowConfidence:
            feedback = Texts.CameraPage.lowConfidence
        case .notDetected:
            feedback = Texts.CameraPage.notDetected
        }
    }
}
