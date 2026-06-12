import SwiftUI

struct LearningCheckpointView: View {
    @Environment(\.dismiss) private var dismiss
    let node: LearningNode
    let onComplete: () -> Void

    @State private var completedChecks: Set<String> = []

    private let checks = [
        "Explain what sign language is",
        "Perform Hello and Thank you",
        "Recognize Yes and No",
        "Pass the mini quiz"
    ]

    var body: some View {
        ZStack {
            LiquidGlassBackground()

            ScrollView(showsIndicators: false) {
                content
            }
        }
        .navigationTitle(node.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 18) {
            LearningStepHeader(node: node)
            checklistCard
            completeButton
        }
        .padding(20)
    }

    private var checklistCard: some View {
        LiquidGlassCard {
            VStack(alignment: .leading, spacing: 14) {
                Text("Module checklist")
                    .font(Font.title2(.bold))
                    .foregroundStyle(LiquidGlassTheme.foreground)

                ForEach(checks, id: \.self) { check in
                    checkButton(check)
                }
            }
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

                Text(check)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(LiquidGlassTheme.foreground)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(.plain)
    }

    private var completeButton: some View {
        LiquidGlassButton(title: Texts.LearningFlowPage.completeCheckpoint, systemImage: "flag.checkered", tint: LiquidGlassTheme.success) {
            onComplete()
            dismiss()
        }
        .disabled(completedChecks.count < checks.count)
        .opacity(completedChecks.count == checks.count ? 1 : 0.45)
    }
}
