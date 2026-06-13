import Foundation

struct GestureRecognitionConfiguration {
    let modelResourceName: String
    let modelResourceExtension: String
    let numHands: Int
    let minHandDetectionConfidence: Float
    let minHandPresenceConfidence: Float
    let minTrackingConfidence: Float
    let lowConfidenceThreshold: Double
    let recognizedThreshold: Double
    let exerciseCompletionThreshold: Double

    static let mediaPipeDefault = GestureRecognitionConfiguration(
        modelResourceName: "gesture_recognizer",
        modelResourceExtension: "task",
        numHands: 1,
        minHandDetectionConfidence: 0.55,
        minHandPresenceConfidence: 0.55,
        minTrackingConfidence: 0.5,
        lowConfidenceThreshold: 0.45,
        recognizedThreshold: 0.75,
        exerciseCompletionThreshold: 0.9
    )
}
