import Foundation

final class SupabaseAppleAccountService {
    static let shared = SupabaseAppleAccountService()
    private let urlSession = URLSession.shared

    private init() {}

    func storeAppleRefreshToken(authorizationCode: String) async {
        do {
            try await sendStoreTokenRequest(authorizationCode: authorizationCode, isRetry: false)
        } catch {
#if DEBUG
            print("[AppleAccountService] store token skipped/failed: \(error.localizedDescription)")
#endif
        }
    }

    private func sendStoreTokenRequest(authorizationCode: String, isRetry: Bool) async throws {
        let accessToken = try await validAccessToken()

        let url = SupabaseConfig.functionsURL.appendingPathComponent("store_apple_refresh_token")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(SupabaseConfig.anonKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        let body: [String: String] = ["authorization_code": authorizationCode]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

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
                try await sendStoreTokenRequest(authorizationCode: authorizationCode, isRetry: true)
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

        throw SupabaseRESTError.server(status: http.statusCode, message: "Request failed (\(http.statusCode))")
    }

    private func validAccessToken() async throws -> String {
        if let token = AuthSessionStore.shared.currentAccessToken,
           !AuthSessionStore.shared.isAccessTokenExpired {
            return token
        }

        if AuthSessionStore.shared.currentRefreshToken != nil {
            let refreshed = try await SupabaseAuthService.shared.refreshSession()
            AuthSessionStore.shared.updateTokens(
                accessToken: refreshed.accessToken,
                refreshToken: refreshed.refreshToken
            )

            if let token = AuthSessionStore.shared.currentAccessToken {
                return token
            }
        }

        throw SupabaseRESTError.notAuthenticated
    }
}
