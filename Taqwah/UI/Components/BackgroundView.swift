import SwiftUI

struct AppBackground: View {
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        Group {
            if scheme == .light {
                LinearGradient(
                    colors: [
                        Color(red: 226/255, green: 240/255, blue: 230/255),
                        Color(red: 240/255, green: 248/255, blue: 242/255),
                        Color(red: 248/255, green: 252/255, blue: 249/255)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            } else {
                LinearGradient(
                    colors: [
                        Color(red: 9/255, green: 51/255, blue: 27/255),
                        Color(red: 1/255, green: 26/255, blue: 21/255),
                        .black
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
        }
        .ignoresSafeArea()
    }
}
