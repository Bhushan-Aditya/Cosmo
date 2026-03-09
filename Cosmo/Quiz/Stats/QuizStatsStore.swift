import Foundation

struct QuizCategoryStats: Codable, Hashable {
    var bestScore: Int
    var bestAccuracy: Int
    var runsPlayed: Int
    var lastRunDate: Date?

    static let empty = QuizCategoryStats(
        bestScore: 0,
        bestAccuracy: 0,
        runsPlayed: 0,
        lastRunDate: nil
    )
}

@MainActor
final class QuizStatsStore: ObservableObject {
    @Published private(set) var statsByCategory: [String: QuizCategoryStats] = [:]

    private let defaults: UserDefaults
    private let storageKey = "cosmo.quiz.stats.v1"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        load()
    }

    func stats(for categoryId: String) -> QuizCategoryStats {
        statsByCategory[categoryId] ?? .empty
    }

    func record(result: QuizRunResult) {
        guard result.totalCount > 0 else { return }

        let accuracy = Int((Double(result.correctCount) / Double(result.totalCount) * 100).rounded())

        var current = statsByCategory[result.categoryId] ?? .empty
        current.runsPlayed += 1
        current.lastRunDate = Date()
        current.bestScore = max(current.bestScore, result.correctCount)
        current.bestAccuracy = max(current.bestAccuracy, accuracy)

        statsByCategory[result.categoryId] = current
        persist()
    }

    private func load() {
        guard let data = defaults.data(forKey: storageKey) else { return }
        do {
            let decoded = try JSONDecoder().decode([String: QuizCategoryStats].self, from: data)
            statsByCategory = decoded
        } catch {
            statsByCategory = [:]
        }
    }

    private func persist() {
        do {
            let data = try JSONEncoder().encode(statsByCategory)
            defaults.set(data, forKey: storageKey)
        } catch {
            // If encoding fails, we keep the in-memory stats.
        }
    }
}

