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

        let eventMask = (CGEventMask(1) << CGEventType.flagsChanged.rawValue)
            | (CGEventMask(1) << CGEventType.keyDown.rawValue)

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
        case .flagsChanged:
            handleFlagsChanged(event)
        default:
            break
        }

        return Unmanaged.passUnretained(event)
    }

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
            isPressed = flags.contains(.maskCommand)
        case .right:
            isPressed = flags.contains(.maskCommand)
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
