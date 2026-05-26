import SwiftUI

struct AthkarListView: View {
    let category: AthkarCategory
    @Environment(\.colorScheme) private var scheme
    @State private var completedIndices: Set<Int> = []

    private var athkarList: [Dhikr] {
        category.athkar
    }

    var body: some View {
        ZStack {
            AppBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {

                    // MARK: - Category Header
                    headerSection

                    // MARK: - Dhikr Cards
                    ForEach(Array(athkarList.enumerated()), id: \.element.id) { index, dhikr in
                        NavigationLink(destination: AthkarDetailView(
                            athkarList: athkarList,
                            startIndex: index,
                            completedIndices: $completedIndices
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
        .navigationTitle(category.rawValue)
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(.hidden, for: .navigationBar)
        .foregroundColor(.adaptiveText(scheme))
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(category.arabicTitle)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.adaptiveText(scheme))

            HStack(spacing: 16) {
                Label("\(athkarList.count) athkar", systemImage: "book.fill")
                    .font(.subheadline)
                    .foregroundColor(.secondaryText(scheme))

                if !completedIndices.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("\(completedIndices.count)/\(athkarList.count) done")
                            .foregroundColor(.green)
                    }
                    .font(.subheadline)
                }
            }

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

        return VStack(alignment: .leading, spacing: 12) {
            // Top row: title + repetition badge
            HStack {
                HStack(spacing: 8) {
                    Text("\(index + 1)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
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
                    if isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.system(size: 16))
                    }

                    Text("×\(dhikr.repetitions)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(isCompleted ? .green : .white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            Capsule().fill(
                                LinearGradient(
                                    colors: isCompleted
                                        ? [Color.green.opacity(0.2), Color.green.opacity(0.2)]
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
                .font(.system(size: 20))
                .foregroundColor(.adaptiveText(scheme))
                .multilineTextAlignment(.trailing)
                .lineSpacing(8)
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
                            ? Color.green.opacity(0.3)
                            : (scheme == .light
                                ? Color(red: 200/255, green: 230/255, blue: 201/255).opacity(0.4)
                                : Color.white.opacity(0.1)),
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
