import Foundation

protocol GestureRecognitionServiceProtocol {
    func recognize(target: GestureType?) async -> GestureRecognitionResult
}

