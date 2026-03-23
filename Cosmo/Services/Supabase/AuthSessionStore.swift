import Foundation

final class AuthSessionStore {
    static let shared = AuthSessionStore()

    private let defaults = UserDefaults.standard
    private let loginDateKey = "auth.loginDate"
    private let userIdKey = "auth.userId"
    private let emailKey = "auth.email"
    private let tokenTypeKey = "auth.tokenType"
    private let maxSessionAge: TimeInterval = 24 * 60 * 60

    private init() {}

    var hasValidLogin: Bool {
        guard let loginDate = defaults.object(forKey: loginDateKey) as? Date else {
            return false
        }
        return Date().timeIntervalSince(loginDate) <= maxSessionAge
    }

    func persistSuccessfulLogin(session: SupabaseSession) {
        defaults.set(Date(), forKey: loginDateKey)
        defaults.set(session.user.id, forKey: userIdKey)
        defaults.set(session.user.email, forKey: emailKey)
        defaults.set(session.tokenType, forKey: tokenTypeKey)

#if DEBUG
        print("[AuthSessionStore] Login persisted for 24h. userId=\(session.user.id), email=\(session.user.email ?? "nil")")
#endif
    }

    func clearSession() {
        defaults.removeObject(forKey: loginDateKey)
        defaults.removeObject(forKey: userIdKey)
        defaults.removeObject(forKey: emailKey)
        defaults.removeObject(forKey: tokenTypeKey)

#if DEBUG
        print("[AuthSessionStore] Session cleared")
#endif
    }
}
