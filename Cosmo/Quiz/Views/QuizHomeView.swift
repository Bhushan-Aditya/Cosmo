import SwiftUI

struct QuizHomeView: View {
    @StateObject private var dataStore = QuizDataStore()
    @StateObject private var statsStore = QuizStatsStore()

    var body: some View {
        ZStack {
            CosmoAnimatedBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    header
                        .padding(.top, 18)

                    categoriesGrid
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
        }
        .onAppear { dataStore.loadIfNeeded() }
        .preferredColorScheme(.dark)
        .navigationTitle("Quiz")
        .navigationBarTitleDisplayMode(.large)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Cosmic Quiz")
                .font(.system(size: 34, weight: .bold))
                .foregroundColor(.white)

            Text("Pick a category and run a 10‑question mission.")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.75))
        }
        .padding(16)
        .cosmoCard(cornerRadius: 22)
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
                                stats: statsStore.stats(for: category.id)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
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

