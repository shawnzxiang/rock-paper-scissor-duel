import SwiftUI

struct SettingsSheet: View {
    @ObservedObject var vm: GameViewModel
    @ObservedObject var store: SettingsStore

    @State private var showResetConfirm = false

    var body: some View {
        let open = vm.settingsOpen
        let flipped = vm.settingsSide == .top

        ZStack(alignment: flipped ? .top : .bottom) {
            Color.black.opacity(open ? 0.55 : 0)
                .animation(.easeInOut(duration: 0.22), value: open)
                .ignoresSafeArea()
                .onTapGesture {
                    if showResetConfirm { showResetConfirm = false }
                    else { vm.closeGear() }
                }
                .allowsHitTesting(open)

            if open {
                sheetContent(flipped: flipped)
                    .rotationEffect(.degrees(flipped ? 180 : 0))
                    .transition(.move(edge: flipped ? .top : .bottom).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.32, dampingFraction: 0.85), value: open)
        .onChange(of: open) { _, newValue in
            if !newValue { showResetConfirm = false }
        }
    }

    @ViewBuilder
    private func sheetContent(flipped: Bool) -> some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(Color.white.opacity(0.28))
                .frame(width: 40, height: 5)
                .padding(.top, 6)
                .padding(.bottom, 14)

            HStack {
                Text("Settings")
                    .font(.lilita(30))
                    .tracking(0.2)
                    .foregroundStyle(.white)
                Spacer()
                Button {
                    vm.closeGear()
                } label: {
                    Text(verbatim: "✕")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 36, height: 36)
                        .background(Color.white.opacity(0.14), in: Circle())
                }
            }
            .padding(.horizontal, 4)
            .padding(.bottom, 14)

            ScrollView {
                VStack(spacing: 0) {
                    sectionHeader("Appearance")
                    group {
                        verticalRow(title: "Palette",
                                    subtitle: "Color scheme for both halves") {
                            SegmentedPicker(
                                value: Binding(get: { store.value.palette },
                                               set: { v in store.patch { $0.palette = v } }),
                                options: Palette.allCases.map { (LocalizedStringKey($0.displayName), $0) }
                            )
                        }
                    }

                    sectionHeader("Game")
                    group {
                        row(title: "No ties",
                            subtitle: "Auto-reroll when both players pick the same") {
                            ToggleSwitch(on: Binding(get: { store.value.noTies },
                                                     set: { v in store.patch { $0.noTies = v } }))
                        }
                    }

                    sectionHeader("Accessibility")
                    group {
                        row(title: "Sounds",
                            subtitle: "Play sound effects during the game") {
                            ToggleSwitch(on: Binding(get: { store.value.sounds },
                                                     set: { v in store.patch { $0.sounds = v } }))
                        }
                        separator
                        row(title: "Haptics",
                            subtitle: "Vibrate on countdown and reveal") {
                            ToggleSwitch(on: Binding(get: { store.value.haptics },
                                                     set: { v in store.patch { $0.haptics = v } }))
                        }
                        separator
                        row(title: "Reduce motion",
                            subtitle: "Calmer transitions") {
                            ToggleSwitch(on: Binding(get: { store.value.reduceMotion },
                                                     set: { v in store.patch { $0.reduceMotion = v } }))
                        }
                    }

                    Button {
                        showResetConfirm = true
                    } label: {
                        Text("Reset scores")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(Color(hex: 0xFF453A))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                            .background(Color(hex: 0xFF453A).opacity(0.18),
                                        in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                    .padding(.top, 18)
                    .padding(.horizontal, 4)
                }
                .padding(.bottom, flipped ? 10 : 40)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, flipped ? 40 : 10)
        .padding(.bottom, flipped ? 10 : 40)
        .frame(maxWidth: .infinity)
        .frame(maxHeight: UIScreen.main.bounds.height * 0.78)
        .background(
            Color(hex: 0x1C1C1E)
                .clipShape(
                    UnevenRoundedRectangle(
                        cornerRadii: flipped
                            ? .init(bottomLeading: 32, bottomTrailing: 32)
                            : .init(topLeading: 32, topTrailing: 32),
                        style: .continuous
                    )
                )
        )
        .shadow(color: .black.opacity(0.35),
                radius: 60, x: 0, y: flipped ? 20 : -20)
        .overlay {
            if showResetConfirm {
                ConfirmDialog(
                    title: "Reset scores?",
                    confirmLabel: "Reset scores",
                    onCancel: { showResetConfirm = false },
                    onConfirm: {
                        vm.resetScores()
                        showResetConfirm = false
                        vm.closeGear()
                    }
                )
                .transition(.opacity.combined(with: .scale(scale: 0.92)))
            }
        }
        .animation(.spring(response: 0.28, dampingFraction: 0.85), value: showResetConfirm)
    }

    // MARK: - Layout helpers
    private func sectionHeader(_ text: LocalizedStringKey) -> some View {
        Text(text)
            .font(.fredoka(12, weight: .semibold))
            .tracking(0.8)
            .textCase(.uppercase)
            .foregroundStyle(Color.white.opacity(0.55))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.top, 18)
            .padding(.bottom, 8)
    }

