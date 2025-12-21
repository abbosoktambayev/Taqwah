import SwiftUI

struct AppearanceView: View {
    // Наблюдаем за менеджером
    @ObservedObject private var manager = SettingsManager.shared
    
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Choose your theme")
                        .font(.headline)
                    
                    // Привязываем выбор к строковой переменной в менеджере
                    Picker("Theme", selection: $manager.colorSchemeSelection) {
                        Text("System").tag("system")
                        Text("Light").tag("light")
                        Text("Dark").tag("dark")
                    }
                    .pickerStyle(.segmented)
                }
                .padding(.vertical, 8)
            }
            
            Section {
                Text("The app will follow your choice immediately.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("Appearance")
    }
}

#Preview {
    AppearanceView()
        .preferredColorScheme(.dark)
}
