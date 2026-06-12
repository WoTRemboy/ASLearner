import Foundation

enum GestureType: String, CaseIterable, Identifiable, Hashable {
    case hello
    case thankYou
    case yes
    case no
    case please
    case help
    case good
    case bad
    case iLoveYou
    case learn

    var id: String { rawValue }
}

enum GestureDifficulty: String, CaseIterable {
    case beginner = "Beginner"
    case medium = "Medium"
    case advanced = "Advanced"
}

struct GestureModel: Identifiable, Hashable {
    let id: String
    let type: GestureType
    let englishName: String
    let russianName: String
    let executionDescription: String
    let difficulty: GestureDifficulty
    let category: String
    let symbolName: String
    let mediaPlaceholderName: String?
}

enum RecognitionStatus: String {
    case recognized
    case lowConfidence
    case notDetected

    var title: String {
        switch self {
        case .recognized:
            "Recognized"
        case .lowConfidence:
            "Low confidence"
        case .notDetected:
            "Not detected"
        }
    }
}

struct GestureRecognitionResult: Identifiable, Equatable {
    let id = UUID()
    let gestureID: String
    let gestureName: String
    let confidence: Double
    let timestamp: Date
    let status: RecognitionStatus
}

