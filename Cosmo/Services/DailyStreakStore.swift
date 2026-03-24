import Foundation

extension Notification.Name {
    static let dailyStreakDidUpdate = Notification.Name("dailyStreak.didUpdate")
}

/// Tracks a single unified daily streak — incremented once per day whenever
/// the user completes a quiz run OR a game session.
final class DailyStreakStore {
    static let shared = DailyStreakStore()

    private let defaults = UserDefaults.standard
    private let currentKey  = "dailyStreak.current"
    private let bestKey     = "dailyStreak.best"
    private let lastActiveKey = "dailyStreak.lastActive"

    private init() {}

    var currentStreak: Int { defaults.integer(forKey: currentKey) }
    var bestStreak: Int    { defaults.integer(forKey: bestKey) }
    var lastActiveDate: Date? { defaults.object(forKey: lastActiveKey) as? Date }

    /// Call after any successful quiz run or game session. Safe to call multiple
    /// times on the same day — only the first call counts.
    func recordActivity() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        if let last = lastActiveDate {
            let lastDay = calendar.startOfDay(for: last)
            // Already recorded today — no change needed.
            if lastDay == today { return }
        }

        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let lastDay   = lastActiveDate.map { calendar.startOfDay(for: $0) }

        let newStreak = (lastDay == yesterday) ? currentStreak + 1 : 1
        let newBest   = max(bestStreak, newStreak)

        defaults.set(newStreak, forKey: currentKey)
        defaults.set(newBest,   forKey: bestKey)
        defaults.set(Date(),    forKey: lastActiveKey)

        NotificationCenter.default.post(name: .dailyStreakDidUpdate, object: nil)

#if DEBUG
        print("[DailyStreak] Recorded. current=\(newStreak) best=\(newBest)")
#endif
    }

    func clearAll() {
        defaults.removeObject(forKey: currentKey)
        defaults.removeObject(forKey: bestKey)
        defaults.removeObject(forKey: lastActiveKey)
    }
}
