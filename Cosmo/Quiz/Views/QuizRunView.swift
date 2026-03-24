import SwiftUI

struct QuizRunResult: Hashable, Codable {
    let categoryId: String
    let questionIds: [String]
    let answersById: [String: Int]
    let correctCount: Int
    let totalCount: Int
}

struct QuizRunView: View {
    let category: QuizCategory

    @StateObject private var dataStore = QuizDataStore()

    @Environment(\.dismiss) private var dismiss

    @State private var questions: [QuizQuestion] = []
    @State private var currentIndex: Int = 0
    @State private var selectedIndex: Int? = nil
    @State private var revealAnswer: Bool = false
    @State private var answersById: [String: Int] = [:]
    @State private var showResults: Bool = false
    @State private var popToHome: Bool = false

    private var currentQuestion: QuizQuestion? {
        questions.indices.contains(currentIndex) ? questions[currentIndex] : nil
    }

    var body: some View {
        ZStack {
            CosmoAnimatedBackground()

            VStack(spacing: 14) {
                header

                if let q = currentQuestion {
                    questionCard(q)
                    answersList(q)
                    footer(q)
                } else if dataStore.loadError != nil {
                    loadErrorCard
                } else {
                    loadingCard
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 18)
        }
        .onAppear {
            dataStore.loadIfNeeded()
            prepareRunIfNeeded()
        }
        .onChange(of: dataStore.bank) { _, _ in
            prepareRunIfNeeded()
        }
        .onChange(of: popToHome) { _, shouldPop in
            if shouldPop {
                dismiss()
            }
        }
        .preferredColorScheme(.dark)
        .navigationTitle(category.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Exit") { dismiss() }
                    .foregroundColor(.white.opacity(0.85))
            }
        }
        .background(
            NavigationLink(
                destination: QuizResultsView(
                    category: category,
                    questions: questions,
                    result: makeResult(),
                    onReviewLater: {
                        popToHome = true
                    }
                ),
                isActive: $showResults
            ) {
                EmptyView()
            }
            .hidden()
        )
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Question \(min(currentIndex + 1, max(questions.count, 1)))/\(max(questions.count, 10))")
                    .font(.footnote.weight(.semibold))
                    .foregroundColor(.white.opacity(0.75))

                Spacer()

                Text(category.title)
                    .font(.footnote.weight(.semibold))
                    .foregroundColor(category.accent.color.opacity(0.95))
            }

