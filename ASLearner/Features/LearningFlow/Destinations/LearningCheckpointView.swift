import SwiftUI

struct LearningCheckpointView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var session = LearningTaskSessionViewModel(pageCount: 3)

    let node: LearningNode
    let onComplete: () -> DayStreakUpdate?

    @State private var completedChecks: Set<String> = []
    @State private var streakUpdate: DayStreakUpdate?
    @State private var canContinueAfterStreak = false
    @State private var didApplyCompletion = false

    private let checks = [
        "Объяснить, что такое жестовый язык",
        "Распознать «Да» и «Нет»",
        "Показать «Привет» и «Спасибо»",
        "Пройти мини-тест"
    ]

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
                    title: Texts.LearningFlowPage.completeCheckpoint,
                    isEnabled: session.isShowingResultContent,
                    action: completeTask
                )
            } else {
                LearningTaskBottomControls(
                    timeString: session.timeString,
                    elapsedSeconds: session.elapsedSeconds,
                    canMoveForward: canMoveForward,
                    close: { dismiss() },
                    moveForward: { session.moveForward(canMoveForward: canMoveForward) }
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

    private var canMoveForward: Bool {
        switch session.currentPageIndex {
        case 0:
            true
        case 1:
            completedChecks.count == checks.count
        default:
            true
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
                } else {
                    switch session.currentPageIndex {
                case 0:
                    LearningTaskReferencePage(
                        node: node,
                        symbolName: "flag.checkered",
                        title: "Итог модуля",
                        text: "Завершите раздел: подтвердите теорию, практику с камерой и короткие проверки распознавания.",
                        notes: ["4 проверки", "Базовые жесты", "Обновление прогресса"]
                    )
                case 1:
                    checklistPage
                default:
                    LearningTaskResultPage(
                        percent: session.resultPercentCounter,
                        isShowingContent: session.isShowingResultContent,
                        title: "Итог",
                        value: "\(node.xpReward) XP",
                        timeString: session.timeString,
                        systemImage: "flag.checkered"
                    )
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .scrollBounceBehavior(.basedOnSize, axes: [.vertical])
    }

    private var checklistPage: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 10) {
                Text("Чек-лист модуля")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(LiquidGlassTheme.foreground)

                Text("Отметьте пункты после проверки навыка.")
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundStyle(LiquidGlassTheme.mutedForeground)
            }

            VStack(spacing: 12) {
                ForEach(checks, id: \.self) { check in
                    checkButton(check)
                }
            }
        }
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

    private func checkButton(_ check: String) -> some View {
        Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                _ = completedChecks.insert(check)
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: completedChecks.contains(check) ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(completedChecks.contains(check) ? LiquidGlassTheme.success : LiquidGlassTheme.mutedForeground)
                    .font(.title3)

                Text(check)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(LiquidGlassTheme.foreground)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .glassEffect(.regular.interactive().tint(rowTint(for: check)), in: .rect(cornerRadius: 18))
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
    }

    private func rowTint(for check: String) -> Color {
        completedChecks.contains(check) ? LiquidGlassTheme.success.opacity(0.16) : LiquidGlassTheme.glassTint
    }
}
