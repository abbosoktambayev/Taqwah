import SwiftUI

struct AppBackground: View {
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        Color.adaptiveBackground(scheme)
        .ignoresSafeArea()
    }
}
