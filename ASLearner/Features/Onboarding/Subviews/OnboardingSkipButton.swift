import SwiftUI

struct OnboardingSkipButton: View {
    let show: Bool
    let action: () -> Void

    var body: some View {
        if show {
            Button {
                withAnimation {
                    action()
                }
            } label: {
                Text(Texts.OnboardingPage.skip)
                    .foregroundStyle(Color.LabelColors.primary)
            }
            .buttonStyle(.glass)
            .frame(height: 20)
            .transition(.blurReplace)
            .padding(.horizontal)
            .padding(.top)
        } else {
            Color.clear
                .frame(height: 20)
                .padding(.top)
        }
    }
}