            ProgressView(value: progress)
                .tint(category.accent.color)
        }
        .padding(14)
        .cosmoCard()
    }

    private var progress: Double {
        guard !questions.isEmpty else { return 0 }
        return Double(currentIndex) / Double(max(questions.count - 1, 1))
    }

    private func questionCard(_ q: QuizQuestion) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                difficultyPill(q.difficulty)
                Spacer()
            }

            Text(q.prompt)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .cosmoCard(cornerRadius: 22)
    }

    private func answersList(_ q: QuizQuestion) -> some View {
        VStack(spacing: 10) {
            ForEach(q.choices.indices, id: \.self) { idx in
                AnswerRow(
                    title: q.choices[idx],
                    accent: category.accent.color,
                    state: answerState(for: q, index: idx)
                )
                .onTapGesture {
                    guard !revealAnswer else { return }
                    selectedIndex = idx
                    answersById[q.id] = idx
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        revealAnswer = true
                    }
                }
            }
        }
    }

    private func footer(_ q: QuizQuestion) -> some View {
        VStack(spacing: 12) {
            if revealAnswer {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 8) {
                        Image(systemName: isCorrect(q) ? "checkmark.seal.fill" : "xmark.seal.fill")
                            .foregroundColor(isCorrect(q) ? .green : .red)
                        Text(isCorrect(q) ? "Correct" : "Not quite")
                            .font(.headline)
                            .foregroundColor(.white)
                    }

                    Text(q.explanation)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.78))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(14)
                .cosmoCard()
            }

            Button {
                nextOrFinish()
            } label: {
                Text(currentIndex >= questions.count - 1 ? "Finish" : "Next")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(category.accent.color.opacity(0.85))
                    .cornerRadius(14)
            }
            .disabled(!revealAnswer)
            .opacity(revealAnswer ? 1 : 0.55)
        }
    }

    private var loadingCard: some View {
        VStack(spacing: 10) {
            ProgressView()
                .tint(.white)
            Text("Preparing your mission…")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.75))
        }
        .padding(18)
        .cosmoCard()
    }

    private var loadErrorCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Couldn’t load quiz data")
                .font(.headline)
                .foregroundColor(.white)
            Text(dataStore.loadError?.localizedDescription ?? "Unknown error")
                .font(.footnote)
                .foregroundColor(.white.opacity(0.75))
        }
        .padding(16)
        .cosmoCard()
    }

    private func prepareRunIfNeeded() {
        guard questions.isEmpty else { return }
        guard dataStore.loadError == nil else { return }

        let pool = dataStore.questions(for: category.id)
        guard pool.count >= 10 else { return }

        questions = Array(pool.shuffled().prefix(10))
        currentIndex = 0
        selectedIndex = nil
        revealAnswer = false
        answersById = [:]
    }

    private func isCorrect(_ q: QuizQuestion) -> Bool {
        guard let selected = answersById[q.id] else { return false }
        return selected == q.correctIndex
    }

    private func nextOrFinish() {
        if currentIndex >= questions.count - 1 {
            uploadResultImmediately()
            showResults = true
            return
        }

        currentIndex += 1
        selectedIndex = nil
        revealAnswer = false
    }

    private func uploadResultImmediately() {
        let result = makeResult()
        DailyStreakStore.shared.recordActivity()
        Task {
            do {
                try await SupabaseQuizSyncService.shared.uploadQuizRun(result)
                ToastManager.shared.show("Run synced", style: .success)
            } catch {
                ToastManager.shared.show("Sync failed — will retry when online", style: .error)
#if DEBUG
                print("[QuizRun] Immediate sync failed: \(error.localizedDescription)")
#endif
            }
        }
    }

    private func makeResult() -> QuizRunResult {
        let correct = questions.reduce(into: 0) { partial, q in
            if answersById[q.id] == q.correctIndex { partial += 1 }
        }
        return QuizRunResult(
            categoryId: category.id,
            questionIds: questions.map(\.id),
            answersById: answersById,
            correctCount: correct,
            totalCount: questions.count
        )
    }

    private func difficultyPill(_ difficulty: QuizDifficulty) -> some View {
        let (title, color): (String, Color) = {
            switch difficulty {
            case .easy: return ("Easy", .green)
            case .medium: return ("Medium", .yellow)
            case .hard: return ("Hard", .red)
            }
        }()

        return Text(title)
            .font(.caption.weight(.semibold))
            .foregroundColor(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.white.opacity(0.08))
            .cornerRadius(10)
    }

    private func answerState(for q: QuizQuestion, index: Int) -> AnswerRow.State {
        guard revealAnswer else {
            return index == selectedIndex ? .selected : .normal
        }
        if index == q.correctIndex {
            return .correct
        }
        if let selectedIndex = selectedIndex, index == selectedIndex, selectedIndex != q.correctIndex {
            return .incorrect
        }
        return .disabled
    }
}

private struct AnswerRow: View {
    enum State {
        case normal
        case selected
        case correct
        case incorrect
        case disabled
    }

    let title: String
    let accent: Color
    let state: State

    var body: some View {
        HStack(spacing: 12) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.white)
                .fixedSize(horizontal: false, vertical: true)

            Spacer()

            if state == .correct {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            } else if state == .incorrect {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.red)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .modifier(AnswerSurface(state: state, accent: accent))
    }
}

private struct AnswerSurface: ViewModifier {
    let state: AnswerRow.State
    let accent: Color

    func body(content: Content) -> some View {
        let stroke: Color
        let fillOpacity: Double

        switch state {
        case .normal:
            stroke = Color.white.opacity(0.14)
            fillOpacity = 0.22
        case .selected:
            stroke = accent.opacity(0.65)
            fillOpacity = 0.26
        case .correct:
            stroke = Color.green.opacity(0.75)
            fillOpacity = 0.24
        case .incorrect:
            stroke = Color.red.opacity(0.75)
            fillOpacity = 0.24
        case .disabled:
            stroke = Color.white.opacity(0.10)
            fillOpacity = 0.18
        }

        return content
            .cosmoCard(
                cornerRadius: 16,
                strokeColor: stroke,
                fillOpacity: fillOpacity
            )
            .opacity(state == .disabled ? 0.7 : 1)
    }
}

