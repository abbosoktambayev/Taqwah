import SwiftUI

struct AthkarView: View {

    @Environment(\.colorScheme) private var scheme
    @StateObject private var progress = AthkarProgressManager.shared
    @StateObject private var favorites = AthkarFavoritesManager.shared

    private let columns = [
        GridItem(.flexible(), spacing: 16, alignment: .top),
        GridItem(.flexible(), spacing: 16, alignment: .top)
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()
                    .foregroundColor(.primary)

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {

                        dailyStatusSection

                        Text("Choose a category")
                            .foregroundColor(.secondaryText(scheme))
                            .padding(.horizontal)

                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(AthkarCategory.allCases) { category in
                                NavigationLink(destination: AthkarListView(category: category)) {
                                    categoryCard(category)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal)

                        Text("FAVORITES")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(.sectionTitle(scheme))
                            .padding(.horizontal)

                        NavigationLink(destination: AthkarFavoritesView()) {
                            favoritesCard
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal)

                        Spacer(minLength: 24)
                    }
                    .padding(.top, 8)
                }
                .safeAreaPadding(.bottom, 96)
            }
            .navigationTitle("Athkar")
            .navigationBarTitleDisplayMode(.large)
            .foregroundColor(.adaptiveText(scheme))
        }
    }

    // MARK: - Daily Status

    private var dailyStatusSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("TODAY")
                    .font(.mono(10))
                    .tracking(0.8)
                    .foregroundColor(.ter)

                Spacer()

                Text("\(progress.dailyCoreCompletedCount())/\(AthkarProgressManager.dailyCoreCategories.count)")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.adaptiveAccent(scheme))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.brandDim)
                    .clipShape(Capsule())
            }

            VStack(spacing: 10) {
                ForEach(AthkarProgressManager.dailyCoreCategories) { category in
                    NavigationLink(destination: AthkarDetailView(
                        athkarList: category.athkar,
                        startIndex: progress.resumeIndex(for: category),
                        completedIndices: progress.binding(for: category)
                    )) {
                        AthkarDailyStatusRow(status: progress.status(for: category))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.horizontal)
    }

    // MARK: - Category Card

    private func categoryCard(_ category: AthkarCategory) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.parchment.opacity(0.14))
                    .frame(width: 56, height: 56)

                Image(systemName: category.icon)
                    .font(.system(size: 26, weight: .medium))
                    .foregroundColor(.parchment)
            }

            Text(LocalizedStringKey(category.rawValue))
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.parchment)
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text("\(category.athkar.count) athkar")
                .font(.subheadline)
                .foregroundColor(Color.parchment.opacity(0.75))
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 22)
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity)
        .frame(height: 160)
        .background(
            LinearGradient(
                colors: category.gradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 28))
    }

    // MARK: - Favorites Card

    private var favoritesCard: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.cardBackground(scheme))
                    .frame(width: 48, height: 48)
                Image(systemName: "star.fill")
                    .foregroundColor(.prayerAccent)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Favorites")
                    .font(.headline)
                    .foregroundColor(.adaptiveText(scheme))
                Text(favorites.favoriteIDs.isEmpty ? "No favorites yet" : "\(favorites.favoriteIDs.count) saved")
                    .font(.subheadline)
                    .foregroundColor(.secondaryText(scheme))
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundColor(.secondaryText(scheme))
        }
        .padding()
        .background(Color.cardBackground(scheme))
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(Color.cardBorder(scheme), lineWidth: 1)
        )
    }
}

#Preview {
    Group {
        AthkarView().preferredColorScheme(.dark)
        AthkarView().preferredColorScheme(.light)
    }
}

struct AthkarDailyStatusRow: View {
    let status: AthkarCategoryProgressSnapshot
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(status.isComplete ? Color.goldDim : Color.brandDim)
                    .frame(width: 42, height: 42)
                Image(systemName: status.isComplete ? "checkmark.circle.fill" : status.category.icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(status.isComplete ? .prayerAccent : .adaptiveAccent(scheme))
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(LocalizedStringKey(status.category.rawValue))
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.adaptiveText(scheme))

                HStack(spacing: 6) {
                    Text("\(status.completedCount)/\(status.totalCount) done")
                    if status.streak > 0 {
                        Text("·")
                        Text("\(status.streak)d streak")
                    }
                }
                .font(.caption)
                .foregroundColor(.secondaryText(scheme))
            }

            Spacer(minLength: 8)

            Text(status.isComplete ? "Review" : "Continue #\(status.resumeIndex + 1)")
                .font(.caption.weight(.semibold))
                .foregroundColor(status.isComplete ? .prayerAccent : .adaptiveAccent(scheme))

            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundColor(.ter)
        }
        .padding(14)
        .background(Color.cardBackground(scheme))
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(Color.cardBorder(scheme), lineWidth: 1)
        )
    }
}
