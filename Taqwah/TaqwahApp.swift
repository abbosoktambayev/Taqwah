import SwiftUI

@main
struct TaqwahApp: App {

    @StateObject private var settings = SettingsManager.shared

    var body: some Scene {
        WindowGroup {
            SplashView()
                .preferredColorScheme(settings.colorScheme)
        }
    }
}
