import SwiftUI

struct AthkarView: View {
    @State private var count = 0

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Text("Athkar Counter")
                    .font(.title)
                    .padding(.top, 24)

                Text("\(count)")
                    .font(.system(size: 72, weight: .bold))
                    .padding()

                Button {
                    count += 1
                } label: {
                    Text("Tap to count")
                        .font(.title3)
                        .frame(width: 200, height: 200)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                }

                Button {
                    count = 0
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.title2)
                        .padding()
                        .foregroundColor(.green)
                        .background(Color.white.opacity(0.1))
                        .clipShape(Circle())
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Athkar")
        }
    }
}

#Preview {
    AthkarView()
}
