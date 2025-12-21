import SwiftUI

struct AthkarView: View {

    // MARK: - Category Model
    struct Category: Identifiable {
        let id = UUID()
        let title: String
        let subtitle: String
        let icon: String
        let colors: [Color]
    }

    // MARK: - Category List
    private let categories: [Category] = [
        Category(
            title: "All Athkar",
            subtitle: "41 athkar",
            icon: "clock.fill",
            colors: [
                Color(red: 0.11, green: 0.23, blue: 0.22),
                Color(red: 0.09, green: 0.25, blue: 0.31)
            ]
        ),
        Category(
            title: "Morning",
            subtitle: "14 athkar",
            icon: "sun.max.fill",
            colors: [
                Color(red: 0.40, green: 0.20, blue: 0.70),
                Color(red: 0.75, green: 0.30, blue: 0.55)
            ]
        ),
        Category(
            title: "Evening",
            subtitle: "14 athkar",
            icon: "moon.fill",
            colors: [
                Color(red: 0.95, green: 0.60, blue: 0.15),
                Color(red: 0.95, green: 0.45, blue: 0.20)
            ]
        ),
        Category(
            title: "Favorites",
            subtitle: "No favorites yet",
            icon: "star.fill",
            colors: [
                Color(red: 0.25, green: 0.28, blue: 0.33),
                Color(red: 0.20, green: 0.22, blue: 0.26)
            ]
        ),
        Category(
            title: "My Athkar",
            subtitle: "Add your own dhikr",
            icon: "plus.circle.fill",
            colors: [
                Color(red: 0.18, green: 0.55, blue: 0.45),
                Color(red: 0.22, green: 0.65, blue: 0.52)
            ]
        )
    ]

    private let columns = [
        GridItem(.flexible(), spacing: 16, alignment: .top),
        GridItem(.flexible(), spacing: 16, alignment: .top)
    ]

    // MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()
                    .foregroundColor(.primary)
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {

                        // подзаголовок
                        Text("Choose a category")
                            .foregroundColor(.white.opacity(0.6))
                            .padding(.horizontal)

                        // сетка
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(categories) { category in
                                categoryCard(category)
                            }
                        }
                        .padding(.horizontal)

                        Spacer(minLength: 24)
                    }
                    .padding(.top, 8)
                }
            }
            .navigationTitle("Athkar")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    // MARK: - Category Card View
    private func categoryCard(_ category: Category) -> some View {
        VStack(alignment: .leading, spacing: 14) {   // ← ВЫРАВНИВАЕМ ВЛЕВО
            
            // Иконка
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.15))
                    .frame(width: 56, height: 56)

                Image(systemName: category.icon)
                    .font(.system(size: 26, weight: .medium))
                    .foregroundColor(.white)
            }

            // Название
            Text(category.title)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)  // ← текст влево

            // Подзаголовок
            Text(category.subtitle)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.75))
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)  // ← текст влево
        }
        .padding(.vertical, 22)
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity)
        .frame(height: 160)
        .background(
            LinearGradient(
                colors: category.colors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 28))
    }
}

#Preview {
    AthkarView()
        .preferredColorScheme(.dark)
}
