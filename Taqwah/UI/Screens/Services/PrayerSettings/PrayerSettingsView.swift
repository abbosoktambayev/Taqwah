import SwiftUI

struct PrayerSettingsView: View {
    @Environment(\.colorScheme) private var scheme
    @StateObject private var settings = SettingsManager.shared

    @AppStorage("adjust_Fajr") private var fajrAdj: Int = 0
    @AppStorage("adjust_Sunrise") private var sunriseAdj: Int = 0
    @AppStorage("adjust_Dhuhr") private var dhuhrAdj: Int = 0
    @AppStorage("adjust_Asr") private var asrAdj: Int = 0
    @AppStorage("adjust_Maghrib") private var maghribAdj: Int = 0
    @AppStorage("adjust_Isha") private var ishaAdj: Int = 0

    var body: some View {
        List {
            Section {
                NavigationLink {
                    CalculationMethodView()
                } label: {
                    HStack {
                        Text("Calculation Method")
                            .foregroundStyle(Color.adaptiveText(scheme))
                        Spacer()
                        Text(settings.calculationMethod.title)
                            .foregroundStyle(Color.secondaryText(scheme))
                    }
                }
                .listRowBackground(Color.cardBackground(scheme))
            }

            Section {
                adjustmentRow("Fajr", binding: $fajrAdj)
                adjustmentRow("Sunrise", binding: $sunriseAdj)
                adjustmentRow("Dhuhr", binding: $dhuhrAdj)
                adjustmentRow("Asr", binding: $asrAdj)
                adjustmentRow("Maghrib", binding: $maghribAdj)
                adjustmentRow("Isha", binding: $ishaAdj)
            } header: {
                Text("Time Adjustments")
            } footer: {
                Text("Adjustments are added to the calculated prayer times. Use ± minutes to fine-tune for your location.")
            }

            Section {
                Button(role: .destructive) {
                    resetAdjustments()
                } label: {
                    Text("Reset All Adjustments")
                        .frame(maxWidth: .infinity)
                }
                .listRowBackground(Color.cardBackground(scheme))
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(AppBackground())
        .navigationTitle("Prayer Settings")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            // Time adjustments changed → refresh scheduled prayer notifications.
            NotificationManager.shared.reschedule(using: PrayerTimesManager.shared.allDays)
        }
    }

    private func adjustmentRow(_ name: String, binding: Binding<Int>) -> some View {
        Stepper(value: binding, in: -30...30) {
            HStack {
                Text(LocalizedStringKey(name))
                    .foregroundStyle(Color.adaptiveText(scheme))
                Spacer()
                Text("\(binding.wrappedValue > 0 ? "+" : "")\(binding.wrappedValue) min")
                    .font(.subheadline)
                    .monospacedDigit()
                    .foregroundStyle(binding.wrappedValue == 0 ? Color.secondaryText(scheme) : Color.adaptiveAccent(scheme))
            }
        }
        .listRowBackground(Color.cardBackground(scheme))
    }

    private func resetAdjustments() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        fajrAdj = 0; sunriseAdj = 0; dhuhrAdj = 0
        asrAdj = 0; maghribAdj = 0; ishaAdj = 0
    }
}

#Preview("Dark") {
    NavigationStack { PrayerSettingsView() }.preferredColorScheme(.dark)
}

#Preview("Light") {
    NavigationStack { PrayerSettingsView() }.preferredColorScheme(.light)
}
