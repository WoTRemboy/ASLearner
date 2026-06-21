import Foundation

struct LlamaCppGenerationOptions {
    var maxTokens: Int = 180
    var temperature: Double = 0.35
    var topP: Double = 0.9
}

enum LlamaCppRuntimeError: LocalizedError {
    case runtimeUnavailable
    case modelNotFound(String)
    case emptyResponse

    var errorDescription: String? {
        switch self {
        case .runtimeUnavailable:
            "llama.cpp runtime is not connected yet."
        case .modelNotFound(let modelName):
            "GGUF model was not found in bundle: \(modelName)."
        case .emptyResponse:
            "llama.cpp returned an empty response."
        }
    }
}

protocol LlamaCppRuntimeProtocol {
    nonisolated func complete(prompt: String, options: LlamaCppGenerationOptions) async throws -> String
}

struct UnavailableLlamaCppRuntime: LlamaCppRuntimeProtocol {
    func complete(prompt: String, options: LlamaCppGenerationOptions) async throws -> String {
        throw LlamaCppRuntimeError.runtimeUnavailable
    }
}
