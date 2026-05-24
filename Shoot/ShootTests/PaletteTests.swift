import XCTest
@testable import Shoot

final class PaletteTests: XCTestCase {

    func testEveryPaletteHasColorsForBothSides() {
        for p in Palette.allCases {
            for side in [Side.top, .bot] {
                let s = p.side(side)
                XCTAssertFalse(s.colors.isEmpty,
                               "\(p)/\(side) palette side has no colors")
                XCTAssertTrue(s.colors.count == 1 || s.colors.count == 2,
                              "\(p)/\(side) should be solid (1) or gradient (2), got \(s.colors.count)")
            }
        }
    }

    func testFlatIsSolidColors() {
        XCTAssertEqual(Palette.flat.side(.top).colors.count, 1)
        XCTAssertEqual(Palette.flat.side(.bot).colors.count, 1)
    }

    func testCandyAndPopAreGradients() {
        XCTAssertEqual(Palette.candy.side(.top).colors.count, 2)
        XCTAssertEqual(Palette.candy.side(.bot).colors.count, 2)
        XCTAssertEqual(Palette.pop.side(.top).colors.count,   2)
        XCTAssertEqual(Palette.pop.side(.bot).colors.count,   2)
    }

    // Mono is the only palette that flips foreground tint per side
    // (white text on black top, ink text on light bot).
    func testMonoFlipsTintAndHandFillOnLightSide() {
        let top = Palette.mono.side(.top)
        let bot = Palette.mono.side(.bot)
        XCTAssertEqual(top.tint,     .white)
        XCTAssertEqual(top.handFill, .white)
        XCTAssertEqual(bot.tint,     .ink)
        XCTAssertEqual(bot.handFill, .ink)
    }

    func testNonMonoPalettesAllUseWhiteTint() {
        for p in [Palette.candy, .flat, .pop] {
            for side in [Side.top, .bot] {
                XCTAssertEqual(p.side(side).tint, .white,
                               "\(p)/\(side) should use white tint")
            }
        }
    }

    func testPaletteIsCodable() throws {
        for p in Palette.allCases {
            let data = try JSONEncoder().encode(p)
            let decoded = try JSONDecoder().decode(Palette.self, from: data)
            XCTAssertEqual(p, decoded)
        }
    }

    func testIdleIconVariantIsCodable() throws {
        for v in IdleIconVariant.allCases {
            let data = try JSONEncoder().encode(v)
            let decoded = try JSONDecoder().decode(IdleIconVariant.self, from: data)
            XCTAssertEqual(v, decoded)
        }
    }

    func testPaletteDisplayNamesNonEmpty() {
        for p in Palette.allCases {
            XCTAssertFalse(p.displayName.isEmpty)
        }
    }

    func testIdleIconDisplayNamesNonEmpty() {
        for v in IdleIconVariant.allCases {
            XCTAssertFalse(v.displayName.isEmpty)
        }
    }
}
