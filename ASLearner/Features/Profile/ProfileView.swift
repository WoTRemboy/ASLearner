import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var appViewModel: AppViewModel

    var body: some View {
        ZStack {
            LiquidGlassBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    profileHeader
                        .padding(.horizontal, 20)

                    overviewGrid
                        .padding(.horizontal, 20)

                    recognitionAnalysis
                        .padding(.horizontal, 20)

                    achievementGallery
                        .padding(.horizontal, 20)
                }
                .padding(.bottom, 28)
            }
        }
        .navigationTitle(Texts.ProfilePage.title)
        .navigationBarTitleDisplayMode(.large)
    }

    private var profileHeader: some View {
        LiquidGlassCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(alignment: .firstTextBaseline, spacing: 0) {
                            Text("\(Texts.HomePage.progressLevel) \(appViewModel.progress.level)")
                                .foregroundStyle(LiquidGlassTheme.foreground)
                            Text(" • \(appViewModel.progress.xp) \(Texts.HomePage.xp)")
                                .foregroundStyle(LiquidGlassTheme.mutedForeground)
                        }
                        .font(Font.title())
                    }
                    Spacer()
                    Text("\(Int(appViewModel.progress.levelProgress * 100))%")
                        .font(Font.largeTitle3(.bold))
                        .foregroundStyle(LiquidGlassTheme.accent)
                }

                LiquidGlassProgressView(value: appViewModel.progress.levelProgress)

                Text("\(Texts.HomePage.nextLevel) \(appViewModel.progress.nextLevelXP) \(Texts.HomePage.xp)")
                    .font(Font.caption())
                    .foregroundStyle(LiquidGlassTheme.mutedForeground)
            }
        }
    }

    private var overviewGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
            ProfileStatTile(title: Texts.Stats.streak, value: "\(appViewModel.progress.streak)d", systemImage: "flame.fill", tint: LiquidGlassTheme.secondaryAccent)
            ProfileStatTile(title: Texts.Stats.lessons, value: "\(completedLearningStepCount)", systemImage: "play.fill")
        }
    }

    private var recognitionAnalysis: some View {
        NavigationLink {
            DictionaryView()
        } label: {
            LiquidGlassCard {
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        Text(Texts.StatisticsPage.recognitionCoverage)
                            .font(Font.largeTitle3(.semibold))
                            .foregroundStyle(LiquidGlassTheme.foreground)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(Font.largeTitle3(.bold))
                            .foregroundStyle(LiquidGlassTheme.mutedForeground)
                    }

                    LiquidGlassProgressView(
                        value: Double(appViewModel.progress.recognizedGestures.count) / Double(max(appViewModel.gestures.count, 1)),
                        tint: LiquidGlassTheme.success
                    )

                    LazyVGrid(columns: recognitionGalleryColumns, spacing: 12) {
                        ForEach(Array(appViewModel.gestures.enumerated()), id: \.element.id) { index, gesture in
                            ProfileGestureIcon(
                                gesture: gesture,
                                isUnlocked: appViewModel.progress.recognizedGestures.contains(gesture.type),
                                tint: achievementTints[index % achievementTints.count]
                            )
                        }
                    }
                    .padding(.top, 2)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .contentShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private var achievementGallery: some View {
        NavigationLink {
            AchievementsView()
        } label: {
            LiquidGlassCard {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text(Texts.ProfilePage.latestAchievements)
                            .font(Font.largeTitle3(.semibold))
                            .foregroundStyle(LiquidGlassTheme.foreground)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(Font.largeTitle3(.bold))
                            .foregroundStyle(LiquidGlassTheme.mutedForeground)
                    }

                    HStack(spacing: 10) {
                        ForEach(Array(appViewModel.achievements.prefix(4).enumerated()), id: \.element.id) { index, achievement in
                            ProfileAchievementIcon(
                                achievement: achievement,
                                tint: achievementTints[index % achievementTints.count]
                            )
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .contentShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private var completedLearningStepCount: Int {
        min(appViewModel.progress.completedLearningNodeIDs.count, 10)
    }

    private var recognitionGalleryColumns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 8), count: 5)
    }

    private var achievementTints: [Color] {
        [
            LiquidGlassTheme.warning,
            LiquidGlassTheme.secondaryAccent,
            LiquidGlassTheme.accent,
            LiquidGlassTheme.success
        ]
    }
}

private struct ProfileGestureIcon: View {
    let gesture: GestureModel
    let isUnlocked: Bool
    let tint: Color

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Image(systemName: gesture.symbolName)
                .font(.system(size: 23, weight: .bold))
                .foregroundStyle(isUnlocked ? .white : Color.white.opacity(0.50))
                .frame(width: 52, height: 52)
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
                .shadow(color: tint.opacity(isUnlocked ? 0.20 : 0.06), radius: 14, x: 0, y: 8)

            if !isUnlocked {
                Image(systemName: "lock.fill")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Color.white.opacity(0.72))
                    .padding(6)
                    .background(Color.black.opacity(0.22), in: Circle())
                    .offset(x: 5, y: -3)
            }
        }
        .frame(maxWidth: .infinity)
        .accessibilityLabel(gesture.englishName)
    }
}

private struct ProfileStatTile: View {
    let title: String
    let value: String
    let systemImage: String
    var tint: Color = LiquidGlassTheme.accent

    var body: some View {
        LiquidGlassCard(cornerRadius: 22, padding: 14) {
            HStack(alignment: .center, spacing: 10) {
                VStack(alignment: .center, spacing: 6) {
                    Image(systemName: systemImage)
                        .font(Font.largeTitle3(.semibold))
                        .foregroundStyle(tint)
                        .frame(width: 34, height: 34)
                        .background(tint.opacity(0.15), in: Circle())

                    Text(title)
                        .font(Font.caption())
                        .foregroundStyle(LiquidGlassTheme.mutedForeground)
                        .multilineTextAlignment(.trailing)
                        .lineLimit(2)
                        .minimumScaleFactor(0.76)
                }
                Spacer(minLength: 6)

                Text(value)
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundStyle(LiquidGlassTheme.foreground)
                    .lineLimit(1)
                    //.minimumScaleFactor(0.48)
            }
            .frame(maxWidth: .infinity, minHeight: 76, alignment: .center)
        }
    }
}

private struct ProfileAchievementIcon: View {
    let achievement: AchievementModel
    let tint: Color

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Image(systemName: achievement.symbolName)
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(achievement.isUnlocked ? .white : Color.white.opacity(0.48))
                .frame(width: 52, height: 52)
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
                .shadow(color: tint.opacity(achievement.isUnlocked ? 0.22 : 0.08), radius: 14, x: 0, y: 8)

            if achievement.isUnlocked {
                Text("NEW")
                    .font(.system(size: 10, weight: .black))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(LiquidGlassTheme.secondaryAccent, in: Capsule())
                    .offset(x: 8, y: -4)
            } else {
                Image(systemName: "lock.fill")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Color.white.opacity(0.72))
                    .padding(6)
                    .background(Color.black.opacity(0.22), in: Circle())
                    .offset(x: 5, y: -3)
            }
        }
        .frame(maxWidth: .infinity)
    }
}
