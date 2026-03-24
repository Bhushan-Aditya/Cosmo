import Foundation

struct GameSessionSnapshot: Codable {
    let score: Int
    let waveReached: Int
    let livesLeft: Int
    let durationSeconds: Int
}

struct RemoteGameStreakInfo: Decodable {
    let currentStreak: Int
    let bestStreak: Int
    let lastGameDate: String?

    enum CodingKeys: String, CodingKey {
        case currentStreak = "current_streak"
        case bestStreak = "best_streak"
        case lastGameDate = "last_game_date"
    }
}

struct RemoteGameSessionHistoryRow: Decodable, Identifiable {
    var id: String { playedAt }
    let score: Int
    let waveReached: Int
    let livesLeft: Int
    let durationSeconds: Int
    let playedAt: String

    enum CodingKeys: String, CodingKey {
        case score
        case waveReached = "wave_reached"
        case livesLeft = "lives_left"
        case durationSeconds = "duration_seconds"
        case playedAt = "played_at"
    }
}

struct RemoteGameLeaderboardEntry: Decodable, Identifiable {
    var id: String { userId }
    let rank: Int
    let sessionDate: String?
    let userId: String
    let displayName: String
    let totalScore: Int
    let totalSessions: Int
    let bestScore: Int
    let totalDurationSeconds: Int

    enum CodingKeys: String, CodingKey {
        case rank
        case sessionDate = "session_date"
        case userId = "user_id"
        case displayName = "display_name"
        case totalScore = "total_score"
        case totalSessions = "total_sessions"
        case bestScore = "best_score"
        case totalDurationSeconds = "total_duration_seconds"
    }
}

private struct RemoteGameSessionPayload: Encodable {
    let userId: String
    let score: Int
    let waveReached: Int
    let livesLeft: Int
    let durationSeconds: Int

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case score
        case waveReached = "wave_reached"
        case livesLeft = "lives_left"
        case durationSeconds = "duration_seconds"
    }
}

final class SupabaseGameSyncService {
    static let shared = SupabaseGameSyncService()

    private let client = SupabaseRESTClient.shared
    private let encoder = JSONEncoder()

    private init() {}

    func uploadGameSession(_ snapshot: GameSessionSnapshot, enqueueOnFailure: Bool = true) async throws {
        guard let userId = AuthSessionStore.shared.currentUserId else {
            if enqueueOnFailure {
                await SupabaseUploadQueue.shared.enqueue(.gameSession(snapshot))
            }
            throw SupabaseRESTError.notAuthenticated
        }

        do {
            let payload = RemoteGameSessionPayload(
                userId: userId,
                score: snapshot.score,
                waveReached: snapshot.waveReached,
                livesLeft: snapshot.livesLeft,
                durationSeconds: snapshot.durationSeconds
            )

            try await client.post(
                "game_sessions",
                jsonBody: try encoder.encode(payload)
            )

            try await upsertGameStreak(userId: userId)
            await MainActor.run {
                NotificationCenter.default.post(name: .gameDataDidSync, object: nil)
            }
        } catch {
            if enqueueOnFailure {
                await SupabaseUploadQueue.shared.enqueue(.gameSession(snapshot))
            }
            throw error
        }
    }

    func fetchGameStreak() async throws -> RemoteGameStreakInfo? {
        guard let userId = AuthSessionStore.shared.currentUserId else {
            throw SupabaseRESTError.notAuthenticated
        }

        let rows: [RemoteGameStreakInfo] = try await client.get(
            "game_streaks",
            queryItems: [
                URLQueryItem(name: "select", value: "current_streak,best_streak,last_game_date"),
                URLQueryItem(name: "user_id", value: "eq.\(userId)"),
                URLQueryItem(name: "limit", value: "1")
            ],
            as: [RemoteGameStreakInfo].self
        )

        return rows.first
    }

    func fetchGameHistory(limit: Int = 30) async throws -> [RemoteGameSessionHistoryRow] {
        guard let userId = AuthSessionStore.shared.currentUserId else {
            throw SupabaseRESTError.notAuthenticated
        }

        return try await client.get(
            "game_sessions",
            queryItems: [
                URLQueryItem(name: "select", value: "score,wave_reached,lives_left,duration_seconds,played_at"),
                URLQueryItem(name: "user_id", value: "eq.\(userId)"),
                URLQueryItem(name: "order", value: "played_at.desc"),
                URLQueryItem(name: "limit", value: "\(limit)")
            ],
            as: [RemoteGameSessionHistoryRow].self
        )
    }

    func fetchGameDailyLeaderboard(date: String, limit: Int = 100) async throws -> [RemoteGameLeaderboardEntry] {
        try await client.get(
            "v_game_leaderboard_daily",
            queryItems: [
                URLQueryItem(name: "session_date", value: "eq.\(date)"),
                URLQueryItem(name: "order", value: "rank.asc"),
                URLQueryItem(name: "limit", value: "\(limit)")
            ],
            as: [RemoteGameLeaderboardEntry].self
        )
    }

    func fetchGameAllTimeLeaderboard(limit: Int = 100) async throws -> [RemoteGameLeaderboardEntry] {
        try await client.get(
            "v_game_leaderboard_all_time",
            queryItems: [
                URLQueryItem(name: "order", value: "rank.asc"),
                URLQueryItem(name: "limit", value: "\(limit)")
            ],
            as: [RemoteGameLeaderboardEntry].self
        )
    }

    private func upsertGameStreak(userId: String) async throws {
        let today = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)

        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        struct RemoteGameStreakRow: Decodable {
            let currentStreak: Int
            let bestStreak: Int
            let lastGameDate: String?

            enum CodingKeys: String, CodingKey {
                case currentStreak = "current_streak"
                case bestStreak = "best_streak"
                case lastGameDate = "last_game_date"
            }
        }

        struct RemoteGameStreakUpsertPayload: Encodable {
            let userId: String
            let currentStreak: Int
            let bestStreak: Int
            let lastGameDate: String
            let updatedAt: String

            enum CodingKeys: String, CodingKey {
                case userId = "user_id"
                case currentStreak = "current_streak"
                case bestStreak = "best_streak"
                case lastGameDate = "last_game_date"
                case updatedAt = "updated_at"
            }
        }

        let rows: [RemoteGameStreakRow] = try await client.get(
            "game_streaks",
            queryItems: [
                URLQueryItem(name: "select", value: "current_streak,best_streak,last_game_date"),
                URLQueryItem(name: "user_id", value: "eq.\(userId)"),
                URLQueryItem(name: "limit", value: "1")
            ],
            as: [RemoteGameStreakRow].self
        )

        let calendar = Calendar.current
        let todayStart = calendar.startOfDay(for: today)
        let yesterdayStart = calendar.date(byAdding: .day, value: -1, to: todayStart)

        let existing = rows.first
        let existingLastDate = existing?.lastGameDate.flatMap { dateFormatter.date(from: $0) }

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

        let payload = RemoteGameStreakUpsertPayload(
            userId: userId,
            currentStreak: nextCurrentStreak,
            bestStreak: nextBestStreak,
            lastGameDate: dateFormatter.string(from: today),
            updatedAt: isoFormatter.string(from: today)
        )

        try await client.post(
            "game_streaks",
            queryItems: [URLQueryItem(name: "on_conflict", value: "user_id")],
            jsonBody: try encoder.encode(payload),
            prefer: "resolution=merge-duplicates"
        )
    }
}
