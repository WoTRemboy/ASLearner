import SwiftUI

struct LearningQuizStepView: View {
    @Environment(\.dismiss) private var dismiss
    let node: LearningNode
    let onComplete: () -> Void

    @State private var selectedAnswer: QuizAnswer?
    @State private var didAnswerCorrectly = false

    private let question: QuizQuestion

    init(node: LearningNode, onComplete: @escaping () -> Void) {
        self.node = node
        self.onComplete = onComplete
        self.question = LearningQuizStepView.makeQuestion(for: node)
    }

    var body: some View {
        ZStack {
            LiquidGlassBackground()

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    LearningStepHeader(node: node)

                    LiquidGlassCard {
                        VStack(alignment: .leading, spacing: 14) {
                            Label(Texts.LearningFlowPage.chooseAnswer, systemImage: "questionmark.circle.fill")
                                .font(Font.largeTitle3(.semibold))
                                .foregroundStyle(LiquidGlassTheme.foreground)

                            Text(question.prompt)
                                .font(Font.title2(.bold))
                                .foregroundStyle(LiquidGlassTheme.foreground)
                                .fixedSize(horizontal: false, vertical: true)

                            Text(question.hint)
                                .font(Font.body())
                                .foregroundStyle(LiquidGlassTheme.mutedForeground)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }

                    VStack(spacing: 10) {
                        ForEach(question.answers) { answer in
                            answerButton(answer)
                        }
                    }

                    if let selectedAnswer {
                        Text(selectedAnswer.isCorrect ? Texts.LearningFlowPage.correctAnswer : Texts.LearningFlowPage.wrongAnswer)
                            .font(Font.caption(.semibold))
                            .foregroundStyle(selectedAnswer.isCorrect ? LiquidGlassTheme.success : LiquidGlassTheme.warning)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    LiquidGlassButton(title: Texts.LearningFlowPage.complete, systemImage: "checkmark.circle.fill", tint: LiquidGlassTheme.success) {
                        onComplete()
                        dismiss()
                    }
                    .disabled(!didAnswerCorrectly)
                    .opacity(didAnswerCorrectly ? 1 : 0.45)
                }
                .padding(20)
            }
        }
        .navigationTitle(node.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func answerButton(_ answer: QuizAnswer) -> some View {
        Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.84)) {
                selectedAnswer = answer
                didAnswerCorrectly = answer.isCorrect
            }
        } label: {
            HStack {
                Text(answer.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(LiquidGlassTheme.foreground)

                Spacer()

                if selectedAnswer?.id == answer.id {
                    Image(systemName: answer.isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundStyle(answer.isCorrect ? LiquidGlassTheme.success : LiquidGlassTheme.warning)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .glassEffect(.regular.tint(answerTint(answer)), in: .rect(cornerRadius: 18))
        }
        .buttonStyle(.plain)
    }

    private func answerTint(_ answer: QuizAnswer) -> Color {
        guard selectedAnswer?.id == answer.id else {
            return Color.BackgroundColors.card.opacity(0.28)
        }
        return answer.isCorrect ? LiquidGlassTheme.success.opacity(0.24) : LiquidGlassTheme.warning.opacity(0.24)
    }

    private static func makeQuestion(for node: LearningNode) -> QuizQuestion {
        if let gestureType = node.gestureId {
            let gesture = GestureRepository.gesture(for: gestureType)
            return QuizQuestion(
                type: .chooseTranslation,
                prompt: "Choose the Russian translation for \(gesture.englishName).",
                gesture: gesture.type,
                answers: [
                    QuizAnswer(title: gesture.russianName, isCorrect: true),
                    QuizAnswer(title: "Помощь", isCorrect: false),
                    QuizAnswer(title: "Да", isCorrect: false),
                    QuizAnswer(title: "Учиться", isCorrect: false)
                ].shuffled(),
                hint: gesture.executionDescription
            )
        }

        return QuizQuestion(
            type: .chooseGesture,
            prompt: "Which set belongs to the first module?",
            gesture: nil,
            answers: [
                QuizAnswer(title: "Hello, Thank you, Yes, No", isCorrect: true),
                QuizAnswer(title: "Help, Bad, Learn, Please", isCorrect: false),
                QuizAnswer(title: "Good, Bad, I love you, Learn", isCorrect: false),
                QuizAnswer(title: "Please, Help, Good, Bad", isCorrect: false)
            ],
            hint: "Remember the gestures practiced on the learning path."
        )
    }
}
