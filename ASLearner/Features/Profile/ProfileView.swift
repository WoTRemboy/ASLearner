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

                    quizHistory
                        .padding(.horizontal, 20)

                    achievementsSection
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
                        Text("\(Texts.HomePage.progressLevel) \(appViewModel.progress.level)")
                            .font(Font.title())
                            .foregroundStyle(LiquidGlassTheme.foreground)
                        Text("\(appViewModel.progress.xp) \(Texts.HomePage.xp) • \(appViewModel.progress.streak)-\(Texts.HomePage.streak)")
                            .font(Font.subheadline())
                            .foregroundStyle(LiquidGlassTheme.mutedForeground)
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
            StatCard(title: Texts.HomePage.xp, value: "\(appViewModel.progress.xp)", systemImage: "bolt.fill")
            StatCard(title: Texts.Stats.level, value: "\(appViewModel.progress.level)", systemImage: "arrow.up.circle.fill", tint: LiquidGlassTheme.success)
            StatCard(title: Texts.Stats.streak, value: "\(appViewModel.progress.streak)d", systemImage: "flame.fill", tint: LiquidGlassTheme.secondaryAccent)
            StatCard(title: Texts.Stats.badges, value: "\(appViewModel.progress.unlockedAchievementIDs.count)", systemImage: "trophy.fill", tint: LiquidGlassTheme.warning)
            StatCard(title: Texts.Stats.lessons, value: "\(appViewModel.progress.completedLessonIDs.count)/\(appViewModel.lessons.count)", systemImage: "play.fill")
            StatCard(title: Texts.Stats.averageQuiz, value: "\(Int(appViewModel.averageQuizScore * 100))%", systemImage: "percent", tint: LiquidGlassTheme.warning)
        }
    }

    private var recognitionAnalysis: some View {
        LiquidGlassCard {
            VStack(alignment: .leading, spacing: 14) {
                Text(Texts.StatisticsPage.recognitionCoverage)
                    .font(Font.largeTitle3(.semibold))
                    .foregroundStyle(LiquidGlassTheme.foreground)

                LiquidGlassProgressView(
                    value: Double(appViewModel.progress.recognizedGestures.count) / Double(max(appViewModel.gestures.count, 1)),
                    tint: LiquidGlassTheme.success
                )

                Text("\(appViewModel.progress.recognizedGestures.count) of \(appViewModel.gestures.count) \(Texts.StatisticsPage.recognitionCoverageSuffix)")
                    .font(Font.subheadline())
                    .foregroundStyle(LiquidGlassTheme.mutedForeground)
                    .fixedSize(horizontal: false, vertical: true)

                FlowLayout(items: appViewModel.gestures) { gesture in
                    GestureChip(gesture: gesture)
                        .opacity(appViewModel.progress.recognizedGestures.contains(gesture.type) ? 1 : 0.45)
                }
            }
        }
    }

    private var quizHistory: some View {
        LiquidGlassCard {
            VStack(alignment: .leading, spacing: 14) {
                Text(Texts.StatisticsPage.quizHistory)
                    .font(Font.largeTitle3(.semibold))
                    .foregroundStyle(LiquidGlassTheme.foreground)

                if appViewModel.progress.quizScores.isEmpty {
                    Text(Texts.StatisticsPage.emptyQuizHistory)
                        .font(Font.subheadline())
                        .foregroundStyle(LiquidGlassTheme.mutedForeground)
                } else {
                    ForEach(appViewModel.progress.quizScores.suffix(5)) { score in
                        HStack {
                            Text(score.date, style: .date)
                                .font(Font.subheadline())
                                .foregroundStyle(LiquidGlassTheme.foreground)
                            Spacer()
                            Text("\(score.correctAnswers)/\(score.totalQuestions)")
                                .font(Font.largeTitle3(.bold))
                                .foregroundStyle(LiquidGlassTheme.accent)
                        }
                    }
                }
            }
        }
    }

    private var achievementsSection: some View {
        VStack(spacing: 14) {
            if let unlocked = appViewModel.achievements.first(where: \.isUnlocked) {
                AchievementBadge(achievement: unlocked)
            }

            NavigationLink {
                AchievementsView()
            } label: {
                Label(Texts.ProfilePage.viewAchievements, systemImage: "trophy.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .foregroundStyle(.white)
            }
            .buttonStyle(.glassProminent)
            .tint(LiquidGlassTheme.warning)
        }
    }
}
