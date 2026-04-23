import Foundation

// MARK: - Question (delivered without correct_index)

struct DailyQuizQuestion: Codable, Identifiable {
    let id: String
    let position: Int
    let prompt: String
    let options: [String]
    let difficulty: String
}

// MARK: - Start attempt

struct DailyAttemptStartRequest: Encodable {
    let quizDate: String?

    enum CodingKeys: String, CodingKey {
        case quizDate = "quiz_date"
    }
}

struct DailyAttemptStartResponse: Decodable {
    let attemptId: String
    let attemptNo: Int
    let remainingAttempts: Int
    let quizDate: String
    let questions: [DailyQuizQuestion]

    enum CodingKeys: String, CodingKey {
        case attemptId        = "attempt_id"
        case attemptNo        = "attempt_no"
        case remainingAttempts = "remaining_attempts"
        case quizDate         = "quiz_date"
        case questions
    }
}

// MARK: - Submit attempt

struct DailyAnswerPayload: Encodable {
    let questionId: String
    let selectedIndex: Int?
    let responseSeconds: Double

    enum CodingKeys: String, CodingKey {
        case questionId      = "question_id"
        case selectedIndex   = "selected_index"
        case responseSeconds = "response_seconds"
    }
}

struct DailySubmitRequest: Encodable {
    let attemptId: String
    let answers: [DailyAnswerPayload]

    enum CodingKeys: String, CodingKey {
        case attemptId = "attempt_id"
        case answers
    }
}

struct DailyAttemptResult: Decodable {
    let totalPoints: Int
    let correctCount: Int
    let totalTimeSeconds: Double
    let dailyRank: Int?
    let quizDate: String

    enum CodingKeys: String, CodingKey {
        case totalPoints      = "total_points"
        case correctCount     = "correct_count"
        case totalTimeSeconds = "total_time_seconds"
        case dailyRank        = "daily_rank"
        case quizDate         = "quiz_date"
    }
}

// MARK: - Leaderboard

struct DailyLeaderboardEntry: Decodable, Identifiable {
    var id: String { userId }
    let rank: Int
    let quizDate: String?
    let userId: String
    let displayName: String
    let totalPoints: Int
    let totalTimeSeconds: Double?
    let correctCount: Int?
    let totalAttempts: Int?

    enum CodingKeys: String, CodingKey {
        case rank
        case quizDate         = "quiz_date"
        case userId           = "user_id"
        case displayName      = "display_name"
        case totalPoints      = "total_points"
        case totalTimeSeconds = "total_time_seconds"
        case correctCount     = "correct_count"
        case totalAttempts    = "total_attempts"
    }
}

// MARK: - Attempt status summary (fetched on QuizHomeView appear)

struct DailyAttemptStatus {
    let quizDate: String
    let attemptsUsed: Int
    /// Matches StoreKit / profile “Premium”; stored in Supabase as `is_pro`.
    let hasPremium: Bool

    var cap: Int { hasPremium ? 3 : 1 }
    var attemptsRemaining: Int { max(0, cap - attemptsUsed) }
    var hasAttemptsLeft: Bool { attemptsRemaining > 0 }

    static let unavailable = DailyAttemptStatus(quizDate: "", attemptsUsed: 0, hasPremium: false)
}

// MARK: - Edge function error

struct EdgeFunctionError: Decodable {
    let error: String
}
