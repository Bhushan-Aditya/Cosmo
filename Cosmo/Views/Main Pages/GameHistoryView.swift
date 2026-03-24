import SwiftUI

struct GameHistoryView: View {
    @State private var rows: [RemoteGameSessionHistoryRow] = []
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            Group {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(1.4)
                } else if let errorMessage {
                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 36))
                            .foregroundColor(.orange.opacity(0.8))
                        Text(errorMessage)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.65))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                } else if rows.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "gamecontroller")
                            .font(.system(size: 40))
                            .foregroundColor(.white.opacity(0.3))
                        Text("No game sessions yet")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.5))
                        Text("Play a game to see your history here.")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.35))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                } else {
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 10) {
                            ForEach(rows) { row in
                                GameHistoryRow(row: row)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
        .navigationTitle("Game History")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink {
                    GameLeaderboardView()
                } label: {
                    Image(systemName: "list.number")
                        .foregroundColor(.white.opacity(0.85))
                }
            }
        }
        .task { await load() }
    }

    private func load() async {
        isLoading = true
        errorMessage = nil
        do {
            rows = try await SupabaseGameSyncService.shared.fetchGameHistory(limit: 50)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}

private struct GameHistoryRow: View {
    let row: RemoteGameSessionHistoryRow

    var body: some View {
        HStack(spacing: 14) {
            // Score badge
            VStack(spacing: 2) {
                Text("\(row.score)")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                Text("pts")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.white.opacity(0.45))
            }
            .frame(width: 52)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.cyan.opacity(0.15))
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.cyan.opacity(0.3), lineWidth: 1))
            )

            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 14) {
                    statLabel(icon: "antenna.radiowaves.left.and.right", value: "Wave \(row.waveReached)")
                    statLabel(icon: "heart.fill", value: "\(row.livesLeft) left")
                }
                statLabel(icon: "clock", value: durationString(row.durationSeconds))
            }

            Spacer()

            Text(formattedDate(row.playedAt))
                .font(.system(size: 11))
                .foregroundColor(.white.opacity(0.38))
                .multilineTextAlignment(.trailing)
        }
        .padding(14)
        .cosmoCard(cornerRadius: 14, strokeColor: Color.cyan.opacity(0.2), fillOpacity: 0.14)
    }

    private func statLabel(icon: String, value: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 11))
                .foregroundColor(.white.opacity(0.5))
            Text(value)
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.65))
        }
    }

    private func durationString(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return m > 0 ? "\(m)m \(s)s" : "\(s)s"
    }

    private func formattedDate(_ iso: String) -> String {
        let parser = ISO8601DateFormatter()
        parser.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let fallback = ISO8601DateFormatter()
        guard let date = parser.date(from: iso) ?? fallback.date(from: iso) else { return iso }
        let f = DateFormatter()
        f.dateStyle = .short
        f.timeStyle = .short
        return f.string(from: date)
    }
}
