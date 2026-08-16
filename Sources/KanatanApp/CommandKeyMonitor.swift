import Foundation
import ApplicationServices

#if canImport(KanatanCore)
import KanatanCore
#endif

enum CommandKeyMonitorError: Error {
    case unableToCreateEventTap
}

final class CommandKeyMonitor {
    private let inputSourceController: InputSourceController
    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private var interpreter = CommandTapInterpreter()

    init(inputSourceController: InputSourceController) {
        self.inputSourceController = inputSourceController
    }

    deinit {
        stop()
    }

    func start() throws {
        guard eventTap == nil else { return }

        // Mouse events are included so that ⌘-click / ⌘-scroll count as chords.
        let eventMask = (CGEventMask(1) << CGEventType.flagsChanged.rawValue)
            | (CGEventMask(1) << CGEventType.keyDown.rawValue)
            | (CGEventMask(1) << CGEventType.leftMouseDown.rawValue)
            | (CGEventMask(1) << CGEventType.rightMouseDown.rawValue)
            | (CGEventMask(1) << CGEventType.otherMouseDown.rawValue)
            | (CGEventMask(1) << CGEventType.scrollWheel.rawValue)

        let callback: CGEventTapCallBack = { _, type, event, userInfo in
            guard let userInfo else {
                return Unmanaged.passUnretained(event)
            }

            let monitor = Unmanaged<CommandKeyMonitor>.fromOpaque(userInfo).takeUnretainedValue()
            return monitor.handle(event: event, type: type)
        }

        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .listenOnly,
            eventsOfInterest: eventMask,
            callback: callback,
            userInfo: UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        ) else {
            throw CommandKeyMonitorError.unableToCreateEventTap
        }

        let source = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), source, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)

        eventTap = tap
        runLoopSource = source
    }

    func stop() {
        if let eventTap {
            CGEvent.tapEnable(tap: eventTap, enable: false)
        }

        if let runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
            self.runLoopSource = nil
        }

        if let eventTap {
            CFMachPortInvalidate(eventTap)
            self.eventTap = nil
        }
    }

    private func handle(event: CGEvent, type: CGEventType) -> Unmanaged<CGEvent>? {
        switch type {
        case .tapDisabledByTimeout, .tapDisabledByUserInput:
            if let eventTap {
                CGEvent.tapEnable(tap: eventTap, enable: true)
            }
        case .keyDown:
            // Ignore the Eisu/Kana key events Kanatan posts itself.
            if event.getIntegerValueField(.eventSourceUserData) != InputSourceController.syntheticEventUserData {
                interpreter.nonModifierKeyPressed()
            }
        case .leftMouseDown, .rightMouseDown, .otherMouseDown, .scrollWheel:
            interpreter.nonModifierKeyPressed()
        case .flagsChanged:
            handleFlagsChanged(event)
        default:
            break
        }

        return Unmanaged.passUnretained(event)
    }

    // Device-specific NX flag bits: .maskCommand is shared by both sides, so
    // releasing one ⌘ while the other is held would otherwise read as pressed.
    private static let leftCommandFlag: UInt64 = 0x0000_0008 // NX_DEVICELCMDKEYMASK
    private static let rightCommandFlag: UInt64 = 0x0000_0010 // NX_DEVICERCMDKEYMASK

    private func handleFlagsChanged(_ event: CGEvent) {
        let keyCode = event.getIntegerValueField(.keyboardEventKeycode)

        guard let side = commandSide(for: keyCode) else {
            interpreter.otherModifierChanged()
            return
        }

        let flags = event.flags
        let isPressed: Bool
        switch side {
        case .left:
            isPressed = flags.rawValue & Self.leftCommandFlag != 0
        case .right:
            isPressed = flags.rawValue & Self.rightCommandFlag != 0
        }

        // A ⌘ tap while Shift/Control/Option/fn is held is a chord, not a tap.
        let otherModifiers: CGEventFlags = [.maskShift, .maskControl, .maskAlternate, .maskSecondaryFn]
        if !flags.intersection(otherModifiers).isEmpty {
            interpreter.otherModifierChanged()
        }

        guard let action = interpreter.modifierChanged(side: side, isPressed: isPressed) else {
            return
        }

        inputSourceController.perform(action)
    }

    private func commandSide(for keyCode: Int64) -> CommandSide? {
        switch keyCode {
        case 55:
            return .left
        case 54:
            return .right
        default:
            return nil
        }
    }
}
