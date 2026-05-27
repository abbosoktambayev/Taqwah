import SwiftUI

struct ContentView: View {
    @StateObject private var router = AppRouter.shared
    @StateObject private var localization = LocalizationManager.shared

    var body: some View {
        TabView(selection: $router.selectedTab) {
            HomeView()
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
                .tag(AppTab.home)

            PrayersView()
                .tabItem {
                    Image(systemName: "checkmark.circle")
                    Text("Prayers")
                }
                .tag(AppTab.prayers)

            AthkarView()
                .tabItem {
                    Image(systemName: "bookmark")
                    Text("Athkar")
                }
                .tag(AppTab.athkar)

            ServicesView()
                .tabItem {
                    Image(systemName: "square.grid.2x2")
                    Text("Services")
                }
                .tag(AppTab.services)
        }
        .accentColor(.green)
        .id(localization.languageCode)
    }
}

#Preview {
    ContentView()
}
