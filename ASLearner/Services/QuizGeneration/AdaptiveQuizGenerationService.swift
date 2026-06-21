import Foundation

struct AdaptiveQuizGenerationService: QuizGenerationServiceProtocol {
    private struct QuestionBlueprint {
        let type: QuizType
        let prompt: String
        let correctAnswer: String
        let wrongAnswers: [String]
        let hint: String
        let gesture: GestureModel?
        let material: QuizStudyMaterial?
        let knowledgeArea: QuizKnowledgeArea
        let sourceNodeID: String?
    }

    private let localLLMService: LocalLLMServiceProtocol
    private let questionCount = 5
    private let minimumQuestionCount = 3

    init(localLLMService: LocalLLMServiceProtocol) {
        self.localLLMService = localLLMService
    }

    func generateQuiz(topic: String, gestures: [GestureModel], context: QuizGenerationContext) async -> [QuizQuestion] {
        let learnedGestures = context.learnedGestures.isEmpty ? Array(gestures.prefix(4)) : context.learnedGestures
        let targetQuestionCount = min(
            questionCount,
            max(minimumQuestionCount, learnedGestures.count + context.studyMaterials.count + min(2, context.mistakes.count))
        )
        let blueprints = questionBlueprints(
            topic: topic,
            learnedGestures: learnedGestures,
            materials: context.studyMaterials,
            mistakes: prioritizedMistakes(from: context),
            targetCount: targetQuestionCount
        )

        var questions: [QuizQuestion] = []
        var usedPromptKeys = Set<String>()
        var usedCorrectAnswerKeys = Set<String>()
        var usedAnswerSetKeys = Set<String>()

        for blueprint in blueprints {
            let question = await buildQuestion(
                from: blueprint,
                topic: topic,
                learnedGestures: learnedGestures,
                usedPromptKeys: usedPromptKeys,
                usedCorrectAnswerKeys: usedCorrectAnswerKeys,
                usedAnswerSetKeys: usedAnswerSetKeys
            )
            questions.append(question)
            usedPromptKeys.insert(normalizedKey(question.prompt))

            if let correctAnswer = question.correctAnswer?.title {
                usedCorrectAnswerKeys.insert(normalizedKey(correctAnswer))
            }

            usedAnswerSetKeys.insert(answerSetKey(question.answers))
        }

        return questions
    }

    private func questionBlueprints(
        topic: String,
        learnedGestures: [GestureModel],
        materials: [QuizStudyMaterial],
        mistakes: [QuizMistakeRecord],
        targetCount: Int
    ) -> [QuestionBlueprint] {
        var blueprints: [QuestionBlueprint] = []

        for mistake in mistakes where blueprints.count < 2 {
            if let blueprint = mistakeBlueprint(mistake, learnedGestures: learnedGestures, materials: materials) {
                appendUniqueBlueprint(blueprint, to: &blueprints)
            }
        }

        for material in materials where blueprints.count < targetCount {
            appendUniqueBlueprint(theoryBlueprint(for: material), to: &blueprints)
        }

        var gestureIndex = 0
        var attempts = 0
        let maxAttempts = max(targetCount * max(learnedGestures.count, 1) * 4, 12)

        while blueprints.count < targetCount, !learnedGestures.isEmpty, attempts < maxAttempts {
            let gesture = learnedGestures[gestureIndex % learnedGestures.count]
            let styleIndex = gestureIndex / max(learnedGestures.count, 1)
            appendUniqueBlueprint(gestureBlueprint(for: gesture, styleIndex: styleIndex), to: &blueprints)
            gestureIndex += 1
            attempts += 1
        }

        return Array(blueprints.prefix(targetCount))
    }

    private func appendUniqueBlueprint(_ blueprint: QuestionBlueprint, to blueprints: inout [QuestionBlueprint]) {
        let promptKey = normalizedKey(blueprint.prompt)
        let correctKey = normalizedKey(blueprint.correctAnswer)
        let answerSetKey = normalizedKey(([blueprint.correctAnswer] + blueprint.wrongAnswers).sorted().joined(separator: "|"))

        guard !blueprints.contains(where: { existing in
            normalizedKey(existing.prompt) == promptKey ||
            normalizedKey(existing.correctAnswer) == correctKey ||
            normalizedKey(([existing.correctAnswer] + existing.wrongAnswers).sorted().joined(separator: "|")) == answerSetKey
        }) else {
            return
        }

        blueprints.append(blueprint)
    }

