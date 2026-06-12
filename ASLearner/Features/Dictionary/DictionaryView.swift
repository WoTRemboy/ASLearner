import SwiftUI

struct DictionaryView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @State private var searchText = ""

    private var filteredGestures: [GestureModel] {
        guard !searchText.isEmpty else { return appViewModel.gestures }
        return appViewModel.gestures.filter {
            $0.englishName.localizedCaseInsensitiveContains(searchText) ||
            $0.russianName.localizedCaseInsensitiveContains(searchText) ||
            $0.category.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        ZStack {
            LiquidGlassBackground()

            ScrollView {
                VStack(spacing: 16) {
                    if filteredGestures.isEmpty {
                        emptyState
                            .padding(.top, 60)
                    } else {
                        ForEach(filteredGestures) { gesture in
                            NavigationLink {
                                DictionaryDetailView(gesture: gesture)
                            } label: {
                                dictionaryRow(gesture)
                            }
                            .buttonStyle(.plain)
                            .padding(.horizontal, 20)
                        }
                    }
                }
                .padding(.top, 8)
                .padding(.bottom, 28)
            }
        }
        .navigationTitle(Texts.DictionaryPage.title)
        .navigationBarTitleDisplayMode(.large)
        .toolbarRole(.navigationStack)
        .searchable(
            text: $searchText,
            placement: .toolbarPrincipal,
            prompt: Texts.DictionaryPage.search
        )
    }

    private var emptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48, weight: .semibold))
                .foregroundStyle(LiquidGlassTheme.mutedForeground)

            Text(Texts.DictionaryPage.emptySearch)
                .font(Font.largeTitle3(.semibold))
                .foregroundStyle(LiquidGlassTheme.mutedForeground)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
    }

    private func dictionaryRow(_ gesture: GestureModel) -> some View {
        LiquidGlassCard(cornerRadius: 22, padding: 14) {
            HStack(spacing: 14) {
                Image(systemName: gesture.symbolName)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(LiquidGlassTheme.accent)
                    .frame(width: 48, height: 48)
                    .background(Color.white.opacity(0.13), in: RoundedRectangle(cornerRadius: 16, style: .continuous))

                VStack(alignment: .leading, spacing: 4) {
                    Text(gesture.englishName)
                        .font(.headline)
                        .foregroundStyle(LiquidGlassTheme.foreground)
                    Text("\(gesture.russianName) • \(gesture.category)")
                        .font(.caption)
                        .foregroundStyle(LiquidGlassTheme.mutedForeground)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundStyle(LiquidGlassTheme.mutedForeground)
            }
        }
    }
}

struct DictionaryDetailView: View {
    let gesture: GestureModel

    var body: some View {
        ZStack {
            LiquidGlassBackground()

            ScrollView {
                VStack(spacing: 18) {
                    LiquidGlassCard {
                        VStack(alignment: .leading, spacing: 18) {
                            Image(systemName: gesture.symbolName)
                                .font(.system(size: 76, weight: .bold))
                                .foregroundStyle(LiquidGlassTheme.accent)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 26)
                                .background(Color.white.opacity(0.10), in: RoundedRectangle(cornerRadius: 24, style: .continuous))

                            detailRow(title: Texts.DictionaryPage.category, value: gesture.category)
                            detailRow(title: Texts.DictionaryPage.difficulty, value: gesture.difficulty.rawValue)
                            detailRow(title: Texts.DictionaryPage.howToPerform, value: gesture.executionDescription)
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 28)
            }
        }
        .navigationTitle(gesture.englishName)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func detailRow(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.caption.bold())
                .foregroundStyle(LiquidGlassTheme.accent)
            Text(value)
                .font(.body)
                .foregroundStyle(LiquidGlassTheme.foreground.opacity(0.88))
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
