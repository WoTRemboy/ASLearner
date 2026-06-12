import Foundation

struct MockGestureRecognitionService: GestureRecognitionServiceProtocol {
    func recognize(target: GestureType?) async -> GestureRecognitionResult {
        try? await Task.sleep(nanoseconds: 700_000_000)

        let confidence = Double.random(in: 0.58...0.98)
        let resolvedGesture = target ?? GestureType.allCases.randomElement() ?? .hello
        let gesture = GestureRepository.gesture(for: resolvedGesture)
        let status: RecognitionStatus

        if confidence > 0.78 {
            status = .recognized
        } else if confidence > 0.62 {
            status = .lowConfidence
        } else {
            status = .notDetected
        }

        return GestureRecognitionResult(
            gestureID: gesture.id,
            gestureName: gesture.englishName,
            confidence: confidence,
            timestamp: .now,
            status: status
        )
    }
}