    private func prioritizedMistakes(from context: QuizGenerationContext) -> [QuizMistakeRecord] {
        context.mistakes
            .filter { mistake in
                if let gesture = mistake.gesture {
                    return context.learnedGestures.contains { $0.type == gesture }
                }

                return context.studyMaterials.contains { $0.area == mistake.knowledgeArea }
            }
            .sorted { $0.priorityScore > $1.priorityScore }
    }

    private func mistakeBlueprint(
        _ mistake: QuizMistakeRecord,
        learnedGestures: [GestureModel],
        materials: [QuizStudyMaterial]
    ) -> QuestionBlueprint? {
        if let gestureType = mistake.gesture,
           let gesture = learnedGestures.first(where: { $0.type == gestureType }) {
            var blueprint = gestureBlueprint(for: gesture, styleIndex: mistake.knowledgeArea == .gestureMeaning ? 1 : 0)
            blueprint = QuestionBlueprint(
                type: blueprint.type,
                prompt: "В прошлый раз здесь была ошибка. Что поможет выполнить жест «\(gesture.russianName)» правильно?",
                correctAnswer: blueprint.correctAnswer,
                wrongAnswers: blueprint.wrongAnswers,
                hint: "Сравните выбранный ответ с механикой жеста, а не с названием.",
                gesture: blueprint.gesture,
                material: blueprint.material,
                knowledgeArea: mistake.knowledgeArea,
                sourceNodeID: mistake.sourceNodeID
            )
            return blueprint
        }

        guard let material = materials.first(where: { $0.area == mistake.knowledgeArea }) else {
            return nil
        }

        return QuestionBlueprint(
            type: .theory,
            prompt: "Как исправить ошибку по теме «\(material.title)»?",
            correctAnswer: material.keyFacts.first ?? material.summary,
            wrongAnswers: theoryDistractors(for: material),
            hint: material.summary,
            gesture: nil,
            material: material,
            knowledgeArea: material.area,
            sourceNodeID: material.id
        )
    }

    private func gestureBlueprint(for gesture: GestureModel, styleIndex: Int) -> QuestionBlueprint {
        switch styleIndex % 3 {
        case 0:
            return QuestionBlueprint(
                type: .chooseGesture,
                prompt: "Что лучше всего описывает механику жеста «\(gesture.russianName)»?",
                correctAnswer: gesture.executionDescription,
                wrongAnswers: executionDistractors(for: gesture),
                hint: "Вспомните форму ладони и направление движения.",
                gesture: gesture,
                material: nil,
                knowledgeArea: .gestureExecution,
                sourceNodeID: nil
            )
        case 1:
            return QuestionBlueprint(
                type: .chooseTranslation,
                prompt: "В какой ситуации уместно использовать жест «\(gesture.russianName)»?",
                correctAnswer: usageAnswer(for: gesture),
                wrongAnswers: usageDistractors(for: gesture),
                hint: "Подумайте о коммуникативной задаче жеста.",
                gesture: gesture,
                material: nil,
                knowledgeArea: .gestureMeaning,
                sourceNodeID: nil
            )
        default:
            return QuestionBlueprint(
                type: .theory,
                prompt: "Что важно для распознавания жеста «\(gesture.russianName)» камерой?",
                correctAnswer: "Держать руку в кадре и выполнять движение плавно.",
                wrongAnswers: [
                    "Убрать руку из кадра во время движения.",
                    "Делать жест рывками как можно быстрее.",
                    "Закрыть ладонь второй рукой."
                ],
                hint: "Камере нужны видимая ладонь, спокойный темп и ровное освещение.",
                gesture: gesture,
                material: nil,
                knowledgeArea: .cameraFraming,
                sourceNodeID: nil
            )
        }
    }

