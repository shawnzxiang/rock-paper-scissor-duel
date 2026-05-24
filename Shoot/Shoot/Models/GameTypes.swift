import Foundation

enum Choice: String, CaseIterable, Codable {
    case rock, paper, scissors

    var label: String {
        switch self {
        case .rock:     return "ROCK"
        case .paper:    return "PAPER"
        case .scissors: return "SCISSORS"
        }
    }

    static func random() -> Choice {
        Self.allCases.randomElement() ?? .rock
    }
}

enum Winner {
    case top, bot, tie
}

enum Outcome {
    case win, lose, tie
}

enum Phase {
    case idle, count, reveal, result
}

enum MatchResult {
    case won, lost
}

enum Side {
    case top, bot
}

private let beats: [Choice: Choice] = [
    .rock:     .scissors,
    .paper:    .rock,
    .scissors: .paper,
]

func judge(top: Choice, bot: Choice) -> Winner {
    if top == bot { return .tie }
    return beats[top] == bot ? .top : .bot
}
