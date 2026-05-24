import SwiftUI

/// Triangle of hands with curved arrows showing what beats what.
struct CycleIdleIcon: View {
    var size: CGFloat = 130

    var body: some View {
        ZStack {
            // Arrows
            Canvas { ctx, canvasSize in
                let s = min(canvasSize.width, canvasSize.height) / 100
                ctx.translateBy(x: (canvasSize.width - 100*s)/2, y: (canvasSize.height - 100*s)/2)
                ctx.scaleBy(x: s, y: s)

                let stroke = Color.white
                let lw: CGFloat = 3.5

                func drawArrow(from start: CGPoint, control: CGPoint, to end: CGPoint) {
                    var p = Path()
                    p.move(to: start)
                    p.addQuadCurve(to: end, control: control)
                    ctx.stroke(p, with: .color(stroke),
                               style: StrokeStyle(lineWidth: lw, lineCap: .round))
                    // arrowhead
                    let tangent = CGPoint(x: end.x - control.x, y: end.y - control.y)
                    let len = max(0.0001, hypot(tangent.x, tangent.y))
                    let ux = tangent.x / len, uy = tangent.y / len
                    let perpX = -uy, perpY = ux
                    let head: CGFloat = 5
                    let backX = end.x - ux * head, backY = end.y - uy * head
                    var ah = Path()
                    ah.move(to: end)
                    ah.addLine(to: CGPoint(x: backX + perpX * head/1.8, y: backY + perpY * head/1.8))
                    ah.addLine(to: CGPoint(x: backX - perpX * head/1.8, y: backY - perpY * head/1.8))
                    ah.closeSubpath()
                    ctx.fill(ah, with: .color(stroke))
                }
                drawArrow(from: CGPoint(x: 32, y: 28), control: CGPoint(x: 50, y: 18), to: CGPoint(x: 68, y: 28))
                drawArrow(from: CGPoint(x: 72, y: 36), control: CGPoint(x: 76, y: 56), to: CGPoint(x: 58, y: 72))
                drawArrow(from: CGPoint(x: 42, y: 72), control: CGPoint(x: 24, y: 56), to: CGPoint(x: 28, y: 36))
            }
            .frame(width: size, height: size)
            .shadow(color: Color.ink.opacity(0.32), radius: 0, x: 0, y: 3)

            // Mini hands at the three corners
            let mini: CGFloat = size * (48.0 / 130.0)
            ZStack {
                HandView(kind: .rock,     size: mini, shadow: false)
                    .position(x: mini/2 + size*0.02, y: mini/2 + size*0.02)
                HandView(kind: .scissors, size: mini, shadow: false)
                    .position(x: size - mini/2 - size*0.02, y: mini/2 + size*0.02)
                HandView(kind: .paper,    size: mini, shadow: false)
                    .position(x: size/2, y: size - mini/2)
            }
            .frame(width: size, height: size)
        }
        .frame(width: size, height: size)
    }
}
