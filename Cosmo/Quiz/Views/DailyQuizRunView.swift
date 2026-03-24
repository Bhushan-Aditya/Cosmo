import SwiftUI

struct DailyQuizRunView: View {
    let attemptResponse: DailyAttemptStartResponse

    @Environment(\.dismiss) private var dismiss

    // Question navigation
    @State private var currentIndex: Int = 0
    @State private var selectedIndex: Int? = nil

    // Timer
    @State private var secondsLeft: Int = 30
    @State private var timer: Timer? = nil
    @State private var questionStartTime: Date = Date()

    // Answer collection
    @State private var collectedAnswers: [DailyAnswerPayload] = []

    // Submission
    @State private var isSubmitting: Bool = false
    @State private var submissionError: String? = nil
    @State private var result: DailyAttemptResult? = nil
    @State private var showResults: Bool = false

    private var questions: [DailyQuizQuestion] { attemptResponse.questions }

    private var currentQuestion: DailyQuizQuestion? {
        questions.indices.contains(currentIndex) ? questions[currentIndex] : nil
    }

    private var isLastQuestion: Bool { currentIndex >= questions.count - 1 }

    var body: some View {
        ZStack {
            CosmoAnimatedBackground()

            VStack(spacing: 14) {
                header

                if let q = currentQuestion {
                    questionCard(q)
                    answersList(q)
                } else if isSubmitting {
                    submittingCard
                } else if let error = submissionError {
                    errorCard(error)
                }

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 18)
        }
        .onAppear { startTimer() }
        .onDisappear { stopTimer() }
        .preferredColorScheme(.dark)
        .navigationTitle("Daily Quiz")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Exit") { stopTimer(); dismiss() }
                    .foregroundColor(.white.opacity(0.85))
            }
        }
        .navigationDestination(isPresented: $showResults) {
            if let result {
                DailyQuizResultsView(
                    result: result,
                    questions: questions
                )
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Question \(currentIndex + 1)/\(questions.count)")
                    .font(.footnote.weight(.semibold))
                    .foregroundColor(.white.opacity(0.75))

                Spacer()

                // Countdown ring + number
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.15), lineWidth: 3)
                    Circle()
                        .trim(from: 0, to: CGFloat(secondsLeft) / 30.0)
                        .stroke(timerColor, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 1), value: secondsLeft)
                    Text("\(secondsLeft)")
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .foregroundColor(timerColor)
                }
                .frame(width: 38, height: 38)
            }

            ProgressView(value: Double(currentIndex) / Double(max(questions.count - 1, 1)))
                .tint(.purple)
        }
        .padding(14)
        .cosmoCard()
    }

    private var timerColor: Color {
        if secondsLeft > 15 { return .green }
        if secondsLeft > 8  { return .yellow }
        return .red
    }

    // MARK: - Question card

    private func questionCard(_ q: DailyQuizQuestion) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                difficultyPill(q.difficulty)
                Spacer()
                Text("Attempt \(attemptResponse.attemptNo)")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.white.opacity(0.45))
            }

            Text(q.prompt)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .cosmoCard(cornerRadius: 22)
    }

    // MARK: - Answers list

    private func answersList(_ q: DailyQuizQuestion) -> some View {
        VStack(spacing: 10) {
            ForEach(q.options.indices, id: \.self) { idx in
                DailyAnswerRow(
                    title: q.options[idx],
                    isSelected: selectedIndex == idx,
                    isLocked: selectedIndex != nil
                )
                .onTapGesture {
                    guard selectedIndex == nil else { return }
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                        selectedIndex = idx
                    }
                    stopTimer()
                    // Brief delay so the selection state is visible before advancing
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                        commitAndAdvance(question: q, chosenIndex: idx)
                    }
                }
            }
        }
    }

    // MARK: - State cards

    private var submittingCard: some View {
        VStack(spacing: 14) {
            ProgressView()
                .tint(.white)
                .scaleEffect(1.3)
            Text("Submitting your answers…")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.75))
        }
        .frame(maxWidth: .infinity)
        .padding(30)
        .cosmoCard()
    }

    private func errorCard(_ message: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Submission failed", systemImage: "exclamationmark.triangle.fill")
                .font(.headline)
                .foregroundColor(.red)
            Text(message)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.75))
            Button("Retry") { retrySubmit() }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.purple.opacity(0.8))
                .cornerRadius(14)
        }
        .padding(16)
        .cosmoCard()
    }

    // MARK: - Timer logic

    private func startTimer() {
        secondsLeft = 30
        questionStartTime = Date()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if secondsLeft > 0 {
                secondsLeft -= 1
            } else {
                // Timer expired — record as unanswered and advance
                if let q = currentQuestion {
                    commitAndAdvance(question: q, chosenIndex: nil)
                }
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func resetTimer() {
        stopTimer()
        secondsLeft = 30
        questionStartTime = Date()
        selectedIndex = nil
        startTimer()
    }

    // MARK: - Answer commit + advance

    private func commitAndAdvance(question: DailyQuizQuestion, chosenIndex: Int?) {
        stopTimer()
        let elapsed = min(30.0, Date().timeIntervalSince(questionStartTime))
        let responseSeconds = chosenIndex == nil ? 30.0 : elapsed

        collectedAnswers.append(
            DailyAnswerPayload(
                questionId: question.id,
                selectedIndex: chosenIndex,
                responseSeconds: responseSeconds
            )
        )

        if isLastQuestion {
            submitAll()
        } else {
            currentIndex += 1
            resetTimer()
        }
    }

    // MARK: - Submission

    private func submitAll() {
        isSubmitting = true
        submissionError = nil
        Task {
            do {
                let res = try await SupabaseDailyQuizService.shared.submitAttempt(
                    attemptId: attemptResponse.attemptId,
                    answers: collectedAnswers
                )
                await MainActor.run {
                    isSubmitting = false
                    result = res
                    showResults = true
                }
            } catch {
                await MainActor.run {
                    isSubmitting = false
                    submissionError = error.localizedDescription
                }
            }
        }
    }

    private func retrySubmit() {
        submitAll()
    }

    // MARK: - Helpers

    private func difficultyPill(_ difficulty: String) -> some View {
        let color: Color = {
            switch difficulty {
            case "easy":   return .green
            case "medium": return .yellow
            case "hard":   return .red
            default:       return .white
            }
        }()
        return Text(difficulty.capitalized)
            .font(.caption.weight(.semibold))
            .foregroundColor(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Color.white.opacity(0.08))
            .cornerRadius(10)
    }
}

// MARK: - Daily Answer Row

private struct DailyAnswerRow: View {
    let title: String
    let isSelected: Bool
    let isLocked: Bool

    var body: some View {
        Text(title)
            .font(.subheadline.weight(.semibold))
            .foregroundColor(.white)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 14)
            .padding(.vertical, 13)
            .cosmoCard(
                cornerRadius: 16,
                strokeColor: isSelected ? Color.purple.opacity(0.75) : Color.white.opacity(0.14),
                fillOpacity: isSelected ? 0.30 : 0.22
            )
            .opacity(isLocked && !isSelected ? 0.65 : 1)
            .scaleEffect(isSelected ? 1.015 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}
