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
    var tint: Color = LiquidGlassGalleryPalette.tint(for: 0)

    var body: some View {
        LiquidGlassCard(cornerRadius: 22, padding: 14) {
            HStack(spacing: 14) {
                AchievementGalleryIcon(
                    achievement: achievement,
                    tint: tint,
                    size: 52,
                    showsNewBadge: false
                )
                .frame(width: 56, height: 56)
                .layoutPriority(0)

                VStack(alignment: .leading, spacing: 4) {
                    Text(achievement.title)
                        .font(Font.largeTitle3(.semibold))
                        .foregroundStyle(LiquidGlassTheme.foreground)
                        .lineLimit(2)
                        .minimumScaleFactor(0.82)
                    Text(achievement.description)
                        .font(Font.caption())
                        .foregroundStyle(LiquidGlassTheme.mutedForeground)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .layoutPriority(1)

                if achievement.isUnlocked {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundStyle(LiquidGlassTheme.success)
                        .frame(width: 24)
                }
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

struct GestureSchemeImageView: View {
    let gesture: GestureType
    var widthRatio: CGFloat = 0.64
    var maxSide: CGFloat = 320

    var body: some View {
        if let image = Image.GestureScheme.image(for: gesture) {
            image
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
                .containerRelativeFrame(.horizontal) { length, _ in
                    min(length * widthRatio, maxSide)
                }
                .aspectRatio(1, contentMode: .fit)
                .frame(maxWidth: .infinity)
                .accessibilityHidden(true)
        }
    }
}

enum LiquidGlassGalleryPalette {
    static let tints: [Color] = [
        LiquidGlassTheme.warning,
        LiquidGlassTheme.secondaryAccent,
        LiquidGlassTheme.accent,
        LiquidGlassTheme.success
    ]

    static func tint(for index: Int) -> Color {
        tints[index % tints.count]
    }
}

struct GestureGalleryIcon: View {
    let gesture: GestureModel
    let isUnlocked: Bool
    let tint: Color
    var size: CGFloat = 52
    var showsLockOverlay = false

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Image(systemName: gesture.symbolName)
                .font(.system(size: size * 0.44, weight: .bold))
                .foregroundStyle(isUnlocked ? .white : Color.white.opacity(0.50))
                .frame(width: size, height: size)
                .background(
                    LinearGradient(
                        colors: [
                            tint.opacity(isUnlocked ? 0.95 : 0.30),
                            tint.opacity(isUnlocked ? 0.58 : 0.16)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    in: Circle()
                )
                .overlay {
                    Circle()
                        .stroke(Color.white.opacity(isUnlocked ? 0.44 : 0.18), lineWidth: 2)
                }
                .shadow(color: tint.opacity(isUnlocked ? 0.20 : 0.06), radius: size * 0.27, x: 0, y: size * 0.15)

            if showsLockOverlay, !isUnlocked {
                lockOverlay
            }
        }
        .accessibilityLabel(gesture.englishName)
    }

    private var lockOverlay: some View {
        Image(systemName: "lock.fill")
            .font(.system(size: max(10, size * 0.21), weight: .bold))
            .foregroundStyle(Color.white.opacity(0.72))
            .padding(size * 0.11)
            .background(Color.black.opacity(0.22), in: Circle())
            .offset(x: size * 0.10, y: -size * 0.06)
    }
}

struct AchievementGalleryIcon: View {
    let achievement: AchievementModel
    let tint: Color
    var size: CGFloat = 52
    var showsNewBadge = false
    var showsLockOverlay = false

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Image(systemName: achievement.symbolName)
                .font(.system(size: size * 0.46, weight: .bold))
                .foregroundStyle(achievement.isUnlocked ? .white : Color.white.opacity(0.48))
                .frame(width: size, height: size)
                .background(
                    LinearGradient(
                        colors: [
                            tint.opacity(achievement.isUnlocked ? 0.95 : 0.32),
                            tint.opacity(achievement.isUnlocked ? 0.58 : 0.18)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    in: Circle()
                )
                .overlay {
                    Circle()
                        .stroke(Color.white.opacity(achievement.isUnlocked ? 0.44 : 0.20), lineWidth: 2)
                }
                .shadow(color: tint.opacity(achievement.isUnlocked ? 0.22 : 0.08), radius: size * 0.27, x: 0, y: size * 0.15)

            if showsNewBadge, achievement.isUnlocked {
                Text("NEW")
                    .font(.system(size: max(9, size * 0.19), weight: .black))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(LiquidGlassTheme.secondaryAccent, in: Capsule())
                    .offset(x: size * 0.15, y: -size * 0.08)
            } else if showsLockOverlay, !achievement.isUnlocked {
                Image(systemName: "lock.fill")
                    .font(.system(size: max(10, size * 0.21), weight: .bold))
                    .foregroundStyle(Color.white.opacity(0.72))
                    .padding(size * 0.11)
                    .background(Color.black.opacity(0.22), in: Circle())
                    .offset(x: size * 0.10, y: -size * 0.06)
            }
        }
        .accessibilityLabel(achievement.title)
    }
}
