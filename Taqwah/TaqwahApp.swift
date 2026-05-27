import SwiftUI

@main
struct TaqwahApp: App {

    @StateObject private var settings = SettingsManager.shared
    @StateObject private var localization = LocalizationManager.shared

    init() {
        AppFont.register()
    }

    var body: some Scene {
        WindowGroup {
            SplashView()
                .environment(\.locale, localization.locale)
                .preferredColorScheme(settings.colorScheme)
                .task {
                    CloudSyncManager.shared.start()
                }
                .onOpenURL { url in
                    AppRouter.shared.handle(url)
                }
        }
    }
}
