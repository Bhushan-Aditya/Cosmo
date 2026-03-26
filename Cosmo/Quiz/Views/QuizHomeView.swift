import SwiftUI

struct QuizHomeView: View {
    @StateObject private var dataStore = QuizDataStore()
    @StateObject private var statsStore = QuizStatsStore()
    @State private var remoteStatsByCategory: [String: QuizCategoryStats] = [:]
    @State private var attemptStatus: DailyAttemptStatus = .unavailable
    @State private var isStartingDailyAttempt: Bool = false
    @State private var dailyStartError: String?
    @State private var pendingDailyAttempt: DailyAttemptStartResponse?
    @State private var showDailyRun: Bool = false
    @State private var showLeaderboard: Bool = false

    var body: some View {
        ZStack {
            CosmoAnimatedBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    header
                    dailyQuizSection
                        .padding(.top, 16)

                    categoriesGrid
                        .padding(.top, 20)
                }
                .padding(.bottom, 100)
            }
        }
        .onAppear {
            dataStore.loadIfNeeded()
            Task {
                await fetchRemoteStats()
                await fetchDailyAttemptStatus()
            }
        }
        .preferredColorScheme(.dark)
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $showDailyRun) {
            if let pendingDailyAttempt {
                DailyQuizRunView(attemptResponse: pendingDailyAttempt)
            }
        }
        .navigationDestination(isPresented: $showLeaderboard) {
            DailyLeaderboardView(initialDate: attemptStatus.quizDate.isEmpty ? nil : attemptStatus.quizDate)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 10) {
                Image(systemName: "questionmark.circle.fill")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.white, Color.purple.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                Text("Cosmic Quiz")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
                ProfileTopButton()
            }
            Text("Pick a category and run a 10‑question mission")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.55))
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
    }

    private var categoriesGrid: some View {
        Group {
            if let loadError = dataStore.loadError {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Quiz data unavailable")
                        .font(.headline)
                        .foregroundColor(.white)
                    Text(loadError.localizedDescription)
                        .font(.footnote)
                        .foregroundColor(.white.opacity(0.75))
                }
                .padding(16)
                .cosmoCard()
                .padding(.horizontal, 16)
            } else {
                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: 12),
                        GridItem(.flexible(), spacing: 12)
                    ],
                    spacing: 12
                ) {
                    ForEach(dataStore.categories) { category in
                        NavigationLink {
                            QuizRunView(category: category)
                        } label: {
                            QuizCategoryCard(
                                category: category,
                                stats: mergedStats(for: category.id)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }

    private var dailyQuizSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Daily Quiz")
                    .font(.title3.weight(.bold))
                    .foregroundColor(.white)
                Spacer()
                Button {
                    showLeaderboard = true
                } label: {
                    Label("Leaderboard", systemImage: "list.number")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.white.opacity(0.85))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.white.opacity(0.10))
                        .cornerRadius(10)
                }
                .buttonStyle(.plain)
            }

            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .firstTextBaseline) {
                    Text("New 10-question mission every day")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.white)
                    Spacer()
                    attemptBadge
                }

                Text(attemptSubtitle)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.65))

                if let dailyStartError {
                    Text(dailyStartError)
                        .font(.caption)
                        .foregroundColor(.red.opacity(0.9))
                        .fixedSize(horizontal: false, vertical: true)
                }

                Button {
                    Task { await startDailyAttempt() }
                } label: {
                    HStack {
                        if isStartingDailyAttempt {
                            ProgressView().tint(.white)
                        } else {
                            Image(systemName: "bolt.fill")
                        }
                        Text(isStartingDailyAttempt ? "Starting..." : "Play Daily Quiz")
                            .font(.headline)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
                    .background(
                        LinearGradient(
                            colors: [Color.purple.opacity(0.85), Color.indigo.opacity(0.85)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(14)
                }
                .disabled(isStartingDailyAttempt || !attemptStatus.hasAttemptsLeft || !AuthSessionStore.shared.hasValidLogin)
                .opacity((isStartingDailyAttempt || !attemptStatus.hasAttemptsLeft) ? 0.65 : 1)
            }
            .padding(14)
            .cosmoCard(
                cornerRadius: 18,
                strokeColor: Color.purple.opacity(0.45),
                fillOpacity: 0.20
            )
        }
        .padding(.horizontal, 16)
    }

    private var attemptBadge: some View {
        Text("\(attemptStatus.attemptsUsed)/\(attemptStatus.cap)")
            .font(.caption.weight(.bold))
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(Color.purple.opacity(0.55))
            )
    }

    private var attemptSubtitle: String {
        attemptStatus.isPro
        ? "Pro: \(attemptStatus.attemptsUsed)/5 attempts used today"
        : "Free: \(attemptStatus.attemptsUsed)/1 attempt used today"
    }

    private func mergedStats(for categoryId: String) -> QuizCategoryStats {
        let local = statsStore.stats(for: categoryId)
        guard let remote = remoteStatsByCategory[categoryId] else { return local }

        return QuizCategoryStats(
            bestScore: max(local.bestScore, remote.bestScore),
            bestAccuracy: max(local.bestAccuracy, remote.bestAccuracy),
            runsPlayed: max(local.runsPlayed, remote.runsPlayed),
            lastRunDate: local.lastRunDate ?? remote.lastRunDate
        )
    }

    private func friendlyQuizError(_ error: Error) -> String {
        if let restError = error as? SupabaseRESTError {
            switch restError {
            case .server(let status, let message):
                if status == 404 || message.lowercased().contains("no published daily quiz") {
                    return "Today's quiz isn't ready yet. Check back later!"
                }
                if status == 403 || message.lowercased().contains("attempt limit") {
                    return "You've used all your attempts for today. Come back tomorrow!"
                }
                return message
            case .notAuthenticated:
                return "Could not reach the server. Check your connection and try again."
            default:
                break
            }
        }
        return error.localizedDescription
    }

    @MainActor
    private func fetchRemoteStats() async {
        guard AuthSessionStore.shared.hasValidLogin else { return }
        do {
            remoteStatsByCategory = try await SupabaseQuizSyncService.shared.fetchCategoryStats()
        } catch {
#if DEBUG
            print("[QuizHome] Remote stats fetch skipped: \(error.localizedDescription)")
#endif
        }
    }

    @MainActor
    private func fetchDailyAttemptStatus() async {
        guard AuthSessionStore.shared.hasValidLogin else {
            attemptStatus = .unavailable
            return
        }
        do {
            attemptStatus = try await SupabaseDailyQuizService.shared.fetchAttemptStatus()
        } catch {
#if DEBUG
            print("[QuizHome] Daily attempt status fetch failed: \(error.localizedDescription)")
#endif
        }
    }

    @MainActor
    private func startDailyAttempt() async {
        guard AuthSessionStore.shared.hasValidLogin else {
            dailyStartError = "Sign in required for Daily Quiz."
            return
        }
        guard attemptStatus.hasAttemptsLeft else {
            dailyStartError = "Daily limit reached. Come back tomorrow for more."
            return
        }

        isStartingDailyAttempt = true
        dailyStartError = nil
        defer { isStartingDailyAttempt = false }

        do {
            pendingDailyAttempt = try await SupabaseDailyQuizService.shared.startAttempt()
            showDailyRun = true
            await fetchDailyAttemptStatus()
        } catch {
            dailyStartError = friendlyQuizError(error)
        }
    }

}

private struct QuizCategoryCard: View {
    let category: QuizCategory
    let stats: QuizCategoryStats

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                Image(systemName: category.systemImage)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, category.accent.color.opacity(0.85)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )

                Spacer()
            }

            Text(category.title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .lineLimit(1)

            Text(category.subtitle)
                .font(.caption)
                .foregroundColor(.white.opacity(0.70))
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 4)

            if stats.runsPlayed > 0 {
                Text("Best \(stats.bestScore)/10 • \(stats.bestAccuracy)% • \(stats.runsPlayed) runs")
                    .font(.caption2.weight(.semibold))
                    .foregroundColor(.white.opacity(0.70))
                    .lineLimit(1)
            } else {
                Text("No runs yet")
                    .font(.caption2.weight(.semibold))
                    .foregroundColor(.white.opacity(0.55))
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 120, alignment: .topLeading)
        .cosmoCard(
            cornerRadius: 18,
            strokeColor: category.accent.color.opacity(0.45),
            fillOpacity: 0.22
        )
    }
}
