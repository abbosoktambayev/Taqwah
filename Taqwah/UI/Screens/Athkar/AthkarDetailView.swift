import SwiftUI

struct AthkarDetailView: View {
    let athkarList: [Dhikr]
    let startIndex: Int
    @Binding var completedIndices: Set<Int>
    @Environment(\.colorScheme) private var scheme
    @StateObject private var progressManager = AthkarProgressManager.shared
    @StateObject private var favorites = AthkarFavoritesManager.shared

    @State private var currentIndex: Int = 0
    @State private var counter: Int = 0
    @State private var isCompleted: Bool = false

    private var currentDhikr: Dhikr {
        athkarList[currentIndex]
    }

    private var countProgress: CGFloat {
        guard currentDhikr.repetitions > 0 else { return 0 }
        return min(CGFloat(counter) / CGFloat(currentDhikr.repetitions), 1.0)
    }

    var body: some View {
        ZStack {
            AppBackground()

            VStack(spacing: 0) {
                // Progress header
                progressHeader
                    .padding(.bottom, 16)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Arabic text
                        arabicSection

                        // Translation
                        translationSection

                        // Virtue
                        if let virtue = currentDhikr.virtue {
                            virtueSection(virtue)
                        }
                    }
                    .padding(.horizontal)
                }

                Spacer()

                // Counter area
                counterSection
                    .padding(.bottom, 16)

                // Navigation
                navigationButtons
                    .padding(.bottom, 8)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    withAnimation(Motion.standard) {
                        favorites.toggle(currentDhikr)
                    }
                } label: {
                    Image(systemName: favorites.isFavorite(currentDhikr) ? "star.fill" : "star")
                        .foregroundColor(favorites.isFavorite(currentDhikr) ? .prayerAccent : .adaptiveAccent(scheme))
                }
                .accessibilityLabel(favorites.isFavorite(currentDhikr) ? "Remove from Favorites" : "Add to Favorites")
            }
        }
        .foregroundColor(.adaptiveText(scheme))
        .onAppear {
            currentIndex = min(max(startIndex, 0), max(athkarList.count - 1, 0))
            syncCurrentState()
        }
    }

    // MARK: - Progress Header

    private var progressHeader: some View {
        VStack(spacing: 8) {
            HStack {
                Text(currentDhikr.title)
                    .font(.headline)
                    .foregroundColor(.adaptiveText(scheme))

                Spacer()

                Text("\(currentIndex + 1)/\(athkarList.count)")
                    .font(.caption)
                    .foregroundColor(.secondaryText(scheme))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.cardBackground(scheme))
                    .clipShape(Capsule())
            }

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.progressTrack(scheme))

                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.adaptiveAccent(scheme))
                        .frame(width: geo.size.width * CGFloat(currentIndex + 1) / max(CGFloat(athkarList.count), 1))
                        .animation(.easeInOut, value: currentIndex)
                }
            }
            .frame(height: 4)
        }
        .padding(.horizontal)
    }

    // MARK: - Arabic Section

    private var arabicSection: some View {
        VStack(spacing: 12) {
            Text(currentDhikr.arabic)
                .font(.quran(size: 30))
                .multilineTextAlignment(.center)
                .lineSpacing(16)
                .foregroundColor(.adaptiveText(scheme))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .padding(.horizontal, 16)
                .background(Color.readingSurface)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.cardBorder(scheme), lineWidth: 1)
                )

            Text(currentDhikr.source)
                .font(.caption)
                .foregroundColor(.secondaryText(scheme))
        }
    }

    // MARK: - Translation

    private var translationSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(currentDhikr.transliteration)
                .font(.subheadline)
                .italic()
                .foregroundColor(.secondaryText(scheme))

            Text(currentDhikr.translation)
                .font(.subheadline)
                .foregroundColor(.adaptiveText(scheme))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.cardBackground(scheme))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    // MARK: - Virtue

    private func virtueSection(_ virtue: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "star.fill")
                .foregroundColor(.prayerAccent)
            Text(virtue)
                .font(.caption)
                .foregroundColor(.adaptiveText(scheme))
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.prayerAccent.opacity(scheme == .light ? 0.12 : 0.10))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Counter

    private var counterSection: some View {
        VStack(spacing: 12) {
            // Counter circle — tap to count
            Button {
                if counter < currentDhikr.repetitions {
                    counter += 1
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()

                    if counter >= currentDhikr.repetitions {
                        isCompleted = true
                        completedIndices.insert(currentIndex)
                        progressManager.recordOpened(currentDhikr.category, index: currentIndex)
                        UINotificationFeedbackGenerator().notificationOccurred(.success)

                        // Auto-advance after short delay
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                            goToNext()
                        }
                    }
                }
            } label: {
                ZStack {
                    // Track circle
                    Circle()
                        .stroke(Color.progressTrack(scheme), lineWidth: 8)
                        .frame(width: 120, height: 120)

                    // Progress arc
                    Circle()
                        .trim(from: 0, to: countProgress)
                        .stroke(
                            isCompleted ? Color.adaptiveAccent(scheme) : Color.adaptiveAccent(scheme),
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .frame(width: 120, height: 120)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 0.2), value: counter)

                    // Count text
                    VStack(spacing: 2) {
                        if isCompleted {
                            Image(systemName: "checkmark")
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(.adaptiveAccent(scheme))
                        } else {
                            Text("\(counter)")
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(.adaptiveText(scheme))
                            Text("/ \(currentDhikr.repetitions)")
                                .font(.caption)
                                .foregroundColor(.secondaryText(scheme))
                        }
                    }
                }
            }
            .buttonStyle(.plain)

            Text("Tap to count")
                .font(.caption)
                .foregroundColor(.secondaryText(scheme))
        }
    }

    // MARK: - Navigation

    private var navigationButtons: some View {
        HStack(spacing: 20) {
            Button {
                goToPrevious()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left")
                    Text("Previous")
                }
                .font(.subheadline.weight(.medium))
                .foregroundColor(currentIndex > 0 ? .adaptiveAccent(scheme) : .secondaryText(scheme))
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color.cardBackground(scheme))
                .clipShape(Capsule())
            }
            .disabled(currentIndex == 0)

            Button {
                goToNext()
            } label: {
                HStack(spacing: 6) {
                    Text("Next")
                    Image(systemName: "chevron.right")
                }
                .font(.subheadline.weight(.medium))
                .foregroundColor(currentIndex < athkarList.count - 1 ? .adaptiveAccent(scheme) : .secondaryText(scheme))
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color.cardBackground(scheme))
                .clipShape(Capsule())
            }
            .disabled(currentIndex >= athkarList.count - 1)
        }
    }

    // MARK: - Logic

    private func goToNext() {
        guard currentIndex < athkarList.count - 1 else { return }
        currentIndex += 1
        syncCurrentState()
    }

    private func goToPrevious() {
        guard currentIndex > 0 else { return }
        currentIndex -= 1
        syncCurrentState()
    }

    private func syncCurrentState() {
        guard athkarList.indices.contains(currentIndex) else { return }
        isCompleted = completedIndices.contains(currentIndex)
        counter = isCompleted ? currentDhikr.repetitions : 0
        progressManager.recordOpened(currentDhikr.category, index: currentIndex)
    }
}

#Preview {
    NavigationStack {
        AthkarDetailView(
            athkarList: AthkarCategory.morning.athkar,
            startIndex: 0,
            completedIndices: .constant([])
        )
        .preferredColorScheme(.dark)
    }
}
