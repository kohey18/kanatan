import XCTest
@testable import KanatanCore

final class CommandTapInterpreterTests: XCTestCase {
    func testLeftCommandSingleTapRequestsLatinInput() {
        var interpreter = CommandTapInterpreter()

        XCTAssertNil(interpreter.modifierChanged(side: .left, isPressed: true))
        XCTAssertEqual(interpreter.modifierChanged(side: .left, isPressed: false), .selectLatin)
    }

    func testRightCommandSingleTapRequestsJapaneseInput() {
        var interpreter = CommandTapInterpreter()

        XCTAssertNil(interpreter.modifierChanged(side: .right, isPressed: true))
        XCTAssertEqual(interpreter.modifierChanged(side: .right, isPressed: false), .selectJapanese)
    }

    func testChordDoesNotTriggerInputSwitch() {
        var interpreter = CommandTapInterpreter()

        XCTAssertNil(interpreter.modifierChanged(side: .left, isPressed: true))
        interpreter.nonModifierKeyPressed()
        XCTAssertNil(interpreter.modifierChanged(side: .left, isPressed: false))
    }

    func testSwitchingToOtherCommandCancelsSingleTapBehavior() {
        var interpreter = CommandTapInterpreter()

        XCTAssertNil(interpreter.modifierChanged(side: .left, isPressed: true))
        XCTAssertNil(interpreter.modifierChanged(side: .right, isPressed: true))
        XCTAssertNil(interpreter.modifierChanged(side: .right, isPressed: false))
        XCTAssertNil(interpreter.modifierChanged(side: .left, isPressed: false))
    }

    func testOtherModifierWhileCommandPressedCancelsSingleTapBehavior() {
        var interpreter = CommandTapInterpreter()

        XCTAssertNil(interpreter.modifierChanged(side: .left, isPressed: true))
        interpreter.otherModifierChanged()
        XCTAssertNil(interpreter.modifierChanged(side: .left, isPressed: false))
    }
}