    private func theoryBlueprint(for material: QuizStudyMaterial) -> QuestionBlueprint {
        QuestionBlueprint(
            type: .theory,
            prompt: "Какое утверждение верно по теме «\(material.title)»?",
            correctAnswer: material.keyFacts.first ?? material.summary,
            wrongAnswers: theoryDistractors(for: material),
            hint: material.summary,
            gesture: nil,
            material: material,
            knowledgeArea: material.area,
            sourceNodeID: material.id
        )
    }

    private func buildQuestion(
        from blueprint: QuestionBlueprint,
        topic: String,
        learnedGestures: [GestureModel],
        usedPromptKeys: Set<String>,
        usedCorrectAnswerKeys: Set<String>,
        usedAnswerSetKeys: Set<String>
    ) async -> QuizQuestion {
        let request = LocalLLMQuizRequest(
            topic: topic,
            quizType: blueprint.type,
            targetGesture: blueprint.gesture,
            studyMaterial: blueprint.material,
            relatedMistake: nil,
            learnedGestures: learnedGestures,
            correctAnswer: blueprint.correctAnswer,
            wrongAnswers: blueprint.wrongAnswers
        )
        let draft = await localLLMService.generateQuizQuestionDraft(for: request)
        let draftPrompt = validatedPrompt(draft?.prompt, fallback: blueprint.prompt)
        let draftAnswers = semanticAnswers(from: draft, fallbackCorrect: blueprint.correctAnswer, fallbackWrong: blueprint.wrongAnswers)
        let shouldUseFallback = isDuplicateGeneratedQuestion(
            prompt: draftPrompt,
            answers: draftAnswers,
            usedPromptKeys: usedPromptKeys,
            usedCorrectAnswerKeys: usedCorrectAnswerKeys,
            usedAnswerSetKeys: usedAnswerSetKeys
        )
        let prompt = shouldUseFallback ? blueprint.prompt : draftPrompt
        let answers = shouldUseFallback
            ? semanticAnswers(from: nil, fallbackCorrect: blueprint.correctAnswer, fallbackWrong: blueprint.wrongAnswers)
            : draftAnswers

        return QuizQuestion(
            type: blueprint.type,
            prompt: prompt,
            gesture: blueprint.gesture?.type,
            answers: answers,
            hint: validatedHint(draft?.hint, fallback: blueprint.hint),
            knowledgeArea: blueprint.knowledgeArea,
            sourceNodeID: blueprint.sourceNodeID
        )
    }

    private func isDuplicateGeneratedQuestion(
        prompt: String,
        answers: [QuizAnswer],
        usedPromptKeys: Set<String>,
        usedCorrectAnswerKeys: Set<String>,
        usedAnswerSetKeys: Set<String>
    ) -> Bool {
        let promptKey = normalizedKey(prompt)
        let correctAnswerKey = normalizedKey(answers.first(where: \.isCorrect)?.title ?? "")
        let answersKey = answerSetKey(answers)

        return usedPromptKeys.contains(promptKey) ||
            usedCorrectAnswerKeys.contains(correctAnswerKey) ||
            usedAnswerSetKeys.contains(answersKey)
    }

    private func semanticAnswers(
        from draft: LocalLLMQuizDraft?,
        fallbackCorrect: String,
        fallbackWrong: [String]
    ) -> [QuizAnswer] {
        let draftCorrect = normalizedAnswer(draft?.correctAnswer)
        let draftWrong = draft?.wrongAnswers?.map(normalizedAnswer) ?? []
        let correct = isUsefulAnswer(draftCorrect) ? draftCorrect : fallbackCorrect
        let wrong = usefulWrongAnswers(draftWrong, correct: correct)
        let fallback = usefulWrongAnswers(fallbackWrong, correct: correct)
        let finalWrong = Array((wrong + fallback).prefix(3))

        return ([QuizAnswer(title: correct, isCorrect: true)] + finalWrong.map { QuizAnswer(title: $0, isCorrect: false) }).shuffled()
    }

