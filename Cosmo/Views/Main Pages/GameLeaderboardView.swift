import SwiftUI

struct GameLeaderboardView: View {
    enum Tab: String, CaseIterable {
        case daily = "Daily"
        case allTime = "All-Time"
    }

    @State private var selectedTab: Tab = .daily
    @State private var selectedDate: Date = Date()
    @State private var dailyRows: [RemoteGameLeaderboardEntry] = []
    @State private var allTimeRows: [RemoteGameLeaderboardEntry] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    private var currentUserId: String? { AuthSessionStore.shared.currentUserId }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 12) {
                tabHeader

                if selectedTab == .daily {
                    DatePicker(
                        "",
                        selection: $selectedDate,
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(.compact)
                    .labelsHidden()
                    .tint(.cyan)
                    .padding(.vertical, 6)
                }

                content
            }
            .padding(.horizontal, 16)
            .padding(.top, 10)
            .padding(.bottom, 12)
        }
        .preferredColorScheme(.dark)
        .navigationTitle("Game Leaderboard")
        .navigationBarTitleDisplayMode(.inline)
        .task { await reload() }
        .onChange(of: selectedTab) { _, _ in
            Task { await reload() }
        }
        .onChange(of: selectedDate) { _, _ in
            guard selectedTab == .daily else { return }
            Task { await loadDaily() }
        }
    }

    private var tabHeader: some View {
        HStack(spacing: 8) {
            ForEach(Tab.allCases, id: \.self) { tab in
                Button {
                    selectedTab = tab
                } label: {
                    Text(tab.rawValue)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(selectedTab == tab ? .white : .white.opacity(0.65))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selectedTab == tab ? Color.cyan.opacity(0.35) : Color.white.opacity(0.08))
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(6)
        .cosmoCard(cornerRadius: 14, strokeColor: Color.cyan.opacity(0.25), fillOpacity: 0.14)
    }

    @ViewBuilder
    private var content: some View {
        if isLoading {
            ProgressView().tint(.white).scaleEffect(1.3)
        } else if let errorMessage {
            VStack(spacing: 10) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 28))
                    .foregroundColor(.orange.opacity(0.8))
                Text(errorMessage)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            let rows = selectedTab == .daily ? dailyRows : allTimeRows
            if rows.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "list.number")
                        .font(.system(size: 32))
                        .foregroundColor(.white.opacity(0.3))
                    Text("No leaderboard entries yet")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.6))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 10) {
                        ForEach(rows) { row in
                            leaderboardRow(row)
                        }
                    }
                    .padding(.bottom, 16)
                }
            }
        }
    }

    private func leaderboardRow(_ row: RemoteGameLeaderboardEntry) -> some View {
        let isMe = row.userId == currentUserId
        return HStack(spacing: 12) {
            Text("#\(row.rank)")
                .font(.headline.weight(.bold))
                .foregroundColor(.white)
                .frame(width: 44, alignment: .leading)

            VStack(alignment: .leading, spacing: 4) {
                Text(row.displayName)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.white)
                    .lineLimit(1)

                HStack(spacing: 10) {
                    Text("\(row.totalScore) pts")
                    Text("\(row.totalSessions) runs")
                    Text("best \(row.bestScore)")
                }
                .font(.caption)
                .foregroundColor(.white.opacity(0.6))
            }

            Spacer()

            if isMe {
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
            strokeColor: isMe ? Color.yellow.opacity(0.7) : Color.cyan.opacity(0.25),
            fillOpacity: isMe ? 0.22 : 0.14
        )
    }

    @MainActor
    private func reload() async {
        isLoading = true
        errorMessage = nil
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
            dailyRows = try await SupabaseGameSyncService.shared.fetchGameDailyLeaderboard(
                date: Self.dateFormatter.string(from: selectedDate)
            )
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    @MainActor
    private func loadAllTime() async {
        do {
            allTimeRows = try await SupabaseGameSyncService.shared.fetchGameAllTimeLeaderboard()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.timeZone = TimeZone(identifier: "UTC")
        return f
    }()
}
