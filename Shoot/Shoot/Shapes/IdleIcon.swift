import SwiftUI

struct IdleIcon: View {
    let variant: IdleIconVariant
    var size: CGFloat?

    var body: some View {
        switch variant {
        case .trio:  TrioIdleIcon(size: size ?? 120)
        case .cycle: CycleIdleIcon(size: size ?? 124)
        case .morph: MorphIdleIcon(size: size ?? 108)
        }
    }
}
