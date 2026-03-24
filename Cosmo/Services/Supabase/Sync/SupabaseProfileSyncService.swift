import Foundation

struct RemoteProfile: Decodable {
    let id: String
    let displayName: String?
    let avatarURL: String?
    let timezone: String?

    enum CodingKeys: String, CodingKey {
        case id
        case displayName = "display_name"
        case avatarURL = "avatar_url"
        case timezone
    }
}

private struct RemoteProfileUpsertPayload: Encodable {
    let id: String
    let displayName: String?
    let timezone: String
    let updatedAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case displayName = "display_name"
        case timezone
        case updatedAt = "updated_at"
    }
}

final class SupabaseProfileSyncService {
    static let shared = SupabaseProfileSyncService()

    private let client = SupabaseRESTClient.shared
    private let encoder = JSONEncoder()

    private init() {}

    func upsertCurrentProfile(displayName: String?) async throws {
        guard let userId = AuthSessionStore.shared.currentUserId else {
            throw SupabaseRESTError.notAuthenticated
        }

        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        let trimmedName = displayName?.trimmingCharacters(in: .whitespacesAndNewlines)
        let payload = RemoteProfileUpsertPayload(
            id: userId,
            displayName: trimmedName?.isEmpty == true ? nil : trimmedName,
            timezone: TimeZone.current.identifier,
            updatedAt: isoFormatter.string(from: Date())
        )

        let body = try encoder.encode(payload)

        try await client.post(
            "profiles",
            queryItems: [URLQueryItem(name: "on_conflict", value: "id")],
            jsonBody: body,
            prefer: "resolution=merge-duplicates"
        )
    }

    func fetchCurrentProfile() async throws -> RemoteProfile? {
        guard let userId = AuthSessionStore.shared.currentUserId else {
            throw SupabaseRESTError.notAuthenticated
        }

        let rows: [RemoteProfile] = try await client.get(
            "profiles",
            queryItems: [
                URLQueryItem(name: "select", value: "id,display_name,avatar_url,timezone"),
                URLQueryItem(name: "id", value: "eq.\(userId)"),
                URLQueryItem(name: "limit", value: "1")
            ],
            as: [RemoteProfile].self
        )

        return rows.first
    }
}
