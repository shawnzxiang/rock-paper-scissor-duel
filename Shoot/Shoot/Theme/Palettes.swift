import SwiftUI

struct PaletteSide {
    let colors: [Color]   // 1 = solid, 2 = gradient
    let tint: Color       // text/icon foreground on this side
    let handFill: Color   // fill color inside hand silhouettes
}

enum Palette: String, CaseIterable, Codable, Identifiable {
    case candy, mono, flat, pop
    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .candy: return "Candy"
        case .mono:  return "Mono"
        case .flat:  return "Flat"
        case .pop:   return "Pop"
        }
    }

    func side(_ side: Side) -> PaletteSide {
        switch self {
        case .candy:
            return side == .top
                ? PaletteSide(colors: [Color(hex: 0xFF5E8A), Color(hex: 0xFFAE3A)],
                              tint: .white, handFill: .white)
                : PaletteSide(colors: [Color(hex: 0x3FD1C4), Color(hex: 0x5B6BE8)],
                              tint: .white, handFill: .white)
        case .mono:
            // True black-and-white. The white side flips foreground to ink.
            return side == .top
                ? PaletteSide(colors: [Color(hex: 0x0A0A0A)],
                              tint: .white, handFill: .white)
                : PaletteSide(colors: [Color(hex: 0xF2F2F2)],
                              tint: .ink, handFill: .ink)
        case .flat:
            // Solid bold colors, no gradient. Inspired by 80s sportswear blocks.
            return side == .top
                ? PaletteSide(colors: [Color(hex: 0xFF3B6E)],
                              tint: .white, handFill: .white)
                : PaletteSide(colors: [Color(hex: 0x1E90FF)],
                              tint: .white, handFill: .white)
        case .pop:
            // Comic-book pop-art — bold gradients with high saturation.
            return side == .top
                ? PaletteSide(colors: [Color(hex: 0xFFE600), Color(hex: 0xFF2D55)],
                              tint: .white, handFill: .white)
                : PaletteSide(colors: [Color(hex: 0x00C8FF), Color(hex: 0x7B61FF)],
                              tint: .white, handFill: .white)
        }
    }
}

enum IdleIconVariant: String, CaseIterable, Codable, Identifiable {
    case trio, cycle, morph
    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .trio:  return "Trio"
        case .cycle: return "Cycle"
        case .morph: return "Morph"
        }
    }
}
