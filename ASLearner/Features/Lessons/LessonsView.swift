import SwiftUI

struct LessonsView: View {
    @EnvironmentObject private var appViewModel: AppViewModel

    var body: some View {
        ZStack {
            LiquidGlassBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    ForEach(appViewModel.lessons) { lesson in
                        NavigationLink {
                            LessonDetailView(lesson: lesson)
                        } label: {
                            LessonCard(
                                lesson: lesson,
                                isCompleted: appViewModel.progress.completedLessonIDs.contains(lesson.id),
                                progress: lessonProgress(for: lesson)
                            )
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 20)
                    }
                }
                .padding(.bottom, 28)
            }
            .scrollBounceBehavior(.basedOnSize, axes: [.vertical])
        }
        .navigationTitle(Texts.LessonsPage.title)
        .navigationBarTitleDisplayMode(.large)
    }

    private func lessonProgress(for lesson: LessonModel) -> Double {
        let completedGestures = lesson.gestureTypes.filter { appViewModel.progress.recognizedGestures.contains($0) }
        return Double(completedGestures.count) / Double(max(lesson.gestureTypes.count, 1))
    }
}

struct LessonDetailView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    let lesson: LessonModel

    var body: some View {
        ZStack {
            LiquidGlassBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    LiquidGlassCard {
                        VStack(alignment: .leading, spacing: 14) {
                            Text(Texts.LessonsPage.lessonGestures)
                                .font(.headline)
                                .foregroundStyle(LiquidGlassTheme.foreground)

                            ForEach(lesson.gestureTypes, id: \.self) { type in
                                let gesture = appViewModel.gesture(for: type)
                                NavigationLink {
                                    GesturePracticeView(lesson: lesson, targetGesture: type)
                                } label: {
                                    HStack(spacing: 14) {
                                        Image(systemName: gesture.symbolName)
                                            .font(.title3.weight(.semibold))
                                            .foregroundStyle(LiquidGlassTheme.accent)
                                            .frame(width: 42, height: 42)
                                            .background(Color.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 14, style: .continuous))

                                        VStack(alignment: .leading, spacing: 3) {
                                            Text(gesture.englishName)
                                                .font(.headline)
                                                .foregroundStyle(LiquidGlassTheme.foreground)
                                            Text(gesture.russianName)
                                                .font(.subheadline)
                                                .foregroundStyle(LiquidGlassTheme.mutedForeground)
                                        }

                                        Spacer()

                                        Image(systemName: appViewModel.progress.recognizedGestures.contains(type) ? "checkmark.circle.fill" : "chevron.right")
                                            .foregroundStyle(appViewModel.progress.recognizedGestures.contains(type) ? LiquidGlassTheme.success : LiquidGlassTheme.mutedForeground)
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 28)
            }
            .scrollBounceBehavior(.basedOnSize, axes: [.vertical])
        }
        .navigationTitle(lesson.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
