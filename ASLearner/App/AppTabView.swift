import SwiftUI

struct AppTabView: View {
    var body: some View {
        TabView {
            NavigationStack {
                HomeView()
            }
            .tabItem {
                Label(Texts.Tabbar.home, systemImage: "house.fill")
            }

            NavigationStack {
                LessonsView()
            }
            .tabItem {
                Label(Texts.Tabbar.lessons, systemImage: "play.rectangle.fill")
            }

            NavigationStack {
                QuizView()
            }
            .tabItem {
                Label(Texts.Tabbar.quiz, systemImage: "questionmark.app.fill")
            }

            NavigationStack {
                DictionaryView()
            }
            .tabItem {
                Label(Texts.Tabbar.dictionary, systemImage: "book.closed.fill")
            }

            NavigationStack {
                StatisticsView()
            }
            .tabItem {
                Label(Texts.Tabbar.stats, systemImage: "chart.xyaxis.line")
            }
        }
        .tint(LiquidGlassTheme.accent)
    }
}
