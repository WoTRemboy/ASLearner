import SwiftUI

struct ModuleHeaderCard: View {
    let module: LearningModule
    var transitionID: String?
    var namespace: Namespace.ID?
    var action: (() -> Void)?

    var body: some View {
        Group {
            if let action {
                Button(action: action) {
                    content
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                }
                .buttonStyle(.plain)
            } else {
                content
            }
        }
        .accessibilityAddTraits(action == nil ? [] : .isButton)
    }

    private var content: some View {
        LiquidGlassCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top, spacing: 14) {
                    Image(systemName: "graduationcap.fill")
                        .font(Font.title2(.bold))
                        .foregroundStyle(.white)
                        .frame(width: 48, height: 48)
                        .background(
                            LinearGradient(
                                colors: [
                                    LiquidGlassTheme.accent.opacity(0.95),
                                    LiquidGlassTheme.accent.opacity(0.62)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            in: RoundedRectangle(cornerRadius: 16, style: .continuous)
                        )
                        .overlay {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(Color.white.opacity(0.38), lineWidth: 1)
                        }

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
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .overlay {
            ZoomTransitionSourceOverlay(id: transitionID, namespace: namespace, cornerRadius: 28)
        }
    }
}

struct ModuleProgressDock: View {
    let progress: Double

    var body: some View {
        LiquidGlassCard(cornerRadius: 24, padding: 14) {
            VStack(alignment: .leading, spacing: 9) {
                HStack {
                    Text(Texts.LearningFlowPage.progress)
                    Spacer()
                    Text("\(Int(progress * 100))%")
                }
                .font(Font.caption(.semibold))
                .foregroundStyle(LiquidGlassTheme.mutedForeground)

                ModuleProgressBar(value: progress)
            }
        }
        .padding(.horizontal, 20)
    }
}

private struct ModuleProgressBar: View {
    let value: Double

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(LiquidGlassTheme.accent.opacity(0.22))
                    .overlay {
                        Capsule()
                            .stroke(LiquidGlassTheme.accent.opacity(0.34), lineWidth: 1)
                    }

                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                LiquidGlassTheme.success,
                                LiquidGlassTheme.success.opacity(0.62)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: max(0, min(1, value)) * proxy.size.width)
            }
        }
        .frame(height: 10)
        .animation(.spring(response: 0.45, dampingFraction: 0.82), value: value)
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
    var isSelected = false
    let namespace: Namespace.ID
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

                if isSelected {
                    Circle()
                        .stroke(Color.white.opacity(0.88), lineWidth: 4)
                        .frame(width: 84, height: 84)
                        .shadow(color: LiquidGlassTheme.accent.opacity(0.45), radius: 16, x: 0, y: 8)
                }

                Image(systemName: symbolName)
                    .font(Font.title2(.bold))
                    .foregroundStyle(iconColor)
            }
            .frame(width: 96, height: 96)
        }
        .buttonStyle(.plain)
        .opacity(node.status == .locked ? 0.72 : 1)
        .onAppear {
            guard isCurrent else { return }
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                pulse = true
            }
        }
        .overlay {
            ZoomTransitionSourceOverlay(id: node.id, namespace: namespace, cornerRadius: 48)
                .frame(width: 96, height: 96)
        }
        .accessibilityLabel(node.title)
    }

    private var symbolName: String {
        switch node.status {
        case .completed:
            "checkmark"
        case .locked:
            node.type.symbolName
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
            colors = [
                LiquidGlassTheme.accent.opacity(0.46),
                LiquidGlassTheme.secondaryAccent.opacity(0.30)
            ]
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
            .regular.tint(LiquidGlassTheme.accent.opacity(0.16))
        }
    }

    private var strokeColor: Color {
        switch node.status {
        case .completed:
            LiquidGlassTheme.success.opacity(0.65)
        case .available:
            Color.white.opacity(0.72)
        case .locked:
            LiquidGlassTheme.accent.opacity(0.38)
        }
    }

    private var iconColor: Color {
        node.status == .locked ? Color.white.opacity(0.68) : .white
    }

    private var shadowColor: Color {
        switch node.status {
        case .completed:
            LiquidGlassTheme.success.opacity(0.20)
        case .available:
            LiquidGlassTheme.accent.opacity(0.30)
        case .locked:
            LiquidGlassTheme.accent.opacity(0.10)
        }
    }
}

struct LearningNodeDetailCard: View {
    let node: LearningNode
    let onStart: () -> Void

    private var canStart: Bool {
        node.status != .locked
    }

    var body: some View {
        VStack(spacing: 0) {
            Image(systemName: node.status == .completed ? "checkmark.circle.fill" : node.type.symbolName)
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 72, height: 72)
                .background(node.status == .completed ? LiquidGlassTheme.success : LiquidGlassTheme.accent, in: Circle())
                .overlay {
                    Circle()
                        .stroke(Color.white.opacity(0.46), lineWidth: 5)
                }
                .shadow(color: LiquidGlassTheme.accent.opacity(0.24), radius: 18, x: 0, y: 10)
                .padding(.bottom, -10)
                .zIndex(1)

            LiquidGlassCard(cornerRadius: 26, padding: 18) {
                VStack(alignment: .leading, spacing: 14) {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 8) {
                            Text(node.type.title)
                                .font(Font.caption(.bold))
                                .foregroundStyle(detailTint)

                            Text("\(Texts.LearningFlowPage.unit) \(node.order)")
                                .font(Font.caption(.semibold))
                                .foregroundStyle(LiquidGlassTheme.mutedForeground)
                        }

                        Text(node.title)
                            .font(Font.title2(.bold))
                            .foregroundStyle(LiquidGlassTheme.foreground)

                        Text(node.status == .locked ? Texts.LearningFlowPage.lockedNode : node.subtitle)
                            .font(Font.body())
                            .foregroundStyle(LiquidGlassTheme.mutedForeground)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Button(action: onStart) {
                        HStack(spacing: 6) {
                            Text(Texts.LearningFlowPage.start)
                            Text("+\(node.xpReward) \(Texts.LearningFlowPage.xp)")
                        }
                        .font(.headline)
                        .textCase(.uppercase)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .foregroundStyle(canStart ? detailTint : LiquidGlassTheme.mutedForeground)
                        .background(Color.white.opacity(canStart ? 0.92 : 0.42), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .disabled(!canStart)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 4)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }

    private var detailTint: Color {
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

private struct ZoomTransitionSourceOverlay: View {
    let id: String?
    let namespace: Namespace.ID?
    let cornerRadius: CGFloat

    @ViewBuilder
    var body: some View {
        if let id, let namespace {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(Color.clear)
                .matchedTransitionSource(id: id, in: namespace) { source in
                    source
                        .background(Color.clear)
                        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                }
                .allowsHitTesting(false)
        } else {
            EmptyView()
        }
    }
}
