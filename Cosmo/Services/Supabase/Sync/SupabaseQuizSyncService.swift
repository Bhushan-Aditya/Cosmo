import Foundation

private struct RemoteQuizRunPayload: Encodable {
    let userId: String
    let categoryId: String
    let questionIds: [String]
    let answersById: [String: Int]
    let correctCount: Int
    let totalCount: Int
    let accuracy: Int

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case categoryId = "category_id"
        case questionIds = "question_ids"
        case answersById = "answers_by_id"
        case correctCount = "correct_count"
        case totalCount = "total_count"
        case accuracy
    }
}

private struct RemoteQuizRunRow: Decodable {
    let categoryId: String
    let correctCount: Int
    let accuracy: Int

    enum CodingKeys: String, CodingKey {
        case categoryId = "category_id"
        case correctCount = "correct_count"
        case accuracy
    }
}

struct RemoteQuizRunHistoryRow: Decodable, Identifiable {
    var id: String { playedAt }
    let categoryId: String
    let correctCount: Int
    let totalCount: Int
    let accuracy: Int
    let playedAt: String

    enum CodingKeys: String, CodingKey {
        case categoryId = "category_id"
        case correctCount = "correct_count"
        case totalCount = "total_count"
        case accuracy
        case playedAt = "played_at"
    }
}

struct RemoteQuizStreakInfo: Decodable {
    let currentStreak: Int
    let bestStreak: Int
    let lastQuizDate: String?

    enum CodingKeys: String, CodingKey {
        case currentStreak = "current_streak"
        case bestStreak = "best_streak"
        case lastQuizDate = "last_quiz_date"
    }
}

private struct RemoteQuizStreakRow: Decodable {
    let currentStreak: Int
    let bestStreak: Int
    let lastQuizDate: String?

    enum CodingKeys: String, CodingKey {
        case currentStreak = "current_streak"
        case bestStreak = "best_streak"
        case lastQuizDate = "last_quiz_date"
    }
}

private struct RemoteQuizStreakUpsertPayload: Encodable {
    let userId: String
    let currentStreak: Int
    let bestStreak: Int
    let lastQuizDate: String
    let updatedAt: String

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case currentStreak = "current_streak"
        case bestStreak = "best_streak"
        case lastQuizDate = "last_quiz_date"
        case updatedAt = "updated_at"
    }
}

final class SupabaseQuizSyncService {
    static let shared = SupabaseQuizSyncService()

    private let client = SupabaseRESTClient.shared
    private let encoder = JSONEncoder()

    private init() {}

    func uploadQuizRun(_ result: QuizRunResult, enqueueOnFailure: Bool = true) async throws {
        guard let userId = AuthSessionStore.shared.currentUserId else {
            if enqueueOnFailure {
                await SupabaseUploadQueue.shared.enqueue(.quizRun(result))
            }
            throw SupabaseRESTError.notAuthenticated
        }

        do {
            let total = max(result.totalCount, 1)
            let accuracy = Int((Double(result.correctCount) / Double(total) * 100).rounded())

            let payload = RemoteQuizRunPayload(
                userId: userId,
                categoryId: result.categoryId,
                questionIds: result.questionIds,
                answersById: result.answersById,
                correctCount: result.correctCount,
                totalCount: result.totalCount,
                accuracy: accuracy
            )

            let body = try encoder.encode(payload)
            try await client.post("quiz_runs", jsonBody: body)
            try await upsertQuizStreak(userId: userId)
            await MainActor.run {
                NotificationCenter.default.post(name: .quizDataDidSync, object: nil)
            }
        } catch {
            if enqueueOnFailure {
                await SupabaseUploadQueue.shared.enqueue(.quizRun(result))
            }
            throw error
        }
    }

