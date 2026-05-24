import SwiftUI

private struct PaletteTintKey: EnvironmentKey {
    static let defaultValue: Color = .white
}
private struct PaletteHandFillKey: EnvironmentKey {
    static let defaultValue: Color = .white
}

extension EnvironmentValues {
    var paletteTint: Color {
        get { self[PaletteTintKey.self] }
        set { self[PaletteTintKey.self] = newValue }
    }
    var paletteHandFill: Color {
        get { self[PaletteHandFillKey.self] }
        set { self[PaletteHandFillKey.self] = newValue }
    }
}
