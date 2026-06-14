import SwiftUI

struct AppTabView: View {
    var body: some View {
        TabView {
            Tab(Texts.Tabbar.path, systemImage: "house.fill") {
                NavigationStack {
                    LearningFlowView()
                }
            }

            Tab(Texts.Tabbar.profile, systemImage: "person.crop.circle.fill") {
                NavigationStack {
                    ProfileView()
                }
            }

            Tab(Texts.Tabbar.settings, systemImage: "gearshape.fill") {
                NavigationStack {
                    SettingsView()
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
