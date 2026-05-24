import XCTest
@testable import Shoot

@MainActor
final class GameViewModelTests: XCTestCase {
    private var defaults: UserDefaults!
    private var store: SettingsStore!
    private var vm: GameViewModel!
    private let suiteName = "ShootTests.GameViewModel"

    override func setUp() async throws {
        try await super.setUp()
        defaults = UserDefaults(suiteName: suiteName)
        defaults.removePersistentDomain(forName: suiteName)
        store = SettingsStore(defaults: defaults)
        vm = GameViewModel(store: store)
    }

    override func tearDown() async throws {
        defaults.removePersistentDomain(forName: suiteName)
        vm = nil
        store = nil
        defaults = nil
        try await super.tearDown()
    }

    // MARK: - Initial state

    func testInitialStateIsIdle() {
        XCTAssertEqual(vm.phase, .idle)
        XCTAssertEqual(vm.countLabel, "")
        XCTAssertNil(vm.topChoice)
        XCTAssertNil(vm.botChoice)
        XCTAssertNil(vm.winner)
        XCTAssertEqual(vm.topScore, 0)
        XCTAssertEqual(vm.botScore, 0)
        XCTAssertFalse(vm.demoMode)
        XCTAssertFalse(vm.topHold)
        XCTAssertFalse(vm.botHold)
        XCTAssertFalse(vm.settingsOpen)
    }

    // MARK: - Hold gestures

    func testSetHoldUpdatesTheCorrectSide() {
        vm.setHold(.top, true)
        XCTAssertTrue(vm.topHold)
        XCTAssertFalse(vm.botHold)

        vm.setHold(.bot, true)
        XCTAssertTrue(vm.botHold)

        vm.setHold(.top, false)
        XCTAssertFalse(vm.topHold)
        XCTAssertTrue(vm.botHold)
    }

    // MARK: - Countdown gating

    func testHoldingBothInIdleAdvancesToCount() async {
        store.patch { $0.holdMs = 30 } // fast hold for test speed
        vm.setHold(.top, true)
        vm.setHold(.bot, true)
        try? await Task.sleep(nanoseconds: 100_000_000)
        XCTAssertEqual(vm.phase, .count, "Both halves held → countdown should begin")
    }

    func testHoldingOnlyOneSideDoesNotStartCountdown() async {
        store.patch { $0.holdMs = 30 }
        vm.setHold(.top, true)
        try? await Task.sleep(nanoseconds: 100_000_000)
        XCTAssertEqual(vm.phase, .idle)
    }

    func testReleasingDuringCountdownAbortsToIdle() async {
        store.patch { $0.holdMs = 30 }
        vm.setHold(.top, true)
        vm.setHold(.bot, true)
        try? await Task.sleep(nanoseconds: 100_000_000)
        XCTAssertEqual(vm.phase, .count)

        vm.setHold(.top, false)
        try? await Task.sleep(nanoseconds: 50_000_000)
        XCTAssertEqual(vm.phase, .idle, "Releasing a half during countdown must abort")
        XCTAssertEqual(vm.countLabel, "")
    }

    // MARK: - Reduce motion path

    func testReduceMotionSkipsCountdownLabels() async {
        store.patch { $0.reduceMotion = true; $0.holdMs = 20 }
        vm.setHold(.top, true)
        vm.setHold(.bot, true)
        // Hold(20) + reveal beat(280) + a generous buffer
        try? await Task.sleep(nanoseconds: 700_000_000)
        XCTAssertTrue(vm.phase == .reveal || vm.phase == .result,
                      "Reduce-motion should skip countdown labels and go straight to reveal")
        XCTAssertNotNil(vm.winner)
    }

    // MARK: - Demo mode

    func testRunDemoStartsCountdownWithoutUserHolding() async {
        store.patch { $0.holdMs = 30 }
        vm.runDemo()
        XCTAssertTrue(vm.demoMode)
        XCTAssertTrue(vm.topHold)
        XCTAssertTrue(vm.botHold)

        try? await Task.sleep(nanoseconds: 70_000_000)
        XCTAssertEqual(vm.phase, .count)
    }

    func testDemoCompletesAndStaysAtResultWithoutAutoReset() async {
        store.patch { $0.holdMs = 30; $0.reduceMotion = true }
        vm.runDemo()
        // hold(30) + reveal beat(280) + reveal->result(700) + slack
        try? await Task.sleep(nanoseconds: 1_500_000_000)

        XCTAssertEqual(vm.phase, .result, "Result must persist until user taps replay")
        XCTAssertFalse(vm.demoMode, "Demo mode should clear at reveal")
        XCTAssertFalse(vm.topHold,  "Synthetic holds should clear at reveal")
        XCTAssertFalse(vm.botHold)

        // Wait WELL past any old auto-reset window (was 2.2s)
        try? await Task.sleep(nanoseconds: 3_000_000_000)
        XCTAssertEqual(vm.phase, .result, "No timer must move us off result")
    }

