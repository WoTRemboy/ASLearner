import SwiftUI

struct LearningTheoryView: View {
    @Environment(\.dismiss) private var dismiss
    let node: LearningNode
    let onComplete: () -> Void

    var body: some View {
        ZStack {
            LiquidGlassBackground()

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    LearningStepHeader(node: node)

                    ForEach(infoBlocks, id: \.title) { block in
                        LiquidGlassCard(cornerRadius: 22, padding: 16) {
                            VStack(alignment: .leading, spacing: 8) {
                                Label(block.title, systemImage: block.symbolName)
                                    .font(Font.largeTitle3(.semibold))
                                    .foregroundStyle(LiquidGlassTheme.foreground)

                                Text(block.text)
                                    .font(Font.body())
                                    .foregroundStyle(LiquidGlassTheme.mutedForeground)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }

                    LiquidGlassButton(title: Texts.LearningFlowPage.completeLesson, systemImage: "checkmark.circle.fill") {
                        onComplete()
                        dismiss()
                    }
                }
                .padding(20)
            }
        }
        .navigationTitle(node.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var infoBlocks: [TheoryBlock] {
        if node.id.contains("camera") {
            return [
                TheoryBlock(symbolName: "viewfinder", title: "Keep hands visible", text: "Place both hands inside the camera frame before starting recognition."),
                TheoryBlock(symbolName: "light.max.fill", title: "Use good lighting", text: "A bright and even light source helps computer vision detect key points more reliably."),
                TheoryBlock(symbolName: "hand.raised.fill", title: "Move smoothly", text: "Perform the gesture slowly first, then repeat it with natural speed.")
            ]
        }

        return [
            TheoryBlock(symbolName: "hand.wave.fill", title: "Visual language", text: "Sign language uses hands, facial expression and body position to communicate meaning."),
            TheoryBlock(symbolName: "person.2.fill", title: "Context matters", text: "The same movement can be understood better when it is practiced in short everyday dialogs."),
            TheoryBlock(symbolName: "camera.viewfinder", title: "App practice", text: "This prototype combines lessons, recognition scenarios and quizzes into one learning path.")
        ]
    }
}

private struct TheoryBlock {
    let symbolName: String
    let title: String
    let text: String
}
