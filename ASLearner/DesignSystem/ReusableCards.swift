import SwiftUI

struct StatCard: View {
    let title: String
    let value: String
    let systemImage: String
    var tint: Color = LiquidGlassTheme.accent

    var body: some View {
        LiquidGlassCard(cornerRadius: 22, padding: 14) {
            VStack(alignment: .leading, spacing: 12) {
                Image(systemName: systemImage)
                    .font(Font.largeTitle3(.semibold))
                    .foregroundStyle(tint)
                    .frame(width: 34, height: 34)
                    .background(tint.opacity(0.15), in: Circle())

                Text(value)
                    .font(Font.title2(.bold))
                    .foregroundStyle(LiquidGlassTheme.foreground)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)

                Text(title)
                    .font(Font.caption())
                    .foregroundStyle(LiquidGlassTheme.mutedForeground)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct AchievementBadge: View {
    let achievement: AchievementModel

    var body: some View {
        LiquidGlassCard(cornerRadius: 22, padding: 14) {
            HStack(spacing: 14) {
                Image(systemName: achievement.symbolName)
                    .font(Font.title2(.bold))
                    .foregroundStyle(achievement.isUnlocked ? LiquidGlassTheme.warning : Color.white.opacity(0.38))
                    .frame(width: 48, height: 48)
                    .background(Color.white.opacity(achievement.isUnlocked ? 0.18 : 0.08), in: Circle())

                VStack(alignment: .leading, spacing: 4) {
                    Text(achievement.title)
                        .font(Font.largeTitle3(.semibold))
                        .foregroundStyle(LiquidGlassTheme.foreground)
                    Text(achievement.description)
                        .font(Font.caption())
                        .foregroundStyle(LiquidGlassTheme.mutedForeground)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
                Image(systemName: achievement.isUnlocked ? "checkmark.seal.fill" : "lock.fill")
                    .foregroundStyle(achievement.isUnlocked ? LiquidGlassTheme.success : Color.white.opacity(0.35))
            }
        }
    }
}

struct LessonCard: View {
    let lesson: LessonModel
    let isCompleted: Bool
    let progress: Double

    var body: some View {
        LiquidGlassCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top) {
                    Image(systemName: lesson.accentSymbolName)
                        .font(Font.title2(.bold))
                        .foregroundStyle(LiquidGlassTheme.secondaryAccent)
                        .frame(width: 46, height: 46)
                        .background(Color.white.opacity(0.16), in: RoundedRectangle(cornerRadius: 16, style: .continuous))

                    VStack(alignment: .leading, spacing: 4) {
                        Text(lesson.title)
                            .font(Font.title2(.bold))
                            .foregroundStyle(LiquidGlassTheme.foreground)
                        Text(lesson.subtitle)
                            .font(Font.body())
                            .foregroundStyle(LiquidGlassTheme.mutedForeground)
                    }

                    Spacer()

                    if isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title3)
                            .foregroundStyle(LiquidGlassTheme.success)
                    }
                }

                HStack {
                    Label("\(lesson.estimatedMinutes) \(Texts.LessonsPage.minutes)", systemImage: "clock.fill")
                    Spacer()
                    Label("\(lesson.gestureTypes.count) \(Texts.LessonsPage.gestures)", systemImage: "hand.raised.fill")
                }
                .font(Font.caption(.medium))
                .foregroundStyle(LiquidGlassTheme.mutedForeground)

                LiquidGlassProgressView(value: progress, height: 8, tint: isCompleted ? LiquidGlassTheme.success : LiquidGlassTheme.accent)
            }
        }
    }
}

struct GestureChip: View {
    let gesture: GestureModel

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: gesture.symbolName)
            Text(gesture.englishName)
        }
        .font(Font.caption(.semibold))
        .foregroundStyle(LiquidGlassTheme.foreground)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.14), in: Capsule())
        .overlay(Capsule().stroke(Color.white.opacity(0.18), lineWidth: 1))
    }
}
