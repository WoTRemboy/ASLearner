import SwiftUI

struct AppTabView: View {
    var body: some View {
        TabView {
            Tab(Texts.Tabbar.home, systemImage: "house.fill") {
                NavigationStack {
                    HomeView()
                }
            }

            Tab(Texts.Tabbar.path, systemImage: "graduationcap.fill") {
                NavigationStack {
                    LearningFlowView()
                }
            }

            Tab(Texts.Tabbar.stats, systemImage: "chart.xyaxis.line") {
                NavigationStack {
                    StatisticsView()
                }
            }

            Tab(Texts.Tabbar.dictionary, systemImage: "book.closed.fill", role: .search) {
                NavigationStack {
                    DictionaryView()
                }
            }
        }
        .tint(LiquidGlassTheme.accent)
    }
}
