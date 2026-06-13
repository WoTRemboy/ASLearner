import Foundation

enum GestureRecognitionResultMapper {
    nonisolated static func result(
        label: String?,
        confidence: Double,
        target: GestureType?,
        lowConfidenceThreshold: Double = 0.45,
        recognizedThreshold: Double = 0.75
    ) -> GestureRecognitionResult {
        let mappedGesture = label.flatMap(gestureType(for:))
        let resolvedGestureType = mappedGesture ?? target ?? .hello
        let status = recognitionStatus(
            label: label,
            mappedGesture: mappedGesture,
            confidence: confidence,
            target: target,
            lowConfidenceThreshold: lowConfidenceThreshold,
            recognizedThreshold: recognizedThreshold
        )

        return GestureRecognitionResult(
            gestureID: resolvedGestureType.rawValue,
            gestureName: englishName(for: resolvedGestureType),
            confidence: confidence,
            timestamp: .now,
            status: status
        )
    }

    nonisolated static func gestureType(for label: String) -> GestureType? {
        switch normalized(label) {
        case "hello":
            return .hello
        case "open_palm":
            return .hello
        case "thankyou", "thank_you", "thanks":
            return .thankYou
        case "yes":
            return .yes
        case "closed_fist":
            return .yes
        case "no":
            return .no
        case "please":
            return .please
        case "help":
            return .help
        case "good":
            return .good
        case "thumb_up", "thumbs_up":
            return .good
        case "bad":
            return .bad
        case "thumb_down", "thumbs_down":
            return .bad
        case "iloveyou", "i_love_you", "love_you":
            return .iLoveYou
        case "learn":
            return .learn
        default:
            return nil
        }
    }

    nonisolated private static func englishName(for gesture: GestureType) -> String {
        switch gesture {
        case .hello:
            return "Hello"
        case .thankYou:
            return "Thank you"
        case .yes:
            return "Yes"
        case .no:
            return "No"
        case .please:
            return "Please"
        case .help:
            return "Help"
        case .good:
            return "Good"
        case .bad:
            return "Bad"
        case .iLoveYou:
            return "I love you"
        case .learn:
            return "Learn"
        }
    }

    nonisolated private static func recognitionStatus(
        label: String?,
        mappedGesture: GestureType?,
        confidence: Double,
        target: GestureType?,
        lowConfidenceThreshold: Double,
        recognizedThreshold: Double
    ) -> RecognitionStatus {
        guard let label, normalized(label) != "none" else {
            return .notDetected
        }

        let targetMatches = target == nil || mappedGesture == target

        if confidence >= recognizedThreshold, targetMatches {
            return .recognized
        }

        if confidence >= lowConfidenceThreshold {
            return .lowConfidence
        }

        return .notDetected
    }

    nonisolated private static func normalized(_ label: String) -> String {
        label
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
            .replacingOccurrences(of: " ", with: "_")
            .replacingOccurrences(of: "-", with: "_")
    }
}
