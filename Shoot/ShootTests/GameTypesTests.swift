import XCTest
@testable import Shoot

final class GameTypesTests: XCTestCase {

    // judge() is the core game-logic function. Verify all 9 outcomes explicitly.
    func testJudgeAllNineCombinations() {
        XCTAssertEqual(judge(top: .rock,     bot: .rock),     .tie)
        XCTAssertEqual(judge(top: .rock,     bot: .paper),    .bot)
        XCTAssertEqual(judge(top: .rock,     bot: .scissors), .top)
        XCTAssertEqual(judge(top: .paper,    bot: .rock),     .top)
        XCTAssertEqual(judge(top: .paper,    bot: .paper),    .tie)
        XCTAssertEqual(judge(top: .paper,    bot: .scissors), .bot)
        XCTAssertEqual(judge(top: .scissors, bot: .rock),     .bot)
        XCTAssertEqual(judge(top: .scissors, bot: .paper),    .top)
        XCTAssertEqual(judge(top: .scissors, bot: .scissors), .tie)
    }

    // Labels feed into LocalizedStringKey lookups; ensure they match the catalog keys.
    func testChoiceLabelsAreLocalizedKeys() {
        XCTAssertEqual(Choice.rock.label,     "ROCK")
        XCTAssertEqual(Choice.paper.label,    "PAPER")
        XCTAssertEqual(Choice.scissors.label, "SCISSORS")
    }

    // Sanity-check the RNG: across many calls, every choice is hit.
    func testChoiceRandomCoversAllCases() {
        var seen: Set<Choice> = []
        for _ in 0..<300 { seen.insert(Choice.random()) }
        XCTAssertEqual(seen, Set(Choice.allCases))
    }

    // Roughly even distribution (not a strict statistical test, just a smell check).
    func testChoiceRandomRoughlyUniform() {
        var counts: [Choice: Int] = [.rock: 0, .paper: 0, .scissors: 0]
        let trials = 3000
        for _ in 0..<trials { counts[Choice.random(), default: 0] += 1 }
        for c in Choice.allCases {
            let observed = Double(counts[c]!) / Double(trials)
            // Each case should be within 5 percentage points of 33.3%
            XCTAssertEqual(observed, 1.0/3.0, accuracy: 0.05, "\(c) frequency off: \(observed)")
        }
    }
}
