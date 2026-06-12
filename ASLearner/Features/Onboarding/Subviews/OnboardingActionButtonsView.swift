import SwiftUI

struct OnboardingActionButtonsView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    let namespace: Namespace.ID
    let action: () -> Void

    var body: some View {
        GlassEffectContainer {
            HStack(spacing: 8) {
                if viewModel.showSkipButton {
                    skipPermissionButton
                }

                actionButton
            }
            .padding(.horizontal)
            .padding(.vertical, 30)
        }
    }

    private var actionButton: some View {
        Button {
            viewModel.handleActionButtonTap(externalAction: action)
        } label: {
            Text(viewModel.buttonType.title)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
        .contentTransition(.numericText())
        .buttonStyle(.glassProminent)
        .glassEffectID(Texts.GlassEffectId.Onboarding.permission, in: namespace)
        .foregroundStyle(Color.LabelColors.white)
        .tint(Color.SupportColors.lightBlue)
        .frame(height: 50)
        .frame(maxWidth: .infinity)
        .animation(.easeInOut, value: viewModel.cameraAuthorizationStatus)
    }

    private var skipPermissionButton: some View {
        Button {
            viewModel.handleSkipButtonTap(externalAction: action)
        } label: {
            Text(Texts.OnboardingPage.skipPermission)
                .frame(maxWidth: 100, maxHeight: .infinity, alignment: .center)
        }
        .buttonStyle(.glassProminent)
        .glassEffectID(Texts.GlassEffectId.Onboarding.skipPermission, in: namespace)
        .foregroundStyle(Color.LabelColors.white)
        .tint(Color.SupportColors.lightBlue)
        .frame(height: 50)
    }
}
