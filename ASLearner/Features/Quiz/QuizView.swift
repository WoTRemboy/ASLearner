import SwiftUI

struct QuizView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @State private var questions: [QuizQuestion] = []
    @State private var selectedAnswers: [UUID: UUID] = [:]
    @State private var isLoading = false
    @State private var didSubmit = false
    @State private var generationProgress = 0.0
    @State private var currentGenerationStep = 0

    private var correctCount: Int {
        questions.filter { question in
            guard let selectedID = selectedAnswers[question.id] else { return false }
            return question.answers.first(where: { $0.id == selectedID })?.isCorrect == true
        }.count
    }

    var body: some View {
        ZStack {
            LiquidGlassBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    if isLoading {
                        QuizGenerationProgressView(
                            progress: generationProgress,
                            currentStep: currentGenerationStep,
                            steps: QuizGenerationProgressView.defaultSteps
                        )
                            .padding(.horizontal, 20)
                            .transition(.blurReplace.combined(with: .opacity))
                    } else {
                        quizSummary
                            .padding(.horizontal, 20)

                        ForEach(questions) { question in
                            questionCard(question)
                                .padding(.horizontal, 20)
                        }

                        controls
                            .padding(.horizontal, 20)
                    }
                }
                .padding(.bottom, 28)
            }
            .scrollBounceBehavior(.basedOnSize, axes: [.vertical])
        }
        .navigationTitle(Texts.QuizPage.title)
        .navigationBarTitleDisplayMode(.large)
        .task {
            guard questions.isEmpty else { return }
            await regenerateQuiz()
        }
    }

    private var quizSummary: some View {
        LiquidGlassCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Label("\(questions.count) \(Texts.QuizPage.tasks)", systemImage: "list.bullet.clipboard.fill")
                    Spacer()
                    Label("\(correctCount)/\(questions.count)", systemImage: "checkmark.circle.fill")
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(LiquidGlassTheme.foreground)

                LiquidGlassProgressView(value: questions.isEmpty ? 0 : Double(correctCount) / Double(questions.count), tint: LiquidGlassTheme.success)

                if didSubmit {
                    Text(Texts.QuizPage.submitted)
                        .font(.caption)
                        .foregroundStyle(LiquidGlassTheme.success)
                }
            }
        }
    }

    private func questionCard(_ question: QuizQuestion) -> some View {
        LiquidGlassCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Text(question.type.title)
                        .font(.caption.bold())
                        .foregroundStyle(LiquidGlassTheme.accent)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 7)
                        .background(Color.white.opacity(0.14), in: Capsule())
                    Spacer()
                    if didSubmit {
                        Image(systemName: isQuestionCorrect(question) ? "checkmark.seal.fill" : "xmark.seal.fill")
                            .foregroundStyle(isQuestionCorrect(question) ? LiquidGlassTheme.success : LiquidGlassTheme.secondaryAccent)
                    }
                }

                Text(question.prompt)
                    .font(.headline)
                    .foregroundStyle(LiquidGlassTheme.foreground)
                    .fixedSize(horizontal: false, vertical: true)

                if question.type == .performGesture {
                    performGestureAction(question)
                } else {
                    answerList(question)
                }

                Label(question.hint, systemImage: "lightbulb.fill")
                    .font(.caption)
                    .foregroundStyle(LiquidGlassTheme.mutedForeground)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private func answerList(_ question: QuizQuestion) -> some View {
        VStack(spacing: 10) {
            ForEach(question.answers) { answer in
                Button {
                    guard !didSubmit else { return }
                    selectedAnswers[question.id] = answer.id
                } label: {
                    HStack {
                        Text(answer.title)
                            .font(.subheadline.weight(.semibold))
                        Spacer()
                        if selectedAnswers[question.id] == answer.id {
                            Image(systemName: "checkmark.circle.fill")
                        }
                    }
                    .foregroundStyle(LiquidGlassTheme.foreground)
                    .padding(12)
                    .background(answerBackground(question: question, answer: answer), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.white.opacity(0.18), lineWidth: 1)
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func performGestureAction(_ question: QuizQuestion) -> some View {
        Button {
            guard !didSubmit, let answer = question.answers.first else { return }
            selectedAnswers[question.id] = answer.id
        } label: {
            Label(selectedAnswers[question.id] == question.answers.first?.id ? Texts.QuizPage.performed : Texts.QuizPage.markReady, systemImage: "camera.fill")
                .font(.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .foregroundStyle(LiquidGlassTheme.foreground)
                .background(Color.white.opacity(0.16), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private var controls: some View {
        VStack(spacing: 12) {
            LiquidGlassButton(title: didSubmit ? Texts.QuizPage.newQuiz : Texts.QuizPage.submit, systemImage: didSubmit ? "arrow.clockwise.circle.fill" : "checkmark.circle.fill", tint: didSubmit ? LiquidGlassTheme.secondaryAccent : LiquidGlassTheme.accent) {
                if didSubmit {
                    Task { await regenerateQuiz() }
                } else {
                    submitQuiz()
                }
            }
        }
    }

    private func answerBackground(question: QuizQuestion, answer: QuizAnswer) -> Color {
        if didSubmit, answer.isCorrect {
            return LiquidGlassTheme.success.opacity(0.28)
        }

        if selectedAnswers[question.id] == answer.id {
            return LiquidGlassTheme.accent.opacity(0.30)
        }

        return Color.white.opacity(0.11)
    }

    private func isQuestionCorrect(_ question: QuizQuestion) -> Bool {
        guard let selectedID = selectedAnswers[question.id] else { return false }
        return question.answers.first(where: { $0.id == selectedID })?.isCorrect == true
    }

    private func submitQuiz() {
        guard !didSubmit else { return }
        didSubmit = true
        appViewModel.recordQuizAttempt(questions: questions, selectedAnswerIDs: selectedAnswers)
        appViewModel.applyQuizAward(correctAnswers: correctCount, totalQuestions: questions.count)
    }

    private func regenerateQuiz() async {
        isLoading = true
        didSubmit = false
        selectedAnswers = [:]
        generationProgress = 0
        currentGenerationStep = 0

        await updateGenerationProgress(step: 0, progress: 0.16)
        await updateGenerationProgress(step: 1, progress: 0.34)
        await updateGenerationProgress(step: 2, progress: 0.58)

        questions = await appViewModel.container.quizGenerationService.generateQuiz(
            topic: "Базовые жесты",
            gestures: appViewModel.gestures,
            context: appViewModel.quizGenerationContext
        )

        await updateGenerationProgress(step: 3, progress: 0.92)
        await updateGenerationProgress(step: 3, progress: 1.0)
        isLoading = false
    }

    @MainActor
    private func updateGenerationProgress(step: Int, progress: Double) async {
        withAnimation(.spring(response: 0.42, dampingFraction: 0.84)) {
            currentGenerationStep = step
            generationProgress = progress
        }

        try? await Task.sleep(nanoseconds: 260_000_000)
    }
}

struct QuizGenerationStep: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let systemImage: String
}

struct QuizGenerationProgressView: View {
    let progress: Double
    let currentStep: Int
    let steps: [QuizGenerationStep]

    static let defaultSteps = [
        QuizGenerationStep(title: "Материалы", subtitle: "Выбираем пройденные жесты и теорию", systemImage: "book.pages.fill"),
        QuizGenerationStep(title: "Ошибки", subtitle: "Ищем темы для закрепления", systemImage: "exclamationmark.arrow.trianglehead.counterclockwise.rotate.90"),
        QuizGenerationStep(title: "LLM", subtitle: "Формулируем вопросы и подсказки локально", systemImage: "cpu.fill"),
        QuizGenerationStep(title: "Проверка", subtitle: "Валидируем ответы и собираем тест", systemImage: "checkmark.seal.fill")
    ]

    var body: some View {
        VStack(spacing: 22) {
            Spacer(minLength: 20)

            LiquidGlassCard(cornerRadius: 28, padding: 22) {
                VStack(alignment: .leading, spacing: 22) {
                    header

                    LiquidGlassProgressView(value: progress, height: 14, tint: LiquidGlassTheme.accent)

                    VStack(spacing: 12) {
                        ForEach(Array(steps.enumerated()), id: \.element.id) { index, step in
                            generationStepRow(step, index: index)
                        }
                    }
                }
            }

            Spacer(minLength: 20)
        }
        .frame(maxWidth: .infinity, minHeight: 560)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                Image(systemName: "wand.and.sparkles")
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                    .frame(width: 48, height: 48)
                    .background(LiquidGlassTheme.accent, in: RoundedRectangle(cornerRadius: 16, style: .continuous))

                VStack(alignment: .leading, spacing: 3) {
                    Text(Texts.QuizPage.generationTitle)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(LiquidGlassTheme.foreground)

                    Text("\(Int(progress * 100))%")
                        .font(.headline)
                        .foregroundStyle(LiquidGlassTheme.accent)
                        .contentTransition(.numericText(value: progress))
                }
            }

            Text(progress >= 1 ? Texts.QuizPage.generationCompleted : Texts.QuizPage.generationSubtitle)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(LiquidGlassTheme.mutedForeground)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func generationStepRow(_ step: QuizGenerationStep, index: Int) -> some View {
        let isCompleted = index < currentStep || progress >= 1
        let isCurrent = index == currentStep && progress < 1

        return HStack(spacing: 12) {
            Image(systemName: isCompleted ? "checkmark.circle.fill" : step.systemImage)
                .font(.headline)
                .foregroundStyle(isCompleted ? LiquidGlassTheme.success : isCurrent ? LiquidGlassTheme.accent : LiquidGlassTheme.mutedForeground)
                .frame(width: 34, height: 34)
                .background((isCurrent ? LiquidGlassTheme.accent : LiquidGlassTheme.mutedForeground).opacity(0.12), in: Circle())
                .symbolEffect(.pulse, value: isCurrent)

            VStack(alignment: .leading, spacing: 2) {
                Text(step.title)
                    .font(.headline)
                    .foregroundStyle(LiquidGlassTheme.foreground)

                Text(step.subtitle)
                    .font(.caption)
                    .foregroundStyle(LiquidGlassTheme.mutedForeground)
            }

            Spacer()

            if isCurrent {
                ProgressView()
                    .controlSize(.small)
                    .tint(LiquidGlassTheme.accent)
            }
        }
        .padding(12)
        .background(Color.white.opacity(isCurrent ? 0.14 : 0.08), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .animation(.spring(response: 0.36, dampingFraction: 0.84), value: currentStep)
    }
}