    func fetchCategoryStats() async throws -> [String: QuizCategoryStats] {
        guard let userId = AuthSessionStore.shared.currentUserId else {
            throw SupabaseRESTError.notAuthenticated
        }

        let rows: [RemoteQuizRunRow] = try await client.get(
            "quiz_runs",
            queryItems: [
                URLQueryItem(name: "select", value: "category_id,correct_count,accuracy"),
                URLQueryItem(name: "user_id", value: "eq.\(userId)"),
                URLQueryItem(name: "order", value: "played_at.desc"),
                URLQueryItem(name: "limit", value: "500")
            ],
            as: [RemoteQuizRunRow].self
        )

        var grouped: [String: QuizCategoryStats] = [:]
        for row in rows {
            var current = grouped[row.categoryId] ?? .empty
            current.runsPlayed += 1
            current.bestScore = max(current.bestScore, row.correctCount)
            current.bestAccuracy = max(current.bestAccuracy, row.accuracy)
            grouped[row.categoryId] = current
        }

        return grouped
    }

    func fetchQuizStreak() async throws -> RemoteQuizStreakInfo? {
        guard let userId = AuthSessionStore.shared.currentUserId else {
            throw SupabaseRESTError.notAuthenticated
        }

        let rows: [RemoteQuizStreakInfo] = try await client.get(
            "quiz_streaks",
            queryItems: [
                URLQueryItem(name: "select", value: "current_streak,best_streak,last_quiz_date"),
                URLQueryItem(name: "user_id", value: "eq.\(userId)"),
                URLQueryItem(name: "limit", value: "1")
            ],
            as: [RemoteQuizStreakInfo].self
        )

        return rows.first
    }

    func fetchQuizHistory(limit: Int = 30) async throws -> [RemoteQuizRunHistoryRow] {
        guard let userId = AuthSessionStore.shared.currentUserId else {
            throw SupabaseRESTError.notAuthenticated
        }

        return try await client.get(
            "quiz_runs",
            queryItems: [
                URLQueryItem(name: "select", value: "category_id,correct_count,total_count,accuracy,played_at"),
                URLQueryItem(name: "user_id", value: "eq.\(userId)"),
                URLQueryItem(name: "order", value: "played_at.desc"),
                URLQueryItem(name: "limit", value: "\(limit)")
            ],
            as: [RemoteQuizRunHistoryRow].self
        )
    }

    private func upsertQuizStreak(userId: String) async throws {
        let today = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)

        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        let rows: [RemoteQuizStreakRow] = try await client.get(
            "quiz_streaks",
            queryItems: [
                URLQueryItem(name: "select", value: "current_streak,best_streak,last_quiz_date"),
                URLQueryItem(name: "user_id", value: "eq.\(userId)"),
                URLQueryItem(name: "limit", value: "1")
            ],
            as: [RemoteQuizStreakRow].self
        )

        let calendar = Calendar.current
        let todayStart = calendar.startOfDay(for: today)
        let yesterdayStart = calendar.date(byAdding: .day, value: -1, to: todayStart)

        let existing = rows.first
        let existingLastDate = existing?.lastQuizDate.flatMap { dateFormatter.date(from: $0) }

        let nextCurrentStreak: Int
        if let existingLastDate {
            let existingDay = calendar.startOfDay(for: existingLastDate)
            if existingDay == todayStart {
                nextCurrentStreak = existing?.currentStreak ?? 1
            } else if existingDay == yesterdayStart {
                nextCurrentStreak = (existing?.currentStreak ?? 0) + 1
            } else {
                nextCurrentStreak = 1
            }
        } else {
            nextCurrentStreak = 1
        }

        let nextBestStreak = max(existing?.bestStreak ?? 0, nextCurrentStreak)

        let payload = RemoteQuizStreakUpsertPayload(
            userId: userId,
            currentStreak: nextCurrentStreak,
            bestStreak: nextBestStreak,
            lastQuizDate: dateFormatter.string(from: today),
            updatedAt: isoFormatter.string(from: today)
        )

        try await client.post(
            "quiz_streaks",
            queryItems: [URLQueryItem(name: "on_conflict", value: "user_id")],
            jsonBody: try encoder.encode(payload),
            prefer: "resolution=merge-duplicates"
        )
    }
}
