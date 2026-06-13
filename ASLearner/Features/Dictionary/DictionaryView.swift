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

            ScrollView(showsIndicators: false) {
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
                GestureGalleryIcon(
                    gesture: gesture,
                    isUnlocked: isGestureRecognized(gesture),
                    tint: gestureTint(for: gesture),
                    size: 52
                )
                .frame(width: 52)

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

    private func isGestureRecognized(_ gesture: GestureModel) -> Bool {
        appViewModel.progress.recognizedGestures.contains(gesture.type)
    }

    private func gestureTint(for gesture: GestureModel) -> Color {
        let index = appViewModel.gestures.firstIndex { $0.id == gesture.id } ?? 0
        return LiquidGlassGalleryPalette.tint(for: index)
    }
}

struct DictionaryDetailView: View {
    @EnvironmentObject private var appViewModel: AppViewModel

    let gesture: GestureModel

    var body: some View {
        ZStack {
            LiquidGlassBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    LiquidGlassCard {
                        VStack(alignment: .leading, spacing: 18) {
                            GestureGalleryIcon(
                                gesture: gesture,
                                isUnlocked: isGestureRecognized,
                                tint: gestureTint,
                                size: 112
                            )
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 26)

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

    private var isGestureRecognized: Bool {
        appViewModel.progress.recognizedGestures.contains(gesture.type)
    }

    private var gestureTint: Color {
        let index = appViewModel.gestures.firstIndex { $0.id == gesture.id } ?? 0
        return LiquidGlassGalleryPalette.tint(for: index)
    }
}
