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
                            Text(Texts.ProfilePage.levelTitle(appViewModel.progress.level))
                                .foregroundStyle(LiquidGlassTheme.foreground)
                            Text(Texts.ProfilePage.inlineXP(appViewModel.progress.xp))
                                .foregroundStyle(LiquidGlassTheme.mutedForeground)
                        }
                        .font(Font.title())
                    }
                    Spacer()
                    Text(Texts.ProfilePage.progressPercent(appViewModel.progress.levelProgress))
                        .font(Font.largeTitle3(.bold))
                        .foregroundStyle(LiquidGlassTheme.accent)
                }

                LiquidGlassProgressView(value: appViewModel.progress.levelProgress)

                Text(Texts.ProfilePage.nextLevelXP(appViewModel.progress.nextLevelXP))
                    .font(Font.caption())
                    .foregroundStyle(LiquidGlassTheme.mutedForeground)
            }
        }
    }

    private var overviewGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
            ProfileStatTile(title: Texts.Stats.streak, value: "\(appViewModel.progress.streak)", systemImage: "flame.fill", tint: LiquidGlassTheme.secondaryAccent)
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
                        ForEach(Array(recognitionPreviewGestures.enumerated()), id: \.element.id) { index, gesture in
                            GestureGalleryIcon(
                                gesture: gesture,
                                isUnlocked: appViewModel.progress.recognizedGestures.contains(gesture.type),
                                tint: LiquidGlassGalleryPalette.tint(for: index),
                                showsLockOverlay: true
                            )
                            .frame(maxWidth: .infinity)
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
                            AchievementGalleryIcon(
                                achievement: achievement,
                                tint: LiquidGlassGalleryPalette.tint(for: index),
                                showsNewBadge: true,
                                showsLockOverlay: true
                            )
                            .frame(maxWidth: .infinity)
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

    private var recognitionPreviewGestures: [GestureModel] {
        Array(appViewModel.gestures.prefix(5))
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
