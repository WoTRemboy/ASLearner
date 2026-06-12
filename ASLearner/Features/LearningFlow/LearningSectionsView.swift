import SwiftUI

struct LearningSectionsView: View {
    @Environment(\.dismiss) private var dismiss

    let sections: [LearningSection]
    let transitionID: String
    let namespace: Namespace.ID

    var body: some View {
        NavigationStack {
            ZStack {
                LiquidGlassBackground()

                ScrollView {
                    VStack(spacing: 16) {
                        header

                        ForEach(sections) { section in
                            LearningSectionCard(section: section)
                                .padding(.horizontal, 20)
                        }
                    }
                    .padding(.top, 10)
                    .padding(.bottom, 28)
                }
            }
            .navigationTitle(Texts.LearningFlowPage.sectionsTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .accessibilityLabel(Texts.LearningFlowPage.close)
                }
            }
        }
        .navigationTransition(
            .zoom(sourceID: transitionID, in: namespace)
        )
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(Texts.LearningFlowPage.sectionsSubtitle)
                .font(Font.title2(.bold))
                .foregroundStyle(LiquidGlassTheme.foreground)

            Text(Texts.LearningFlowPage.sectionsDescription)
                .font(Font.body())
                .foregroundStyle(LiquidGlassTheme.mutedForeground)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
    }
}

private struct LearningSectionCard: View {
    let section: LearningSection

    var body: some View {
        LiquidGlassCard(cornerRadius: 24, padding: 16) {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(section.title)
                            .font(Font.title2(.bold))
                            .foregroundStyle(LiquidGlassTheme.foreground)

                        Text(section.isComingSoon ? Texts.LearningFlowPage.comingSoon : section.subtitle)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(LiquidGlassTheme.mutedForeground)

                        if section.isLocked {
                            Label(Texts.LearningFlowPage.locked, systemImage: "lock.fill")
                                .font(Font.caption(.bold))
                                .foregroundStyle(LiquidGlassTheme.accent)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(LiquidGlassTheme.accent.opacity(0.16), in: Capsule())
                        }
                    }

                    Spacer()

                    Image(systemName: sectionSymbolName)
                        .font(Font.title2(.bold))
                        .foregroundStyle(sectionSymbolColor)
                        .frame(width: 44, height: 44)
                        .background(sectionSymbolColor.opacity(0.18), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(sectionSymbolColor.opacity(0.28), lineWidth: 1)
                        }
                }

                if section.isComingSoon {
                    Text(Texts.LearningFlowPage.comingSoonDescription)
                        .font(Font.caption(.semibold))
                        .foregroundStyle(LiquidGlassTheme.mutedForeground)
                        .fixedSize(horizontal: false, vertical: true)
                } else {
                    VStack(spacing: 8) {
                        SectionProgressBar(value: section.progress)

                        Text("\(section.completedCount)/\(section.totalCount)")
                            .font(Font.caption(.bold))
                            .foregroundStyle(LiquidGlassTheme.foreground)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
            }
        }
        .opacity(section.isComingSoon ? 0.72 : 1)
    }

    private var sectionSymbolName: String {
        if section.isComingSoon {
            "clock.badge.fill"
        } else if section.isLocked {
            "lock.fill"
        } else {
            "trophy.fill"
        }
    }

    private var sectionSymbolColor: Color {
        if section.isComingSoon {
            LiquidGlassTheme.mutedForeground
        } else if section.isLocked {
            LiquidGlassTheme.accent
        } else {
            LiquidGlassTheme.success
        }
    }
}

private struct SectionProgressBar: View {
    let value: Double

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(LiquidGlassTheme.accent.opacity(0.22))
                    .overlay {
                        Capsule()
                            .stroke(LiquidGlassTheme.accent.opacity(0.34), lineWidth: 1)
                    }

                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                LiquidGlassTheme.success,
                                LiquidGlassTheme.success.opacity(0.62)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: max(0, min(1, value)) * proxy.size.width)
            }
        }
        .frame(height: 12)
        .animation(.spring(response: 0.45, dampingFraction: 0.82), value: value)
    }
}
