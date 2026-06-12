import SwiftUI

enum LiquidGlassTheme {
    static let background = LinearGradient(
        colors: [
            Color.BackgroundColors.main,
            Color.BackgroundColors.primary,
            Color.BackgroundColors.main
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let accent = Color.SupportColors.lightBlue
    static let secondaryAccent = Color.SupportColors.orange
    static let success = Color.SupportColors.green
    static let warning = Color.SupportColors.yellow
    static let foreground = Color.LabelColors.primary
    static let mutedForeground = Color.LabelColors.secondary
    static let glassTint = Color.BackgroundColors.card.opacity(0.34)
}

struct LiquidGlassBackground: View {
    var body: some View {
        ZStack {
            LiquidGlassTheme.background

            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            LiquidGlassTheme.secondaryAccent.opacity(0.10),
                            Color.clear,
                            LiquidGlassTheme.accent.opacity(0.10)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        }
        .ignoresSafeArea()
    }
}

struct LiquidGlassCard<Content: View>: View {
    var cornerRadius: CGFloat = 28
    var padding: CGFloat = 18
    @ViewBuilder let content: Content

    var body: some View {
        content
            .padding(padding)
            .glassEffect(.regular.tint(LiquidGlassTheme.glassTint), in: .rect(cornerRadius: cornerRadius))
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.55),
                                Color.white.opacity(0.12),
                                LiquidGlassTheme.accent.opacity(0.24)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
            .shadow(color: LiquidGlassTheme.accent.opacity(0.12), radius: 24, x: 0, y: 14)
    }
}

struct LiquidGlassButton: View {
    let title: String
    let systemImage: String
    var tint: Color = LiquidGlassTheme.accent
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .foregroundStyle(.white)
        }
        .buttonStyle(.glassProminent)
        .tint(tint)
    }
}

struct LiquidGlassProgressView: View {
    let value: Double
    var height: CGFloat = 12
    var tint: Color = LiquidGlassTheme.accent

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.white.opacity(0.16))

                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [tint, tint.opacity(0.56)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: max(0, min(1, value)) * proxy.size.width)
            }
        }
        .frame(height: height)
        .animation(.spring(response: 0.45, dampingFraction: 0.82), value: value)
    }
}
