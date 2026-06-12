import SwiftUI

struct GesturePracticeView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    let lesson: LessonModel
    let targetGesture: GestureType
    @State private var hint = Texts.PracticePage.preparingHint

    private var gesture: GestureModel {
        appViewModel.gesture(for: targetGesture)
    }

    var body: some View {
        ZStack {
            LiquidGlassBackground()

            ScrollView {
                VStack(spacing: 18) {
                    LiquidGlassCard {
                        VStack(alignment: .leading, spacing: 18) {
                            HStack(alignment: .top) {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(gesture.englishName)
                                        .font(.largeTitle.bold())
                                        .foregroundStyle(LiquidGlassTheme.foreground)
                                    Text(gesture.russianName)
                                        .font(.title3.weight(.medium))
                                        .foregroundStyle(LiquidGlassTheme.accent)
                                }
                                Spacer()
                                Text(gesture.difficulty.rawValue)
                                    .font(.caption.bold())
                                    .foregroundStyle(LiquidGlassTheme.foreground)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 7)
                                    .background(Color.white.opacity(0.16), in: Capsule())
                            }

                            Text(gesture.executionDescription)
                                .font(.body)
                                .foregroundStyle(LiquidGlassTheme.mutedForeground)
                                .fixedSize(horizontal: false, vertical: true)

                            Divider()
                                .overlay(Color.white.opacity(0.18))

                            Label(hint, systemImage: "brain.head.profile")
                                .font(.subheadline)
                                .foregroundStyle(LiquidGlassTheme.foreground.opacity(0.84))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .padding(.horizontal, 20)

                    NavigationLink {
                        CameraRecognitionView(targetGesture: targetGesture, lessonID: lesson.id)
                    } label: {
                        Label(Texts.PracticePage.openCamera, systemImage: "camera.viewfinder")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                            .foregroundStyle(.white)
                    }
                    .buttonStyle(.glassProminent)
                    .tint(LiquidGlassTheme.accent)
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 28)
            }
        }
        .navigationTitle("\(Texts.PracticePage.titlePrefix) \(gesture.englishName)")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            hint = await appViewModel.container.localLLMService.generateHint(for: targetGesture)
        }
    }
}
