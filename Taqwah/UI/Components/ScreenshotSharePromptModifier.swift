import SwiftUI
import Foundation
import UIKit

struct ScreenshotSharePromptModifier: ViewModifier {
    @State private var isPresented = false
    @State private var autoDismissWorkItem: DispatchWorkItem?

    private let defaults: UserDefaults

    private enum Keys {
        static let lastShownDate = "screenshotSharePrompt.lastShownDate"
        static let screenshotCountSinceLastShow = "screenshotSharePrompt.screenshotCountSinceLastShow"
        static let disabled = "screenshotSharePrompt.disabled"
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .top) {
                if isPresented {
                    ScreenshotShareBanner(
                        title: "Sharing Taqwah?",
                        subtitle: "Tag @abbos.dev",
                        onDismiss: dismissPrompt
                    )
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(10)
                }
            }
            .animation(.easeOut(duration: 0.30), value: isPresented)
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.userDidTakeScreenshotNotification)) { _ in
                handleScreenshot()
            }
            .onDisappear {
                autoDismissWorkItem?.cancel()
                autoDismissWorkItem = nil
            }
    }

    private func handleScreenshot() {
        guard !isDisabledForAutomation else { return }

        let count = defaults.integer(forKey: Keys.screenshotCountSinceLastShow) + 1
        defaults.set(count, forKey: Keys.screenshotCountSinceLastShow)

        guard shouldShowPrompt(screenshotCount: count) else { return }

        defaults.set(Date(), forKey: Keys.lastShownDate)
        defaults.set(0, forKey: Keys.screenshotCountSinceLastShow)
        presentPrompt()
    }

    private func shouldShowPrompt(screenshotCount: Int) -> Bool {
        #if DEBUG
        // Always show while developing so the prompt is easy to verify.
        return true
        #else
        // Production: at most once per hour, so it nudges without nagging.
        if let lastShown = defaults.object(forKey: Keys.lastShownDate) as? Date,
           Date().timeIntervalSince(lastShown) < 60 * 60 {
            return false
        }
        return true
        #endif
    }

    private func presentPrompt() {
        autoDismissWorkItem?.cancel()
        withAnimation(.easeOut(duration: 0.30)) {
            isPresented = true
        }

        let workItem = DispatchWorkItem {
            dismissPrompt()
        }
        autoDismissWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5, execute: workItem)
    }

    private func dismissPrompt() {
        autoDismissWorkItem?.cancel()
        autoDismissWorkItem = nil
        withAnimation(.easeOut(duration: 0.25)) {
            isPresented = false
        }
    }

    private var isDisabledForAutomation: Bool {
        defaults.bool(forKey: Keys.disabled)
        || ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
        || ProcessInfo.processInfo.environment["TAQWAH_DISABLE_SCREENSHOT_SHARE_PROMPT"] == "1"
        || ProcessInfo.processInfo.arguments.contains("-DisableScreenshotSharePrompt")
    }
}

extension View {
    func screenshotSharePrompt() -> some View {
        modifier(ScreenshotSharePromptModifier())
    }
}