    func testRunDemoIsNoOpDuringCountdown() async {
        store.patch { $0.holdMs = 20 }
        vm.runDemo()
        try? await Task.sleep(nanoseconds: 50_000_000)
        XCTAssertEqual(vm.phase, .count)

        let demoBefore = vm.demoMode
        vm.runDemo() // second call during count
        XCTAssertEqual(vm.demoMode, demoBefore, "runDemo() during non-idle phase must be ignored")
    }

    // MARK: - Reset semantics

    func testResetRoundClearsRevealStateButPreservesScores() async {
        store.patch { $0.holdMs = 20; $0.reduceMotion = true }
        vm.setHold(.top, true)
        vm.setHold(.bot, true)
        try? await Task.sleep(nanoseconds: 700_000_000)

        let topBefore = vm.topScore
        let botBefore = vm.botScore
        XCTAssertEqual(topBefore + botBefore, 1, "exactly one score should have incremented (noTies on)")

        vm.resetRound()
        XCTAssertEqual(vm.phase, .idle)
        XCTAssertNil(vm.topChoice)
        XCTAssertNil(vm.botChoice)
        XCTAssertNil(vm.winner)
        XCTAssertEqual(vm.countLabel, "")
        XCTAssertEqual(vm.topScore, topBefore)
        XCTAssertEqual(vm.botScore, botBefore)
    }

    func testResetScoresZerosAllScoresAndReturnsToIdle() async {
        store.patch { $0.holdMs = 20; $0.reduceMotion = true }
        vm.setHold(.top, true)
        vm.setHold(.bot, true)
        try? await Task.sleep(nanoseconds: 700_000_000)
        XCTAssertGreaterThan(vm.topScore + vm.botScore, 0)

        vm.resetScores()
        XCTAssertEqual(vm.topScore, 0)
        XCTAssertEqual(vm.botScore, 0)
        XCTAssertEqual(vm.phase, .idle)
        XCTAssertFalse(vm.demoMode)
        XCTAssertFalse(vm.topHold)
        XCTAssertFalse(vm.botHold)
    }

    // MARK: - No-ties enforcement

    func testNoTiesAlwaysProducesNonTieWinner() async {
        store.patch { $0.holdMs = 10; $0.reduceMotion = true; $0.noTies = true }
        for round in 0..<10 {
            vm.setHold(.top, true)
            vm.setHold(.bot, true)
            try? await Task.sleep(nanoseconds: 500_000_000)
            XCTAssertNotEqual(vm.winner, .tie,
                              "round \(round): noTies=true must reroll until non-tie")
            vm.resetRound()
            vm.setHold(.top, false)
            vm.setHold(.bot, false)
        }
    }

    // MARK: - outcome(for:)

    func testOutcomeForSideWhileNotInRevealReturnsNil() {
        vm.phase = .idle
        vm.winner = .top
        XCTAssertNil(vm.outcome(for: .top))
        XCTAssertNil(vm.outcome(for: .bot))
    }

    func testOutcomeForSideOnTopWinner() {
        vm.phase = .reveal
        vm.winner = .top
        XCTAssertEqual(vm.outcome(for: .top), .win)
        XCTAssertEqual(vm.outcome(for: .bot), .lose)
    }

    func testOutcomeForSideOnBotWinner() {
        vm.phase = .result
        vm.winner = .bot
        XCTAssertEqual(vm.outcome(for: .top), .lose)
        XCTAssertEqual(vm.outcome(for: .bot), .win)
    }

    func testOutcomeForSideOnTieIsTieForBoth() {
        vm.phase = .reveal
        vm.winner = .tie
        XCTAssertEqual(vm.outcome(for: .top), .tie)
        XCTAssertEqual(vm.outcome(for: .bot), .tie)
    }

    // MARK: - Settings sheet

    func testOpenAndCloseGearTracksSide() {
        vm.openGear(side: .top)
        XCTAssertTrue(vm.settingsOpen)
        XCTAssertEqual(vm.settingsSide, .top)

        vm.openGear(side: .bot)
        XCTAssertEqual(vm.settingsSide, .bot)
        XCTAssertTrue(vm.settingsOpen)

        vm.closeGear()
        XCTAssertFalse(vm.settingsOpen)
    }

    // MARK: - Review prompt (bottom-half winner only)
    //
    // The schedule function is exercised directly with a controlled state +
    // a short prompt delay, so these tests are deterministic and don't depend
    // on Choice.random producing a particular outcome.

