import SwiftUI

struct CalculationMethodView: View {
    @Environment(\.colorScheme) private var scheme
    @StateObject private var settings = SettingsManager.shared

    var body: some View {
        List {
            Section {
                ForEach(CalculationMethod.allCases) { method in
                    selectableRow(
                        title: method.title,
                        subtitle: method.subtitle,
                        isSelected: settings.calculationMethod == method
                    ) {
                        guard settings.calculationMethod != method else { return }
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        settings.calculationMethod = method
                    }
                }
            } header: {
                Text("Calculation Method")
            } footer: {
                Text("Different authorities calculate prayer times with slightly different angles. Pick the one used in your region.")
            }

            Section {
                selectableRow(
                    title: "Standard",
                    subtitle: "Shafi'i, Maliki, Hanbali",
                    isSelected: !settings.hanafiAsr
                ) {
                    guard settings.hanafiAsr else { return }
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    settings.hanafiAsr = false
                }
                selectableRow(
                    title: "Hanafi",
                    subtitle: "Later Asr time (shadow ×2)",
                    isSelected: settings.hanafiAsr
                ) {
                    guard !settings.hanafiAsr else { return }
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    settings.hanafiAsr = true
                }
            } header: {
                Text("Asr Calculation")
            } footer: {
                Text("Asr setting applies to international methods. Muftiyat KZ already uses the Hanafi calculation.")
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(AppBackground())
        .navigationTitle("Calculation Method")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func selectableRow(
        title: String,
        subtitle: String,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(LocalizedStringKey(title))
                        .foregroundStyle(Color.adaptiveText(scheme))
                    Text(LocalizedStringKey(subtitle))
                        .font(.caption)
                        .foregroundStyle(Color.secondaryText(scheme))
                }
                Spacer()
                if isSelected {
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
}

#Preview("Dark") {
    NavigationStack { CalculationMethodView() }.preferredColorScheme(.dark)
}

#Preview("Light") {
    NavigationStack { CalculationMethodView() }.preferredColorScheme(.light)
}
