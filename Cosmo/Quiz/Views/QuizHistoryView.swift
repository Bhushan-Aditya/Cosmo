import SwiftUI

struct QuizHistoryView: View {
    @State private var rows: [RemoteQuizRunHistoryRow] = []
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
                        Image(systemName: "questionmark.circle")
                            .font(.system(size: 40))
                            .foregroundColor(.white.opacity(0.3))
                        Text("No quiz runs yet")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.5))
                        Text("Complete a quiz to see your history here.")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.35))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                } else {
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 10) {
                            ForEach(rows) { row in
                                QuizHistoryRow(row: row)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
        .navigationTitle("Quiz History")
        .navigationBarTitleDisplayMode(.inline)
        .task { await load() }
    }

    private func load() async {
        isLoading = true
        errorMessage = nil
        do {
            rows = try await SupabaseQuizSyncService.shared.fetchQuizHistory(limit: 50)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}

private struct QuizHistoryRow: View {
    let row: RemoteQuizRunHistoryRow

    private var accuracyColor: Color {
        switch row.accuracy {
        case 80...: return .green
        case 50..<80: return .orange
        default: return .red.opacity(0.85)
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            // Accuracy ring
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.1), lineWidth: 3)
                    .frame(width: 44, height: 44)
                Circle()
                    .trim(from: 0, to: CGFloat(row.accuracy) / 100)
                    .stroke(accuracyColor, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .frame(width: 44, height: 44)
                    .rotationEffect(.degrees(-90))
                Text("\(row.accuracy)%")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(row.categoryId.replacingOccurrences(of: "_", with: " ").capitalized)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(1)

                Text("\(row.correctCount) / \(row.totalCount) correct")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.55))
            }

            Spacer()

            Text(formattedDate(row.playedAt))
                .font(.system(size: 11))
                .foregroundColor(.white.opacity(0.38))
                .multilineTextAlignment(.trailing)
        }
        .padding(14)
        .cosmoCard(cornerRadius: 14, strokeColor: accuracyColor.opacity(0.25), fillOpacity: 0.16)
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
