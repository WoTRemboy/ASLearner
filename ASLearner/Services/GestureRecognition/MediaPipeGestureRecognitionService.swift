import Foundation
import MediaPipeTasksVision

enum MediaPipeGestureRecognitionError: LocalizedError {
    case modelMissing(String)
    case recognizerNotReady

    var errorDescription: String? {
        switch self {
        case .modelMissing(let modelName):
            "MediaPipe model \(modelName) was not found in the app bundle."
        case .recognizerNotReady:
            "Gesture recognizer is not ready."
        }
    }
}

final class MediaPipeGestureRecognitionService: GestureRecognitionServiceProtocol {
    let runtime: GestureRecognitionRuntime = .mediaPipeGestureRecognizer

    private let configuration: GestureRecognitionConfiguration
    private let fallback: GestureRecognitionServiceProtocol
    private let recognizerQueue = DispatchQueue(label: "com.signa.gesture-recognizer.mediapipe", qos: .userInitiated)

    private var gestureRecognizer: GestureRecognizer?

    init(
        configuration: GestureRecognitionConfiguration = .mediaPipeDefault,
        fallback: GestureRecognitionServiceProtocol = MockGestureRecognitionService()
    ) {
        self.configuration = configuration
        self.fallback = fallback
    }

    func startSession(target: GestureType?) async throws {
        try await withCheckedThrowingContinuation { continuation in
            recognizerQueue.async { [weak self] in
                guard let self else { return }

                do {
                    try self.prepareRecognizerIfNeeded()
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    func recognize(frame: GestureRecognitionFrame, target: GestureType?) async -> GestureRecognitionResult? {
        await withCheckedContinuation { continuation in
            recognizerQueue.async { [weak self] in
                guard let self else {
                    continuation.resume(returning: nil)
                    return
                }

                do {
                    try self.prepareRecognizerIfNeeded()

                    guard let gestureRecognizer = self.gestureRecognizer else {
                        throw MediaPipeGestureRecognitionError.recognizerNotReady
                    }

                    let mediaPipeImage = try MPImage(sampleBuffer: frame.sampleBuffer)
                    let result = try gestureRecognizer.recognize(
                        videoFrame: mediaPipeImage,
                        timestampInMilliseconds: frame.timestampInMilliseconds
                    )

                    continuation.resume(returning: self.map(result, target: target))
                } catch {
                    continuation.resume(returning: nil)
                }
            }
        }
    }

    func stopSession() {
        recognizerQueue.async { [weak self] in
            self?.gestureRecognizer = nil
        }
    }

    func recognize(target: GestureType?) async -> GestureRecognitionResult {
        await fallback.recognize(target: target)
    }

    private func prepareRecognizerIfNeeded() throws {
        guard gestureRecognizer == nil else { return }

        guard let modelPath = Bundle.main.path(
            forResource: configuration.modelResourceName,
            ofType: configuration.modelResourceExtension
        ) else {
            throw MediaPipeGestureRecognitionError.modelMissing(
                "\(configuration.modelResourceName).\(configuration.modelResourceExtension)"
            )
        }

        let options = GestureRecognizerOptions()
        options.baseOptions.modelAssetPath = modelPath
        options.runningMode = .video
        options.numHands = configuration.numHands
        options.minHandDetectionConfidence = configuration.minHandDetectionConfidence
        options.minHandPresenceConfidence = configuration.minHandPresenceConfidence
        options.minTrackingConfidence = configuration.minTrackingConfidence

        gestureRecognizer = try GestureRecognizer(options: options)
    }

    private func map(_ result: GestureRecognizerResult, target: GestureType?) -> GestureRecognitionResult {
        let bestCategory = result.gestures
            .flatMap { $0 }
            .max { lhs, rhs in lhs.score < rhs.score }

        return GestureRecognitionResultMapper.result(
            label: bestCategory?.categoryName,
            confidence: Double(bestCategory?.score ?? 0),
            target: target,
            lowConfidenceThreshold: configuration.lowConfidenceThreshold,
            recognizedThreshold: configuration.recognizedThreshold
        )
    }
}
