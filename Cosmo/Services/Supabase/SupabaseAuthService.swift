import Foundation

struct SupabaseSession: Decodable {
    let accessToken: String
    let refreshToken: String
    let tokenType: String?
    let user: SupabaseUser

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case tokenType = "token_type"
        case user
    }
}

struct SupabaseUser: Decodable {
    let id: String
    let email: String?
}

struct SupabaseAuthErrorResponse: Decodable {
    let error: String?
    let errorDescription: String?
    let message: String?

    enum CodingKeys: String, CodingKey {
        case error
        case errorDescription = "error_description"
        case message
    }
}

enum SupabaseAuthError: LocalizedError {
    case invalidURL
    case invalidResponse
    case server(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid authentication URL."
        case .invalidResponse:
            return "Unexpected authentication response."
        case .server(let message):
            return message
        }
    }
}

final class SupabaseAuthService {
    static let shared = SupabaseAuthService()
    private let session = URLSession.shared

    private init() {}

    func refreshSession() async throws -> SupabaseSession {
        guard let refreshToken = AuthSessionStore.shared.currentRefreshToken else {
            throw SupabaseAuthError.invalidResponse
        }

        guard var components = URLComponents(
            url: SupabaseConfig.authURL.appendingPathComponent("token"),
            resolvingAgainstBaseURL: false
        ) else {
            throw SupabaseAuthError.invalidURL
        }

        components.queryItems = [URLQueryItem(name: "grant_type", value: "refresh_token")]
        guard let url = components.url else { throw SupabaseAuthError.invalidURL }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        SupabaseConfig.defaultHeaders.forEach { request.setValue($1, forHTTPHeaderField: $0) }
        request.httpBody = try JSONSerialization.data(withJSONObject: ["refresh_token": refreshToken])

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw SupabaseAuthError.invalidResponse
        }

        if (200..<300).contains(httpResponse.statusCode) {
            let refreshed = try JSONDecoder().decode(SupabaseSession.self, from: data)
            logAuth("Token refresh success. New expiry decoded from access token.")
            return refreshed
        }

        if let errorResponse = try? JSONDecoder().decode(SupabaseAuthErrorResponse.self, from: data) {
            let message = errorResponse.errorDescription ?? errorResponse.message ?? errorResponse.error ?? "Token refresh failed."
            logAuth("Token refresh failed: \(message)")
            throw SupabaseAuthError.server(message)
        }

        throw SupabaseAuthError.server("Token refresh failed with status \(httpResponse.statusCode).")
    }

    func signInWithApple(idToken: String, rawNonce: String?) async throws -> SupabaseSession {
        logAuth("Starting Supabase token exchange for Apple sign-in")
        logAuth("Incoming Apple id_token: \(idToken)")
        if let claims = decodeJWTPayload(idToken) {
            logAuth("Apple id_token claims: \(claims)")
        }

        guard var components = URLComponents(url: SupabaseConfig.authURL.appendingPathComponent("token"), resolvingAgainstBaseURL: false) else {
            throw SupabaseAuthError.invalidURL
        }

        components.queryItems = [URLQueryItem(name: "grant_type", value: "id_token")]

        guard let url = components.url else {
            throw SupabaseAuthError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        SupabaseConfig.defaultHeaders.forEach { request.setValue($1, forHTTPHeaderField: $0) }

        var body: [String: String] = [
            "provider": "apple",
            "id_token": idToken
        ]

        if let rawNonce, !rawNonce.isEmpty {
            body["nonce"] = rawNonce
            logAuth("Sending nonce to Supabase: \(rawNonce)")
        }

        request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw SupabaseAuthError.invalidResponse
        }

        if (200..<300).contains(httpResponse.statusCode) {
            let session = try JSONDecoder().decode(SupabaseSession.self, from: data)
            logAuth("Supabase response success. status=\(httpResponse.statusCode)")
            logAuth("Supabase user id: \(session.user.id), email: \(session.user.email ?? "nil")")
            logAuth("Supabase access_token: \(session.accessToken)")
            logAuth("Supabase refresh_token: \(session.refreshToken)")
            if let claims = decodeJWTPayload(session.accessToken) {
                logAuth("Supabase access token claims: \(claims)")
            }
            return session
        }

        if let decodedError = try? JSONDecoder().decode(SupabaseAuthErrorResponse.self, from: data) {
            let message = decodedError.errorDescription ?? decodedError.message ?? decodedError.error ?? "Authentication failed."
            logAuth("Supabase error status=\(httpResponse.statusCode), message=\(message)")
            throw SupabaseAuthError.server(message)
        }

        logAuth("Supabase error status=\(httpResponse.statusCode), unreadable body")
        throw SupabaseAuthError.server("Authentication failed with status \(httpResponse.statusCode).")
    }

    private func decodeJWTPayload(_ token: String) -> [String: Any]? {
        let parts = token.split(separator: ".")
        guard parts.count > 1 else { return nil }

        var payload = String(parts[1])
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")

        let padding = payload.count % 4
        if padding > 0 {
            payload += String(repeating: "=", count: 4 - padding)
        }

        guard
            let data = Data(base64Encoded: payload),
            let json = try? JSONSerialization.jsonObject(with: data),
            let claims = json as? [String: Any]
        else {
            return nil
        }

        return claims
    }

    private func logAuth(_ message: String) {
#if DEBUG
        print("[SupabaseAuth] \(message)")
#endif
    }
}
