import SwiftUI

struct ContentView: View {
    @StateObject private var store = SettingsStore()
    @StateObject private var vm: GameViewModel

    init() {
        let s = SettingsStore()
        _store = StateObject(wrappedValue: s)
        _vm = StateObject(wrappedValue: GameViewModel(store: s))
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            GeometryReader { geo in
                ZStack {
                    VStack(spacing: 0) {
                        HalfView(side: .top, vm: vm)
                            .frame(height: geo.size.height / 2)
                        HalfView(side: .bot, vm: vm)
                            .frame(height: geo.size.height / 2)
                    }

                    DividerOverlay(vm: vm)
                        .position(x: geo.size.width / 2, y: geo.size.height / 2)
                }
                .frame(width: geo.size.width, height: geo.size.height)
            }
            .ignoresSafeArea()
            .contentShape(Rectangle())
            .onTapGesture { vm.tapBackground() }

            SettingsSheet(vm: vm, store: store)
                .ignoresSafeArea()
        }
        .preferredColorScheme(.dark)
        .statusBarHidden(true)
        .onAppear {
            // Warm up the audio engine so the first tick has no cold-start latency.
            SoundEngine.shared.ensure()
        }
    }
}

#Preview {
    ContentView()
}
