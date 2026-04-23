import Foundation

// MARK: - Service

final class SupabaseDailyQuizService {
    static let shared = SupabaseDailyQuizService()
    private let urlSession = URLSession.shared

    private init() {}

    // ── Start a daily attempt ────────────────────────────────────────────────

    func startAttempt(quizDate: String? = nil) async throws -> DailyAttemptStartResponse {
        let body = DailyAttemptStartRequest(quizDate: quizDate)
        return try await callFunction("start_daily_attempt", body: body)
    }

    // ── Submit answers and receive score ─────────────────────────────────────

    func submitAttempt(
        attemptId: String,
        answers: [DailyAnswerPayload]
    ) async throws -> DailyAttemptResult {
        let body = DailySubmitRequest(attemptId: attemptId, answers: answers)
        return try await callFunction("submit_daily_attempt", body: body)
    }

    // ── Leaderboard reads (PostgREST views) ───────────────────────────────────

    func fetchDailyLeaderboard(date: String, limit: Int = 100) async throws -> [DailyLeaderboardEntry] {
        try await SupabaseRESTClient.shared.get(
            "v_daily_leaderboard",
            queryItems: [
                URLQueryItem(name: "quiz_date", value: "eq.\(date)"),
                URLQueryItem(name: "order", value: "rank.asc"),
                URLQueryItem(name: "limit", value: "\(limit)"),
            ],
            as: [DailyLeaderboardEntry].self
        )
    }

    func fetchAllTimeLeaderboard(limit: Int = 100) async throws -> [DailyLeaderboardEntry] {
        try await SupabaseRESTClient.shared.get(
            "v_alltime_quiz_leaderboard",
            queryItems: [
                URLQueryItem(name: "order", value: "rank.asc"),
                URLQueryItem(name: "limit", value: "\(limit)"),
            ],
            as: [DailyLeaderboardEntry].self
        )
    }

    // ── Attempt status for QuizHomeView badge ─────────────────────────────────

    /// Returns how many attempts the user has already used today and their entitlement.
    func fetchAttemptStatus() async throws -> DailyAttemptStatus {
        guard let userId = AuthSessionStore.shared.currentUserId else {
            throw SupabaseRESTError.notAuthenticated
        }

        let today = todayIST()

        async let attemptsResult = SupabaseRESTClient.shared.get(
            "daily_attempts",
            queryItems: [
                URLQueryItem(name: "user_id", value: "eq.\(userId)"),
                URLQueryItem(name: "quiz_date", value: "eq.\(today)"),
                URLQueryItem(name: "select", value: "id"),
            ],
            as: [EmptyRow].self
        )

        async let entitlementResult = SupabaseRESTClient.shared.get(
            "user_entitlements",
            queryItems: [
                URLQueryItem(name: "user_id", value: "eq.\(userId)"),
                URLQueryItem(name: "select", value: "is_pro"),
            ],
            as: [EntitlementRow].self
        )

        let attempts = try await attemptsResult
        let entitlements = try await entitlementResult

        let hasPremium = entitlements.first?.hasPremium ?? false
        return DailyAttemptStatus(
            quizDate: today,
            attemptsUsed: attempts.count,
            hasPremium: hasPremium
        )
    }

    // ── Private helpers ───────────────────────────────────────────────────────

    private func callFunction<Request: Encodable, Response: Decodable>(
        _ name: String,
        body: Request
    ) async throws -> Response {
        let url = SupabaseConfig.functionsURL.appendingPathComponent(name)
        return try await performFunctionRequest(url: url, body: body, isRetry: false)
    }

    private func performFunctionRequest<Request: Encodable, Response: Decodable>(
        url: URL,
        body: Request,
        isRetry: Bool
    ) async throws -> Response {
        let accessToken = try await validAccessToken()

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(SupabaseConfig.anonKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONEncoder().encode(body)

#if DEBUG
        print("[DailyQuizService] → \(url.lastPathComponent) isRetry=\(isRetry)")
#endif

        let (data, response) = try await urlSession.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw SupabaseRESTError.invalidResponse
        }

#if DEBUG
        print("[DailyQuizService] ← HTTP \(http.statusCode) body=\(String(data: data, encoding: .utf8) ?? "<binary>")")
#endif

        // Token refresh + retry on 401
        if http.statusCode == 401 && !isRetry {
#if DEBUG
            print("[DailyQuizService] 401 received — attempting token refresh")
#endif
            do {
                let refreshed = try await SupabaseAuthService.shared.refreshSession()
                AuthSessionStore.shared.updateTokens(
                    accessToken: refreshed.accessToken,
                    refreshToken: refreshed.refreshToken
                )
                return try await performFunctionRequest(url: url, body: body, isRetry: true)
            } catch {
#if DEBUG
                print("[DailyQuizService] Token refresh failed: \(error.localizedDescription)")
#endif
                throw SupabaseRESTError.notAuthenticated
            }
        }

        if (200..<300).contains(http.statusCode) {
            return try JSONDecoder().decode(Response.self, from: data)
        }

        // Decode edge function error envelope
        if let errBody = try? JSONDecoder().decode(EdgeFunctionError.self, from: data) {
            throw SupabaseRESTError.server(status: http.statusCode, message: errBody.error)
        }
        throw SupabaseRESTError.server(status: http.statusCode, message: "Request failed (\(http.statusCode))")
    }

    private func validAccessToken() async throws -> String {
        let hasToken = AuthSessionStore.shared.currentAccessToken != nil
        let isExpired = AuthSessionStore.shared.isAccessTokenExpired
        let hasRefresh = AuthSessionStore.shared.currentRefreshToken != nil

#if DEBUG
        print("[DailyQuizService.validAccessToken] hasToken=\(hasToken) isExpired=\(isExpired) hasRefresh=\(hasRefresh)")
#endif

        // Use current token if still valid.
        if let token = AuthSessionStore.shared.currentAccessToken, !isExpired {
            return token
        }

        // Try refresh flow if possible.
        if hasRefresh {
            do {
                let refreshed = try await SupabaseAuthService.shared.refreshSession()
                AuthSessionStore.shared.updateTokens(
                    accessToken: refreshed.accessToken,
                    refreshToken: refreshed.refreshToken
                )
                if let token = AuthSessionStore.shared.currentAccessToken {
                    return token
                }
            } catch {
#if DEBUG
                print("[DailyQuizService.validAccessToken] proactive refresh failed: \(error.localizedDescription)")
#endif
                throw SupabaseRESTError.notAuthenticated
            }
        }

#if DEBUG
        print("[DailyQuizService.validAccessToken] no valid token available — notAuthenticated")
#endif
        throw SupabaseRESTError.notAuthenticated
    }

    private func todayIST() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(identifier: "Asia/Kolkata")
        return formatter.string(from: Date())
    }
}

// MARK: - Private row helpers

private struct EmptyRow: Decodable {
    let id: String
}

private struct EntitlementRow: Decodable {
    let hasPremium: Bool

    enum CodingKeys: String, CodingKey {
        case hasPremium = "is_pro"
    }
}
