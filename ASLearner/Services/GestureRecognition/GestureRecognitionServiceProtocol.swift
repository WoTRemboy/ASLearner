import Foundation
import CoreMedia

enum GestureRecognitionRuntime: String {
    case mock
    case mediaPipeGestureRecognizer
}

struct GestureRecognitionFrame {
    let sampleBuffer: CMSampleBuffer
    let timestampInMilliseconds: Int

    init(sampleBuffer: CMSampleBuffer) {
        self.sampleBuffer = sampleBuffer

        let presentationTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
        let seconds = CMTimeGetSeconds(presentationTime)

        if seconds.isFinite {
            self.timestampInMilliseconds = Int(seconds * 1_000)
        } else {
            self.timestampInMilliseconds = Int(Date().timeIntervalSince1970 * 1_000)
        }
    }
}

protocol GestureRecognitionServiceProtocol {
    var runtime: GestureRecognitionRuntime { get }

    func startSession(target: GestureType?) async throws
    func recognize(frame: GestureRecognitionFrame, target: GestureType?) async -> GestureRecognitionResult?
    func stopSession()
    func recognize(target: GestureType?) async -> GestureRecognitionResult
}

extension GestureRecognitionServiceProtocol {
    var runtime: GestureRecognitionRuntime { .mock }

    func startSession(target: GestureType?) async throws {}

    func recognize(frame: GestureRecognitionFrame, target: GestureType?) async -> GestureRecognitionResult? {
        nil
    }

    func stopSession() {}
}
