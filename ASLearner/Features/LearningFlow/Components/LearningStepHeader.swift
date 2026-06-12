import SwiftUI

struct LearningStepHeader: View {
    let node: LearningNode

    var body: some View {
        LiquidGlassCard {
            HStack(alignment: .top, spacing: 14) {
                Image(systemName: node.type.symbolName)
                    .font(Font.title2(.bold))
                    .foregroundStyle(LiquidGlassTheme.accent)
                    .frame(width: 50, height: 50)
                    .background(Color.white.opacity(0.14), in: RoundedRectangle(cornerRadius: 16, style: .continuous))

                VStack(alignment: .leading, spacing: 6) {
                    Text(node.title)
                        .font(Font.title2(.bold))
                        .foregroundStyle(LiquidGlassTheme.foreground)

                    Text(node.subtitle)
                        .font(Font.body())
                        .foregroundStyle(LiquidGlassTheme.mutedForeground)
                        .fixedSize(horizontal: false, vertical: true)

                    Label("\(node.xpReward) \(Texts.LearningFlowPage.xp)", systemImage: "bolt.fill")
                        .font(Font.caption(.semibold))
                        .foregroundStyle(LiquidGlassTheme.warning)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
