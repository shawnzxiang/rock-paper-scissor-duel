import SwiftUI

/// Lightweight confetti using TimelineView so animation starts on first frame.
struct ConfettiView: View {
    private struct Bit {
        let x: CGFloat      // 0–1 fraction of width
        let phase: Double   // animation phase offset
        let speed: Double   // seconds per cycle
        let drift: CGFloat  // horizontal sway amplitude (fraction)
        let rotationRate: Double
        let baseRotation: Double
        let color: Color
        let size: CGFloat
        let kind: Int       // 0 = rounded square, 1 = circle
    }

    private let bits: [Bit]
    private let start = Date()

    init() {
        var rng = SystemRandomNumberGenerator()
        let palette: [Color] = [
            Color(hex: 0xFFD66E), Color(hex: 0xFF6B9D), Color(hex: 0x3FD1C4),
            Color(hex: 0xFFAE3A), .white, Color(hex: 0x9B7BFF),
        ]
        self.bits = (0..<16).map { i in
            Bit(
                x: CGFloat.random(in: 0.05...0.95, using: &rng),
                phase: Double.random(in: 0...3.5, using: &rng),
                speed: Double.random(in: 2.4...3.8, using: &rng),
                drift: CGFloat.random(in: 0.04...0.12, using: &rng),
                rotationRate: Double.random(in: 200...420, using: &rng),
                baseRotation: Double.random(in: 0...360, using: &rng),
                color: palette[i % palette.count],
                size: CGFloat.random(in: 14...24, using: &rng),
                kind: i % 2
            )
        }
    }

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 60.0, paused: false)) { tl in
            let t = tl.date.timeIntervalSince(start)
            GeometryReader { geo in
                Canvas { ctx, size in
                    for bit in bits {
                        // progress 0→1, then repeats
                        let p = ((t + bit.phase) / bit.speed).truncatingRemainder(dividingBy: 1)
                        // start below the screen, drift up
                        let y = size.height * (1.1 - CGFloat(p) * 1.3)
                        let sway = sin((t + bit.phase) * 2.4) * bit.drift * size.width
                        let x = bit.x * size.width + sway
                        let rot = bit.baseRotation + bit.rotationRate * t
                        // fade in / out at edges of cycle
                        let alpha: Double = {
                            if p < 0.08 { return p / 0.08 }
                            if p > 0.85 { return max(0, (1 - p) / 0.15) }
                            return 1
                        }()

                        var sub = ctx
                        sub.translateBy(x: x, y: y)
                        sub.rotate(by: .degrees(rot))
                        sub.opacity = alpha

                        let rect = CGRect(x: -bit.size/2, y: -bit.size/2,
                                          width: bit.size, height: bit.size)
                        let path: Path = bit.kind == 0
                            ? Path(roundedRect: rect, cornerRadius: 3)
                            : Path(ellipseIn: rect)
                        sub.fill(path, with: .color(bit.color))
                        sub.stroke(path, with: .color(.ink),
                                   style: StrokeStyle(lineWidth: 2, lineJoin: .round))
                    }
                }
                .frame(width: geo.size.width, height: geo.size.height)
            }
        }
        .allowsHitTesting(false)
    }
}
