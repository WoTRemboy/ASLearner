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
                                    .contentShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
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
            .frame(maxWidth: .infinity, alignment: .leading)
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
    @State private var isShowingPractice = false

    let gesture: GestureModel

    var body: some View {
        ZStack {
            LiquidGlassBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    LiquidGlassCard {
                        VStack(alignment: .leading, spacing: 18) {
                            if Image.GestureScheme.assetName(for: gesture.type) != nil {
                                GestureSchemeImageView(gesture: gesture.type, widthRatio: 0.72, maxSide: 320)
                                    .padding(.vertical, 8)
                            }

                            detailRow(title: Texts.DictionaryPage.category, value: gesture.category)
                            detailRow(title: Texts.DictionaryPage.difficulty, value: gesture.difficulty.rawValue)
                            detailRow(title: Texts.DictionaryPage.howToPerform, value: gesture.executionDescription)
                        }
                    }
                    .padding(.horizontal, 20)

                    LiquidGlassButton(
                        title: Texts.DictionaryPage.practiceGesture,
                        systemImage: "camera.viewfinder",
                        tint: LiquidGlassTheme.accent
                    ) {
                        isShowingPractice = true
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 28)
            }
        }
        .navigationTitle(gesture.englishName)
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $isShowingPractice) {
            DictionaryGesturePracticeSheet(gesture: gesture)
        }
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

private struct DictionaryGesturePracticeSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appViewModel: AppViewModel

    let gesture: GestureModel

    @State private var didRecognizeGesture = false
    @State private var didAward = false
    @State private var cameraStopRequest = 0
    @State private var isWaitingForCameraStop = false

    var body: some View {
        NavigationStack {
            ZStack {
                LiquidGlassBackground()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 22) {
                        LiveGestureCameraPanel(
                            gesture: gesture,
                            stopRequest: cameraStopRequest
                        ) {
                            handleRecognitionAccepted()
                        } onStopCompleted: {
                            isWaitingForCameraStop = false
                            dismiss()
                        }

                        VStack(alignment: .leading, spacing: 10) {
                            Text("Тренировка «\(gesture.englishName)»")
                                .font(.system(size: 34, weight: .bold, design: .rounded))
                                .foregroundStyle(LiquidGlassTheme.foreground)

                            if Image.GestureScheme.assetName(for: gesture.type) != nil {
                                GestureSchemeImageView(gesture: gesture.type, widthRatio: 0.62, maxSide: 280)
                                    .padding(.vertical, 6)
                            }

                            Text(gesture.executionDescription)
                                .font(.title3)
                                .fontWeight(.medium)
                                .lineSpacing(4)
                                .foregroundStyle(LiquidGlassTheme.mutedForeground)
                                .fixedSize(horizontal: false, vertical: true)

                            if didRecognizeGesture {
                                Label(Texts.LearningFlowPage.gestureAccepted, systemImage: "checkmark.seal.fill")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(LiquidGlassTheme.success)
                                    .transition(.blurReplace)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 28)
                }
                .scrollBounceBehavior(.basedOnSize, axes: [.vertical])
            }
            .navigationTitle(gesture.englishName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        closeAfterCameraStops()
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .disabled(isWaitingForCameraStop)
                    .accessibilityLabel(Texts.LearningFlowPage.close)
                }
            }
            .interactiveDismissDisabled(true)
        }
    }

    private func handleRecognitionAccepted() {
        didRecognizeGesture = true

        guard !didAward else { return }
        didAward = true
        appViewModel.applyGestureAward(for: gesture.type, lessonID: nil)
    }

    private func closeAfterCameraStops() {
        guard !isWaitingForCameraStop else { return }
        isWaitingForCameraStop = true
        cameraStopRequest += 1
    }
}
