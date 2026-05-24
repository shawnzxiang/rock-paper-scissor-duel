import SwiftUI

extension Color {
    static let ink = Color(red: 0x1A/255.0, green: 0x0F/255.0, blue: 0x1F/255.0)

    init(hex: UInt32, alpha: Double = 1.0) {
        let r = Double((hex >> 16) & 0xFF) / 255.0
        let g = Double((hex >>  8) & 0xFF) / 255.0
        let b = Double( hex        & 0xFF) / 255.0
        self.init(.sRGB, red: r, green: g, blue: b, opacity: alpha)
    }
}

extension Font {
    static func lilita(_ size: CGFloat) -> Font {
        if UIFont(name: "LilitaOne-Regular", size: size) != nil {
            return .custom("LilitaOne-Regular", size: size)
        }
        return .system(size: size, weight: .heavy, design: .rounded)
    }

    static func fredoka(_ size: CGFloat, weight: Font.Weight = .semibold) -> Font {
        // Variable font: register family name and apply weight via SwiftUI.
        if UIFont(name: "Fredoka", size: size) != nil {
            return .custom("Fredoka", size: size).weight(weight)
        }
        return .system(size: size, weight: weight, design: .rounded)
    }
}
