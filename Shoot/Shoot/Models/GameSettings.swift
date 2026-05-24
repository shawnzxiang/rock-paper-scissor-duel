import Foundation
import Combine

struct GameSettings: Codable, Equatable {
    var noTies: Bool = true
    var holdMs: Int = 600
    var haptics: Bool = true
    var sounds: Bool = true
    var reduceMotion: Bool = false
    var palette: Palette = .flat
    var iconVariant: IdleIconVariant = .trio

    init() {}

    // Forward-compatible decode: missing fields fall back to defaults so adding new
    // settings doesn't wipe a user's existing preferences.
    private enum CodingKeys: String, CodingKey {
        case noTies, holdMs, haptics, sounds, reduceMotion, palette, iconVariant
    }
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let d = GameSettings()
        self.noTies       = (try? c.decode(Bool.self, forKey: .noTies))               ?? d.noTies
        self.holdMs       = (try? c.decode(Int.self,  forKey: .holdMs))               ?? d.holdMs
        self.haptics      = (try? c.decode(Bool.self, forKey: .haptics))              ?? d.haptics
        self.sounds       = (try? c.decode(Bool.self, forKey: .sounds))               ?? d.sounds
        self.reduceMotion = (try? c.decode(Bool.self, forKey: .reduceMotion))         ?? d.reduceMotion
        self.palette      = (try? c.decode(Palette.self, forKey: .palette))           ?? d.palette
        self.iconVariant  = (try? c.decode(IdleIconVariant.self, forKey: .iconVariant)) ?? d.iconVariant
    }
}

final class SettingsStore: ObservableObject {
    static let storageKey = "rps_settings_v4"
    private let defaults: UserDefaults
    @Published var value: GameSettings

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if let data = defaults.data(forKey: Self.storageKey),
           let decoded = try? JSONDecoder().decode(GameSettings.self, from: data) {
            self.value = decoded
        } else {
            self.value = GameSettings()
        }
    }

    func patch(_ apply: (inout GameSettings) -> Void) {
        var next = value
        apply(&next)
        guard next != value else { return }
        value = next
        if let data = try? JSONEncoder().encode(next) {
            defaults.set(data, forKey: Self.storageKey)
        }
    }
}
