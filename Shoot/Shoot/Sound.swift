import AVFoundation

@MainActor
final class SoundEngine {
    static let shared = SoundEngine()

    private let engine = AVAudioEngine()
    private let player = AVAudioPlayerNode()
    private let format: AVAudioFormat
    private var started = false

    private init() {
        self.format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1)!
        engine.attach(player)
        engine.connect(player, to: engine.mainMixerNode, format: format)
    }

    func ensure() {
        guard !started else { return }
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)
            try engine.start()
            player.play()
            started = true
        } catch {
            // Audio not available — sounds become no-ops.
        }
    }

    private func buffer(freqs: [Float], duration: Double, volume: Float) -> AVAudioPCMBuffer? {
        let sr = format.sampleRate
        let frameCount = max(1, AVAudioFrameCount(duration * sr))
        guard let buf = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else { return nil }
        buf.frameLength = frameCount
        let ch = buf.floatChannelData![0]
        let twoPi = 2 * Float.pi
        let fade = min(Int(0.012 * sr), Int(frameCount) / 6)
        let n = Int(frameCount)
        for i in 0..<n {
            let t = Float(i) / Float(sr)
            var s: Float = 0
            for f in freqs { s += sin(twoPi * f * t) }
            s /= Float(max(1, freqs.count))
            var env: Float = 1
            if i < fade { env = Float(i) / Float(fade) }
            else if i > n - fade { env = Float(n - i) / Float(fade) }
            ch[i] = s * volume * env
        }
        return buf
    }

    func play(_ freqs: [Float], duration: Double, volume: Float = 0.4) {
        ensure()
        guard started, let buf = buffer(freqs: freqs, duration: duration, volume: volume) else { return }
        player.scheduleBuffer(buf, at: nil, options: [], completionHandler: nil)
    }

    func playSequence(_ notes: [(freqs: [Float], duration: Double)], volume: Float = 0.4) {
        ensure()
        guard started else { return }
        for note in notes {
            if let buf = buffer(freqs: note.freqs, duration: note.duration, volume: volume) {
                player.scheduleBuffer(buf, at: nil, options: [], completionHandler: nil)
            }
        }
    }
}

@MainActor
enum Sound {
    /// Countdown tick for ROCK / PAPER / SCISSORS — ascending pitches.
    static func tick(_ enabled: Bool, _ index: Int) {
        guard enabled else { return }
        let freqs: [Float] = [392, 494, 587] // G4, B4, D5
        SoundEngine.shared.play([freqs[min(max(0, index), 2)]], duration: 0.08, volume: 0.30)
    }

    /// Played on the reveal beat (where "SHOOT!" used to be).
    static func reveal(_ enabled: Bool) {
        guard enabled else { return }
        SoundEngine.shared.play([523, 659, 784], duration: 0.18, volume: 0.40) // C-E-G major chord
    }

    /// Bright ascending arpeggio on win.
    static func win(_ enabled: Bool) {
        guard enabled else { return }
        SoundEngine.shared.playSequence([
            ([523],         0.10),
            ([659],         0.10),
            ([784],         0.10),
            ([1047, 1319],  0.28),
        ], volume: 0.40)
    }

    /// Descending minor on lose.
    static func lose(_ enabled: Bool) {
        guard enabled else { return }
        SoundEngine.shared.playSequence([
            ([440], 0.12),
            ([370], 0.12),
            ([311], 0.28),
        ], volume: 0.30)
    }

    /// Neutral single tone on tie.
    static func tie(_ enabled: Bool) {
        guard enabled else { return }
        SoundEngine.shared.play([587], duration: 0.22, volume: 0.30)
    }

    /// Subtle UI click for button taps.
    static func ui(_ enabled: Bool) {
        guard enabled else { return }
        SoundEngine.shared.play([1200], duration: 0.03, volume: 0.20)
    }
}
