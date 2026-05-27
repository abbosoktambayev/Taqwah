import SwiftUI

struct CalculationMethodView: View {
    @Environment(\.colorScheme) private var scheme
    @StateObject private var settings = SettingsManager.shared

    var body: some View {
        ZStack {
            AppBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {

                    // Intro
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "globe.asia.australia.fill")
                            .font(.title2)
                            .foregroundColor(.adaptiveAccent(scheme))

                        Text("Different authorities calculate prayer times with slightly different angles. Pick the one used in your region.")
                            .font(.caption)
                            .foregroundColor(.secondaryText(scheme))
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 28)
                            .fill(Color.glassFill(scheme))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 28)
                            .stroke(Color.glassBorder(scheme), lineWidth: 1)
                    )
                    .padding(.horizontal)

                    sectionLabel("CALCULATION METHOD")

                    VStack(spacing: 0) {
                        ForEach(Array(CalculationMethod.allCases.enumerated()), id: \.element.id) { index, method in
                            methodRow(method)

                            if index < CalculationMethod.allCases.count - 1 {
                                divider
                            }
                        }
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

                    // MARK: - Asr (Madhab)
                    sectionLabel("ASR CALCULATION")

                    VStack(spacing: 0) {
                        asrRow(title: "Standard",
                               subtitle: "Shafi'i, Maliki, Hanbali",
                               isHanafi: false)
                        divider
                        asrRow(title: "Hanafi",
                               subtitle: "Later Asr time (shadow ×2)",
                               isHanafi: true)
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

                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "info.circle")
                            .foregroundColor(.secondaryText(scheme))
                        Text("Asr setting applies to international methods. Muftiyat KZ already uses the Hanafi calculation.")
                            .font(.caption)
                            .foregroundColor(.secondaryText(scheme))
                    }
                    .padding(.horizontal, 24)

                    Spacer(minLength: 32)
                }
                .padding(.top, 8)
            }
        }
        .navigationTitle("Calculation Method")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Row

    private func methodRow(_ method: CalculationMethod) -> some View {
        let isSelected = settings.calculationMethod == method

        return Button {
            guard !isSelected else { return }
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            settings.calculationMethod = method
        } label: {
            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(method.title)
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(.adaptiveText(scheme))

                    Text(method.subtitle)
                        .font(.caption)
                        .foregroundColor(.secondaryText(scheme))
                }

                Spacer()

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(isSelected ? .adaptiveAccent(scheme) : .uncheckedBorder(scheme))
            }
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Asr Row

    private func asrRow(title: String, subtitle: String, isHanafi: Bool) -> some View {
        let isSelected = settings.hanafiAsr == isHanafi

        return Button {
            guard !isSelected else { return }
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            settings.hanafiAsr = isHanafi
        } label: {
            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(.adaptiveText(scheme))
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondaryText(scheme))
                }
                Spacer()
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(isSelected ? .adaptiveAccent(scheme) : .uncheckedBorder(scheme))
            }
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Components

    private func sectionLabel(_ text: String) -> some View {
        Text(LocalizedStringKey(text))
            .font(.caption.weight(.semibold))
            .foregroundColor(.sectionTitle(scheme))
            .padding(.horizontal)
    }

    private var divider: some View {
        Rectangle()
            .fill(Color.dividerColor(scheme))
            .frame(height: 1)
            .padding(.vertical, 4)
    }
}

#Preview("Dark") {
    NavigationStack { CalculationMethodView() }
        .preferredColorScheme(.dark)
}

#Preview("Light") {
    NavigationStack { CalculationMethodView() }
        .preferredColorScheme(.light)
}
