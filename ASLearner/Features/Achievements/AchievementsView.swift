import SwiftUI

struct AchievementsView: View {
    @EnvironmentObject private var appViewModel: AppViewModel

    var body: some View {
        ZStack {
            LiquidGlassBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    ForEach(appViewModel.achievements) { achievement in
                        AchievementBadge(achievement: achievement)
                            .padding(.horizontal, 20)
                    }
                }
                .padding(.bottom, 28)
            }
        }
        .navigationTitle(Texts.AchievementsPage.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var unlockedCount: Int {
        appViewModel.achievements.filter(\.isUnlocked).count
    }
}
