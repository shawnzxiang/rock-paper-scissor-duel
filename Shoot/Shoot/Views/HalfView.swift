import SwiftUI

struct HalfView: View {
    let side: Side
    @ObservedObject var vm: GameViewModel

    var body: some View {
        let paletteSide = vm.settings.palette.side(side)
        let isTop = side == .top
        let holding = isTop ? vm.topHold : vm.botHold
        let outcome = vm.outcome(for: side)
        let score = isTop ? vm.topScore : vm.botScore
        let choice = isTop ? vm.topChoice : vm.botChoice
        let safeOuter: CGFloat = isTop ? 56 : 40

        let background: AnyView = {
            if paletteSide.colors.count == 1 {
                return AnyView(paletteSide.colors[0])
            } else {
                return AnyView(LinearGradient(
                    colors: paletteSide.colors,
                    startPoint: isTop ? .topLeading : .bottomLeading,
                    endPoint:   isTop ? .bottomTrailing : .topTrailing))
            }
        }()

        ZStack {
            background

            // Dimming overlay
            let overlay: Double = {
                guard vm.phase == .reveal || vm.phase == .result else { return 0 }
                if outcome == .lose { return 0.42 }
                if outcome == .tie  { return 0.16 }
                return 0
            }()
            Color.black.opacity(overlay)
                .animation(.easeInOut(duration: 0.3), value: overlay)
                .allowsHitTesting(false)

            // Hold-pulse outline
            if vm.phase == .idle && holding {
                HoldPulseOverlay(color: paletteSide.tint)
            }

            // Confetti for winning side
            if outcome == .win, vm.phase == .reveal || vm.phase == .result {
                ConfettiView()
            }

            // Content
            VStack {
                Spacer(minLength: 26)
                Group {
                    switch vm.phase {
                    case .idle:
                        IdleContentView(holding: holding, iconVariant: vm.settings.iconVariant)
                    case .count:
                        CountContentView(label: vm.countLabel)
                    case .reveal, .result:
                        if let choice {
                            // Anchor to the score-badge side of the half (bottom in pre-rotation
                            // coords, which is far from the divider in both halves once the top
                            // half is rotated 180°). Color.clear forces the ZStack to fill the
                            // Group's height so .bottom alignment actually anchors.
                            ZStack(alignment: .bottom) {
                                Color.clear
                                RevealContentView(choice: choice, outcome: outcome)
                                    .padding(.bottom, 4)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                ScoreBadgeView(score: score)
                    .padding(.bottom, 4)
                Spacer(minLength: safeOuter)
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)

            // Gear button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button {
                        vm.openGear(side: side)
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(paletteSide.tint)
                            .frame(width: 36, height: 36)
                            .background(paletteSide.tint.opacity(0.12), in: Circle())
                            .overlay(Circle().stroke(paletteSide.tint.opacity(0.55), lineWidth: 2))
                    }
                    .padding(.trailing, 16)
                    .padding(.bottom, safeOuter - 8)
                }
            }
        }
        .environment(\.paletteTint, paletteSide.tint)
        .environment(\.paletteHandFill, paletteSide.handFill)
        .contentShape(Rectangle())
        .clipped()
        .gesture(holdGesture)
        .rotationEffect(.degrees(isTop ? 180 : 0))
    }

    private var holdGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { _ in
                let current = side == .top ? vm.topHold : vm.botHold
                if !current { vm.setHold(side, true) }
            }
            .onEnded { _ in
                guard !vm.demoMode else { return }
                vm.setHold(side, false)
            }
    }
}

private struct HoldPulseOverlay: View {
    let color: Color
    @State private var pulsing = false
    var body: some View {
        Rectangle()
            .stroke(color.opacity(pulsing ? 0 : 0.85), lineWidth: pulsing ? 24 : 8)
            .blur(radius: 0.5)
            .animation(.easeOut(duration: 0.9).repeatForever(autoreverses: false), value: pulsing)
            .allowsHitTesting(false)
            .onAppear { pulsing = true }
    }
}
