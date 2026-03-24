import Foundation

// MARK: - Pending Upload Item

enum PendingUploadItem: Codable {
    case quizRun(QuizRunResult)
    case gameSession(GameSessionSnapshot)

    private enum CodingKey: String, Swift.CodingKey {
        case type, payload
    }

    private enum ItemType: String, Codable {
        case quizRun, gameSession
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKey.self)
        switch self {
        case .quizRun(let result):
            try container.encode(ItemType.quizRun, forKey: .type)
            try container.encode(result, forKey: .payload)
        case .gameSession(let snapshot):
            try container.encode(ItemType.gameSession, forKey: .type)
            try container.encode(snapshot, forKey: .payload)
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKey.self)
        let type = try container.decode(ItemType.self, forKey: .type)
        switch type {
        case .quizRun:
            let result = try container.decode(QuizRunResult.self, forKey: .payload)
            self = .quizRun(result)
        case .gameSession:
            let snapshot = try container.decode(GameSessionSnapshot.self, forKey: .payload)
            self = .gameSession(snapshot)
        }
    }
}

// MARK: - Queue Actor

actor SupabaseUploadQueue {
    static let shared = SupabaseUploadQueue()

    private let defaultsKey = "supabase.pendingUploads"
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private var isDraining = false

    private init() {}

    // MARK: - Enqueue

    func enqueue(_ item: PendingUploadItem) {
        var items = load()
        items.append(item)
        save(items)
#if DEBUG
        print("[UploadQueue] Enqueued item. Queue size: \(items.count)")
#endif
    }

    // MARK: - Drain

    func drain() async {
        guard !isDraining else { return }
        guard AuthSessionStore.shared.hasValidLogin else { return }

        let items = load()
        guard !items.isEmpty else { return }

        isDraining = true
        defer { isDraining = false }

#if DEBUG
        print("[UploadQueue] Draining \(items.count) pending item(s).")
#endif

        var remaining: [PendingUploadItem] = []

        for item in items {
            do {
                try await upload(item)
#if DEBUG
                print("[UploadQueue] Item uploaded successfully.")
#endif
            } catch {
                remaining.append(item)
#if DEBUG
                print("[UploadQueue] Item upload failed, keeping in queue: \(error.localizedDescription)")
#endif
            }
        }

        save(remaining)
    }

    // MARK: - Private

    private func upload(_ item: PendingUploadItem) async throws {
        switch item {
        case .quizRun(let result):
            try await SupabaseQuizSyncService.shared.uploadQuizRun(result, enqueueOnFailure: false)
        case .gameSession(let snapshot):
            try await SupabaseGameSyncService.shared.uploadGameSession(snapshot, enqueueOnFailure: false)
        }
    }

    private func load() -> [PendingUploadItem] {
        guard
            let data = UserDefaults.standard.data(forKey: defaultsKey),
            let items = try? decoder.decode([PendingUploadItem].self, from: data)
        else { return [] }
        return items
    }

    private func save(_ items: [PendingUploadItem]) {
        if let data = try? encoder.encode(items) {
            UserDefaults.standard.set(data, forKey: defaultsKey)
        }
    }
}
