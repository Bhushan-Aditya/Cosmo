import Foundation

enum SupabaseRESTError: LocalizedError {
    case invalidURL
    case notAuthenticated
    case invalidResponse
    case server(status: Int, message: String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid Supabase API URL."
        case .notAuthenticated:
            return "No active session. Please sign in again."
        case .invalidResponse:
            return "Unexpected Supabase response."
        case .server(let status, let message):
            return "Supabase error (\(status)): \(message)"
        }
    }
}

struct SupabaseAPIErrorResponse: Decodable {
    let message: String?
    let error: String?
    let errorDescription: String?
    let hint: String?
    let details: String?

    enum CodingKeys: String, CodingKey {
        case message
        case error
        case errorDescription = "error_description"
        case hint
        case details
    }
}

final class SupabaseRESTClient {
    static let shared = SupabaseRESTClient()
    private let session = URLSession.shared

    private init() {}

    func get<T: Decodable>(
        _ table: String,
        queryItems: [URLQueryItem] = [],
        as type: T.Type
    ) async throws -> T {
        let data = try await request(
            table: table,
            method: "GET",
            queryItems: queryItems,
            body: nil,
            extraHeaders: [:]
        )
        return try JSONDecoder().decode(type, from: data)
    }

    func post(
        _ table: String,
        queryItems: [URLQueryItem] = [],
        jsonBody: Data,
        prefer: String? = nil
    ) async throws {
        var headers: [String: String] = [:]
        if let prefer {
            headers["Prefer"] = prefer
        }

        _ = try await request(
            table: table,
            method: "POST",
            queryItems: queryItems,
            body: jsonBody,
            extraHeaders: headers
        )
    }

    private func request(
        table: String,
        method: String,
        queryItems: [URLQueryItem],
        body: Data?,
        extraHeaders: [String: String],
        isRetry: Bool = false
    ) async throws -> Data {
        guard var components = URLComponents(
            url: SupabaseConfig.restURL.appendingPathComponent(table),
            resolvingAgainstBaseURL: false
        ) else {
            throw SupabaseRESTError.invalidURL
        }

        if !queryItems.isEmpty {
            components.queryItems = queryItems
        }

        guard let url = components.url else {
            throw SupabaseRESTError.invalidURL
        }

        let accessToken = try await validAccessToken()

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method
        urlRequest.httpBody = body

        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue(SupabaseConfig.anonKey, forHTTPHeaderField: "apikey")
        urlRequest.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        for (key, value) in extraHeaders {
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }

        let (data, response) = try await session.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw SupabaseRESTError.invalidResponse
        }

        // On 401, attempt a one-shot token refresh then retry the request.
        if httpResponse.statusCode == 401 && !isRetry {
            do {
                let refreshed = try await SupabaseAuthService.shared.refreshSession()
                AuthSessionStore.shared.updateTokens(
                    accessToken: refreshed.accessToken,
                    refreshToken: refreshed.refreshToken
                )
                return try await request(
                    table: table,
                    method: method,
                    queryItems: queryItems,
                    body: body,
                    extraHeaders: extraHeaders,
                    isRetry: true
                )
            } catch {
                // Avoid hard logout on transient auth failures; surface error to caller.
                throw SupabaseRESTError.notAuthenticated
            }
        }

        if (200..<300).contains(httpResponse.statusCode) {
            return data
        }

        if let errorResponse = try? JSONDecoder().decode(SupabaseAPIErrorResponse.self, from: data) {
            let message = errorResponse.message
                ?? errorResponse.errorDescription
                ?? errorResponse.error
                ?? errorResponse.hint
                ?? errorResponse.details
                ?? "Unknown error"
            throw SupabaseRESTError.server(status: httpResponse.statusCode, message: message)
        }

        throw SupabaseRESTError.server(
            status: httpResponse.statusCode,
            message: "Request failed."
        )
    }

    private func validAccessToken() async throws -> String {
        let hasToken = AuthSessionStore.shared.currentAccessToken != nil
        let isExpired = AuthSessionStore.shared.isAccessTokenExpired
        let hasRefresh = AuthSessionStore.shared.currentRefreshToken != nil

#if DEBUG
        print("[RESTClient.validAccessToken] hasToken=\(hasToken) isExpired=\(isExpired) hasRefresh=\(hasRefresh)")
#endif

        // If we already have a non-expired token, use it.
        if let token = AuthSessionStore.shared.currentAccessToken, !isExpired {
            return token
        }

        // If refresh token exists, try refreshing on demand.
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
                print("[RESTClient.validAccessToken] refresh failed: \(error.localizedDescription)")
#endif
                throw SupabaseRESTError.notAuthenticated
            }
        }

#if DEBUG
        print("[RESTClient.validAccessToken] no valid token — notAuthenticated")
#endif
        throw SupabaseRESTError.notAuthenticated
    }
}
