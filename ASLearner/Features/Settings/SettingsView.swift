import SwiftUI

struct SettingsView: View {
    var body: some View {
        ZStack {
            LiquidGlassBackground()

            ScrollView {
                VStack(spacing: 18) {
                    settingsSection(
                        title: Texts.SettingsPage.learning,
                        rows: [
                            .init(title: Texts.SettingsPage.dailyGoal, value: Texts.SettingsPage.dailyGoalValue, systemImage: "target"),
                            .init(title: Texts.SettingsPage.reminders, value: Texts.SettingsPage.remindersValue, systemImage: "bell.badge.fill")
                        ]
                    )

                    settingsSection(
                        title: Texts.SettingsPage.recognition,
                        rows: [
                            .init(title: Texts.SettingsPage.cameraMode, value: Texts.SettingsPage.cameraModeValue, systemImage: "camera.viewfinder"),
                            .init(title: Texts.SettingsPage.localLLM, value: Texts.SettingsPage.localLLMValue, systemImage: "brain.head.profile")
                        ]
                    )

                    settingsSection(
                        title: Texts.SettingsPage.about,
                        rows: [
                            .init(title: Texts.SettingsPage.appVersion, value: Texts.SettingsPage.appVersionValue, systemImage: "info.circle.fill")
                        ]
                    )
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 28)
            }
        }
        .navigationTitle(Texts.SettingsPage.title)
        .navigationBarTitleDisplayMode(.large)
    }

    private func settingsSection(title: String, rows: [SettingsRow.Model]) -> some View {
        LiquidGlassCard {
            VStack(alignment: .leading, spacing: 14) {
                Text(title)
                    .font(Font.largeTitle3(.semibold))
                    .foregroundStyle(LiquidGlassTheme.foreground)

                ForEach(rows) { row in
                    SettingsRow(model: row)

                    if row.id != rows.last?.id {
                        Divider()
                            .overlay(Color.white.opacity(0.14))
                    }
                }
            }
        }
    }
}

private struct SettingsRow: View {
    struct Model: Identifiable {
        let id = UUID()
        let title: String
        let value: String
        let systemImage: String
    }

    let model: Model

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: model.systemImage)
                .font(Font.title2(.semibold))
                .foregroundStyle(LiquidGlassTheme.accent)
                .frame(width: 38, height: 38)
                .background(LiquidGlassTheme.accent.opacity(0.14), in: RoundedRectangle(cornerRadius: 13, style: .continuous))

            VStack(alignment: .leading, spacing: 3) {
                Text(model.title)
                    .font(Font.largeTitle3(.semibold))
                    .foregroundStyle(LiquidGlassTheme.foreground)
                Text(model.value)
                    .font(Font.caption())
                    .foregroundStyle(LiquidGlassTheme.mutedForeground)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
