import SwiftUI

struct StatisticsView: View {
    @EnvironmentObject private var appViewModel: AppViewModel

    var body: some View {
        ZStack {
            LiquidGlassBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    overviewGrid
                        .padding(.horizontal, 20)

                    recognitionAnalysis
                        .padding(.horizontal, 20)

                    quizHistory
                        .padding(.horizontal, 20)

                    NavigationLink {
                        AchievementsView()
                    } label: {
                        Label(Texts.StatisticsPage.openAchievements, systemImage: "trophy.fill")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .foregroundStyle(.white)
                    }
                    .buttonStyle(.glassProminent)
                    .tint(LiquidGlassTheme.warning)
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 28)
            }
            .scrollBounceBehavior(.basedOnSize, axes: [.vertical])
        }
        .navigationTitle(Texts.StatisticsPage.title)
        .navigationBarTitleDisplayMode(.large)
    }

    private var overviewGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
            StatCard(title: Texts.HomePage.xp, value: "\(appViewModel.progress.xp)", systemImage: "bolt.fill")
            StatCard(title: Texts.Stats.level, value: "\(appViewModel.progress.level)", systemImage: "arrow.up.circle.fill", tint: LiquidGlassTheme.success)
            StatCard(title: Texts.Stats.streak, value: "\(appViewModel.progress.streak)d", systemImage: "flame.fill", tint: LiquidGlassTheme.secondaryAccent)
            StatCard(title: Texts.Stats.averageQuiz, value: "\(Int(appViewModel.averageQuizScore * 100))%", systemImage: "percent", tint: LiquidGlassTheme.warning)
        }
    }

    private var recognitionAnalysis: some View {
        LiquidGlassCard {
            VStack(alignment: .leading, spacing: 14) {
                Text(Texts.StatisticsPage.recognitionCoverage)
                    .font(.headline)
                    .foregroundStyle(LiquidGlassTheme.foreground)

                LiquidGlassProgressView(value: Double(appViewModel.progress.recognizedGestures.count) / Double(max(appViewModel.gestures.count, 1)))

                Text("\(appViewModel.progress.recognizedGestures.count) of \(appViewModel.gestures.count) \(Texts.StatisticsPage.recognitionCoverageSuffix)")
                    .font(.subheadline)
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
                    .font(.headline)
                    .foregroundStyle(LiquidGlassTheme.foreground)

                if appViewModel.progress.quizScores.isEmpty {
                    Text(Texts.StatisticsPage.emptyQuizHistory)
                        .font(.subheadline)
                        .foregroundStyle(LiquidGlassTheme.mutedForeground)
                } else {
                    ForEach(appViewModel.progress.quizScores.suffix(5)) { score in
                        HStack {
                            Text(score.date, style: .date)
                                .font(.subheadline)
                                .foregroundStyle(LiquidGlassTheme.foreground)
                            Spacer()
                            Text("\(score.correctAnswers)/\(score.totalQuestions)")
                                .font(.subheadline.bold())
                                .foregroundStyle(LiquidGlassTheme.accent)
                        }
                    }
                }
            }
        }
    }
}

struct FlowLayout<Item: Identifiable, Content: View>: View {
    let items: [Item]
    let content: (Item) -> Content

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 118), spacing: 8)], alignment: .leading, spacing: 8) {
            ForEach(items) { item in
                content(item)
            }
        }
    }
}
