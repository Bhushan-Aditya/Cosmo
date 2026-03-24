import SwiftUI

struct DailyLeaderboardView: View {
    enum LeaderboardTab: String, CaseIterable {
        case daily = "Daily"
        case allTime = "All-Time"
    }

    let initialDate: String?

    @State private var selectedTab: LeaderboardTab = .daily
    @State private var selectedDate: Date = Date()
    @State private var dailyEntries: [DailyLeaderboardEntry] = []
    @State private var allTimeEntries: [DailyLeaderboardEntry] = []
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?

    private var userId: String? { AuthSessionStore.shared.currentUserId }

    init(initialDate: String? = nil) {
        self.initialDate = initialDate
        if let initialDate,
           let parsed = Self.dateFormatter.date(from: initialDate) {
            _selectedDate = State(initialValue: parsed)
        }
    }

    var body: some View {
        ZStack {
            CosmoAnimatedBackground()

            VStack(spacing: 14) {
                pickerRow

                if selectedTab == .daily {
                    dateSelector
                }

                content
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
            .padding(.bottom, 18)
        }
        .preferredColorScheme(.dark)
        .navigationTitle("Leaderboard")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await reload()
        }
        .onChange(of: selectedTab) { _, _ in
            Task { await reload() }
        }
        .onChange(of: selectedDate) { _, _ in
            guard selectedTab == .daily else { return }
            Task { await loadDaily() }
        }
    }

    private var pickerRow: some View {
        HStack(spacing: 8) {
            ForEach(LeaderboardTab.allCases, id: \.self) { tab in
                Button {
                    selectedTab = tab
                } label: {
                    Text(tab.rawValue)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(selectedTab == tab ? .white : .white.opacity(0.65))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(selectedTab == tab ? Color.purple.opacity(0.55) : Color.white.opacity(0.06))
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(6)
        .cosmoCard(cornerRadius: 16, fillOpacity: 0.2)
    }

    private var dateSelector: some View {
        DatePicker(
            "Date",
            selection: $selectedDate,
            displayedComponents: [.date]
        )
        .datePickerStyle(.compact)
        .labelsHidden()
        .tint(.purple)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .cosmoCard(cornerRadius: 14, fillOpacity: 0.18)
    }

    @ViewBuilder
    private var content: some View {
        if isLoading {
            loadingCard
        } else if let errorMessage {
            errorCard(errorMessage)
        } else {
            let rows = selectedTab == .daily ? dailyEntries : allTimeEntries
            if rows.isEmpty {
                emptyCard
            } else {
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 10) {
                        ForEach(rows) { entry in
                            leaderboardRow(entry)
                        }
                    }
                    .padding(.bottom, 20)
                }
            }
        }
    }

    private var loadingCard: some View {
        VStack(spacing: 10) {
            ProgressView().tint(.white)
            Text("Loading leaderboard…")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.72))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
        .cosmoCard()
    }

    private func errorCard(_ message: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Could not load leaderboard")
                .font(.headline)
                .foregroundColor(.white)
            Text(message)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.72))
            Button("Retry") {
                Task { await reload() }
            }
            .font(.subheadline.weight(.semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(Color.purple.opacity(0.7))
            .cornerRadius(10)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .cosmoCard()
    }

    private var emptyCard: some View {
        VStack(spacing: 8) {
            Image(systemName: "list.number")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white.opacity(0.75))
            Text("No entries yet")
                .font(.headline)
                .foregroundColor(.white)
            Text(selectedTab == .daily
                 ? "Be the first one to complete today's daily quiz."
                 : "All-time rankings will appear after attempts are submitted.")
                .font(.footnote)
                .multilineTextAlignment(.center)
                .foregroundColor(.white.opacity(0.65))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
        .padding(.horizontal, 16)
        .cosmoCard()
    }

    private func leaderboardRow(_ entry: DailyLeaderboardEntry) -> some View {
        let isCurrentUser = entry.userId == userId
        return HStack(spacing: 10) {
            Text("#\(entry.rank)")
                .font(.subheadline.weight(.bold))
                .foregroundColor(.white)
                .frame(width: 42, alignment: .leading)

            VStack(alignment: .leading, spacing: 4) {
                Text(entry.displayName)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.white)
                    .lineLimit(1)

                HStack(spacing: 10) {
                    Text("\(entry.totalPoints) pts")
                    if let time = entry.totalTimeSeconds {
                        Text(String(format: "%.1fs", time))
                    }
                    if let attempts = entry.totalAttempts {
                        Text("\(attempts) attempts")
                    }
                }
                .font(.caption)
                .foregroundColor(.white.opacity(0.62))
            }

            Spacer()

            if isCurrentUser {
                Text("You")
                    .font(.caption.weight(.bold))
                    .foregroundColor(.black.opacity(0.8))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.yellow.opacity(0.9))
                    .cornerRadius(8)
            }
        }
        .padding(13)
        .cosmoCard(
            cornerRadius: 14,
            strokeColor: isCurrentUser ? Color.yellow.opacity(0.7) : Color.white.opacity(0.14),
            fillOpacity: isCurrentUser ? 0.26 : 0.18
        )
    }

    @MainActor
    private func reload() async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        switch selectedTab {
        case .daily:
            await loadDaily()
        case .allTime:
            await loadAllTime()
        }
    }

    @MainActor
    private func loadDaily() async {
        do {
            let dateString = Self.dateFormatter.string(from: selectedDate)
            dailyEntries = try await SupabaseDailyQuizService.shared.fetchDailyLeaderboard(date: dateString)
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    @MainActor
    private func loadAllTime() async {
        do {
            allTimeEntries = try await SupabaseDailyQuizService.shared.fetchAllTimeLeaderboard()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(identifier: "Asia/Kolkata")
        return formatter
    }()
}
