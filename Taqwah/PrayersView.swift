import SwiftUI

struct PrayersView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Prayer Tracker")
                        .font(.title.bold())

                    Text("Here will be your 2/5, 5/5 progress UI")
                        .foregroundStyle(.secondary)
                }
                .padding()
            }
            .navigationTitle("Prayers")
        }
    }
}

#Preview {
    PrayersView()
}
