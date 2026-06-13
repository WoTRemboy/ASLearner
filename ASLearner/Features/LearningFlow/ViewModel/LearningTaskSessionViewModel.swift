import Foundation
import SwiftUI
import Combine

@MainActor
final class LearningTaskSessionViewModel: ObservableObject {
    let pageCount: Int
    let resultPercent: Int

    @Published var currentPageIndex = 0
    @Published var elapsedSeconds = 0
    @Published var resultPercentCounter = 0
    @Published var isShowingResultContent = false

    private var elapsedTask: Task<Void, Never>?
    private var resultCounterTask: Task<Void, Never>?

    init(pageCount: Int, resultPercent: Int = 100) {
        self.pageCount = max(1, pageCount)
        self.resultPercent = max(0, min(100, resultPercent))
    }

    deinit {
        elapsedTask?.cancel()
        resultCounterTask?.cancel()
    }

    var isResultPage: Bool {
        currentPageIndex == pageCount - 1
    }

    var progress: Double {
        guard pageCount > 1 else { return 1 }
        return Double(currentPageIndex) / Double(pageCount - 1)
    }

    var timeString: String {
        let minutes = elapsedSeconds / 60
        let seconds = elapsedSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var currentPageID: String {
        "task-page-\(currentPageIndex)"
    }

    func startTimer() {
        guard elapsedTask == nil else { return }
        elapsedTask = Task { @MainActor [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                guard !Task.isCancelled else { return }
                self?.elapsedSeconds += 1
            }
        }
    }

    func stopTimer() {
        elapsedTask?.cancel()
        elapsedTask = nil
    }

    func moveForward(canMoveForward: Bool) {
        guard canMoveForward, currentPageIndex < pageCount - 1 else { return }

        withAnimation(.spring(response: 0.42, dampingFraction: 0.86)) {
            currentPageIndex += 1
        }

        if isResultPage {
            stopTimer()
            startResultCounter()
        }
    }

    private func startResultCounter() {
        resultCounterTask?.cancel()
        resultPercentCounter = 0
        isShowingResultContent = false

        resultCounterTask = Task { @MainActor [weak self] in
            try? await Task.sleep(nanoseconds: 350_000_000)

            while !Task.isCancelled {
                guard let self else { return }

                if self.resultPercentCounter < self.resultPercent {
                    withAnimation(.linear(duration: 0.006)) {
                        self.resultPercentCounter += 1
                    }
                    try? await Task.sleep(nanoseconds: 6_000_000)
                } else {
                    self.resultCounterTask = nil
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                        self.isShowingResultContent = true
                    }
                    return
                }
            }
        }
    }
}
