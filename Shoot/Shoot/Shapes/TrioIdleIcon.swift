import SwiftUI

/// Three mini hands fanned out side-by-side. Default idle icon — most "this is RPS" at a glance.
struct TrioIdleIcon: View {
    var size: CGFloat = 120
    var shadow: Bool = true

    @Environment(\.paletteHandFill) private var fill

    var body: some View {
        Canvas { ctx, canvasSize in
            let refW: CGFloat = 240, refH: CGFloat = 140
            let s = min(canvasSize.width / refW, canvasSize.height / refH)
            let dx = (canvasSize.width - refW * s) / 2
            let dy = (canvasSize.height - refH * s) / 2
            ctx.translateBy(x: dx, y: dy)
            ctx.scaleBy(x: s, y: s)

            let stroke = Color.ink
            let sw: CGFloat = 5

            // ROCK
            ctx.drawLayer { c in
                c.translateBy(x: -10, y: 18); c.scaleBy(x: 0.78, y: 0.78)
                c.translateBy(x: 60, y: 80); c.rotate(by: .degrees(-12)); c.translateBy(x: -60, y: -80)
                let p = HandPaths.rockOutline
                c.fill(p, with: .color(fill))
                c.stroke(p, with: .color(stroke),
                         style: StrokeStyle(lineWidth: sw, lineCap: .round, lineJoin: .round))
                for (a, b) in HandPaths.rockKnuckles {
                    var k = Path(); k.move(to: a); k.addLine(to: b)
                    c.stroke(k, with: .color(stroke),
                             style: StrokeStyle(lineWidth: 3.5, lineCap: .round))
                }
            }
            // PAPER
            ctx.drawLayer { c in
                c.translateBy(x: 60, y: 8); c.scaleBy(x: 0.78, y: 0.78)
                let thumb = HandPaths.paperThumb
                c.fill(thumb, with: .color(fill))
                c.stroke(thumb, with: .color(stroke),
                         style: StrokeStyle(lineWidth: sw, lineCap: .round, lineJoin: .round))
                for f in [
                    HandPaths.finger(x: 33, w: 12, tipY: 10, angle: -8),
                    HandPaths.finger(x: 47, w: 12, tipY: 6,  angle: -2),
                    HandPaths.finger(x: 61, w: 12, tipY: 8,  angle:  3),
                    HandPaths.finger(x: 75, w: 12, tipY: 20, angle: 11),
                ] {
                    c.fill(f, with: .color(fill))
                    c.stroke(f, with: .color(stroke),
                             style: StrokeStyle(lineWidth: sw, lineCap: .round, lineJoin: .round))
                }
                let palm = HandPaths.palm
                c.fill(palm, with: .color(fill))
                c.stroke(palm, with: .color(stroke),
                         style: StrokeStyle(lineWidth: sw, lineCap: .round, lineJoin: .round))
            }
            // SCISSORS
            ctx.drawLayer { c in
                c.translateBy(x: 130, y: 18); c.scaleBy(x: 0.78, y: 0.78)
                c.translateBy(x: 60, y: 80); c.rotate(by: .degrees(12)); c.translateBy(x: -60, y: -80)
                for f in [
                    HandPaths.finger(x: 32, w: 12, tipY: 8, angle: -16),
                    HandPaths.finger(x: 48, w: 12, tipY: 8, angle:  16),
                    HandPaths.finger(x: 65, w: 11, tipY: 50, angle: 0),
                    HandPaths.finger(x: 78, w: 11, tipY: 50, angle: 0),
                ] {
                    c.fill(f, with: .color(fill))
                    c.stroke(f, with: .color(stroke),
                             style: StrokeStyle(lineWidth: sw, lineCap: .round, lineJoin: .round))
                }
                let palm = HandPaths.palm
                c.fill(palm, with: .color(fill))
                c.stroke(palm, with: .color(stroke),
                         style: StrokeStyle(lineWidth: sw, lineCap: .round, lineJoin: .round))
                let thumb = HandPaths.scissorsThumb
                c.fill(thumb, with: .color(fill))
                c.stroke(thumb, with: .color(stroke),
                         style: StrokeStyle(lineWidth: sw, lineCap: .round, lineJoin: .round))
            }
        }
        .frame(width: size, height: size * (140.0/240.0))
        .modifier(IconShadowModifier(enabled: shadow))
    }
}

struct IconShadowModifier: ViewModifier {
    let enabled: Bool
    func body(content: Content) -> some View {
        if enabled {
            content.shadow(color: Color.ink.opacity(0.32), radius: 0, x: 0, y: 5)
        } else {
            content
        }
    }
}
