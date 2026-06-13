import SwiftUI

struct LearningQuizStepView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: LearningQuizSessionViewModel

    let node: LearningNode
    let onComplete: () -> Void

    init(node: LearningNode, onComplete: @escaping () -> Void) {
        self.node = node
        self.onComplete = onComplete
        self._viewModel = StateObject(wrappedValue: LearningQuizSessionViewModel(node: node))
    }

    var body: some View {
        ZStack {
            LiquidGlassBackground()

            animatedPageContent
        }
        .safeAreaInset(edge: .top) {
            LearningTaskProgressBar(progress: viewModel.progress)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
        }
        .safeAreaInset(edge: .bottom) {
            if viewModel.isResultPage {
                LearningTaskResultButton {
                    onComplete()
                    dismiss()
                }
            } else {
                LearningTaskBottomControls(
                    timeString: viewModel.timeString,
                    elapsedSeconds: viewModel.elapsedSeconds,
                    canMoveForward: viewModel.canMoveForward,
                    close: { dismiss() },
                    moveForward: { viewModel.moveForward() }
                )
            }
        }
        .toolbar {
            ToolbarItem {
                LearningQuizScoreView(score: viewModel.quizScore)
            }
        }
        .navigationTitle(node.title)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.startTimer()
        }
        .onDisappear {
            viewModel.stopTimer()
        }
    }

    @ViewBuilder
    private var animatedPageContent: some View {
        ZStack {
            ForEach([viewModel.currentPage], id: \.id) { page in
                pageContent(for: page)
                    .transition(
                        .asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        )
                    )
            }
        }
        .animation(.spring(response: 0.42, dampingFraction: 0.86), value: viewModel.currentPage.id)
    }

    @ViewBuilder
    private func pageContent(for page: LearningQuizPage) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 22) {
                switch page {
                case .theory(let card):
                    LearningQuizTheoryPage(card: card, node: node)
                case .practice:
                    LearningQuizPracticePage(viewModel: viewModel, node: node)
                case .question(let question):
                    LearningQuizQuestionPage(question: question, viewModel: viewModel)
                case .result:
                    LearningQuizResultPage(viewModel: viewModel, node: node)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .scrollBounceBehavior(.basedOnSize, axes: [.vertical])
    }
}

private struct LearningQuizScoreView: View {
    let score: Int

    var body: some View {
        Text("Score: \(score)")
            .font(.headline)
            .contentTransition(.numericText(value: Double(score)))
            .frame(minWidth: 92)
    }
}

private struct LearningQuizTheoryPage: View {
    let card: LearningQuizTheoryCard
    let node: LearningNode

    var body: some View {
        LearningTaskReferencePage(
            node: node,
            symbolName: card.symbolName,
            title: card.title,
            text: card.text,
            notes: card.notes
        )
    }
}

private struct LearningQuizPracticePage: View {
    @ObservedObject var viewModel: LearningQuizSessionViewModel
    let node: LearningNode

    private var gesture: GestureModel {
        node.gestureId.map { GestureRepository.gesture(for: $0) } ?? GestureRepository.gesture(for: .hello)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            cameraPreview

            VStack(alignment: .leading, spacing: 10) {
                Text("Try \(gesture.englishName)")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(LiquidGlassTheme.foreground)

                Text(gesture.executionDescription)
                    .font(.title3)
                    .fontWeight(.medium)
                    .lineSpacing(4)
                    .foregroundStyle(LiquidGlassTheme.mutedForeground)
                    .fixedSize(horizontal: false, vertical: true)

                if viewModel.didPractice {
                    Label("Practice accepted. Continue to the test.", systemImage: "checkmark.seal.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(LiquidGlassTheme.success)
                        .transition(.blurReplace)
                }
            }

            Button {
                viewModel.simulatePractice()
            } label: {
                Label(Texts.LearningFlowPage.simulateGesture, systemImage: "camera.viewfinder")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
            }
            .buttonStyle(.glassProminent)
            .tint(viewModel.didPractice ? LiquidGlassTheme.success : LiquidGlassTheme.accent)
        }
    }

    private var cameraPreview: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.black.opacity(0.24))
                .aspectRatio(4 / 3, contentMode: .fit)
                .overlay {
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(Color.white.opacity(0.22), lineWidth: 1)
                }

            VStack(spacing: 12) {
                Image(systemName: viewModel.didPractice ? "checkmark.circle.fill" : "camera.viewfinder")
                    .font(.system(size: 54, weight: .semibold))
                    .foregroundStyle(viewModel.didPractice ? LiquidGlassTheme.success : LiquidGlassTheme.accent)

                Text(viewModel.didPractice ? "Recognized \(gesture.englishName)" : Texts.CameraPage.mockPreview)
                    .font(Font.caption(.bold))
                    .foregroundStyle(.white)
            }
        }
    }
}

