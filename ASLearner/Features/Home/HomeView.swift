import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var appViewModel: AppViewModel

    var body: some View {
        ZStack {
            LiquidGlassBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    progressHeader
                        .padding(.horizontal, 20)

                    statsGrid
                        .padding(.horizontal, 20)

                    demoScenarioCard
                        .padding(.horizontal, 20)

                    recentAchievement
                        .padding(.horizontal, 20)
                }
                .padding(.bottom, 28)
            }
            .scrollBounceBehavior(.basedOnSize, axes: [.vertical])
        }
        .navigationTitle(Texts.HomePage.title)
        .navigationBarTitleDisplayMode(.large)
    }

    private var progressHeader: some View {
        LiquidGlassCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(Texts.HomePage.progressLevel) \(appViewModel.progress.level)")
                            .font(.title.bold())
                            .foregroundStyle(LiquidGlassTheme.foreground)
                        Text("\(appViewModel.progress.xp) \(Texts.HomePage.xp) • \(appViewModel.progress.streak)-\(Texts.HomePage.streak)")
                            .font(.subheadline)
                            .foregroundStyle(LiquidGlassTheme.mutedForeground)
                    }
                    Spacer()
                    Text("\(Int(appViewModel.progress.levelProgress * 100))%")
                        .font(.title3.bold())
                        .foregroundStyle(LiquidGlassTheme.accent)
                }

                LiquidGlassProgressView(value: appViewModel.progress.levelProgress)

                Text("\(Texts.HomePage.nextLevel) \(appViewModel.progress.nextLevelXP) \(Texts.HomePage.xp)")
                    .font(.caption)
                    .foregroundStyle(LiquidGlassTheme.mutedForeground)
            }
        }
    }

    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
            StatCard(title: Texts.Stats.lessons, value: "\(appViewModel.progress.completedLessonIDs.count)/\(appViewModel.lessons.count)", systemImage: "play.fill")
            StatCard(title: Texts.Stats.gestures, value: "\(appViewModel.progress.recognizedGestures.count)", systemImage: "hand.raised.fill", tint: LiquidGlassTheme.secondaryAccent)
            StatCard(title: Texts.Stats.quizAverage, value: "\(Int(appViewModel.averageQuizScore * 100))%", systemImage: "checkmark.seal.fill", tint: LiquidGlassTheme.success)
            StatCard(title: Texts.Stats.badges, value: "\(appViewModel.progress.unlockedAchievementIDs.count)", systemImage: "trophy.fill", tint: LiquidGlassTheme.warning)
        }
    }

    private var demoScenarioCard: some View {
        LiquidGlassCard {
            VStack(alignment: .leading, spacing: 16) {
                Label(Texts.HomePage.demoTitle, systemImage: "sparkles")
                    .font(.headline)
                    .foregroundStyle(LiquidGlassTheme.accent)

                Text(Texts.HomePage.demoDescription)
                    .font(.subheadline)
                    .foregroundStyle(LiquidGlassTheme.mutedForeground)
                    .fixedSize(horizontal: false, vertical: true)

                NavigationLink {
                    GesturePracticeView(lesson: appViewModel.lessons[0], targetGesture: .hello)
                } label: {
                    Label(Texts.HomePage.practiceHello, systemImage: "camera.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .foregroundStyle(.white)
                }
                .buttonStyle(.glassProminent)
                .tint(LiquidGlassTheme.accent)
            }
        }
    }

    @ViewBuilder
    private var recentAchievement: some View {
        if let unlocked = appViewModel.achievements.first(where: \.isUnlocked) {
            AchievementBadge(achievement: unlocked)
        }
    }
}
