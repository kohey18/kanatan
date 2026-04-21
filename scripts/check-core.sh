#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

cat >"$TMP_DIR/checks.swift" <<'SWIFT'
import Foundation

func assertEqual<T: Equatable>(_ actual: T?, _ expected: T?, _ message: String) {
    if actual != expected {
        fputs("FAIL: \(message). expected=\(String(describing: expected)) actual=\(String(describing: actual))\n", stderr)
        exit(1)
    }
}

func assertNil<T>(_ actual: T?, _ message: String) {
    if actual != nil {
        fputs("FAIL: \(message). expected=nil actual=\(String(describing: actual))\n", stderr)
        exit(1)
    }
}

@main
struct CheckRunner {
    static func main() {
        do {
            var interpreter = CommandTapInterpreter()
            assertNil(interpreter.modifierChanged(side: .left, isPressed: true), "left press should not trigger action")
            assertEqual(interpreter.modifierChanged(side: .left, isPressed: false), .selectLatin, "left single tap should request latin")
        }

        do {
            var interpreter = CommandTapInterpreter()
            assertNil(interpreter.modifierChanged(side: .right, isPressed: true), "right press should not trigger action")
            assertEqual(interpreter.modifierChanged(side: .right, isPressed: false), .selectJapanese, "right single tap should request japanese")
        }

        do {
            var interpreter = CommandTapInterpreter()
            assertNil(interpreter.modifierChanged(side: .left, isPressed: true), "left press should not trigger action")
            interpreter.nonModifierKeyPressed()
            assertNil(interpreter.modifierChanged(side: .left, isPressed: false), "chord should not trigger input switch")
        }

        do {
            var interpreter = CommandTapInterpreter()
            assertNil(interpreter.modifierChanged(side: .left, isPressed: true), "left press should not trigger action")
            assertNil(interpreter.modifierChanged(side: .right, isPressed: true), "pressing other command should cancel single tap")
            assertNil(interpreter.modifierChanged(side: .right, isPressed: false), "releasing second command should not trigger input switch")
            assertNil(interpreter.modifierChanged(side: .left, isPressed: false), "releasing original command after crossover should not trigger input switch")
        }

        do {
            var interpreter = CommandTapInterpreter()
            assertNil(interpreter.modifierChanged(side: .left, isPressed: true), "left press should not trigger action")
            interpreter.otherModifierChanged()
            assertNil(interpreter.modifierChanged(side: .left, isPressed: false), "other modifier should cancel single tap")
        }

        print("Core checks passed")
    }
}
SWIFT

swiftc \
  "$ROOT_DIR/Sources/CmdEisuuKanaCore/CommandTapInterpreter.swift" \
  "$TMP_DIR/checks.swift" \
  -o "$TMP_DIR/checks"

"$TMP_DIR/checks"
