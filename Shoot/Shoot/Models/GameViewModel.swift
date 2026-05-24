import SwiftUI
import Combine

@MainActor
final class GameViewModel: ObservableObject {
    @Published var phase: Phase = .idle
    @Published var countLabel: String = ""

    @Published var topHold: Bool = false
    @Published var botHold: Bool = false

    @Published var topChoice: Choice? = nil
    @Published var botChoice: Choice? = nil
    @Published var winner: Winner? = nil

    @Published var topScore: Int = 0
    @Published var botScore: Int = 0

    @Published var demoMode: Bool = false

    @Published var settingsOpen: Bool = false
    @Published var settingsSide: Side = .bot

    private let store: SettingsStore
    private var cancellables: Set<AnyCancellable> = []
    private var holdGateTask: Task<Void, Never>?
    private var sequenceTask: Task<Void, Never>?
    private var revealHoldTask: Task<Void, Never>?

    init(store: SettingsStore) {
        self.store = store

        Publishers.CombineLatest3($topHold, $botHold, $phase)
            .sink { [weak self] top, bot, phase in
                guard let self else { return }
                if phase == .idle && top && bot {
                    self.startHoldGate()
                } else {
                    self.holdGateTask?.cancel()
                    self.holdGateTask = nil
                }
                if phase == .count && !(top && bot) && !self.demoMode {
                    self.sequenceTask?.cancel()
                    self.sequenceTask = nil
                    self.countLabel = ""
                    self.phase = .idle
                }
            }
            .store(in: &cancellables)
    }

    var settings: GameSettings { store.value }

    func setHold(_ side: Side, _ value: Bool) {
        switch side {
        case .top: topHold = value
        case .bot: botHold = value
        }
        if value {
            Haptics.tap(settings.haptics, style: .light)
        }
    }

    private func startHoldGate() {
        holdGateTask?.cancel()
        let delay = settings.holdMs
        holdGateTask = Task { [weak self] in
            do {
                try await Task.sleep(nanoseconds: UInt64(delay) * 1_000_000)
            } catch { return }
            guard let self else { return }
            guard self.phase == .idle, (self.topHold && self.botHold) else { return }
            self.startCountdown()
        }
    }

    private func startCountdown() {
        sequenceTask?.cancel()
        phase = .count
        Haptics.tap(settings.haptics, style: .light)

        // Reduce motion: skip the ROCK/PAPER/SCISSORS sequence entirely and reveal after a short beat.
        if settings.reduceMotion {
            sequenceTask = Task { [weak self] in
                guard let self else { return }
                do { try await Task.sleep(nanoseconds: 280_000_000) } catch { return }
                if Task.isCancelled { return }
                await MainActor.run {
                    Haptics.tap(self.settings.haptics, style: .medium)
                    Sound.reveal(self.settings.sounds)
                }
                await self.doReveal()
            }
            return
        }

        let labels = ["ROCK", "PAPER", "SCISSORS"]
        let step = 520
        sequenceTask = Task { [weak self] in
            guard let self else { return }
            for (i, label) in labels.enumerated() {
                if Task.isCancelled { return }
                await MainActor.run {
                    self.countLabel = label
                    Haptics.tap(self.settings.haptics, style: .light)
                    Sound.tick(self.settings.sounds, i)
                }
                do {
                    try await Task.sleep(nanoseconds: UInt64(step) * 1_000_000)
                } catch { return }
            }
            if Task.isCancelled { return }
            await MainActor.run {
                Haptics.tap(self.settings.haptics, style: .medium)
                Sound.reveal(self.settings.sounds)
            }
            await self.doReveal()
        }
    }

    private func doReveal() async {
        var a = Choice.random()
        var b = Choice.random()
        var outcome = judge(top: a, bot: b)
        if settings.noTies {
            var guardCount = 0
            while outcome == .tie && guardCount < 20 {
                a = Choice.random()
                b = Choice.random()
                outcome = judge(top: a, bot: b)
                guardCount += 1
            }
        }

        topChoice = a
        botChoice = b
        winner = outcome
        phase = .reveal
        Haptics.notify(settings.haptics, .success)
        switch outcome {
        case .tie:       Sound.tie(settings.sounds)
        case .top, .bot: Sound.win(settings.sounds)
        }

        if outcome == .top { topScore += 1 }
        else if outcome == .bot { botScore += 1 }

        // Demo ends at reveal. Clear synthetic holds so the result screen behaves like a real round
        // (persists until the user taps the ⟳ replay button — no auto-reset).
        if demoMode {
            demoMode = false
            topHold = false
            botHold = false
        }

        revealHoldTask?.cancel()
        revealHoldTask = Task { [weak self] in
            do { try await Task.sleep(nanoseconds: 700_000_000) } catch { return }
            guard let self else { return }
            if Task.isCancelled { return }
            await MainActor.run { self.phase = .result }
        }
    }

    func resetRound() {
        sequenceTask?.cancel()
        revealHoldTask?.cancel()
        phase = .idle
        topChoice = nil
        botChoice = nil
        winner = nil
        countLabel = ""
    }

    func resetScores() {
        sequenceTask?.cancel()
        revealHoldTask?.cancel()
        topScore = 0
        botScore = 0
        demoMode = false
        topHold = false
        botHold = false
        resetRound()
    }

    func runDemo() {
        guard phase == .idle, !demoMode else { return }
        demoMode = true
        topHold = true
        botHold = true
    }

    func openGear(side: Side) {
        settingsSide = side
        settingsOpen = true
    }

    func closeGear() { settingsOpen = false }

    func tapBackground() {
        // No-op: round only resets via the ⟳ replay button.
    }

    func outcome(for side: Side) -> Outcome? {
        guard phase == .reveal || phase == .result else { return nil }
        guard let winner else { return nil }
        if winner == .tie { return .tie }
        return ((winner == .top && side == .top) || (winner == .bot && side == .bot))
            ? .win : .lose
    }
}
