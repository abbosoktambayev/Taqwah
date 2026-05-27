import SwiftUI

struct TasbihView: View {
    @Environment(\.colorScheme) private var scheme
    @StateObject private var tasbih = TasbihManager.shared
    @State private var pulse = false

    var body: some View {
        ZStack {
            AppBackground()

            VStack(spacing: 0) {
                phraseSelector
                    .padding(.top, 8)

                Spacer()

                counterButton

                Spacer()

                statsRow
                targetSelector
                resetButtons
                    .padding(.bottom, 16)
            }
        }
        .navigationTitle("Tasbih")
        .navigationBarTitleDisplayMode(.inline)
        .foregroundColor(.adaptiveText(scheme))
    }

    // MARK: - Phrase selector

    private var phraseSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(Array(TasbihPhrase.presets.enumerated()), id: \.element.id) { index, phrase in
                    let isSelected = index == tasbih.phraseIndex
                    Button {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        tasbih.selectPhrase(index)
                    } label: {
                        Text(phrase.transliteration)
                            .font(.subheadline.weight(.medium))
                            .foregroundColor(isSelected ? .white : .secondaryText(scheme))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(
                                Capsule().fill(isSelected
                                    ? Color.adaptiveAccent(scheme)
                                    : Color.glassFill(scheme))
                            )
                            .overlay(
                                Capsule().stroke(Color.glassBorder(scheme), lineWidth: isSelected ? 0 : 1)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
        }
    }

    // MARK: - Counter

    private var counterButton: some View {
        Button {
            tap()
        } label: {
            ZStack {
                Circle()
                    .stroke(Color.progressTrack(scheme), lineWidth: 14)
                    .frame(width: 260, height: 260)

                Circle()
                    .trim(from: 0, to: tasbih.progress)
                    .stroke(
                        Color.adaptiveAccent(scheme),
                        style: StrokeStyle(lineWidth: 14, lineCap: .round)
                    )
                    .frame(width: 260, height: 260)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut(duration: 0.2), value: tasbih.count)

                VStack(spacing: 10) {
                    Text(tasbih.phrase.arabic)
                        .font(.quran(size: 30))
                        .foregroundColor(.adaptiveText(scheme))
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.6)
                        .padding(.horizontal, 24)

                    Text("\(tasbih.count)")
                        .font(.system(size: 64, weight: .bold, design: .rounded))
                        .foregroundColor(.adaptiveAccent(scheme))
                        .contentTransition(.numericText())

                    if tasbih.target > 0 {
                        Text("of \(tasbih.target)")
                            .font(.subheadline)
                            .foregroundColor(.secondaryText(scheme))
                    }
                }
            }
            .frame(width: 260, height: 260)
            .contentShape(Circle())
            .scaleEffect(pulse ? 0.96 : 1.0)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Stats

    private var statsRow: some View {
        HStack(spacing: 12) {
            statChip(icon: "arrow.triangle.2.circlepath", value: "\(tasbih.rounds)", label: "Rounds")
            statChip(icon: "infinity", value: "\(tasbih.total)", label: "Total")
        }
        .padding(.horizontal)
        .padding(.bottom, 16)
    }

    private func statChip(icon: String, value: String, label: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundColor(.adaptiveAccent(scheme))
            VStack(alignment: .leading, spacing: 1) {
                Text(value)
                    .font(.headline)
                    .foregroundColor(.adaptiveText(scheme))
                Text(LocalizedStringKey(label))
                    .font(.caption2)
                    .foregroundColor(.secondaryText(scheme))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.glassFill(scheme))
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.glassBorder(scheme), lineWidth: 1))
    }

    // MARK: - Target selector

    private var targetSelector: some View {
        HStack(spacing: 10) {
            ForEach(TasbihManager.targets, id: \.self) { value in
                let isSelected = value == tasbih.target
                Button {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    tasbih.selectTarget(value)
                } label: {
                    Text(value == 0 ? "∞" : "\(value)")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(isSelected ? .white : .secondaryText(scheme))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(isSelected ? Color.adaptiveAccent(scheme) : Color.glassFill(scheme))
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 12)
    }

    // MARK: - Reset

    private var resetButtons: some View {
        HStack(spacing: 16) {
            Button {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                withAnimation { tasbih.resetCount() }
            } label: {
                Label("Reset count", systemImage: "arrow.counterclockwise")
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.adaptiveAccent(scheme))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.glassFill(scheme))
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)

            Button {
                UINotificationFeedbackGenerator().notificationOccurred(.warning)
                withAnimation { tasbih.resetAll() }
            } label: {
                Label("Reset rounds", systemImage: "trash")
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.secondaryText(scheme))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.glassFill(scheme))
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal)
    }

    // MARK: - Logic

    private func tap() {
        let completedRound = tasbih.increment()

        withAnimation(.easeInOut(duration: 0.08)) { pulse = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
            withAnimation(.easeInOut(duration: 0.12)) { pulse = false }
        }

        if completedRound {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        } else {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
    }
}

#Preview("Dark") {
    NavigationStack { TasbihView() }.preferredColorScheme(.dark)
}

#Preview("Light") {
    NavigationStack { TasbihView() }.preferredColorScheme(.light)
}
