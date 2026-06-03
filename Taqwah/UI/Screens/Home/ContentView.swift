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
                    Image(systemName: "square.grid.2x2")
                    Text(verbatim: localization.localized("Services"))
                }
                .tag(AppTab.services)
        }
        .tint(.adaptiveAccent(scheme))
        .id(localization.languageCode)
    }
}

#Preview {
    ContentView()
}
