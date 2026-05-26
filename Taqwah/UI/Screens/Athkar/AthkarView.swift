import SwiftUI

struct AthkarView: View {

    @Environment(\.colorScheme) private var scheme

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

                        // Favorites (coming soon)
                        Text("Coming Soon")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(.sectionTitle(scheme))
                            .padding(.horizontal)

                        favoritesCard
                            .padding(.horizontal)

                        Spacer(minLength: 24)
                    }
                    .padding(.top, 8)
                }
            }
            .navigationTitle("Athkar")
            .navigationBarTitleDisplayMode(.large)
            .foregroundColor(.adaptiveText(scheme))
        }
    }

    // MARK: - Category Card

    private func categoryCard(_ category: AthkarCategory) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.15))
                    .frame(width: 56, height: 56)

                Image(systemName: category.icon)
                    .font(.system(size: 26, weight: .medium))
                    .foregroundColor(.white)
            }

            Text(category.rawValue)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text("\(category.athkar.count) athkar")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.75))
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
                    .foregroundColor(.yellow)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Favorites")
                    .font(.headline)
                    .foregroundColor(.adaptiveText(scheme))
                Text("No favorites yet")
                    .font(.subheadline)
                    .foregroundColor(.secondaryText(scheme))
            }

            Spacer()
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
