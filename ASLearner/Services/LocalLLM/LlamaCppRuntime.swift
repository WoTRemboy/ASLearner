import Foundation
import llama

final class LlamaCppRuntime: LlamaCppRuntimeProtocol, @unchecked Sendable {
    nonisolated(unsafe) private let model: OpaquePointer
    nonisolated(unsafe) private let context: OpaquePointer
    nonisolated(unsafe) private let vocab: OpaquePointer
    private let generationQueue = DispatchQueue(label: "aslearner.llama.runtime")

    init(modelName: String = "Qwen3-0.6B-Q8_0") throws {
        guard let modelPath = Bundle.main.path(forResource: modelName, ofType: "gguf") else {
            throw LlamaCppRuntimeError.modelNotFound(modelName)
        }

        llama_backend_init()

        var modelParams = llama_model_default_params()
        modelParams.n_gpu_layers = 99
        modelParams.use_mmap = true

        guard let loadedModel = llama_model_load_from_file(modelPath, modelParams) else {
            throw LlamaCppRuntimeError.modelNotFound(modelName)
        }

        var contextParams = llama_context_default_params()
        contextParams.n_ctx = 2048
        contextParams.n_batch = 512
        contextParams.n_threads = max(2, Int32(ProcessInfo.processInfo.processorCount - 1))
        contextParams.n_threads_batch = contextParams.n_threads

        guard let loadedContext = llama_init_from_model(loadedModel, contextParams),
              let loadedVocab = llama_model_get_vocab(loadedModel) else {
            llama_model_free(loadedModel)
            throw LlamaCppRuntimeError.runtimeUnavailable
        }

        self.model = loadedModel
        self.context = loadedContext
        self.vocab = loadedVocab
    }

    deinit {
        llama_free(context)
        llama_model_free(model)
    }

    nonisolated func complete(prompt: String, options: LlamaCppGenerationOptions) async throws -> String {
        try await Task.detached(priority: .userInitiated) { [self] in
            try generationQueue.sync {
                try generate(prompt: prompt, options: options)
            }
        }.value
    }

    nonisolated private func generate(prompt: String, options: LlamaCppGenerationOptions) throws -> String {
        llama_kv_self_clear(context)

        var promptTokens = try tokenize(prompt)
        guard !promptTokens.isEmpty else {
            throw LlamaCppRuntimeError.emptyResponse
        }

        try promptTokens.withUnsafeMutableBufferPointer { buffer in
            let batch = llama_batch_get_one(buffer.baseAddress, Int32(buffer.count))
            guard llama_decode(context, batch) == 0 else {
                throw LlamaCppRuntimeError.runtimeUnavailable
            }
        }

        guard let sampler = makeSampler(options: options) else {
            throw LlamaCppRuntimeError.runtimeUnavailable
        }
        defer { llama_sampler_free(sampler) }

        var generatedText = ""

        for _ in 0..<options.maxTokens {
            let token = llama_sampler_sample(sampler, context, -1)
            guard !llama_vocab_is_eog(vocab, token) else { break }

            llama_sampler_accept(sampler, token)
            generatedText += piece(for: token)

            var nextToken = token
            try withUnsafeMutablePointer(to: &nextToken) { pointer in
                let batch = llama_batch_get_one(pointer, 1)
                guard llama_decode(context, batch) == 0 else {
                    throw LlamaCppRuntimeError.runtimeUnavailable
                }
            }
        }

        let cleaned = generatedText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleaned.isEmpty else {
            throw LlamaCppRuntimeError.emptyResponse
        }

        return cleaned
    }

    nonisolated private func tokenize(_ text: String) throws -> [llama_token] {
        let capacity = max(32, text.utf8.count + 16)
        var tokens = Array<llama_token>(repeating: 0, count: capacity)

        let count = text.withCString { cString in
            llama_tokenize(
                vocab,
                cString,
                Int32(strlen(cString)),
                &tokens,
                Int32(tokens.count),
                true,
                true
            )
        }

        guard count > 0 else {
            throw LlamaCppRuntimeError.emptyResponse
        }

        return Array(tokens.prefix(Int(count)))
    }

    nonisolated private func makeSampler(options: LlamaCppGenerationOptions) -> UnsafeMutablePointer<llama_sampler>? {
        let params = llama_sampler_chain_default_params()
        let sampler = llama_sampler_chain_init(params)

        guard let sampler else { return nil }

        llama_sampler_chain_add(sampler, llama_sampler_init_top_k(40))
        llama_sampler_chain_add(sampler, llama_sampler_init_top_p(Float(options.topP), 1))
        llama_sampler_chain_add(sampler, llama_sampler_init_temp(Float(options.temperature)))
        llama_sampler_chain_add(sampler, llama_sampler_init_dist(UInt32.random(in: 1...UInt32.max)))

        return sampler
    }

    nonisolated private func piece(for token: llama_token) -> String {
        var buffer = Array<CChar>(repeating: 0, count: 128)
        var count = llama_token_to_piece(vocab, token, &buffer, Int32(buffer.count), 0, false)

        if count < 0 {
            buffer = Array<CChar>(repeating: 0, count: Int(-count))
            count = llama_token_to_piece(vocab, token, &buffer, Int32(buffer.count), 0, false)
        }

        guard count > 0 else { return "" }

        let bytes = buffer.prefix(Int(count)).map { UInt8(bitPattern: $0) }
        return String(decoding: bytes, as: UTF8.self)
    }
}
