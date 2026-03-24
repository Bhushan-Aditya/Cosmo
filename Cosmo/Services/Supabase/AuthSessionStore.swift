import Foundation

final class AuthSessionStore {
    static let shared = AuthSessionStore()

    private let defaults = UserDefaults.standard
    private let loginDateKey = "auth.loginDate"
    private let userIdKey = "auth.userId"
    private let emailKey = "auth.email"
    private let accessTokenKey = "auth.accessToken"
    private let refreshTokenKey = "auth.refreshToken"
    private let tokenTypeKey = "auth.tokenType"
    private let tokenExpiresAtKey = "auth.tokenExpiresAt"

    // Buffer before expiry within which we proactively refresh.
    private let expiryBuffer: TimeInterval = 60

    private init() {}

    // MARK: - Validity

    var hasValidLogin: Bool {
        // Valid as long as we have a user ID and a stored expiry that hasn't passed.
        guard
            defaults.string(forKey: userIdKey) != nil,
            let expiresAt = defaults.object(forKey: tokenExpiresAtKey) as? Date
        else {
            // Fall back to legacy 24h window if no expiry stored yet.
            guard let loginDate = defaults.object(forKey: loginDateKey) as? Date else {
                return false
            }
            return Date().timeIntervalSince(loginDate) <= 24 * 60 * 60
        }
        return Date() < expiresAt
    }

    var isAccessTokenExpired: Bool {
        guard let expiresAt = defaults.object(forKey: tokenExpiresAtKey) as? Date else {
            return false
        }
        return Date() >= expiresAt.addingTimeInterval(-expiryBuffer)
    }

    // MARK: - Accessors

    var currentUserId: String? {
        defaults.string(forKey: userIdKey)
    }

    var currentEmail: String? {
        defaults.string(forKey: emailKey)
    }

    var currentAccessToken: String? {
        defaults.string(forKey: accessTokenKey)
    }

    var currentRefreshToken: String? {
        defaults.string(forKey: refreshTokenKey)
    }

    var lastLoginDate: Date? {
        defaults.object(forKey: loginDateKey) as? Date
    }

    // MARK: - Mutations

    func persistSuccessfulLogin(session: SupabaseSession) {
        let expiresAt = expiryDate(from: session.accessToken)
        defaults.set(Date(), forKey: loginDateKey)
        defaults.set(session.user.id, forKey: userIdKey)
        defaults.set(session.user.email, forKey: emailKey)
        defaults.set(session.accessToken, forKey: accessTokenKey)
        defaults.set(session.refreshToken, forKey: refreshTokenKey)
        defaults.set(session.tokenType, forKey: tokenTypeKey)
        defaults.set(expiresAt, forKey: tokenExpiresAtKey)

#if DEBUG
        print("[AuthSessionStore] Login persisted. userId=\(session.user.id), expiresAt=\(expiresAt?.description ?? "unknown")")
#endif
    }

    func updateTokens(accessToken: String, refreshToken: String) {
        let expiresAt = expiryDate(from: accessToken)
        defaults.set(accessToken, forKey: accessTokenKey)
        defaults.set(refreshToken, forKey: refreshTokenKey)
        defaults.set(expiresAt, forKey: tokenExpiresAtKey)

#if DEBUG
        print("[AuthSessionStore] Tokens refreshed. expiresAt=\(expiresAt?.description ?? "unknown")")
#endif
    }

    func clearSession() {
        defaults.removeObject(forKey: loginDateKey)
        defaults.removeObject(forKey: userIdKey)
        defaults.removeObject(forKey: emailKey)
        defaults.removeObject(forKey: accessTokenKey)
        defaults.removeObject(forKey: refreshTokenKey)
        defaults.removeObject(forKey: tokenTypeKey)
        defaults.removeObject(forKey: tokenExpiresAtKey)
        NotificationCenter.default.post(name: .authDidLogout, object: nil)

#if DEBUG
        print("[AuthSessionStore] Session cleared")
#endif
    }

    // MARK: - Helpers

    private func expiryDate(from jwt: String) -> Date? {
        let parts = jwt.split(separator: ".")
        guard parts.count > 1 else { return nil }

        var payload = String(parts[1])
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        let padding = payload.count % 4
        if padding > 0 { payload += String(repeating: "=", count: 4 - padding) }

        guard
            let data = Data(base64Encoded: payload),
            let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let exp = json["exp"] as? TimeInterval
        else { return nil }

        return Date(timeIntervalSince1970: exp)
    }
}

extension Notification.Name {
    static let authDidLogout = Notification.Name("auth.didLogout")
}
