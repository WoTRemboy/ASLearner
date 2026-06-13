import SwiftUI

struct LearningTaskProgressBar: View {
    let progress: Double
    var tint: Color = LiquidGlassTheme.success

    var body: some View {
        LiquidGlassProgressView(value: progress, height: 18, tint: tint)
    }
}

struct LearningTaskBottomControls: View {
    let timeString: String
    let elapsedSeconds: Int
    let canMoveForward: Bool
    let close: () -> Void
    let moveForward: () -> Void

    var body: some View {
        GlassEffectContainer {
            HStack(spacing: 12) {
                Button(action: close) {
                    Image(systemName: "xmark")
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundStyle(Color.red)
                        .padding()
                }
                .buttonStyle(.glass)

                Text(timeString)
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .contentTransition(.numericText(countsDown: false))
                    .animation(.default, value: elapsedSeconds)
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .glassEffect(.regular.interactive())

                Button(action: moveForward) {
                    Image(systemName: "arrow.forward")
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundStyle(canMoveForward ? LiquidGlassTheme.success : LiquidGlassTheme.mutedForeground.opacity(0.7))
                        .padding()
                }
                .buttonStyle(.glass)
                .disabled(!canMoveForward)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 10)
        }
    }
}

struct LearningTaskResultButton: View {
    let title: String
    let action: () -> Void

    init(title: String = Texts.LearningFlowPage.complete, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
        .buttonStyle(.glassProminent)
        .tint(LiquidGlassTheme.success)
        .frame(height: 70)
        .padding(.horizontal, 20)
        .padding(.bottom, 10)
    }
}

struct LearningTaskResultPage: View {
    let percent: Int
    let isShowingContent: Bool
    let title: String
    let value: String
    let timeString: String
    let systemImage: String
    var tint: Color = LiquidGlassTheme.success

    @Namespace private var namespace

    var body: some View {
        VStack(spacing: 40) {
            Spacer(minLength: 12)

            Text("\(percent)\(isShowingContent ? "%" : "")")
                .font(.system(size: 132, weight: .heavy, design: .rounded))
                .minimumScaleFactor(0.62)
                .lineLimit(1)
                .frame(maxWidth: .infinity)
                .foregroundStyle(LiquidGlassTheme.mutedForeground.opacity(0.48))
                .contentTransition(.numericText(value: Double(percent)))

            if isShowingContent {
                HStack(spacing: 12) {
                    resultPill(
                        title: title,
                        value: value,
                        systemImage: systemImage,
                        tint: tint,
                        glassID: "learning-task-result-main"
                    )

                    resultPill(
                        title: "Time",
                        value: timeString,
                        systemImage: "timer",
                        tint: LiquidGlassTheme.accent,
                        glassID: "learning-task-result-time"
                    )
                }
                .transition(.blurReplace)
            }

            Spacer(minLength: 12)
        }
        .frame(maxWidth: .infinity, minHeight: 540)
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

struct LearningTaskReferencePage: View {
    let node: LearningNode
    let symbolName: String
    let title: String
    let text: String
    let notes: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 28) {
            Image(systemName: symbolName)
                .font(.system(size: 58, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 100, height: 100)
                .background(
                    LinearGradient(
                        colors: [
                            LiquidGlassTheme.accent,
                            LiquidGlassTheme.secondaryAccent.opacity(0.82)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    in: RoundedRectangle(cornerRadius: 30, style: .continuous)
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .stroke(Color.white.opacity(0.42), lineWidth: 1)
                }
                .shadow(color: LiquidGlassTheme.accent.opacity(0.24), radius: 26, x: 0, y: 16)

            VStack(alignment: .leading, spacing: 14) {
                Text(title)
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(LiquidGlassTheme.foreground)
                    .lineLimit(3)
                    .minimumScaleFactor(0.72)
                    .contentTransition(.numericText())

                Text(text)
                    .font(.title3)
                    .fontWeight(.medium)
                    .lineSpacing(4)
                    .foregroundStyle(LiquidGlassTheme.mutedForeground)
                    .fixedSize(horizontal: false, vertical: true)
                    .contentTransition(.numericText())
            }

            VStack(alignment: .leading, spacing: 12) {
                ForEach(notes, id: \.self) { note in
                    HStack(spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.headline)
                            .foregroundStyle(LiquidGlassTheme.success)

                        Text(note)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(LiquidGlassTheme.foreground)
                            .contentTransition(.numericText())
                    }
                    .padding(.vertical, 2)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 18)
    }
}
