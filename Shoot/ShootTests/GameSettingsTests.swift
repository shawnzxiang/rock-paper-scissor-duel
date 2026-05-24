import XCTest
@testable import Shoot

final class GameSettingsTests: XCTestCase {

    func testDefaultsMatchSpec() {
        let s = GameSettings()
        XCTAssertTrue(s.noTies,        "no-ties should default on")
        XCTAssertEqual(s.holdMs, 600)
        XCTAssertTrue(s.haptics)
        XCTAssertTrue(s.sounds)
        XCTAssertFalse(s.reduceMotion)
        XCTAssertEqual(s.palette,     .flat)
        XCTAssertEqual(s.iconVariant, .trio)
    }

    func testCodableRoundTripPreservesAllFields() throws {
        var s = GameSettings()
        s.noTies       = false
        s.holdMs       = 1000
        s.haptics      = false
        s.sounds       = false
        s.reduceMotion = true
        s.palette      = .mono
        s.iconVariant  = .cycle

        let data = try JSONEncoder().encode(s)
        let decoded = try JSONDecoder().decode(GameSettings.self, from: data)
        XCTAssertEqual(s, decoded)
    }

    // Older payloads must still decode — fields added after release default in.
    func testForwardCompatibleDecodeWithMissingNewFields() throws {
        let json = """
        {"noTies": false, "holdMs": 1000, "haptics": false, "reduceMotion": true, "palette": "mono"}
        """.data(using: .utf8)!

        let decoded = try JSONDecoder().decode(GameSettings.self, from: json)

        XCTAssertFalse(decoded.noTies)
        XCTAssertEqual(decoded.holdMs, 1000)
        XCTAssertFalse(decoded.haptics)
        XCTAssertTrue(decoded.reduceMotion)
        XCTAssertEqual(decoded.palette, .mono)
        // These weren't in the payload — must fall back to defaults, not crash.
        XCTAssertTrue(decoded.sounds)
        XCTAssertEqual(decoded.iconVariant, .trio)
    }

    func testDecodeEmptyObjectUsesAllDefaults() throws {
        let json = "{}".data(using: .utf8)!
        let decoded = try JSONDecoder().decode(GameSettings.self, from: json)
        XCTAssertEqual(decoded, GameSettings())
    }

    // If a future build renames or drops an enum case, decoded older data shouldn't crash —
    // unknown values fall back to default.
    func testDecodeUnknownEnumValueFallsBackToDefault() throws {
        let json = """
        {"palette": "neon_2099", "iconVariant": "spinner_galaxy"}
        """.data(using: .utf8)!
        let decoded = try JSONDecoder().decode(GameSettings.self, from: json)
        XCTAssertEqual(decoded.palette,     .flat)  // GameSettings.init default
        XCTAssertEqual(decoded.iconVariant, .trio)
    }

    func testDecodeWrongTypesFallsBackToDefault() throws {
        // numeric strings, wrong-type bool, etc.
        let json = """
        {"noTies": "yes", "holdMs": "fast", "haptics": 1}
        """.data(using: .utf8)!
        let decoded = try JSONDecoder().decode(GameSettings.self, from: json)
        XCTAssertEqual(decoded, GameSettings(), "any decode error per-field should soft-fail to defaults")
    }
}

// MARK: - SettingsStore (UserDefaults persistence)

final class SettingsStoreTests: XCTestCase {
    private let suiteName = "ShootTests.SettingsStore"
    private var defaults: UserDefaults!

    override func setUp() {
        super.setUp()
        defaults = UserDefaults(suiteName: suiteName)
        defaults.removePersistentDomain(forName: suiteName)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suiteName)
        defaults = nil
        super.tearDown()
    }

    func testFreshStoreReturnsDefaults() {
        let store = SettingsStore(defaults: defaults)
        XCTAssertEqual(store.value, GameSettings())
    }

    func testPatchUpdatesValueAndPersists() {
        let store = SettingsStore(defaults: defaults)
        store.patch { $0.haptics = false; $0.palette = .pop }
        XCTAssertFalse(store.value.haptics)
        XCTAssertEqual(store.value.palette, .pop)

        // New store, same defaults — must read back the persisted value.
        let store2 = SettingsStore(defaults: defaults)
        XCTAssertFalse(store2.value.haptics)
        XCTAssertEqual(store2.value.palette, .pop)
    }

    func testPatchSkipsWriteWhenNoChange() {
        let store = SettingsStore(defaults: defaults)
        store.patch { $0.haptics = true } // already true by default
        // Storage shouldn't be populated for a no-op patch.
        XCTAssertNil(defaults.data(forKey: SettingsStore.storageKey),
                     "no-op patch should not write to defaults")
    }

    func testPersistedSettingsSurviveProcessRestart() {
        // First "launch"
        let s1 = SettingsStore(defaults: defaults)
        s1.patch {
            $0.noTies = false
            $0.palette = .mono
            $0.sounds = false
            $0.holdMs = 1000
        }
        // Simulate process restart
        let s2 = SettingsStore(defaults: defaults)
        XCTAssertFalse(s2.value.noTies)
        XCTAssertEqual(s2.value.palette, .mono)
        XCTAssertFalse(s2.value.sounds)
        XCTAssertEqual(s2.value.holdMs, 1000)
    }

    func testCorruptStoredDataFallsBackToDefaults() {
        defaults.set(Data([0xDE, 0xAD, 0xBE, 0xEF]), forKey: SettingsStore.storageKey)
        let store = SettingsStore(defaults: defaults)
        XCTAssertEqual(store.value, GameSettings(), "corrupt data should fall back, not crash")
    }
}