private struct LearningQuizQuestionPage: View {
    let question: QuizQuestion
    @ObservedObject var viewModel: LearningQuizSessionViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 40) {
            LearningQuizQuestionTitle(question: question)

            GlassEffectContainer {
                LazyVStack(spacing: 16) {
                    ForEach(question.answers) { answer in
                        LearningQuizOptionView(question: question, answer: answer, viewModel: viewModel)
                    }
                }
            }
        }
    }
}

private struct LearningQuizQuestionTitle: View {
    let question: QuizQuestion

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(question.type.title)
                .font(.title)
                .fontWeight(.semibold)
                .foregroundStyle(LiquidGlassTheme.foreground)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(question.prompt)
                .font(.title2)
                .foregroundStyle(LiquidGlassTheme.foreground)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

private struct LearningQuizOptionView: View {
    let question: QuizQuestion
    let answer: QuizAnswer
    @ObservedObject var viewModel: LearningQuizSessionViewModel
    @Namespace private var namespace

    var body: some View {
        GlassEffectContainer {
            VStack(spacing: 5) {
                optionButton

                if viewModel.showExplanation(for: answer, question: question) {
                    explanationView
                }
            }
        }
    }

    private var optionButton: some View {
        Text(answer.title)
            .font(.title3)
            .padding()
            .frame(maxWidth: .infinity)
            .contentShape(.capsule)
            .multilineTextAlignment(.center)
            .glassEffect(.regular.interactive().tint(viewModel.answerTint(answer, for: question)))
            .glassEffectID("learning-quiz-option", in: namespace)
            .animation(.spring(response: 0.32, dampingFraction: 0.82), value: viewModel.selectedAnswers[question.id])
            .onTapGesture {
                viewModel.select(answer, for: question)
            }
            .sensoryFeedback(answer.isCorrect ? .impact : .warning, trigger: viewModel.selectedAnswers[question.id] == answer)
    }

    private var explanationView: some View {
        Text(question.hint)
            .font(.body)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .foregroundStyle(LiquidGlassTheme.foreground)
            .glassEffect(.regular.tint(LiquidGlassTheme.secondaryAccent.opacity(0.24)), in: .rect(cornerRadius: 16))
            .glassEffectID("learning-quiz-explanation", in: namespace)
            .padding(.horizontal)
            .transition(.blurReplace)
    }
}

private struct LearningQuizResultPage: View {
    @ObservedObject var viewModel: LearningQuizSessionViewModel
    let node: LearningNode
    @Namespace private var namespace

    var body: some View {
        VStack(spacing: 40) {
            Spacer(minLength: 12)

            Text("\(viewModel.resultPercentCounter)\(viewModel.isShowingResultContent ? "%" : "")")
                .font(.system(size: 132, weight: .heavy, design: .rounded))
                .minimumScaleFactor(0.62)
                .lineLimit(1)
                .frame(maxWidth: .infinity)
                .foregroundStyle(LiquidGlassTheme.mutedForeground.opacity(0.48))
                .contentTransition(.numericText(value: Double(viewModel.resultPercentCounter)))

            if viewModel.isShowingResultContent {
                resultDetails
                    .transition(.blurReplace)
            }

            Spacer(minLength: 12)
        }
        .frame(maxWidth: .infinity, minHeight: 540)
    }

    private var resultDetails: some View {
        GlassEffectContainer {
            HStack(spacing: 12) {
                resultPill(
                    title: "Score",
                    value: "\(viewModel.quizScore)",
                    systemImage: "bolt.fill",
                    tint: LiquidGlassTheme.warning,
                    glassID: "learning-quiz-result-score"
                )

                resultPill(
                    title: "Time",
                    value: viewModel.timeString,
                    systemImage: "timer",
                    tint: LiquidGlassTheme.accent,
                    glassID: "learning-quiz-result-time"
                )
            }
        }
    }

    private func resultPill(title: String, value: String, systemImage: String, tint: Color, glassID: String) -> some View {
        VStack(spacing: 8) {
            Label(title, systemImage: systemImage)
                .font(Font.caption(.semibold))
                .foregroundStyle(tint)

            Text(value)
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(LiquidGlassTheme.foreground)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
                .contentTransition(.numericText())
        }
        .frame(maxWidth: .infinity)
        .padding()
        .glassEffect(.regular.interactive().tint(tint.opacity(0.18)), in: .rect(cornerRadius: 24))
        .glassEffectID(glassID, in: namespace)
    }
}
