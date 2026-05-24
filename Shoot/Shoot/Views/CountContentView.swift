import SwiftUI

struct CountContentView: View {
    let label: String
    @Environment(\.paletteTint) private var tint

    var body: some View {
        Text(LocalizedStringKey(label))
            .font(.lilita(72))
            .foregroundStyle(tint)
            .shadow(color: Color.ink.opacity(0.35), radius: 0, x: 0, y: 6)
            .lineLimit(1)
            .minimumScaleFactor(0.55)
            .padding(.horizontal, 12)
            .id(label)
            .transition(.scale(scale: 0.55).combined(with: .opacity))
            .animation(.spring(response: 0.32, dampingFraction: 0.55), value: label)
    }
}
