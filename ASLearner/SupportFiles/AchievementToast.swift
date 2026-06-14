import Combine
import SwiftUI
import UIKit

struct AchievementToastItem: Identifiable {
    let id = UUID()
    let title: String
    let symbolName: String
    let tint: Color
    var duration: TimeInterval = 2.4
}

@MainActor
final class AchievementToastCenter: ObservableObject {
    static let shared = AchievementToastCenter()

    @Published fileprivate var toasts: [AchievementToastItem] = []

    private init() {}

    func present(achievement: AchievementModel) {
        present(
            title: achievement.title,
            symbolName: achievement.symbolName,
            tint: LiquidGlassTheme.warning
        )
    }

    func present(title: String, symbolName: String, tint: Color? = nil) {
        withAnimation(.snappy(duration: 0.3)) {
            toasts.append(
                AchievementToastItem(
                    title: title,
                    symbolName: symbolName,
                    tint: tint ?? LiquidGlassTheme.warning
                )
            )
        }
    }

    fileprivate func remove(_ item: AchievementToastItem) {
        withAnimation(.snappy(duration: 0.3)) {
            toasts.removeAll { $0.id == item.id }
        }
    }
}

struct AchievementToastRootView<Content: View>: View {
    @ViewBuilder let content: Content

    @State private var overlayWindow: UIWindow?

    var body: some View {
        content
            .onAppear {
                configureToastWindowIfNeeded()
            }
    }

    private func configureToastWindowIfNeeded() {
        guard overlayWindow == nil,
              let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return
        }

        let window = PassthroughToastWindow(windowScene: windowScene)
        window.backgroundColor = .clear
        window.isHidden = false
        window.isUserInteractionEnabled = true
        window.tag = 1401

        let controller = UIHostingController(rootView: AchievementToastGroup())
        controller.view.frame = windowScene.keyWindow?.frame ?? .zero
        controller.view.backgroundColor = .clear
        window.rootViewController = controller

        overlayWindow = window
    }
}

private final class PassthroughToastWindow: UIWindow {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let view = super.hitTest(point, with: event) else { return nil }
        return rootViewController?.view == view ? nil : view
    }
}

private struct AchievementToastGroup: View {
    @ObservedObject private var center = AchievementToastCenter.shared

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                ForEach(center.toasts) { item in
                    AchievementToastView(size: proxy.size, item: item)
                        .scaleEffect(scale(for: item))
                        .offset(y: offsetY(for: item))
                        .zIndex(Double(center.toasts.firstIndex { $0.id == item.id } ?? 0))
                }
            }
            .padding(.bottom, proxy.safeAreaInsets.bottom + 70)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        }
    }

    private func offsetY(for item: AchievementToastItem) -> CGFloat {
        let index = CGFloat(center.toasts.firstIndex { $0.id == item.id } ?? 0)
        let totalCount = CGFloat(center.toasts.count) - 1
        return (totalCount - index) >= 2 ? -22 : ((totalCount - index) * -12)
    }

    private func scale(for item: AchievementToastItem) -> CGFloat {
        let index = CGFloat(center.toasts.firstIndex { $0.id == item.id } ?? 0)
        let totalCount = CGFloat(center.toasts.count) - 1
        return 1 - ((totalCount - index) >= 2 ? 0.16 : ((totalCount - index) * 0.08))
    }
}

private struct AchievementToastView: View {
    let size: CGSize
    let item: AchievementToastItem

    @State private var dismissTask: DispatchWorkItem?

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: item.symbolName)
                .font(.system(size: 21, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 40, height: 40)
                .background(
                    LinearGradient(
                        colors: [
                            item.tint.opacity(0.95),
                            item.tint.opacity(0.58)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    in: Circle()
                )
                .overlay {
                    Circle()
                        .stroke(Color.white.opacity(0.42), lineWidth: 1)
                }

            VStack(alignment: .leading, spacing: 2) {
                Text(item.title)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(LiquidGlassTheme.foreground)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(maxWidth: min(size.width - 40, 360))
        .glassEffect(.regular.interactive().tint(item.tint.opacity(0.18)), in: .rect(cornerRadius: 22))
        .contentShape(.rect(cornerRadius: 22))
        .gesture(
            DragGesture(minimumDistance: 0)
                .onEnded { value in
                    if value.translation.height + value.velocity.height > 90 {
                        removeToast()
                    }
                }
        )
        .transition(.scale.combined(with: .opacity))
        .onAppear {
            guard dismissTask == nil else { return }
            let task = DispatchWorkItem {
                removeToast()
            }
            dismissTask = task
            DispatchQueue.main.asyncAfter(deadline: .now() + item.duration, execute: task)
        }
    }

    private func removeToast() {
        dismissTask?.cancel()
        AchievementToastCenter.shared.remove(item)
    }
}
