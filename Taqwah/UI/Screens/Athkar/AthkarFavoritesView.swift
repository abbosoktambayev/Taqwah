import SwiftUI

struct AthkarFavoritesView: View {
    @Environment(\.colorScheme) private var scheme
    @StateObject private var favorites = AthkarFavoritesManager.shared
    @StateObject private var progress = AthkarProgressManager.shared

    private var favoriteItems: [FavoriteDhikr] {
        favorites.allFavorites()
    }

    var body: some View {
        ZStack {
            AppBackground()

            ScrollView(showsIndicators: false) {
                if favoriteItems.isEmpty {
                    emptyState
                        .padding(.top, 48)
                } else {
                    LazyVStack(alignment: .leading, spacing: 16) {
                        header

                        ForEach(favoriteItems) { item in
                            NavigationLink(destination: AthkarDetailView(
                                athkarList: item.category.athkar,
                                startIndex: item.index,
                                completedIndices: progress.binding(for: item.category)
                            )) {
                                favoriteCard(item)
                            }
                            .buttonStyle(.plain)
                        }

                        Spacer(minLength: 40)
                    }
                    .padding(.top, 8)
                }
            }
        }
        .navigationTitle("Favorites")
        .navigationBarTitleDisplayMode(.large)
        .foregroundColor(.adaptiveText(scheme))
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("FAVORITES")
                .font(.mono(11)).tracking(0.6)
                .foregroundColor(.sectionTitle(scheme))

            Text("\(favoriteItems.count) saved")
                .font(.subheadline)
                .foregroundColor(.secondaryText(scheme))
        }
        .padding(.horizontal)
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.adaptiveAccent(scheme).opacity(0.12))
                    .frame(width: 76, height: 76)

                Image(systemName: "star")
                    .font(.system(size: 30, weight: .medium))
                    .foregroundColor(.adaptiveAccent(scheme))
            }

            VStack(spacing: 6) {
                Text("No favorites yet")
                    .font(.headline)
                    .foregroundColor(.adaptiveText(scheme))

                Text("Open any dhikr and tap the star to keep it here.")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondaryText(scheme))
            }
            .padding(.horizontal, 28)
        }
        .frame(maxWidth: .infinity)
    }

    private func favoriteCard(_ item: FavoriteDhikr) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: item.category.icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.adaptiveAccent(scheme))
                    .frame(width: 24)

                Text(LocalizedStringKey(item.category.rawValue))
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.secondaryText(scheme))

                Spacer()

                Image(systemName: "star.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.prayerAccent)
            }

            Text(item.dhikr.title)
                .font(.headline)
                .foregroundColor(.adaptiveText(scheme))
                .lineLimit(1)

            Text(item.dhikr.arabic)
                .font(.quran(size: 22))
                .foregroundColor(.adaptiveText(scheme))
                .multilineTextAlignment(.trailing)
                .lineSpacing(8)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .lineLimit(2)

            Text(item.dhikr.source)
                .font(.caption2)
                .foregroundColor(.secondaryText(scheme))
        }
        .padding(18)
        .background(Color.cardBackground(scheme))
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.cardBorder(scheme), lineWidth: 1)
        )
        .padding(.horizontal)
    }
}

#Preview {
    NavigationStack {
        AthkarFavoritesView()
    }
    .preferredColorScheme(.dark)
}
