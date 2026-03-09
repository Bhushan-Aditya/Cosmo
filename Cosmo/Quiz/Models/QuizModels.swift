import SwiftUI

enum QuizDifficulty: String, Codable, CaseIterable, Comparable {
    case easy
    case medium
    case hard

    var sortOrder: Int {
        switch self {
        case .easy: return 0
        case .medium: return 1
        case .hard: return 2
        }
    }

    static func < (lhs: QuizDifficulty, rhs: QuizDifficulty) -> Bool {
        lhs.sortOrder < rhs.sortOrder
    }
}

struct QuizCategory: Identifiable, Hashable {
    let id: String
    let title: String
    let subtitle: String
    let systemImage: String
    let accent: Accent

    enum Accent: String, Codable, CaseIterable, Hashable {
        case orange
        case cyan
        case purple
        case green
        case yellow
        case pink
        case blue
        case mint
        case gray

        var color: Color {
            switch self {
            case .orange: return .orange
            case .cyan: return .cyan
            case .purple: return .purple
            case .green: return .green
            case .yellow: return .yellow
            case .pink: return .pink
            case .blue: return .blue
            case .mint: return .mint
            case .gray: return .gray
            }
        }
    }
}

struct QuizQuestion: Identifiable, Codable, Hashable {
    let id: String
    let categoryId: String
    let difficulty: QuizDifficulty
    let prompt: String
    let choices: [String]
    let correctIndex: Int
    let explanation: String
    let sources: [String]
}

struct QuizQuestionBank: Codable, Equatable {
    let questions: [QuizQuestion]
}

