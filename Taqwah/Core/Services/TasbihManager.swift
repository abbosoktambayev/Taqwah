import Foundation
import SwiftUI
import Combine

/// A preset dhikr phrase for the tasbih counter.
struct TasbihPhrase: Identifiable, Equatable {
    let id = UUID()
    let arabic: String
    let transliteration: String
    let translation: String

    static let presets: [TasbihPhrase] = [
        TasbihPhrase(arabic: "سُبْحَانَ اللَّهِ", transliteration: "SubhanAllah", translation: "Glory be to Allah"),
        TasbihPhrase(arabic: "الْحَمْدُ لِلَّهِ", transliteration: "Alhamdulillah", translation: "All praise is to Allah"),
        TasbihPhrase(arabic: "اللَّهُ أَكْبَرُ", transliteration: "Allahu Akbar", translation: "Allah is the Greatest"),
        TasbihPhrase(arabic: "لَا إِلَهَ إِلَّا اللَّهُ", transliteration: "La ilaha illallah", translation: "There is no god but Allah"),
        TasbihPhrase(arabic: "أَسْتَغْفِرُ اللَّهَ", transliteration: "Astaghfirullah", translation: "I seek Allah's forgiveness")
    ]
}

@MainActor
final class TasbihManager: ObservableObject {

    static let shared = TasbihManager()

    @Published var count: Int { didSet { defaults.set(count, forKey: "tasbih_count") } }
    @Published var rounds: Int { didSet { defaults.set(rounds, forKey: "tasbih_rounds") } }
    @Published var target: Int { didSet { defaults.set(target, forKey: "tasbih_target") } }
    /// Lifetime total across all sessions.
    @Published var total: Int { didSet { defaults.set(total, forKey: "tasbih_total") } }
    @Published var phraseIndex: Int { didSet { defaults.set(phraseIndex, forKey: "tasbih_phrase") } }

    /// Available targets; 0 means unlimited.
    static let targets = [33, 99, 100, 0]

    private let defaults = UserDefaults.standard

    private init() {
        count = defaults.integer(forKey: "tasbih_count")
        rounds = defaults.integer(forKey: "tasbih_rounds")
        total = defaults.integer(forKey: "tasbih_total")
        phraseIndex = defaults.integer(forKey: "tasbih_phrase")
        let savedTarget = defaults.object(forKey: "tasbih_target") as? Int
        target = savedTarget ?? 33
    }

    var phrase: TasbihPhrase {
        TasbihPhrase.presets[min(phraseIndex, TasbihPhrase.presets.count - 1)]
    }

    var progress: CGFloat {
        guard target > 0 else { return 0 }
        return min(CGFloat(count) / CGFloat(target), 1.0)
    }

    /// Increment the counter. Returns true if a full round just completed.
    @discardableResult
    func increment() -> Bool {
        count += 1
        total += 1
        if target > 0 && count >= target {
            rounds += 1
            count = 0
            return true
        }
        return false
    }

    func resetCount() {
        count = 0
    }

    func resetAll() {
        count = 0
        rounds = 0
    }

    func selectTarget(_ value: Int) {
        target = value
        count = 0
    }

    func selectPhrase(_ index: Int) {
        phraseIndex = index
    }
}
