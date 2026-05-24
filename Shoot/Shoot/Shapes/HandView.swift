import SwiftUI

struct HandView: View {
    let kind: Choice
    var size: CGFloat = 200
    var fill: Color? = nil   // override; otherwise reads from environment
    var stroke: Color = .ink
    var strokeWidth: CGFloat = 5
    var shadow: Bool = true

    @Environment(\.paletteHandFill) private var envFill

    var body: some View {
        let actualFill = fill ?? envFill
        Canvas { ctx, canvasSize in
            let s = min(canvasSize.width, canvasSize.height) / HandPaths.referenceSize
            let dx = (canvasSize.width - HandPaths.referenceSize * s) / 2
            let dy = (canvasSize.height - HandPaths.referenceSize * s) / 2
            ctx.translateBy(x: dx, y: dy)
            ctx.scaleBy(x: s, y: s)

            switch kind {
            case .rock:     drawRock(in: &ctx, fill: actualFill)
            case .paper:    drawPaper(in: &ctx, fill: actualFill)
            case .scissors: drawScissors(in: &ctx, fill: actualFill)
            }
        }
        .frame(width: size, height: size)
        .modifier(HandShadowModifier(enabled: shadow))
    }

    private func strokeAndFill(_ ctx: inout GraphicsContext, _ path: Path, fill: Color) {
        ctx.fill(path, with: .color(fill))
        ctx.stroke(path, with: .color(stroke),
                   style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round, lineJoin: .round))
    }

    private func drawRock(in ctx: inout GraphicsContext, fill: Color) {
        strokeAndFill(&ctx, HandPaths.rockOutline, fill: fill)
        for (a, b) in HandPaths.rockKnuckles {
            var p = Path()
            p.move(to: a); p.addLine(to: b)
            ctx.stroke(p, with: .color(stroke),
                       style: StrokeStyle(lineWidth: 3.5, lineCap: .round))
        }
        var nail = Path()
        nail.move(to: CGPoint(x: 13, y: 76))
        nail.addQuadCurve(to: CGPoint(x: 11, y: 81), control: CGPoint(x: 10, y: 77))
        nail.addQuadCurve(to: CGPoint(x: 13, y: 76), control: CGPoint(x: 14, y: 80))
        nail.closeSubpath()
        ctx.fill(nail, with: .color(Color.ink.opacity(0.22)))
    }

    private func drawPaper(in ctx: inout GraphicsContext, fill: Color) {
        strokeAndFill(&ctx, HandPaths.paperThumb, fill: fill)
        strokeAndFill(&ctx, HandPaths.finger(x: 33, w: 12, tipY: 10, angle: -8), fill: fill)
        strokeAndFill(&ctx, HandPaths.finger(x: 47, w: 12, tipY: 6,  angle: -2), fill: fill)
        strokeAndFill(&ctx, HandPaths.finger(x: 61, w: 12, tipY: 8,  angle:  3), fill: fill)
        strokeAndFill(&ctx, HandPaths.finger(x: 75, w: 12, tipY: 20, angle: 11), fill: fill)
        strokeAndFill(&ctx, HandPaths.palm, fill: fill)
    }

    private func drawScissors(in ctx: inout GraphicsContext, fill: Color) {
        strokeAndFill(&ctx, HandPaths.finger(x: 32, w: 12, tipY: 8, angle: -16), fill: fill)
        strokeAndFill(&ctx, HandPaths.finger(x: 48, w: 12, tipY: 8, angle:  16), fill: fill)
        strokeAndFill(&ctx, HandPaths.finger(x: 65, w: 11, tipY: 50, angle: 0), fill: fill)
        strokeAndFill(&ctx, HandPaths.finger(x: 78, w: 11, tipY: 50, angle: 0), fill: fill)
        strokeAndFill(&ctx, HandPaths.palm, fill: fill)
        strokeAndFill(&ctx, HandPaths.scissorsThumb, fill: fill)
    }
}

private struct HandShadowModifier: ViewModifier {
    let enabled: Bool
    func body(content: Content) -> some View {
        if enabled {
            content.shadow(color: Color.ink.opacity(0.32), radius: 0, x: 0, y: 6)
        } else {
            content
        }
    }
}
