import SwiftUI

struct AppearanceView: View {
    @ObservedObject private var manager = SettingsManager.shared
    @Environment(\.colorScheme) private var scheme

    private let options: [(id: String, title: String, icon: String)] = [
        ("system", "System", "iphone"),
        ("light", "Light", "sun.max.fill"),
        ("dark", "Dark", "moon.stars.fill")
    ]

    var body: some View {
        List {
            Section {
                ForEach(options, id: \.id) { option in
                    Button {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        manager.colorSchemeSelection = option.id
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: option.icon)
                                .font(.system(size: 17))
                                .foregroundStyle(Color.adaptiveAccent(scheme))
                                .frame(width: 28)

                            Text(LocalizedStringKey(option.title))
                                .foregroundStyle(Color.adaptiveText(scheme))

                            Spacer()

                            if manager.colorSchemeSelection == option.id {
                                Image(systemName: "checkmark")
                                    .font(.body.weight(.semibold))
                                    .foregroundStyle(Color.adaptiveAccent(scheme))
                            }
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .listRowBackground(Color.cardBackground(scheme))
                }
            } footer: {
                Text("The app updates instantly when you pick a theme.")
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(AppBackground())
        .navigationTitle("Appearance")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("Dark") {
    NavigationStack { AppearanceView() }.preferredColorScheme(.dark)
}

#Preview("Light") {
    NavigationStack { AppearanceView() }.preferredColorScheme(.light)
}
