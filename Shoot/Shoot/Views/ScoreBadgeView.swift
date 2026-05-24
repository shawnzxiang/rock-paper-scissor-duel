import SwiftUI

struct ScoreBadgeView: View {
    let score: Int
    @Environment(\.paletteTint) private var tint

    var body: some View {
        HStack(spacing: 10) {
            TrophyIcon(size: 20)
            Text("\(score)")
                .font(.lilita(22))
                .foregroundStyle(tint)
        }
        .padding(.vertical, 6)
        .padding(.leading, 14)
        .padding(.trailing, 16)
        .background(tint.opacity(0.12), in: Capsule(style: .continuous))
        .overlay(
            Capsule(style: .continuous)
                .stroke(tint.opacity(0.35), lineWidth: 2)
        )
    }
}