    func testReviewPromptFiresAfterBotWinAndDelay() async {
        var count = 0
        vm.reviewRequester = { count += 1 }
        vm.reviewPromptDelay = 0.10
        vm.phase = .result
        vm.winner = .bot
        vm.scheduleReviewPromptIfApplicable(winner: .bot)
        try? await Task.sleep(nanoseconds: 250_000_000)
        XCTAssertEqual(count, 1, "bot win should fire one review prompt after the delay")
    }

    func testReviewPromptDoesNotFireForTopWin() async {
        var count = 0
        vm.reviewRequester = { count += 1 }
        vm.reviewPromptDelay = 0.10
        vm.phase = .result
        vm.winner = .top
        vm.scheduleReviewPromptIfApplicable(winner: .top)
        try? await Task.sleep(nanoseconds: 250_000_000)
        XCTAssertEqual(count, 0, "top win must not trigger review prompt")
    }

    func testReviewPromptDoesNotFireForTie() async {
        var count = 0
        vm.reviewRequester = { count += 1 }
        vm.reviewPromptDelay = 0.10
        vm.phase = .result
        vm.winner = .tie
        vm.scheduleReviewPromptIfApplicable(winner: .tie)
        try? await Task.sleep(nanoseconds: 250_000_000)
        XCTAssertEqual(count, 0, "tie must not trigger review prompt")
    }

    func testReviewPromptOnlyFiresOncePerSession() async {
        var count = 0
        vm.reviewRequester = { count += 1 }
        vm.reviewPromptDelay = 0.05
        vm.phase = .result
        vm.winner = .bot
        // First call fires.
        vm.scheduleReviewPromptIfApplicable(winner: .bot)
        try? await Task.sleep(nanoseconds: 150_000_000)
        XCTAssertEqual(count, 1)
        // Subsequent bot wins should not re-prompt.
        vm.scheduleReviewPromptIfApplicable(winner: .bot)
        try? await Task.sleep(nanoseconds: 150_000_000)
        XCTAssertEqual(count, 1, "second bot win in same session must not re-prompt")
    }

    func testReviewPromptCancelledByResetRound() async {
        var count = 0
        vm.reviewRequester = { count += 1 }
        vm.reviewPromptDelay = 0.20
        vm.phase = .result
        vm.winner = .bot
        vm.scheduleReviewPromptIfApplicable(winner: .bot)
        // Reset before the prompt fires.
        try? await Task.sleep(nanoseconds: 50_000_000)
        vm.resetRound()
        try? await Task.sleep(nanoseconds: 300_000_000)
        XCTAssertEqual(count, 0, "resetRound must cancel a pending prompt")
    }

    func testReviewPromptSkippedIfPhaseLeftResult() async {
        // Schedule a prompt, then manually transition the phase out of reveal/result
        // before the delay elapses.
        var count = 0
        vm.reviewRequester = { count += 1 }
        vm.reviewPromptDelay = 0.15
        vm.phase = .result
        vm.winner = .bot
        vm.scheduleReviewPromptIfApplicable(winner: .bot)
        try? await Task.sleep(nanoseconds: 50_000_000)
        vm.phase = .idle   // simulated navigation away
        try? await Task.sleep(nanoseconds: 250_000_000)
        XCTAssertEqual(count, 0, "leaving result screen must skip the prompt")
    }

    func testReviewPromptSkippedIfSettingsOpen() async {
        var count = 0
        vm.reviewRequester = { count += 1 }
        vm.reviewPromptDelay = 0.15
        vm.phase = .result
        vm.winner = .bot
        vm.settingsOpen = true
        vm.scheduleReviewPromptIfApplicable(winner: .bot)
        try? await Task.sleep(nanoseconds: 250_000_000)
        XCTAssertEqual(count, 0, "open settings sheet must skip the prompt")
    }

    // MARK: - Background tap is a no-op (regression guard)

    func testTapBackgroundDoesNotMutateState() async {
        store.patch { $0.holdMs = 20; $0.reduceMotion = true }
        vm.setHold(.top, true)
        vm.setHold(.bot, true)
        // hold(20) + reveal beat(280) + reveal→result(700) + slack
        try? await Task.sleep(nanoseconds: 1_300_000_000)
        XCTAssertEqual(vm.phase, .result)

        let scoreBefore = (vm.topScore, vm.botScore)
        let winnerBefore = vm.winner
        vm.tapBackground()
        XCTAssertEqual(vm.phase, .result, "background tap must NOT advance phase")
        XCTAssertEqual(vm.topScore, scoreBefore.0)
        XCTAssertEqual(vm.botScore, scoreBefore.1)
        XCTAssertEqual(vm.winner, winnerBefore)
    }
}
