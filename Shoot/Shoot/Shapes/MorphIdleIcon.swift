import SwiftUI

/// Single big hand cycling rock → paper → scissors on a slow loop.
struct MorphIdleIcon: View {
    var size: CGFloat = 110
    @State private var index = 0

    private let order: [Choice] = [.rock, .paper, .scissors]
    private let timer = Timer.publish(every: 0.9, on: .main, in: .common).autoconnect()

    var body: some View {
        HandView(kind: order[index], size: size)
            .id(index)
            .transition(.scale(scale: 0.78).combined(with: .opacity))
            .animation(.spring(response: 0.28, dampingFraction: 0.6), value: index)
            .onReceive(timer) { _ in
                index = (index + 1) % order.count
            }
            .frame(width: size, height: size)
    }
}
