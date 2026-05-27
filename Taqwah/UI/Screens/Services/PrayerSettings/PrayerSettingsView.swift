import SwiftUI

struct PrayerSettingsView: View {
    @Environment(\.colorScheme) private var scheme
    @StateObject private var settings = SettingsManager.shared

    private let prayers = ["Fajr", "Sunrise", "Dhuhr", "Asr", "Maghrib", "Isha"]
    
    @AppStorage("adjust_Fajr") private var fajrAdj: Int = 0
    @AppStorage("adjust_Sunrise") private var sunriseAdj: Int = 0
    @AppStorage("adjust_Dhuhr") private var dhuhrAdj: Int = 0
    @AppStorage("adjust_Asr") private var asrAdj: Int = 0
    @AppStorage("adjust_Maghrib") private var maghribAdj: Int = 0
    @AppStorage("adjust_Isha") private var ishaAdj: Int = 0
    
    var body: some View {
        ZStack {
            AppBackground()
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    
                    // MARK: - Calculation Method
                    sectionLabel("CALCULATION METHOD")

                    NavigationLink {
                        CalculationMethodView()
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(settings.calculationMethod.title)
                                    .font(.system(size: 17, weight: .medium))
                                    .foregroundColor(.adaptiveText(scheme))

                                Text(settings.calculationMethod.subtitle)
                                    .font(.caption)
                                    .foregroundColor(.secondaryText(scheme))
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondaryText(scheme))
                                .font(.caption)
                        }
                        .padding(.vertical, 10)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 28)
                            .fill(Color.glassFill(scheme))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 28)
                            .stroke(Color.glassBorder(scheme), lineWidth: 1)
                    )
                    .padding(.horizontal)
                    
                    // MARK: - Time Adjustments
                    sectionLabel("TIME ADJUSTMENTS")
                    
                    VStack(spacing: 0) {
                        adjustmentRow("Fajr", binding: $fajrAdj)
                        divider
                        adjustmentRow("Sunrise", binding: $sunriseAdj)
                        divider
                        adjustmentRow("Dhuhr", binding: $dhuhrAdj)
                        divider
                        adjustmentRow("Asr", binding: $asrAdj)
                        divider
                        adjustmentRow("Maghrib", binding: $maghribAdj)
                        divider
                        adjustmentRow("Isha", binding: $ishaAdj)
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 28)
                            .fill(Color.glassFill(scheme))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 28)
                            .stroke(Color.glassBorder(scheme), lineWidth: 1)
                    )
                    .padding(.horizontal)
                    
                    // Reset button
                    Button {
                        resetAdjustments()
                    } label: {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Reset All Adjustments")
                        }
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(.adaptiveAccent(scheme))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 28)
                                .fill(Color.glassFill(scheme))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 28)
                                .stroke(Color.glassBorder(scheme), lineWidth: 1)
                        )
                    }
                    .padding(.horizontal)
                    
                    // Info note
                    HStack(spacing: 10) {
                        Image(systemName: "info.circle")
                            .foregroundColor(.secondaryText(scheme))
                        
                        Text("Adjustments are added to the calculated prayer times. Use ± minutes to fine-tune for your location.")
                            .font(.caption)
                            .foregroundColor(.secondaryText(scheme))
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer(minLength: 32)
                }
                .padding(.top, 8)
            }
        }
        .navigationTitle("Prayer Settings")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            // Time adjustments changed → refresh scheduled prayer notifications.
            NotificationManager.shared.reschedule(using: PrayerTimesManager.shared.allDays)
        }
    }
    
    // MARK: - Components
    
    private func sectionLabel(_ text: String) -> some View {
        Text(LocalizedStringKey(text))
            .font(.caption.weight(.semibold))
            .foregroundColor(.sectionTitle(scheme))
            .padding(.horizontal)
    }
    
    private func adjustmentRow(_ name: String, binding: Binding<Int>) -> some View {
        HStack {
            Text(name)
                .font(.system(size: 16))
                .foregroundColor(.adaptiveText(scheme))
            
            Spacer()
            
            HStack(spacing: 12) {
                Button {
                    binding.wrappedValue -= 1
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.title3)
                        .foregroundColor(.secondaryText(scheme))
                }
                
                Text("\(binding.wrappedValue > 0 ? "+" : "")\(binding.wrappedValue) min")
                    .font(.system(size: 14, weight: .medium, design: .monospaced))
                    .foregroundColor(binding.wrappedValue == 0 ? .secondaryText(scheme) : .adaptiveAccent(scheme))
                    .frame(width: 70)
                
                Button {
                    binding.wrappedValue += 1
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundColor(.secondaryText(scheme))
                }
            }
        }
        .padding(.vertical, 8)
    }
    
    private var divider: some View {
        Rectangle()
            .fill(Color.dividerColor(scheme))
            .frame(height: 1)
            .padding(.vertical, 4)
    }
    
    private func resetAdjustments() {
        fajrAdj = 0
        sunriseAdj = 0
        dhuhrAdj = 0
        asrAdj = 0
        maghribAdj = 0
        ishaAdj = 0
    }
}

#Preview("Dark") {
    NavigationStack {
        PrayerSettingsView()
    }
    .preferredColorScheme(.dark)
}

#Preview("Light") {
    NavigationStack {
        PrayerSettingsView()
    }
    .preferredColorScheme(.light)
}
