import SwiftUI

struct DividerOverlay: View {
    @ObservedObject var vm: GameViewModel

    var body: some View {
        ZStack {
            if vm.phase == .idle {
                VSButton {
                    Sound.ui(vm.settings.sounds)
                    vm.runDemo()
                }
                .disabled(vm.demoMode)
            }
            if vm.phase == .result {
                ReplayButton {
                    Sound.ui(vm.settings.sounds)
                    vm.resetRound()
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 0)
        .zIndex(30)
    }
}

private struct VSButton: View {
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Text("VS")
                .font(.lilita(26))
                .tracking(-0.5)
                .foregroundStyle(Color.ink)
                .frame(width: 76, height: 76)
                .background(Color(hex: 0xFFD66E), in: Circle())
                .overlay(Circle().stroke(Color.ink, lineWidth: 4))
        }
        .rotationEffect(.degrees(-6))
        .shadow(color: .ink, radius: 0, x: 0, y: 6)
        .shadow(color: .black.opacity(0.35), radius: 14, x: 0, y: 14)
    }
}

private struct ReplayButton: View {
    let action: () -> Void

    var body: some View {
        let D: CGFloat = 76
        Button(action: action) {
            ZStack {
                // Shadow is on the circle background only, so the icon doesn't
                // get drawn into the shadow as a ghost. (SF Symbol Images, unlike
                // Text, bleed into hard-offset shadows when the .shadow modifier
                // sits outside the composed view.)
                Circle()
                    .fill(Color(hex: 0xFFD66E))
                    .frame(width: D, height: D)
                    .shadow(color: .ink, radius: 0, x: 0, y: 6)
                    .shadow(color: .black.opacity(0.35), radius: 14, x: 0, y: 14)
                Circle()
                    .stroke(Color.ink, lineWidth: 4)
                    .frame(width: D, height: D)
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 32, weight: .heavy))
                    .foregroundStyle(Color.ink)
            }
        }
        .buttonStyle(.plain)
        .transition(.scale(scale: 0.7).combined(with: .opacity))
    }
}
