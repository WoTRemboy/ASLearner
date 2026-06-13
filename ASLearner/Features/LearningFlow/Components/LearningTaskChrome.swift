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
                    .font(.system(size: 34, weight: .semibold, design: .rounded))
                    .fontWeight(.semibold)
                    .lineLimit(1)
                    .minimumScaleFactor(0.55)
                    .allowsTightening(true)
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
    var isEnabled = true
    let action: () -> Void

    init(
        title: String = Texts.LearningFlowPage.complete,
        isEnabled: Bool = true,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.isEnabled = isEnabled
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
        .tint(isEnabled ? LiquidGlassTheme.success : LiquidGlassTheme.mutedForeground.opacity(0.45))
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1 : 0.56)
        .scaleEffect(isEnabled ? 1 : 0.97)
        .animation(.spring(response: 0.34, dampingFraction: 0.78), value: isEnabled)
        .frame(height: 70)
        .padding(.horizontal, 20)
        .padding(.bottom, 10)
    }
}

struct SkipGestureToolbarButton: View {
    let onConfirm: () -> Void

    @State private var isShowingConfirmation = false

    var body: some View {
        Button(Texts.LearningFlowPage.skipGesture) {
            isShowingConfirmation = true
        }
        .font(.headline)
        .popover(
            isPresented: $isShowingConfirmation,
            attachmentAnchor: .rect(.bounds),
            arrowEdge: .top
        ) {
            SkipGestureConfirmationPopover {
                isShowingConfirmation = false
                onConfirm()
            } onCancel: {
                isShowingConfirmation = false
            }
            .presentationCompactAdaptation(.popover)
        }
    }
}

private struct SkipGestureConfirmationPopover: View {
    let onConfirm: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(Texts.LearningFlowPage.skipGestureTitle)
                .font(.headline)
                .foregroundStyle(LiquidGlassTheme.foreground)

            Text(Texts.LearningFlowPage.skipGestureMessage)
                .font(.subheadline)
                .foregroundStyle(LiquidGlassTheme.mutedForeground)
                .fixedSize(horizontal: false, vertical: true)

            VStack(spacing: 10) {
                Button(role: .destructive, action: onConfirm) {
                    Text(Texts.LearningFlowPage.skipGestureConfirm)
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                Button(action: onCancel) {
                    Text(Texts.OnboardingPage.CameraAlert.cancel)
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
        }
        .padding(18)
        .frame(width: 300)
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

struct LearningStreakCelebrationPage: View {
    let update: DayStreakUpdate
    var onCountAnimationCompleted: () -> Void = {}

    @State private var displayedStreak: Int
    @State private var didAnimateStreak = false

    init(update: DayStreakUpdate, onCountAnimationCompleted: @escaping () -> Void = {}) {
        self.update = update
        self.onCountAnimationCompleted = onCountAnimationCompleted
        _displayedStreak = State(initialValue: update.previousStreak)
    }

    var body: some View {
        VStack(spacing: 32) {
            Spacer(minLength: 16)

            VStack(spacing: 10) {
                HStack(alignment: .center, spacing: 16) {
                    Text("\(displayedStreak)")
                        .font(.system(size: 132, weight: .heavy, design: .rounded))
                        .foregroundStyle(LiquidGlassTheme.secondaryAccent)
                        .lineLimit(1)
                        .minimumScaleFactor(0.58)
                        .contentTransition(.numericText(value: Double(displayedStreak)))

                    Image(systemName: "flame.fill")
                        .font(.system(size: 96, weight: .black))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    LiquidGlassTheme.secondaryAccent,
                                    LiquidGlassTheme.warning
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .shadow(color: LiquidGlassTheme.secondaryAccent.opacity(0.28), radius: 20, x: 0, y: 12)
                        .symbolEffect(.bounce, value: update.currentStreak)
                }
                .frame(maxWidth: .infinity)

                Text(Texts.LearningFlowPage.streakTitle)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(LiquidGlassTheme.secondaryAccent)
            }

            streakWeekView

            Text(Texts.LearningFlowPage.streakSubtitle)
                .font(.subheadline.weight(.medium))
                .multilineTextAlignment(.center)
                .foregroundStyle(LiquidGlassTheme.mutedForeground)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 12)

            Spacer(minLength: 16)
        }
        .frame(maxWidth: .infinity, minHeight: 540)
        .onAppear {
            guard !didAnimateStreak else { return }
            didAnimateStreak = true
            displayedStreak = update.previousStreak

            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 1_000_000_000)

                withAnimation(.spring(response: 0.46, dampingFraction: 0.82)) {
                    displayedStreak = update.currentStreak
                }

                try? await Task.sleep(nanoseconds: 520_000_000)
                onCountAnimationCompleted()
            }
        }
    }