    private func normalizedAnswer(_ answer: String?) -> String {
        guard let answer else { return "" }
        return answer.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func usefulWrongAnswers(_ answers: [String], correct: String) -> [String] {
        var unique: [String] = []

        for answer in answers {
            let normalized = normalizedAnswer(answer)
            guard isUsefulAnswer(normalized),
                  normalized.caseInsensitiveCompare(correct) != .orderedSame,
                  !unique.contains(where: { $0.caseInsensitiveCompare(normalized) == .orderedSame }) else {
                continue
            }

            unique.append(normalized)
        }

        return unique
    }

    private func answerSetKey(_ answers: [QuizAnswer]) -> String {
        answers
            .map(\.title)
            .map(normalizedKey)
            .sorted()
            .joined(separator: "|")
    }

    private func normalizedKey(_ value: String) -> String {
        value
            .lowercased()
            .replacingOccurrences(of: "ё", with: "е")
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }

    private func isUsefulAnswer(_ answer: String) -> Bool {
        guard answer.count >= 12 else { return false }

        let shortGestureNames = Set(["да", "нет", "привет", "спасибо"])
        return !shortGestureNames.contains(answer.lowercased())
    }

    private func executionDistractors(for gesture: GestureModel) -> [String] {
        switch gesture.type {
        case .yes:
            [
                "Раскрыть ладонь и отвести её от лба наружу.",
                "Свести два пальца с большим пальцем несколько раз.",
                "Коснуться подбородка пальцами и отвести руку вперёд."
            ]
        case .no:
            [
                "Сжать кулак и качнуть им вверх-вниз.",
                "Положить ладонь на грудь и сделать круг.",
                "Поднять большой, указательный и мизинец."
            ]
        case .hello:
            [
                "Сжать кулак и качнуть им как кивок.",
                "Коснуться подбородка и отвести руку вперёд.",
                "Провести ладонью от губ вниз к другой ладони."
            ]
        case .thankYou:
            [
                "Открыть ладонь у лба и отвести её наружу.",
                "Дважды свести указательный и средний пальцы с большим.",
                "Как будто перенести информацию с ладони ко лбу."
            ]
        default:
            [
                "Спрятать ладонь за корпусом во время движения.",
                "Выполнить жест другой формой руки без нужного движения.",
                "Сделать случайный взмах без фиксированной формы ладони."
            ]
        }
    }

    private func usageAnswer(for gesture: GestureModel) -> String {
        switch gesture.type {
        case .yes:
            "Чтобы подтвердить согласие или ответить утвердительно."
        case .no:
            "Чтобы вежливо показать отрицательный ответ или отказ."
        case .hello:
            "Чтобы начать общение и поприветствовать собеседника."
        case .thankYou:
            "Чтобы выразить благодарность после помощи или ответа."
        default:
            "Чтобы передать значение «\(gesture.russianName)» в коротком сообщении."
        }
    }

    private func usageDistractors(for gesture: GestureModel) -> [String] {
        GestureRepository.gestures
            .filter { $0.type != gesture.type }
            .prefix(3)
            .map(usageAnswer(for:))
    }

    private func theoryDistractors(for material: QuizStudyMaterial) -> [String] {
        switch material.area {
        case .cameraFraming:
            [
                "Руки можно держать за пределами кадра.",
                "Контровой свет всегда повышает точность.",
                "Резкие движения помогают камере лучше распознавать жест."
            ]
        case .signLanguageBasics:
            [
                "Жестовый язык передаёт смысл только пальцами.",
                "Контекст не влияет на запоминание жеста.",
                "Практику лучше откладывать до конца всего курса."
            ]
        case .gestureMeaning, .gestureExecution:
            [
                "Движение жеста не связано со смыслом.",
                "Описание выполнения можно игнорировать.",
                "Все жесты выполняются одинаковой формой ладони."
            ]
        }
    }

    private func validatedPrompt(_ prompt: String?, fallback: String) -> String {
        let cleaned = prompt?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard cleaned.count >= 10, !looksLikeTrivialNameQuestion(cleaned) else {
            return fallback
        }

        return cleaned
    }

    private func looksLikeTrivialNameQuestion(_ prompt: String) -> Bool {
        let lowercased = prompt.lowercased()
        return lowercased.contains("какой жест соответствует") || lowercased.contains("выберите значение жеста")
    }

    private func validatedHint(_ hint: String?, fallback: String) -> String {
        let cleaned = hint?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard cleaned.count >= 8 else {
            return fallback
        }

        return cleaned
    }
}
