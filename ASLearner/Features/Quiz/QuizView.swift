import SwiftUI

struct QuizView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @State private var questions: [QuizQuestion] = []
    @State private var selectedAnswers: [UUID: UUID] = [:]
    @State private var isLoading = false
    @State private var didSubmit = false

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
                        loadingCard
                            .padding(.horizontal, 20)
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

    private var loadingCard: some View {
        LiquidGlassCard {
            HStack(spacing: 14) {
                ProgressView()
                    .tint(LiquidGlassTheme.accent)
                Text(Texts.QuizPage.loading)
                    .font(.headline)
                    .foregroundStyle(LiquidGlassTheme.foreground)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
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
        appViewModel.applyQuizAward(correctAnswers: correctCount, totalQuestions: questions.count)
    }

    private func regenerateQuiz() async {
        isLoading = true
        didSubmit = false
        selectedAnswers = [:]
        questions = await appViewModel.container.quizGenerationService.generateQuiz(topic: "Basic sign language", gestures: appViewModel.gestures)
        isLoading = false
    }
}
