import SwiftUI

struct IdleContentView: View {
    let holding: Bool
    let iconVariant: IdleIconVariant

    @Environment(\.paletteTint) private var tint
    @State private var wobble: Bool = false

    var body: some View {
        VStack(spacing: 22) {
            ZStack {
                Circle()
                    .fill(tint.opacity(0.20))
                    .overlay(Circle().stroke(tint.opacity(0.70), lineWidth: 5))
                    .overlay(Circle().inset(by: 5).stroke(Color.black.opacity(0.06), lineWidth: 3))
                    .frame(width: 160, height: 160)
                IdleIcon(variant: iconVariant)
            }
            .shadow(color: .black.opacity(0.12), radius: 0, x: 0, y: 8)
            .scaleEffect(holding ? 0.92 : 1.0)
            .rotationEffect(.degrees(holding ? -3 : (wobble ? 3 : -3)))
            .animation(holding
                       ? .spring(response: 0.18, dampingFraction: 0.7)
                       : .easeInOut(duration: 2.6).repeatForever(autoreverses: true),
                       value: holding || wobble)
            .onAppear { wobble = true }

            (holding ? Text("READY!") : Text("TAP & HOLD"))
                .font(.lilita(44))
                .foregroundStyle(tint)
                .shadow(color: Color.ink.opacity(0.28), radius: 0, x: 0, y: 4)
                .scaleEffect(holding ? 1.06 : 1.0)
                .animation(.spring(response: 0.18, dampingFraction: 0.7), value: holding)
        }
    }
}
