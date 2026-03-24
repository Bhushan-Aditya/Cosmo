import SwiftUI

struct QuizResultsView: View {
    let category: QuizCategory
    let questions: [QuizQuestion]
    let result: QuizRunResult
    let onReviewLater: () -> Void

    @Environment(\.dismiss) private var dismiss
    @StateObject private var statsStore = QuizStatsStore()

    @State private var startNewRun: Bool = false

    var body: some View {
        ZStack {
            CosmoAnimatedBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 14) {
                    summaryCard
                        .padding(.top, 16)

                    actionsRow

                    reviewSection
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
        }
        .preferredColorScheme(.dark)
        .navigationTitle("Results")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            statsStore.record(result: result)
        }
        .navigationDestination(isPresented: $startNewRun) {
            QuizRunView(category: category)
        }
    }

    private var accuracyPercent: Int {
        guard result.totalCount > 0 else { return 0 }
        return Int((Double(result.correctCount) / Double(result.totalCount) * 100).rounded())
    }

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(category.title)
                        .font(.headline)
                        .foregroundColor(.white)
                    Text("Mission complete")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.75))
                }
                Spacer()
                Image(systemName: "flag.checkered")
                    .foregroundColor(category.accent.color.opacity(0.95))
            }

            HStack(spacing: 12) {
                statPill(title: "Score", value: "\(result.correctCount)/\(result.totalCount)", color: category.accent.color)
                statPill(title: "Accuracy", value: "\(accuracyPercent)%", color: .white)
                Spacer()
            }
        }
        .padding(16)
        .cosmoCard(cornerRadius: 22, strokeColor: category.accent.color.opacity(0.45), fillOpacity: 0.22)
    }

    private func statPill(title: String, value: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundColor(.white.opacity(0.7))
            Text(value)
                .font(.headline)
                .foregroundColor(color)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color.white.opacity(0.08))
        .cornerRadius(14)
    }

    private var actionsRow: some View {
        HStack(spacing: 12) {
            Button {
                startNewRun = true
            } label: {
                Text("New Run")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(category.accent.color.opacity(0.85))
                    .cornerRadius(14)
            }

            Button {
                onReviewLater()
                dismiss()
            } label: {
                Text("Review Later")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.9))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.white.opacity(0.10))
                    .cornerRadius(14)
            }
        }
    }

    private var reviewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Review")
                .font(.title3.weight(.bold))
                .foregroundColor(.white)
                .padding(.top, 6)

            VStack(spacing: 10) {
                ForEach(questions) { q in
                    ReviewRow(
                        question: q,
                        selectedIndex: result.answersById[q.id],
                        accent: category.accent.color
                    )
                }
            }
        }
    }
}

private struct ReviewRow: View {
    let question: QuizQuestion
    let selectedIndex: Int?
    let accent: Color

    private var isCorrect: Bool {
        selectedIndex == question.correctIndex
    }

    var body: some View {
        DisclosureGroup {
            VStack(alignment: .leading, spacing: 10) {
                if let selectedIndex, question.choices.indices.contains(selectedIndex) {
                    HStack(alignment: .top, spacing: 8) {
                        Text("Your answer:")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(.white.opacity(0.65))
                        Text(question.choices[selectedIndex])
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                HStack(alignment: .top, spacing: 8) {
                    Text("Correct:")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.white.opacity(0.65))
                    Text(question.choices[question.correctIndex])
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Text(question.explanation)
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.75))
                    .fixedSize(horizontal: false, vertical: true)

                if !question.sources.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Sources")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(.white.opacity(0.65))
                        ForEach(question.sources, id: \.self) { src in
                            Text(src)
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.65))
                        }
                    }
                }
            }
            .padding(.top, 8)
        } label: {
            HStack(spacing: 10) {
                Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(isCorrect ? .green : .red)
                Text(question.prompt)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.white)
                    .lineLimit(2)
                Spacer()
            }
        }
        .accentColor(accent)
        .padding(14)
        .cosmoCard(cornerRadius: 18, strokeColor: accent.opacity(0.25), fillOpacity: 0.20)
    }
}
