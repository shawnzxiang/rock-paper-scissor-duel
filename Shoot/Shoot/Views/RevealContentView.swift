import SwiftUI

struct RevealContentView: View {
    let choice: Choice
    let outcome: Outcome?

    @Environment(\.paletteTint) private var tint

    private var verdict: String {
        switch outcome {
        case .win:  return "WIN!"
        case .lose: return "LOSE"
        case .tie:  return "TIE"
        case .none: return ""
        }
    }

    var body: some View {
        VStack(spacing: 8) {
            HandView(kind: choice, size: 100)
                .id("hand-\(choice.rawValue)")
                .transition(.scale(scale: 0.3).combined(with: .opacity))

            Text(LocalizedStringKey(choice.label))
                .font(.lilita(18))
                .tracking(2)
                .foregroundStyle(tint)
                .padding(.horizontal, 12)
                .padding(.vertical, 3)
                .background(tint.opacity(0.18), in: RoundedRectangle(cornerRadius: 11, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 11, style: .continuous)
                        .stroke(tint.opacity(0.45), lineWidth: 2)
                )

            Text(LocalizedStringKey(verdict))
                .font(.lilita(32))
                .foregroundStyle(tint)
                .shadow(color: Color.ink.opacity(0.35), radius: 0, x: 0, y: 4)
                .padding(.top, 2)
        }
    }
}
