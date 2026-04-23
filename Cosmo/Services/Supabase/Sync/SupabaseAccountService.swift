import Foundation

final class SupabaseAccountService {
    static let shared = SupabaseAccountService()
    private let urlSession = URLSession.shared

    private init() {}

    func deleteCurrentAccount() async throws {
        let url = SupabaseConfig.functionsURL.appendingPathComponent("delete_account")
        try await performDeleteRequest(url: url, isRetry: false)
    }

    private func performDeleteRequest(url: URL, isRetry: Bool) async throws {
        let accessToken = try await validAccessToken()

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(SupabaseConfig.anonKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.httpBody = Data("{}".utf8)

        let (data, response) = try await urlSession.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw SupabaseRESTError.invalidResponse
        }

        if http.statusCode == 401 && !isRetry {
            do {
                let refreshed = try await SupabaseAuthService.shared.refreshSession()
                AuthSessionStore.shared.updateTokens(
                    accessToken: refreshed.accessToken,
                    refreshToken: refreshed.refreshToken
                )
                try await performDeleteRequest(url: url, isRetry: true)
                return
            } catch {
                throw SupabaseRESTError.notAuthenticated
            }
        }

        if (200..<300).contains(http.statusCode) {
            return
        }

        if let errBody = try? JSONDecoder().decode(EdgeFunctionError.self, from: data) {
            throw SupabaseRESTError.server(status: http.statusCode, message: errBody.error)
        }

        throw SupabaseRESTError.server(
            status: http.statusCode,
            message: "Request failed (\(http.statusCode))"
        )
    }

    private func validAccessToken() async throws -> String {
        if let token = AuthSessionStore.shared.currentAccessToken,
           !AuthSessionStore.shared.isAccessTokenExpired {
            return token
        }

        if AuthSessionStore.shared.currentRefreshToken != nil {
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
                throw SupabaseRESTError.notAuthenticated
            }
        }

        throw SupabaseRESTError.notAuthenticated
    }
}
