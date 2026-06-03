import SwiftUI

struct AthkarListView: View {
    let category: AthkarCategory
    @Environment(\.colorScheme) private var scheme
    @StateObject private var progress = AthkarProgressManager.shared
    @StateObject private var favorites = AthkarFavoritesManager.shared

    private var completedIndices: Set<Int> {
        progress.completed(for: category)
    }

    private var status: AthkarCategoryProgressSnapshot {
        progress.status(for: category)
    }

    private var athkarList: [Dhikr] {
        category.athkar
    }

    var body: some View {
        ZStack {
            AppBackground()

            ScrollView(showsIndicators: false) {
                LazyVStack(alignment: .leading, spacing: 20) {

                    // MARK: - Category Header
                    headerSection

                    // MARK: - Dhikr Cards
                    ForEach(Array(athkarList.enumerated()), id: \.element.id) { index, dhikr in
                        NavigationLink(destination: AthkarDetailView(
                            athkarList: athkarList,
                            startIndex: index,
                            completedIndices: progress.binding(for: category)
                        )) {
                            dhikrCard(dhikr, index: index)
                        }
                        .buttonStyle(.plain)
                    }

                    Spacer(minLength: 40)
                }
                .padding(.top, 8)
            }
        }
        .navigationTitle(LocalizedStringKey(category.rawValue))
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(.hidden, for: .navigationBar)
        .foregroundColor(.adaptiveText(scheme))
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(category.arabicTitle)
                .font(.quran(size: 30))
                .foregroundColor(.adaptiveText(scheme))

            HStack(spacing: 16) {
                Label("\(athkarList.count) athkar", systemImage: "book.fill")
                    .font(.subheadline)
                    .foregroundColor(.secondaryText(scheme))

                if !completedIndices.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.adaptiveAccent(scheme))
                        Text("\(completedIndices.count)/\(athkarList.count) done")
                            .foregroundColor(.adaptiveAccent(scheme))
                    }
                    .font(.subheadline)
                }
            }

            NavigationLink(destination: AthkarDetailView(
                athkarList: athkarList,
                startIndex: status.resumeIndex,
                completedIndices: progress.binding(for: category)
            )) {
                HStack(spacing: 8) {
                    Image(systemName: status.isComplete ? "arrow.counterclockwise" : "play.fill")
                    Text(status.isComplete ? "Review" : "Continue")
                }
                .font(.caption.weight(.semibold))
                .foregroundColor(status.isComplete ? .prayerAccent : .adaptiveAccent(scheme))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(status.isComplete ? Color.goldDim : Color.brandDim)
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)

            // Progress bar
            if !completedIndices.isEmpty {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.primary.opacity(scheme == .light ? 0.08 : 0.15))
                            .frame(height: 6)

                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                LinearGradient(
                                    colors: category.gradientColors,
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(
                                width: geo.size.width * CGFloat(completedIndices.count) / CGFloat(athkarList.count),
                                height: 6
                            )
                            .animation(.easeInOut(duration: 0.3), value: completedIndices.count)
                    }
                }
                .frame(height: 6)
            }
        }
        .padding(.horizontal)
    }

    // MARK: - Dhikr Card

    private func dhikrCard(_ dhikr: Dhikr, index: Int) -> some View {
        let isCompleted = completedIndices.contains(index)
        let isFavorite = favorites.isFavorite(dhikr)

        return VStack(alignment: .leading, spacing: 12) {
            // Top row: title + repetition badge
            HStack {
                HStack(spacing: 8) {
                    Text("\(index + 1)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.parchment)
                        .frame(width: 26, height: 26)
                        .background(
                            Circle().fill(
                                LinearGradient(
                                    colors: category.gradientColors,
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        )

                    Text(dhikr.title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.adaptiveText(scheme))
                        .lineLimit(1)
                }

                Spacer()

                HStack(spacing: 4) {
                    if isFavorite {
                        Image(systemName: "star.fill")
                            .foregroundColor(.prayerAccent)
                            .font(.system(size: 14))
                    }

                    if isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.adaptiveAccent(scheme))
                            .font(.system(size: 16))
                    }

                    Text("×\(dhikr.repetitions)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(isCompleted ? .adaptiveAccent(scheme) : .parchment)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            Capsule().fill(
                                LinearGradient(
                                    colors: isCompleted
                                        ? [Color.adaptiveAccent(scheme).opacity(0.16), Color.adaptiveAccent(scheme).opacity(0.16)]
                                        : category.gradientColors,
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        )
                }
            }

            // Arabic text
            Text(dhikr.arabic)
                .font(.quran(size: 22))
                .foregroundColor(.adaptiveText(scheme))
                .multilineTextAlignment(.trailing)
                .lineSpacing(10)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .lineLimit(3)

            // Source
            Text(dhikr.source)
                .font(.caption2)
                .foregroundColor(.secondaryText(scheme))
        }
        .padding(.vertical, 18)
        .padding(.horizontal, 18)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color.primary.opacity(scheme == .light ? 0.06 : 0.12))

                RoundedRectangle(cornerRadius: 28)
                    .stroke(
                        isCompleted
                            ? Color.adaptiveAccent(scheme).opacity(0.3)
                            : Color.cardBorder(scheme),
                        lineWidth: 1
                    )
            }
        )
        .padding(.horizontal)
    }
}

// MARK: - Previews

#Preview("Light") {
    NavigationStack {
        AthkarListView(category: .morning)
    }
    .preferredColorScheme(.light)
}

#Preview("Dark") {
    NavigationStack {
        AthkarListView(category: .morning)
    }
    .preferredColorScheme(.dark)
}
