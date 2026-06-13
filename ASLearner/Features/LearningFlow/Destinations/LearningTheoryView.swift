import SwiftUI

struct LearningTheoryView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var session: LearningTaskSessionViewModel
    @State private var streakUpdate: DayStreakUpdate?
    @State private var canContinueAfterStreak = false
    @State private var didApplyCompletion = false

    let node: LearningNode
    let onComplete: () -> DayStreakUpdate?

    private let infoBlocks: [TheoryBlock]

    init(node: LearningNode, onComplete: @escaping () -> DayStreakUpdate?) {
        let blocks = LearningTheoryView.makeInfoBlocks(for: node)
        self.node = node
        self.onComplete = onComplete
        self.infoBlocks = blocks
        self._session = StateObject(wrappedValue: LearningTaskSessionViewModel(pageCount: blocks.count + 1))
    }

    var body: some View {
        ZStack {
            LiquidGlassBackground()
            animatedPageContent
        }
        .safeAreaInset(edge: .top) {
            LearningTaskProgressBar(progress: session.progress)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
        }
        .safeAreaInset(edge: .bottom) {
            if streakUpdate != nil {
                LearningTaskResultButton(
                    title: Texts.LearningFlowPage.continueButton,
                    isEnabled: canContinueAfterStreak
                ) {
                    dismiss()
                }
            } else if session.isResultPage {
                LearningTaskResultButton(
                    title: Texts.LearningFlowPage.completeLesson,
                    isEnabled: session.isShowingResultContent,
                    action: completeTask
                )
            } else {
                LearningTaskBottomControls(
                    timeString: session.timeString,
                    elapsedSeconds: session.elapsedSeconds,
                    canMoveForward: true,
                    close: { dismiss() },
                    moveForward: { session.moveForward(canMoveForward: true) }
                )
            }
        }
        .navigationTitle(node.title)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            session.startTimer()
        }
        .onDisappear {
            session.stopTimer()
        }
    }

    private var animatedPageContent: some View {
        ZStack {
            ForEach([session.currentPageID], id: \.self) { _ in
                pageContent
                    .transition(
                        .asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        )
                    )
            }
        }
        .animation(.spring(response: 0.42, dampingFraction: 0.86), value: session.currentPageID)
    }

    @ViewBuilder
    private var pageContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 22) {
                if let streakUpdate {
                    LearningStreakCelebrationPage(update: streakUpdate) {
                        withAnimation(.spring(response: 0.34, dampingFraction: 0.78)) {
                            canContinueAfterStreak = true
                        }
                    }
                } else if session.isResultPage {
                    LearningTaskResultPage(
                        percent: session.resultPercentCounter,
                        isShowingContent: session.isShowingResultContent,
                        title: "Урок",
                        value: "\(node.xpReward) XP",
                        timeString: session.timeString,
                        systemImage: "book.pages.fill"
                    )
                } else {
                    let block = infoBlocks[min(session.currentPageIndex, infoBlocks.count - 1)]
                    LearningTaskReferencePage(
                        node: node,
                        symbolName: block.symbolName,
                        title: block.title,
                        text: block.text,
                        notes: block.notes
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .scrollBounceBehavior(.basedOnSize, axes: [.vertical])
    }

    private func completeTask() {
        guard !didApplyCompletion else {
            dismiss()
            return
        }

        didApplyCompletion = true

        if let update = onComplete() {
            canContinueAfterStreak = false
            withAnimation(.spring(response: 0.42, dampingFraction: 0.86)) {
                streakUpdate = update
            }
        } else {
            dismiss()
        }
    }

    private static func makeInfoBlocks(for node: LearningNode) -> [TheoryBlock] {
        if node.id.contains("camera") {
            return [
                TheoryBlock(
                    symbolName: "viewfinder",
                    title: "Держите руки в кадре",
                    text: "Перед распознаванием поместите руки в область камеры. Модели нужен чистый вид кистей, ладоней и пальцев.",
                    notes: ["Руки в кадре", "Плечи расслаблены", "Без резких движений"]
                ),
                TheoryBlock(
                    symbolName: "light.max.fill",
                    title: "Добавьте света",
                    text: "Ровное освещение помогает компьютерному зрению точнее находить ключевые точки руки.",
                    notes: ["Свет спереди", "Без контрового света", "Спокойный фон"]
                ),
                TheoryBlock(
                    symbolName: "hand.raised.fill",
                    title: "Двигайтесь плавно",
                    text: "Сначала выполните жест медленно, затем повторите в естественном темпе. Так прототипу проще считать движение.",
                    notes: ["Сначала медленно", "Повторите один раз", "Естественный темп"]
                )
            ]
        }

        return [
            TheoryBlock(
                symbolName: "hand.wave.fill",
                title: "Визуальный язык",
                text: "Жестовый язык передаёт смысл через руки, мимику и положение тела. Мы начнём с простых повседневных жестов.",
                notes: ["Руки", "Мимика", "Положение тела"]
            ),
            TheoryBlock(
                symbolName: "person.2.fill",
                title: "Контекст важен",
                text: "Жест легче запомнить, если связать его с короткой ситуацией и понятным переводом.",
                notes: ["Смысл", "Диалог", "Перевод"]
            ),
            TheoryBlock(
                symbolName: "camera.viewfinder",
                title: "Учитесь через действие",
                text: "Маршрут чередует короткие справки, практику с камерой и проверки, чтобы жест сразу закреплялся.",
                notes: ["Короткая теория", "Практика сразу", "Быстрая проверка"]
            )
        ]
    }
}

private struct TheoryBlock {
    let symbolName: String
    let title: String
    let text: String
    let notes: [String]
}
