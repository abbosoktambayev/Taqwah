import SwiftUI

struct ContentView: View {
    @StateObject private var router = AppRouter.shared
    @StateObject private var localization = LocalizationManager.shared
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        TabView(selection: $router.selectedTab) {
            HomeView()
                .tabItem {
                    Image(systemName: "house")
                    Text(verbatim: localization.localized("Home"))
                }
                .tag(AppTab.home)

            PrayersView()
                .tabItem {
                    Image(systemName: "checkmark.circle")
                    Text(verbatim: localization.localized("Prayers"))
                }
                .tag(AppTab.prayers)

            AthkarView()
                .tabItem {
                    Image(systemName: "bookmark")
                    Text(verbatim: localization.localized("Athkar"))
                }
                .tag(AppTab.athkar)

            ServicesView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text(verbatim: localization.localized("Settings"))
                }
                .tag(AppTab.services)
        }
        .tint(.adaptiveAccent(scheme))
        .id(localization.languageCode)
        .screenshotSharePrompt()
    }
}

#Preview {
    ContentView()
}
