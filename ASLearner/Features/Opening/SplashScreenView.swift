import SwiftUI

struct SplashScreenView: View {
    @State private var isActive = false
    @State private var id = 0

    private let texts = [String(), Texts.AppInfo.title]

    var body: some View {
        if isActive {
            ContentView()
        } else {
            content
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        withAnimation {
                            isActive = true
                        }
                    }
                }
        }
    }

    private var content: some View {
        VStack(spacing: 8) {
            splashImage

            Text(texts[id])
                .foregroundStyle(Color.LabelColors.primary)
                .font(.system(size: 80, weight: .medium))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .padding(.horizontal, 30)
        }
        .contentTransition(.numericText())
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.BackgroundColors.primary)
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { _ in
                withAnimation {
                    id += 1
                }
            }
        }
    }

    private var splashImage: some View {
        GeometryReader { proxy in
            let imageSize = proxy.size.width / 1.5

            Image.Splash.logo
                .resizable()
                .scaledToFit()
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(Color.SupportColors.blue)
                .frame(width: imageSize, height: imageSize)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .transition(.symbolEffect(.drawOn.individually))
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

#Preview {
    SplashScreenView()
}
