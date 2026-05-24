import SwiftUI

enum HandPaths {
    static let referenceSize: CGFloat = 120
    static let palmY: CGFloat = 60

    static var rockOutline: Path {
        var p = Path()
        p.move(to: CGPoint(x: 22, y: 72))
        p.addQuadCurve(to: CGPoint(x: 41, y: 72), control: CGPoint(x: 31.5, y: 36))
        p.addQuadCurve(to: CGPoint(x: 60, y: 72), control: CGPoint(x: 50.5, y: 28))
        p.addQuadCurve(to: CGPoint(x: 79, y: 72), control: CGPoint(x: 69.5, y: 28))
        p.addQuadCurve(to: CGPoint(x: 98, y: 72), control: CGPoint(x: 88.5, y: 40))
        p.addLine(to: CGPoint(x: 98, y: 92))
        p.addQuadCurve(to: CGPoint(x: 84, y: 110), control: CGPoint(x: 98, y: 110))
        p.addLine(to: CGPoint(x: 36, y: 110))
        p.addQuadCurve(to: CGPoint(x: 22, y: 92), control: CGPoint(x: 22, y: 110))
        p.addLine(to: CGPoint(x: 22, y: 86))
        p.addQuadCurve(to: CGPoint(x: 12, y: 76), control: CGPoint(x: 10, y: 84))
        p.addQuadCurve(to: CGPoint(x: 22, y: 72), control: CGPoint(x: 14, y: 68))
        p.closeSubpath()
        return p
    }

    static let rockKnuckles: [(CGPoint, CGPoint)] = [
        (CGPoint(x: 26, y: 64), CGPoint(x: 37, y: 64)),
        (CGPoint(x: 45, y: 60), CGPoint(x: 56, y: 60)),
        (CGPoint(x: 64, y: 60), CGPoint(x: 75, y: 60)),
        (CGPoint(x: 83, y: 64), CGPoint(x: 94, y: 64)),
    ]

    static var paperThumb: Path {
        var p = Path()
        p.move(to: CGPoint(x: 14, y: 92))
        p.addQuadCurve(to: CGPoint(x: 8, y: 64), control: CGPoint(x: 2, y: 80))
        p.addLine(to: CGPoint(x: 18, y: 52))
        p.addQuadCurve(to: CGPoint(x: 34, y: 54), control: CGPoint(x: 26, y: 42))
        p.addLine(to: CGPoint(x: 34, y: 80))
        p.addQuadCurve(to: CGPoint(x: 22, y: 96), control: CGPoint(x: 34, y: 94))
        p.addQuadCurve(to: CGPoint(x: 14, y: 92), control: CGPoint(x: 14, y: 98))
        p.closeSubpath()
        return p
    }

    static var palm: Path {
        var p = Path()
        p.move(to: CGPoint(x: 28, y: palmY))
        p.addLine(to: CGPoint(x: 28, y: 92))
        p.addQuadCurve(to: CGPoint(x: 44, y: 108), control: CGPoint(x: 28, y: 108))
        p.addLine(to: CGPoint(x: 76, y: 108))
        p.addQuadCurve(to: CGPoint(x: 92, y: 92), control: CGPoint(x: 92, y: 108))
        p.addLine(to: CGPoint(x: 92, y: palmY))
        p.closeSubpath()
        return p
    }

    static var scissorsThumb: Path {
        var p = Path()
        p.move(to: CGPoint(x: 58, y: 64))
        p.addQuadCurve(to: CGPoint(x: 82, y: 58), control: CGPoint(x: 68, y: 56))
        p.addQuadCurve(to: CGPoint(x: 92, y: 72), control: CGPoint(x: 94, y: 60))
        p.addQuadCurve(to: CGPoint(x: 78, y: 80), control: CGPoint(x: 88, y: 80))
        p.addLine(to: CGPoint(x: 66, y: 80))
        p.addQuadCurve(to: CGPoint(x: 58, y: 64), control: CGPoint(x: 54, y: 80))
        p.closeSubpath()
        return p
    }

    /// Vertical finger pointing up from the palm line. `tipY` = how high the tip reaches (small = tall finger).
    /// Cap is a semicircle bulging upward (smaller y).
    static func finger(x: CGFloat, w: CGFloat, tipY: CGFloat, angle: CGFloat = 0) -> Path {
        let ry = tipY + w / 2
        let cx = x + w / 2
        var p = Path()
        p.move(to: CGPoint(x: x, y: palmY))
        p.addLine(to: CGPoint(x: x, y: ry))

        let r = w / 2
        let segments = 18
        for i in 1...segments {
            let t = CGFloat(i) / CGFloat(segments)
            let theta = CGFloat.pi - CGFloat.pi * t
            let px = cx + r * cos(theta)
            let py = ry - r * sin(theta)
            p.addLine(to: CGPoint(x: px, y: py))
        }

        p.addLine(to: CGPoint(x: x + w, y: palmY))
        p.closeSubpath()

        if angle != 0 {
            let rad = angle * .pi / 180
            var t = CGAffineTransform.identity
            t = t.translatedBy(x: cx, y: palmY)
            t = t.rotated(by: rad)
            t = t.translatedBy(x: -cx, y: -palmY)
            p = p.applying(t)
        }
        return p
    }
}
