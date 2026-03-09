import Foundation

@MainActor
final class QuizDataStore: ObservableObject {
    @Published private(set) var bank: QuizQuestionBank?
    @Published private(set) var loadError: QuizRepositoryError?

    private let repository: QuizRepository

    init(repository: QuizRepository = .shared) {
        self.repository = repository
    }

    var categories: [QuizCategory] { repository.categories }

    func loadIfNeeded() {
        guard bank == nil, loadError == nil else { return }
        do {
            bank = try repository.loadQuestionBank()
        } catch let error as QuizRepositoryError {
            loadError = error
        } catch {
            loadError = .decodeFailed(error.localizedDescription)
        }
    }

    func questions(for categoryId: String) -> [QuizQuestion] {
        guard let bank else { return [] }
        return repository.questions(for: categoryId, in: bank)
    }
}

