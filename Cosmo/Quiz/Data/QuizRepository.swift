import Foundation

enum QuizRepositoryError: Error, LocalizedError {
    case resourceMissing(String)
    case decodeFailed(String)
    case validationFailed([String])

    var errorDescription: String? {
        switch self {
        case .resourceMissing(let name):
            return "Missing bundled resource: \(name)"
        case .decodeFailed(let message):
            return "Failed to decode quiz data: \(message)"
        case .validationFailed(let issues):
            return "Quiz data validation failed:\n- " + issues.joined(separator: "\n- ")
        }
    }
}

final class QuizRepository {
    static let shared = QuizRepository()

    let categories: [QuizCategory] = [
        QuizCategory(
            id: "solarSystem",
            title: "Solar System",
            subtitle: "Planets, moons, and orbits",
            systemImage: "sun.max.fill",
            accent: .orange
        ),
        QuizCategory(
            id: "cosmicPhenomena",
            title: "Cosmic Phenomena",
            subtitle: "Black holes, stars, and beyond",
            systemImage: "sparkles",
            accent: .purple
        ),
        QuizCategory(
            id: "spaceTime",
            title: "Space-Time",
            subtitle: "Relativity and time dilation",
            systemImage: "clock.fill",
            accent: .yellow
        ),
        QuizCategory(
            id: "earthAndSpace",
            title: "Earth & Space",
            subtitle: "Gravity, tides, and eclipses",
            systemImage: "globe.americas.fill",
            accent: .cyan
        ),
        QuizCategory(
            id: "technology",
            title: "Technology",
            subtitle: "Telescopes, rockets, and innovation",
            systemImage: "telescope.fill",
            accent: .green
        ),
        QuizCategory(
            id: "theories",
            title: "Theories",
            subtitle: "Big ideas that shape the cosmos",
            systemImage: "atom",
            accent: .blue
        )
    ]

    private init() {}

    func loadQuestionBank() throws -> QuizQuestionBank {
        let resourceName = "quiz_questions"
        let bundle = Bundle.main
        let candidates: [URL?] = [
            bundle.url(forResource: resourceName, withExtension: "json"),
            bundle.url(forResource: resourceName, withExtension: "json", subdirectory: "Quiz/Data"),
            bundle.url(forResource: resourceName, withExtension: "json", subdirectory: "Quiz")
        ]
        guard let url = candidates.compactMap({ $0 }).first else {
            throw QuizRepositoryError.resourceMissing("\(resourceName).json")
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let bank = try decoder.decode(QuizQuestionBank.self, from: data)
            try validate(bank: bank)
            return bank
        } catch let error as QuizRepositoryError {
            throw error
        } catch {
            throw QuizRepositoryError.decodeFailed(error.localizedDescription)
        }
    }

    func questions(for categoryId: String, in bank: QuizQuestionBank) -> [QuizQuestion] {
        bank.questions.filter { $0.categoryId == categoryId }
    }

    private func validate(bank: QuizQuestionBank) throws {
        var issues: [String] = []

        let ids = bank.questions.map(\.id)
        let uniqueIds = Set(ids)
        if uniqueIds.count != ids.count {
            issues.append("Question IDs must be unique.")
        }

        let validCategoryIds = Set(categories.map(\.id))
        for q in bank.questions {
            if q.prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                issues.append("[\(q.id)] prompt is empty.")
            }
            if q.explanation.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                issues.append("[\(q.id)] explanation is empty.")
            }
            if q.choices.count != 4 {
                issues.append("[\(q.id)] must have exactly 4 choices (has \(q.choices.count)).")
            }
            if !(0..<q.choices.count).contains(q.correctIndex) {
                issues.append("[\(q.id)] correctIndex out of range.")
            }
            if !validCategoryIds.contains(q.categoryId) {
                issues.append("[\(q.id)] categoryId '\(q.categoryId)' is not a known category.")
            }
        }

        // Ensure each category has enough questions for a 10-question run.
        for category in categories {
            let count = bank.questions.filter { $0.categoryId == category.id }.count
            if count < 10 {
                issues.append("Category '\(category.id)' needs at least 10 questions (has \(count)).")
            }
        }

        if !issues.isEmpty {
            throw QuizRepositoryError.validationFailed(issues)
        }
    }
}

