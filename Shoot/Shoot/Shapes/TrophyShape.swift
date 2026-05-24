import SwiftUI

/// Chunky trophy used in the score badge.
struct TrophyIcon: View {
    var size: CGFloat = 20
    var color: Color = Color(hex: 0xFFD66E)

    var body: some View {
        Canvas { ctx, canvasSize in
            let s = min(canvasSize.width, canvasSize.height) / 24
            ctx.translateBy(x: (canvasSize.width - 24*s)/2, y: (canvasSize.height - 24*s)/2)
            ctx.scaleBy(x: s, y: s)

            // Cup body
            var cup = Path()
            cup.move(to: CGPoint(x: 7, y: 4))
            cup.addLine(to: CGPoint(x: 17, y: 4))
            cup.addLine(to: CGPoint(x: 17, y: 7))
            cup.addArc(center: CGPoint(x: 12, y: 7), radius: 5,
                       startAngle: .degrees(0), endAngle: .degrees(180), clockwise: false)
            cup.addLine(to: CGPoint(x: 7, y: 4))
            cup.closeSubpath()
            ctx.fill(cup, with: .color(color))
            ctx.stroke(cup, with: .color(.ink),
                       style: StrokeStyle(lineWidth: 2, lineJoin: .round))

            // Handles + stem + base
            let stroke = StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round)
            var handles = Path()
            // right handle
            handles.move(to: CGPoint(x: 17, y: 4))
            handles.addLine(to: CGPoint(x: 20, y: 4))
            handles.addLine(to: CGPoint(x: 20, y: 6))
            handles.addQuadCurve(to: CGPoint(x: 17, y: 9), control: CGPoint(x: 20, y: 9))
            // left handle
            handles.move(to: CGPoint(x: 7, y: 4))
            handles.addLine(to: CGPoint(x: 4, y: 4))
            handles.addLine(to: CGPoint(x: 4, y: 6))
            handles.addQuadCurve(to: CGPoint(x: 7, y: 9), control: CGPoint(x: 4, y: 9))
            // base bar
            handles.move(to: CGPoint(x: 9, y: 19))
            handles.addLine(to: CGPoint(x: 15, y: 19))
            // stem
            handles.move(to: CGPoint(x: 12, y: 12))
            handles.addLine(to: CGPoint(x: 12, y: 19))
            ctx.stroke(handles, with: .color(.ink), style: stroke)
        }
        .frame(width: size, height: size)
    }
}
