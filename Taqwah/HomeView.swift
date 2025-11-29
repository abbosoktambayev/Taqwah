import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("As-salamu alaykum")
                        .font(.largeTitle.bold())

                    Text("Home screen will be designed later")
                        .foregroundStyle(.secondary)
                }
                .padding()
            }
            .navigationTitle("")
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    HomeView()
}
