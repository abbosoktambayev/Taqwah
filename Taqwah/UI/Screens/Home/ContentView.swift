import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }

            PrayersView()
                .tabItem {
                    Image(systemName: "checkmark.circle")
                    Text("Prayers")
                }

            AthkarView()
                .tabItem {
                    Image(systemName: "bookmark")
                    Text("Athkar")
                }

            ServicesView()
                .tabItem {
                    Image(systemName: "square.grid.2x2")
                    Text("Services")
                }
        }
        .accentColor(.green)
    }
}

#Preview {
    ContentView()
}
