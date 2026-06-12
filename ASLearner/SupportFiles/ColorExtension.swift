import SwiftUI

extension Color {
    enum LabelColors {
        static let primary = Color.primary
        static let secondary = Color.secondary
        static let disable = Color.secondary.opacity(0.35)
        static let blue = Color(red: 0.31, green: 0.35, blue: 0.73)
        static let purple = Color(red: 0.54, green: 0.35, blue: 0.85)
        static let white = Color.white
    }

    enum BackgroundColors {
        static let main = Color.white
        static let primary = Color(red: 0.949, green: 0.949, blue: 0.969)
        static let card = Color.white.opacity(0.78)
    }

    enum SupportColors {
        static let blue = Color(red: 0.314, green: 0.345, blue: 0.725)
        static let red = Color(red: 0.89, green: 0.23, blue: 0.28)
        static let lightBlue = Color(red: 0.59, green: 0.63, blue: 1.00)
        static let purple = Color(red: 0.54, green: 0.35, blue: 0.85)
        static let orange = Color(red: 0.92, green: 0.55, blue: 0.30)
        static let green = Color(red: 0.34, green: 0.68, blue: 0.46)
        static let yellow = Color(red: 0.92, green: 0.68, blue: 0.22)
    }
}

