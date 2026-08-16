public enum CommandSide: Equatable, Hashable {
    case left
    case right
}

public enum CommandTapAction: Equatable {
    case selectLatin
    case selectJapanese
}

public struct CommandTapInterpreter {
    private var pressedSides: Set<CommandSide> = []
    private var candidateSide: CommandSide?
    private var chordDetected = false

    public init() {}

    public func isPressed(_ side: CommandSide) -> Bool {
        pressedSides.contains(side)
    }

    public mutating func modifierChanged(side: CommandSide, isPressed: Bool) -> CommandTapAction? {
        if isPressed {
            handlePress(of: side)
            return nil
        }

        return handleRelease(of: side)
    }

    public mutating func nonModifierKeyPressed() {
        if !pressedSides.isEmpty {
            chordDetected = true
        }
    }

    public mutating func otherModifierChanged() {
        if !pressedSides.isEmpty {
            chordDetected = true
        }
    }

    private mutating func handlePress(of side: CommandSide) {
        let inserted = pressedSides.insert(side).inserted
        guard inserted else { return }

        if pressedSides.count == 1 {
            candidateSide = side
            chordDetected = false
            return
        }

        candidateSide = nil
        chordDetected = true
    }

    private mutating func handleRelease(of side: CommandSide) -> CommandTapAction? {
        let removed = pressedSides.remove(side) != nil
        guard removed else { return nil }

        defer {
            if pressedSides.isEmpty {
                candidateSide = nil
                chordDetected = false
            }
        }

        guard candidateSide == side, !chordDetected, pressedSides.isEmpty else {
            return nil
        }

        switch side {
        case .left:
            return .selectLatin
        case .right:
            return .selectJapanese
        }
    }
}
