import StoreKit
import UIKit

/// Wrapper around `SKStoreReviewController` so it can be feature-gated and
/// stubbed in tests. Apple already rate-limits to 3 prompts per user per 365
/// days; this app additionally limits to one prompt per app session.
///
/// **Timing rationale**: 2.5 seconds after the user-facing player wins. Long
/// enough for the win animation and confetti to land emotionally (UX research
/// on rating prompts consistently finds "after a positive moment, once the
/// reward sinks in" performs best — too-immediate prompts feel intrusive,
/// too-late prompts miss the emotional peak). The trigger is gated to the
/// bottom half because the top half is rotated 180° for the opposing player
/// — only the bottom player can actually see and act on the system alert.
@MainActor
enum ReviewPrompter {
    static func requestReview() {
        guard let scene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive })
            ?? UIApplication.shared.connectedScenes.first as? UIWindowScene
        else { return }
        SKStoreReviewController.requestReview(in: scene)
    }
}
