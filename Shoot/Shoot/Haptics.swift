import UIKit

enum Haptics {
    static func tap(_ enabled: Bool, style: UIImpactFeedbackGenerator.FeedbackStyle = .light) {
        guard enabled else { return }
        let g = UIImpactFeedbackGenerator(style: style)
        g.impactOccurred()
    }

    static func notify(_ enabled: Bool, _ type: UINotificationFeedbackGenerator.FeedbackType) {
        guard enabled else { return }
        let g = UINotificationFeedbackGenerator()
        g.notificationOccurred(type)
    }
}
