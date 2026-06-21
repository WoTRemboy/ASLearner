import Foundation

enum GestureType: String, CaseIterable, Identifiable, Hashable, Codable {
    case yes
    case no
    case hello
    case thankYou
    case please
    case help
    case good
    case bad
    case iLoveYou
    case learn

    var id: String { rawValue }
}

enum GestureDifficulty: String, CaseIterable {
    case beginner = "Начальный"
    case medium = "Средний"
    case advanced = "Сложный"
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
            "Распознан"
        case .lowConfidence:
            "Низкая уверенность"
        case .notDetected:
            "Не найден"
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
