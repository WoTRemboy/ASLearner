import AVFoundation
import Combine
import Foundation
import SwiftUI

final class OnboardingViewModel: ObservableObject {
    @Published var steps = OnboardingStep.stepsSetup()
    @Published var currentStep = 0
    @Published var cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
    @Published var showCameraPermissionAlert = false

    var pages: [Int] {
        Array(0..<steps.count)
    }

    var isLastPage: Bool {
        currentStep == steps.count - 1
    }

    var buttonType: OnboardingButtonType {
        isLastPage ? .getCameraPermission(access: cameraAuthorizationStatus) : .nextPage
    }

    var showSkipButton: Bool {
        buttonType.showSkipButton && !steps[currentStep].grantedAccess
    }

    func setupCurrentStep(newValue: Int) {
        currentStep = newValue
    }

    func refreshCameraAuthorization() {
        cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        updateCameraAccess(cameraAuthorizationStatus == .authorized)
    }

    func drawOnSymbol(_ index: Int) async {
        try? await Task.sleep(for: .seconds(0.2))
        guard steps.indices.contains(index) else { return }
        guard !steps[index].drawOn else { return }
        steps[index].drawOn = true
    }

    func triggerDrawOnSymbol(_ index: Int) {
        Task {
            await drawOnSymbol(index)
        }
    }

    func handleActionButtonTap(externalAction: @escaping () -> Void) {
        switch buttonType {
        case .nextPage:
            externalAction()
        case .getCameraPermission(let access):
            handleCameraPermission(access: access, externalAction: externalAction)
        }
    }

    func handleSkipButtonTap(externalAction: @escaping () -> Void) {
        externalAction()
    }

    private func handleCameraPermission(access: AVAuthorizationStatus, externalAction: @escaping () -> Void) {
        switch access {
        case .authorized:
            externalAction()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                Task { @MainActor [weak self] in
                    guard let viewModel = self else { return }
                    viewModel.refreshCameraAuthorization()
                }
            }
        default:
            showCameraPermissionAlert.toggle()
        }
    }

    private func updateCameraAccess(_ granted: Bool) {
        guard let lastIndex = steps.indices.last else { return }
        withAnimation {
            steps[lastIndex].grantedAccess = granted
        }
    }
}
