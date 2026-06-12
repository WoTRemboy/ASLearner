import AVFoundation
import SwiftUI

struct OnboardingStep: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let image: Image
    var drawOn = false
    var grantedAccess = false
}

extension OnboardingStep {
    static func stepsSetup() -> [OnboardingStep] {
        [
            OnboardingStep(
                name: Texts.OnboardingPage.FirstPage.title,
                description: Texts.OnboardingPage.FirstPage.description,
                image: .OnboardingPage.first
            ),
            OnboardingStep(
                name: Texts.OnboardingPage.SecondPage.title,
                description: Texts.OnboardingPage.SecondPage.description,
                image: .OnboardingPage.second
            ),
            OnboardingStep(
                name: Texts.OnboardingPage.ThirdPage.title,
                description: Texts.OnboardingPage.ThirdPage.description,
                image: .OnboardingPage.third
            ),
            OnboardingStep(
                name: Texts.OnboardingPage.FourthPage.title,
                description: Texts.OnboardingPage.FourthPage.description,
                image: .OnboardingPage.fourth,
                grantedAccess: AVCaptureDevice.authorizationStatus(for: .video) == .authorized
            )
        ]
    }
}

enum OnboardingButtonType: Equatable {
    case nextPage
    case getCameraPermission(access: AVAuthorizationStatus)

    var title: String {
        switch self {
        case .nextPage:
            Texts.OnboardingPage.next
        case .getCameraPermission(let access):
            switch access {
            case .notDetermined:
                Texts.OnboardingPage.permission
            case .authorized:
                Texts.OnboardingPage.begin
            default:
                Texts.OnboardingPage.forbidden
            }
        }
    }

    var showSkipButton: Bool {
        switch self {
        case .nextPage:
            false
        case .getCameraPermission:
            true
        }
    }
}
