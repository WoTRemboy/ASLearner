import Foundation

struct LlamaCppLocalLLMService: LocalLLMServiceProtocol {
    private let runtime: LlamaCppRuntimeProtocol
    private let fallbackService: LocalLLMServiceProtocol
    private let modelName: String

    init(
        modelName: String = "Qwen3-0.6B-Q8_0",
        runtime: LlamaCppRuntimeProtocol = UnavailableLlamaCppRuntime(),
        fallbackService: LocalLLMServiceProtocol = MockLocalLLMService()
    ) {
        self.modelName = modelName
        self.runtime = runtime
        self.fallbackService = fallbackService
    }

    func generateHint(for gesture: GestureType) async -> String {
        let model = GestureRepository.gesture(for: gesture)
        let prompt = """
        You are an offline iOS tutor for sign language learners.
        Write one short Russian hint for practicing the gesture.
        Gesture: \(model.englishName)
        Execution: \(model.executionDescription)
        Requirements:
        - Russian only.
        - One sentence.
        - No markdown.
        """

        guard let response = try? await runtime.complete(
            prompt: prompt,
            options: LlamaCppGenerationOptions(maxTokens: 80, temperature: 0.25)
        ) else {
            return await fallbackService.generateHint(for: gesture)
        }

        let cleaned = clean(response)
        return cleaned.isEmpty ? await fallbackService.generateHint(for: gesture) : cleaned
    }

    func generateQuiz(topic: String) async -> String {
        let prompt = """
        You are an offline iOS quiz generator.
        Summarize a short Russian quiz plan for the topic "\(topic)".
        Requirements:
        - Russian only.
        - One sentence.
        - No markdown.
        """

        guard let response = try? await runtime.complete(
            prompt: prompt,
            options: LlamaCppGenerationOptions(maxTokens: 90, temperature: 0.3)
        ) else {
            return await fallbackService.generateQuiz(topic: topic)
        }

        let cleaned = clean(response)
        return cleaned.isEmpty ? await fallbackService.generateQuiz(topic: topic) : cleaned
    }

    func generateQuizQuestionDraft(for request: LocalLLMQuizRequest) async -> LocalLLMQuizDraft? {
        let prompt = quizPrompt(for: request)

        guard let response = try? await runtime.complete(
            prompt: prompt,
            options: LlamaCppGenerationOptions(maxTokens: 180, temperature: 0.28)
        ) else {
            return await fallbackService.generateQuizQuestionDraft(for: request)
        }

        if let draft = decodeDraft(from: response) {
            return draft
        }

        return await fallbackService.generateQuizQuestionDraft(for: request)
    }

    private func quizPrompt(for request: LocalLLMQuizRequest) -> String {
        let learned = request.learnedGestures
            .map { "\($0.englishName): \($0.executionDescription)" }
            .joined(separator: "\n")
        let wrongAnswers = request.wrongAnswers.joined(separator: "; ")
        let targetGesture = request.targetGesture
        let material = request.studyMaterial
        let relatedMistake = request.relatedMistake.map {
            "Previous mistake: selected '\($0.selectedAnswerTitle)' instead of '\($0.correctAnswerTitle)' in area \($0.knowledgeArea.title)."
        } ?? "Previous mistake: none."

        return """
        You are running locally on iPhone through llama.cpp with model \(modelName).
        Generate one short adaptive quiz question for a sign language learning app.

        Topic: \(request.topic)
        Question type: \(request.quizType.rawValue)
        Target gesture: \(targetGesture?.englishName ?? "none")
        Russian meaning: \(targetGesture?.russianName ?? "none")
        Source correct answer idea: \(request.correctAnswer)
        Source wrong answer ideas: \(wrongAnswers)
        Gesture execution: \(targetGesture?.executionDescription ?? "none")
        Theory material: \(material?.title ?? "none") — \(material?.summary ?? "none")
        Key facts: \(material?.keyFacts.joined(separator: "; ") ?? "none")
        \(relatedMistake)
        Learned gestures:
        \(learned)

        Return only valid compact JSON with this exact shape:
        {"prompt":"Russian question text","correctAnswer":"one correct Russian answer","wrongAnswers":["wrong answer 1","wrong answer 2","wrong answer 3"],"hint":"Russian hint text"}

        Rules:
        - Russian only.
        - Generate a meaningful learning question about gesture mechanics, hand position, camera framing, theory, or a previous mistake.
        - Do not ask to choose a gesture name from a list of gesture names.
        - Do not make the correct answer a single word like "Да", "Нет", "Привет", or "Спасибо".
        - The correct answer must be based on the source correct answer idea.
        - Wrong answers must be plausible but clearly incorrect according to the lesson material.
        - The hint must help recall the principle or movement, not reveal the exact answer.
        - Keep each answer under 90 characters.
        - No markdown.
        """
    }

    private func decodeDraft(from response: String) -> LocalLLMQuizDraft? {
        let json = extractJSONObject(from: response)
        guard let data = json.data(using: .utf8),
              let draft = try? JSONDecoder().decode(LocalLLMQuizDraft.self, from: data),
              isValid(draft) else {
            return nil
        }

        return LocalLLMQuizDraft(
            prompt: clean(draft.prompt),
            correctAnswer: clean(draft.correctAnswer ?? ""),
            wrongAnswers: draft.wrongAnswers?.map(clean).filter { !$0.isEmpty },
            hint: clean(draft.hint)
        )
    }

    private func extractJSONObject(from response: String) -> String {
        guard let start = response.firstIndex(of: "{"),
              let end = response.lastIndex(of: "}"),
              start <= end else {
            return response
        }

        return String(response[start...end])
    }

    private func isValid(_ draft: LocalLLMQuizDraft) -> Bool {
        !clean(draft.prompt).isEmpty && !clean(draft.hint).isEmpty
    }

    private func clean(_ text: String) -> String {
        text
            .replacingOccurrences(of: "\n", with: " ")
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
