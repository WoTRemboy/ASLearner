import SwiftUI

extension Image {
    enum Splash {
        static let logo = Image(systemName: "hands.sparkles.fill")
    }

    enum OnboardingPage {
        static let first = Image(systemName: "hands.sparkles.fill")
        static let second = Image(systemName: "sparkles")
        static let third = Image(systemName: "trophy.circle")
        static let fourth = Image(systemName: "camera.viewfinder")
    }

    enum GestureScheme {
        static func image(for gesture: GestureType) -> Image? {
            guard let assetName = assetName(for: gesture) else { return nil }
            return Image(assetName)
        }

        static func assetName(for gesture: GestureType) -> String? {
            switch gesture {
            case .hello:
                "GestureSchemeHello"
            case .thankYou:
                "GestureSchemeThankYou"
            case .yes:
                "GestureSchemeYes"
            case .no:
                "GestureSchemeNo"
            case .please, .help, .good, .bad, .iLoveYou, .learn:
                nil
            }
        }
    }
}
