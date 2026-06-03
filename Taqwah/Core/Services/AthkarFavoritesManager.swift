import Foundation
import Combine

struct FavoriteDhikr: Identifiable {
    let dhikr: Dhikr
    let category: AthkarCategory
    let index: Int

    var id: String { dhikr.stableID }
}

@MainActor
final class AthkarFavoritesManager: ObservableObject {

    static let shared = AthkarFavoritesManager()

    @Published private(set) var favoriteIDs: Set<String> = []

    private let storageKey = "athkarFavorites_v1"

    private init() {
        load()
    }

    func isFavorite(_ dhikr: Dhikr) -> Bool {
        favoriteIDs.contains(dhikr.stableID)
    }

    func toggle(_ dhikr: Dhikr) {
        if isFavorite(dhikr) {
            favoriteIDs.remove(dhikr.stableID)
        } else {
            favoriteIDs.insert(dhikr.stableID)
        }
        save()
    }

    func allFavorites() -> [FavoriteDhikr] {
        AthkarCategory.allCases.flatMap { category in
            category.athkar.enumerated().compactMap { index, dhikr in
                guard favoriteIDs.contains(dhikr.stableID) else { return nil }
                return FavoriteDhikr(dhikr: dhikr, category: category, index: index)
            }
        }
    }

    func reloadFromStore() {
        load()
    }

    private func load() {
        let saved = UserDefaults.standard.stringArray(forKey: storageKey) ?? []
        favoriteIDs = Set(saved)
    }

    private func save() {
        UserDefaults.standard.set(Array(favoriteIDs).sorted(), forKey: storageKey)
    }
}
