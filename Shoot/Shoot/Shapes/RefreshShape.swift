import SwiftUI

struct RefreshIcon: View {
    var size: CGFloat = 28
    var color: Color = .ink

    var body: some View {
        Canvas { ctx, canvasSize in
            let s = min(canvasSize.width, canvasSize.height) / 24
            ctx.translateBy(x: (canvasSize.width - 24*s)/2, y: (canvasSize.height - 24*s)/2)
            ctx.scaleBy(x: s, y: s)

            let style = StrokeStyle(lineWidth: 2.8, lineCap: .round, lineJoin: .round)

            // Top-right arc (3/4 of a circle)
            var p = Path()
            p.addArc(center: CGPoint(x: 12, y: 12), radius: 9,
                     startAngle: .degrees(200), endAngle: .degrees(340), clockwise: true)
            ctx.stroke(p, with: .color(color), style: style)

            // Top-right arrowhead
            var ah1 = Path()
            ah1.move(to: CGPoint(x: 21, y: 3))
            ah1.addLine(to: CGPoint(x: 21, y: 9))
            ah1.addLine(to: CGPoint(x: 15, y: 9))
            ctx.stroke(ah1, with: .color(color), style: style)

            // Bottom-left arc
            var q = Path()
            q.addArc(center: CGPoint(x: 12, y: 12), radius: 9,
                     startAngle: .degrees(20), endAngle: .degrees(160), clockwise: true)
            ctx.stroke(q, with: .color(color), style: style)

            // Bottom-left arrowhead
            var ah2 = Path()
            ah2.move(to: CGPoint(x: 3, y: 21))
            ah2.addLine(to: CGPoint(x: 3, y: 15))
            ah2.addLine(to: CGPoint(x: 9, y: 15))
            ctx.stroke(ah2, with: .color(color), style: style)
        }
        .frame(width: size, height: size)
    }
}