    private var streakWeekView: some View {
        HStack(spacing: 10) {
            ForEach(streakDays) { day in
                StreakDayCircle(day: day)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }

    private var streakDays: [StreakDayModel] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: update.date)
        let orderedWeekdayIndexes = (0..<7).map { (calendar.firstWeekday - 1 + $0) % 7 }
        let todayWeekdayIndex = calendar.component(.weekday, from: today) - 1
        let todayPosition = orderedWeekdayIndexes.firstIndex(of: todayWeekdayIndex) ?? 0
        let startOfWeek = calendar.date(byAdding: .day, value: -todayPosition, to: today) ?? today
        let symbols = calendar.shortWeekdaySymbols
        let completedEndPosition = displayedStreak == update.currentStreak ? todayPosition : todayPosition - 1
        let completedStartPosition = max(0, completedEndPosition - max(0, displayedStreak - 1))

        return orderedWeekdayIndexes.enumerated().map { position, weekdayIndex in
            let date = calendar.date(byAdding: .day, value: position, to: startOfWeek) ?? today
            let isToday = calendar.isDate(date, inSameDayAs: today)
            let isCompleted = displayedStreak > 0 && position >= completedStartPosition && position <= completedEndPosition

            return StreakDayModel(
                id: position,
                title: symbols[weekdayIndex].prefix(2).description,
                isToday: isToday,
                isCompleted: isCompleted
            )
        }
    }
}

private struct StreakDayModel: Identifiable {
    let id: Int
    let title: String
    let isToday: Bool
    let isCompleted: Bool
}

private struct StreakDayCircle: View {
    let day: StreakDayModel

    var body: some View {
        VStack(spacing: 8) {
            Text(day.title)
                .font(.caption.weight(.bold))
                .foregroundStyle(day.isToday ? LiquidGlassTheme.secondaryAccent : LiquidGlassTheme.mutedForeground)

            ZStack {
                Circle()
                    .fill(circleFill)
                    .frame(width: 42, height: 42)
                    .shadow(color: shadowColor, radius: day.isToday ? 14 : 8, x: 0, y: 6)

                Image(systemName: day.isCompleted ? "checkmark" : "circle")
                    .font(.system(size: day.isCompleted ? 18 : 12, weight: .heavy))
                    .foregroundStyle(day.isCompleted ? .white : LiquidGlassTheme.mutedForeground.opacity(0.7))
            }
            .overlay {
                if day.isToday {
                    Circle()
                        .stroke(Color.white.opacity(0.66), lineWidth: 2)
                }
            }
            .scaleEffect(day.isToday ? 1.1 : 1)
            .animation(.spring(response: 0.42, dampingFraction: 0.78), value: day.isCompleted)
        }
        .frame(maxWidth: .infinity)
    }

    private var circleFill: Color {
        if day.isCompleted {
            return day.isToday ? LiquidGlassTheme.secondaryAccent : LiquidGlassTheme.warning
        }

        return LiquidGlassTheme.mutedForeground.opacity(0.16)
    }

    private var shadowColor: Color {
        day.isCompleted ? circleFill.opacity(0.28) : .clear
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
