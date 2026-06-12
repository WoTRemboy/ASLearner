import SwiftUI

struct ModuleHeaderCard: View {
    let module: LearningModule
    let progress: Double

    var body: some View {
        LiquidGlassCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top, spacing: 14) {
                    Image(systemName: "map.fill")
                        .font(Font.title2(.bold))
                        .foregroundStyle(LiquidGlassTheme.accent)
                        .frame(width: 48, height: 48)
                        .background(Color.white.opacity(0.16), in: RoundedRectangle(cornerRadius: 16, style: .continuous))

                    VStack(alignment: .leading, spacing: 5) {
                        Text(module.title)
                            .font(Font.title2(.bold))
                            .foregroundStyle(LiquidGlassTheme.foreground)

                        Text(module.description)
                            .font(Font.body())
                            .foregroundStyle(LiquidGlassTheme.mutedForeground)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(Texts.LearningFlowPage.progress)
                        Spacer()
                        Text("\(Int(progress * 100))%")
                    }
                    .font(Font.caption(.semibold))
                    .foregroundStyle(LiquidGlassTheme.mutedForeground)

                    LiquidGlassProgressView(value: progress, height: 10, tint: LiquidGlassTheme.success)
                }
            }
        }
    }
}

struct LearningPathLine: View {
    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [
                        LiquidGlassTheme.accent.opacity(0.25),
                        Color.white.opacity(0.24),
                        LiquidGlassTheme.secondaryAccent.opacity(0.25)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(width: 5)
            .clipShape(Capsule())
            .glassEffect(.regular.tint(Color.white.opacity(0.10)), in: .capsule)
    }
}

struct LearningNodeCircle: View {
    let node: LearningNode
    let isCurrent: Bool
    let action: () -> Void

    @State private var pulse = false

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(fillStyle)
                    .frame(width: 74, height: 74)
                    .glassEffect(glassEffect, in: .circle)
                    .overlay {
                        Circle()
                            .stroke(strokeColor, lineWidth: node.status == .available ? 2 : 1)
                    }
                    .shadow(color: shadowColor, radius: isCurrent ? 24 : 10, x: 0, y: 10)

                if isCurrent {
                    Circle()
                        .stroke(LiquidGlassTheme.accent.opacity(0.36), lineWidth: 8)
                        .frame(width: 86, height: 86)
                        .scaleEffect(pulse ? 1.12 : 0.92)
                        .opacity(pulse ? 0.12 : 0.55)
                }

                Image(systemName: symbolName)
                    .font(Font.title2(.bold))
                    .foregroundStyle(iconColor)
            }
            .frame(width: 96, height: 96)
        }
        .buttonStyle(.plain)
        .disabled(node.status == .locked)
        .opacity(node.status == .locked ? 0.48 : 1)
        .onAppear {
            guard isCurrent else { return }
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                pulse = true
            }
        }
        .accessibilityLabel(node.title)
    }

    private var symbolName: String {
        switch node.status {
        case .completed:
            "checkmark"
        case .locked:
            "lock.fill"
        case .available:
            node.type.symbolName
        }
    }

    private var fillStyle: LinearGradient {
        let colors: [Color]
        switch node.status {
        case .completed:
            colors = [LiquidGlassTheme.success, LiquidGlassTheme.success.opacity(0.58)]
        case .available:
            colors = [LiquidGlassTheme.accent, LiquidGlassTheme.secondaryAccent.opacity(0.78)]
        case .locked:
            colors = [Color.white.opacity(0.20), Color.white.opacity(0.07)]
        }

        return LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    private var glassEffect: Glass {
        switch node.status {
        case .available:
            .regular.tint(LiquidGlassTheme.accent.opacity(0.28))
        case .completed:
            .regular.tint(LiquidGlassTheme.success.opacity(0.24))
        case .locked:
            .regular.tint(Color.white.opacity(0.08))
        }
    }

    private var strokeColor: Color {
        switch node.status {
        case .completed:
            LiquidGlassTheme.success.opacity(0.65)
        case .available:
            Color.white.opacity(0.72)
        case .locked:
            Color.white.opacity(0.16)
        }
    }

    private var iconColor: Color {
        node.status == .locked ? Color.white.opacity(0.62) : .white
    }

    private var shadowColor: Color {
        switch node.status {
        case .completed:
            LiquidGlassTheme.success.opacity(0.20)
        case .available:
            LiquidGlassTheme.accent.opacity(0.30)
        case .locked:
            Color.clear
        }
    }
}

struct LearningNodeLabel: View {
    let node: LearningNode

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(spacing: 6) {
                Text("\(node.order)")
                    .font(Font.caption(.bold))
                    .foregroundStyle(statusColor)

                Text(node.type.title)
                    .font(Font.caption(.semibold))
                    .foregroundStyle(statusColor)
            }

            Text(node.title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(LiquidGlassTheme.foreground)
                .fixedSize(horizontal: false, vertical: true)

            Text("\(node.xpReward) \(Texts.LearningFlowPage.xp)")
                .font(Font.caption())
                .foregroundStyle(LiquidGlassTheme.mutedForeground)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .frame(maxWidth: 168, alignment: .leading)
        .glassEffect(.regular.tint(Color.BackgroundColors.card.opacity(node.status == .locked ? 0.12 : 0.30)), in: .rect(cornerRadius: 18))
        .opacity(node.status == .locked ? 0.48 : 1)
    }

    private var statusColor: Color {
        switch node.status {
        case .completed:
            LiquidGlassTheme.success
        case .available:
            LiquidGlassTheme.accent
        case .locked:
            LiquidGlassTheme.mutedForeground
        }
    }
}
