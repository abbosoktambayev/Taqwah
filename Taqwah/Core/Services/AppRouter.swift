import SwiftUI
import Combine

enum AppTab: Hashable {
    case home, prayers, athkar, services
}

/// Routes deep links (e.g. from widgets) to the right tab.
@MainActor
final class AppRouter: ObservableObject {
    static let shared = AppRouter()

    @Published var selectedTab: AppTab = .home

    private init() {}

    /// Handle a `taqwah://<host>` deep link.
    func handle(_ url: URL) {
        switch url.host {
        case "prayers":  selectedTab = .prayers
        case "athkar":   selectedTab = .athkar
        case "services": selectedTab = .services
        default:         selectedTab = .home
        }
    }
}