    private func group<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        VStack(spacing: 0) { content() }
            .background(Color.white.opacity(0.07))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func row<Control: View>(title: LocalizedStringKey, subtitle: LocalizedStringKey,
                                    @ViewBuilder control: () -> Control) -> some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.fredoka(17, weight: .medium))
                    .foregroundStyle(.white)
                Text(subtitle)
                    .font(.fredoka(13))
                    .foregroundStyle(Color.white.opacity(0.55))
            }
            Spacer(minLength: 12)
            control()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    private func verticalRow<Control: View>(title: LocalizedStringKey, subtitle: LocalizedStringKey,
                                            @ViewBuilder control: () -> Control) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.fredoka(17, weight: .medium))
                    .foregroundStyle(.white)
                Text(subtitle)
                    .font(.fredoka(13))
                    .foregroundStyle(Color.white.opacity(0.55))
            }
            control()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    private var separator: some View {
        Rectangle()
            .fill(Color.white.opacity(0.08))
            .frame(height: 1)
            .padding(.leading, 16)
    }
}

// MARK: - Confirmation dialog (in-sheet, respects 180° rotation)

private struct ConfirmDialog: View {
    let title: LocalizedStringKey
    let confirmLabel: LocalizedStringKey
    let onCancel: () -> Void
    let onConfirm: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.45)
                .onTapGesture(perform: onCancel)
            VStack(spacing: 18) {
                Text(title)
                    .font(.fredoka(19, weight: .semibold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                HStack(spacing: 10) {
                    Button(action: onCancel) {
                        Text("Cancel")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 13)
                            .background(Color.white.opacity(0.14),
                                        in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                    Button(action: onConfirm) {
                        Text(confirmLabel)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 13)
                            .background(Color(hex: 0xFF453A),
                                        in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                }
            }
            .padding(20)
            .background(Color(hex: 0x2C2C2E),
                        in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
            .padding(.horizontal, 30)
        }
    }
}

// MARK: - Custom controls

private struct ToggleSwitch: View {
    @Binding var on: Bool
    var body: some View {
        Button { on.toggle() } label: {
            ZStack(alignment: on ? .trailing : .leading) {
                Capsule()
                    .fill(on ? Color(hex: 0x30D158) : Color(red: 120/255, green: 120/255, blue: 128/255).opacity(0.32))
                    .frame(width: 51, height: 31)
                Circle()
                    .fill(.white)
                    .frame(width: 27, height: 27)
                    .padding(.horizontal, 2)
                    .shadow(color: .black.opacity(0.2), radius: 1.5, x: 0, y: 1)
            }
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.22, dampingFraction: 0.85), value: on)
    }
}

private struct SegmentedPicker<T: Hashable>: View {
    @Binding var value: T
    let options: [(LocalizedStringKey, T)]

    var body: some View {
        HStack(spacing: 2) {
            ForEach(options.indices, id: \.self) { i in
                let opt = options[i]
                let selected = opt.1 == value
                Button {
                    value = opt.1
                } label: {
                    Text(opt.0)
                        .font(.fredoka(14, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 10)
                        .background(
                            selected
                                ? Color(red: 99/255, green: 99/255, blue: 102/255)
                                : Color.clear,
                            in: RoundedRectangle(cornerRadius: 8, style: .continuous)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(2)
        .background(Color(red: 120/255, green: 120/255, blue: 128/255).opacity(0.24),
                    in: RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}
