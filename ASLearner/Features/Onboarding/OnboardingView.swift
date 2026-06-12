import SwiftUI
import SwiftUIPager

struct OnboardingView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var viewModel = OnboardingViewModel()
    @StateObject private var page: Page = .first()
    @Namespace private var namespace

    var body: some View {
        VStack(alignment: .trailing) {
            skipButton
            content
            progressCircles
            actionButtons
        }
        .background(Color.BackgroundColors.primary)
        .onChange(of: page.index) { _, newValue in
            withAnimation {
                viewModel.setupCurrentStep(newValue: newValue)
            }
            viewModel.triggerDrawOnSymbol(newValue)
        }
        .task {
            viewModel.refreshCameraAuthorization()
            viewModel.triggerDrawOnSymbol(0)
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                viewModel.refreshCameraAuthorization()
            }
        }
        .alert(Texts.OnboardingPage.CameraAlert.title, isPresented: $viewModel.showCameraPermissionAlert) {
            cameraAlertButtons
        } message: {
            Text(Texts.OnboardingPage.CameraAlert.content)
        }
    }

    private var skipButton: some View {
        OnboardingSkipButton(show: !viewModel.isLastPage) {
            page.update(.moveToLast)
        }
    }

    private var content: some View {
        Pager(
            page: page,
            data: viewModel.pages,
            id: \.self
        ) { index in
            VStack(spacing: 16) {
                animatedImage(for: index)
                VStack(spacing: 16) {
                    Text(viewModel.steps[index].name)
                        .font(Font.largeTitle(.bold))
                        .padding(.top)
                    
                    Text(viewModel.steps[index].description)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
            }
            .foregroundStyle(Color.LabelColors.primary)
            .tag(index)
        }
        .interactive(scale: 0.8)
        .itemSpacing(10)
        .itemAspectRatio(1.0)
        .swipeInteractionArea(.allAvailable)
        .multiplePagination()
        .horizontal()
    }

    @ViewBuilder
    private func animatedImage(for index: Int) -> some View {
        GeometryReader { proxy in
            let imageSize = proxy.size.width / 1.2

            Group {
                if viewModel.steps[index].drawOn {
                    viewModel.steps[index].image
                        .resizable()
                        .scaledToFit()
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(Color.SupportColors.blue)
                        .transition(.symbolEffect(.drawOn.individually))
                } else {
                    Color.clear
                }
            }
            .frame(width: imageSize, height: imageSize)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .aspectRatio(1, contentMode: .fit)
    }

    private var progressCircles: some View {
        HStack {
            ForEach(viewModel.pages, id: \.self) { step in
                if step == page.index {
                    Circle()
                        .frame(width: 15, height: 15)
                        .foregroundStyle(Color.LabelColors.primary)
                        .transition(.scale)
                } else {
                    Circle()
                        .frame(width: 10, height: 10)
                        .foregroundStyle(Color.LabelColors.disable)
                        .transition(.scale)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var actionButtons: some View {
        OnboardingActionButtonsView(viewModel: viewModel, namespace: namespace) {
            withAnimation {
                if viewModel.isLastPage {
                    appViewModel.completeOnboarding()
                } else {
                    page.update(.next)
                }
            }
        }
    }

    @ViewBuilder
    private var cameraAlertButtons: some View {
        Button(Texts.OnboardingPage.CameraAlert.settings) {
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        }

        Button(Texts.OnboardingPage.CameraAlert.cancel, role: .cancel) {}
    }
}
