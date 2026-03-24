import SwiftUI

struct DailyQuizResultsView: View {
    let result: DailyAttemptResult
    let questions: [DailyQuizQuestion]

    @Environment(\.dismiss) private var dismiss
    @State private var showLeaderboard: Bool = false

    private var accuracyPercent: Int {
        guard !questions.isEmpty else { return 0 }
        return Int((Double(result.correctCount) / Double(questions.count) * 100).rounded())
    }

    private var performanceLabel: String {
        switch accuracyPercent {
        case 90...100: return "Outstanding!"
        case 70..<90:  return "Well Done!"
        case 50..<70:  return "Not Bad!"
        default:       return "Keep Practicing"
        }
    }

    private var performanceColor: Color {
        switch accuracyPercent {
        case 90...100: return .green
        case 70..<90:  return Color(red: 0.4, green: 0.9, blue: 0.5)
        case 50..<70:  return .yellow
        default:       return .orange
        }
    }

    var body: some View {
        ZStack {
            CosmoAnimatedBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    heroCard
                        .padding(.top, 20)

                    statsRow

                    if let rank = result.dailyRank {
                        rankCard(rank)
                    }

                    actionsStack
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 40)
            }
        }
        .preferredColorScheme(.dark)
        .navigationTitle("Results")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    // Pop all the way to QuizHomeView
                    dismiss()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Quiz")
                    }
                    .foregroundColor(.white.opacity(0.85))
                }
            }
        }
        .navigationDestination(isPresented: $showLeaderboard) {
            DailyLeaderboardView(initialDate: result.quizDate)
        }
    }

    // MARK: - Hero

    private var heroCard: some View {
        VStack(spacing: 14) {
            Image(systemName: "trophy.fill")
                .font(.system(size: 52))
                .foregroundStyle(
                    LinearGradient(
                        colors: [performanceColor, performanceColor.opacity(0.6)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            Text(performanceLabel)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)

            Text("\(result.correctCount) / \(questions.count) correct")
                .font(.title3.weight(.semibold))
                .foregroundColor(.white.opacity(0.8))

            Text("Daily Quiz · \(formattedDate(result.quizDate))")
                .font(.footnote)
                .foregroundColor(.white.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
        .cosmoCard(cornerRadius: 24, strokeColor: performanceColor.opacity(0.35), fillOpacity: 0.22)
    }

    // MARK: - Stats row

    private var statsRow: some View {
        HStack(spacing: 12) {
            statPill(
                icon: "star.fill",
                label: "Points",
                value: "\(result.totalPoints)",
                color: .yellow
            )
            statPill(
                icon: "clock.fill",
                label: "Avg Time",
                value: avgTimeString,
                color: .cyan
            )
            statPill(
                icon: "percent",
                label: "Accuracy",
                value: "\(accuracyPercent)%",
                color: performanceColor
            )
        }
    }

    private var avgTimeString: String {
        guard !questions.isEmpty else { return "—" }
        let avg = result.totalTimeSeconds / Double(questions.count)
        return String(format: "%.1fs", avg)
    }

    private func statPill(icon: String, label: String, value: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(color)
            Text(value)
                .font(.headline)
                .foregroundColor(.white)
            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundColor(.white.opacity(0.55))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .cosmoCard(cornerRadius: 18, strokeColor: color.opacity(0.25), fillOpacity: 0.20)
    }

    // MARK: - Rank card

    private func rankCard(_ rank: Int) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.yellow.opacity(0.15))
                    .frame(width: 52, height: 52)
                Text(rankEmoji(rank))
                    .font(.system(size: 26))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Daily Rank")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.white.opacity(0.55))
                Text("#\(rank)")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
            }

            Spacer()

            Button {
                showLeaderboard = true
            } label: {
                HStack(spacing: 5) {
                    Text("Leaderboard")
                        .font(.subheadline.weight(.semibold))
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                }
                .foregroundColor(.white.opacity(0.85))
                .padding(.horizontal, 14)
                .padding(.vertical, 9)
                .background(Color.purple.opacity(0.55))
                .cornerRadius(12)
            }
        }
        .padding(16)
        .cosmoCard(cornerRadius: 20, strokeColor: Color.yellow.opacity(0.3), fillOpacity: 0.22)
    }

    private func rankEmoji(_ rank: Int) -> String {
        switch rank {
        case 1: return "🥇"
        case 2: return "🥈"
        case 3: return "🥉"
        default: return "🏅"
        }
    }

    // MARK: - Actions

    private var actionsStack: some View {
        VStack(spacing: 12) {
            Button {
                showLeaderboard = true
            } label: {
                Label("View Leaderboard", systemImage: "list.number")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(
                        LinearGradient(
                            colors: [Color.purple.opacity(0.85), Color.indigo.opacity(0.85)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
            }

            Button {
                dismiss()
            } label: {
                Text("Done")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.85))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(Color.white.opacity(0.10))
                    .cornerRadius(16)
            }
        }
    }

    // MARK: - Helpers

    private func formattedDate(_ dateString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        guard let date = inputFormatter.date(from: dateString) else { return dateString }
        let outputFormatter = DateFormatter()
        outputFormatter.dateStyle = .medium
        return outputFormatter.string(from: date)
    }
}
