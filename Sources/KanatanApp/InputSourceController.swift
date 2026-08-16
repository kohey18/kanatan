import Foundation
import Carbon.HIToolbox

#if canImport(KanatanCore)
import KanatanCore
#endif

struct InputSourceConfiguration {
    let latinSourceID: String
    let latinInputModeID: String
    let japaneseInputModeID: String
    let japaneseSourceID: String

    static let `default` = InputSourceConfiguration(
        latinSourceID: "com.apple.keylayout.ABC",
        latinInputModeID: "com.apple.inputmethod.Roman",
        japaneseInputModeID: "com.apple.inputmethod.Japanese",
        japaneseSourceID: "com.apple.inputmethod.Kotoeri.RomajiTyping"
    )
}

final class InputSourceController {
    /// Marks key events posted by Kanatan itself so CommandKeyMonitor can
    /// ignore them instead of treating them as user chords.
    static let syntheticEventUserData: Int64 = 0x4B414E41 // "KANA"

    private let configuration: InputSourceConfiguration

    // Primary mechanism: post the JIS Eisu/Kana key, exactly like a JIS
    // keyboard (and like cmd-eikana / Karabiner-Elements). IMEs such as
    // Google Japanese Input handle these keys natively and per input
    // context, which TISSelectInputSource does not do reliably.
    // TIS selection is kept as a fallback, verified shortly after the key
    // post, for setups where the Eisu/Kana keys are unbound or no IME is
    // active.
    private let verifyDelay: DispatchTimeInterval = .milliseconds(150)
    private var pendingVerification: DispatchWorkItem?

    private enum JISKey: CGKeyCode {
        case eisu = 102 // kVK_JIS_Eisu
        case kana = 104 // kVK_JIS_Kana
    }

    init(configuration: InputSourceConfiguration = .default) {
        self.configuration = configuration
    }

    func perform(_ action: CommandTapAction) {
        pendingVerification?.cancel()

        switch action {
        case .selectLatin:
            postKey(.eisu)
        case .selectJapanese:
            postKey(.kana)
        }

        scheduleVerification(for: action)
    }

    // MARK: - JIS key posting

    private func postKey(_ key: JISKey) {
        guard let source = CGEventSource(stateID: .hidSystemState),
              let down = CGEvent(keyboardEventSource: source, virtualKey: key.rawValue, keyDown: true),
              let up = CGEvent(keyboardEventSource: source, virtualKey: key.rawValue, keyDown: false) else {
            print("Failed to create key event for keyCode \(key.rawValue)")
            return
        }

        down.setIntegerValueField(.eventSourceUserData, value: Self.syntheticEventUserData)
        up.setIntegerValueField(.eventSourceUserData, value: Self.syntheticEventUserData)
        down.post(tap: .cghidEventTap)
        up.post(tap: .cghidEventTap)
    }

    // MARK: - TIS fallback

    private func scheduleVerification(for action: CommandTapAction) {
        let verification = DispatchWorkItem { [weak self] in
            guard let self, !self.isSatisfied(action) else { return }
            self.selectViaTIS(action)
        }
        pendingVerification = verification
        DispatchQueue.main.asyncAfter(deadline: .now() + verifyDelay, execute: verification)
    }

    private func isSatisfied(_ action: CommandTapAction) -> Bool {
        guard let source = TISCopyCurrentKeyboardInputSource()?.takeRetainedValue() else {
            return true
        }

        switch action {
        case .selectLatin:
            guard let pointer = TISGetInputSourceProperty(source, kTISPropertyInputSourceIsASCIICapable) else {
                return false
            }
            return CFBooleanGetValue(Unmanaged<CFBoolean>.fromOpaque(pointer).takeUnretainedValue())
        case .selectJapanese:
            // Match the actual Japanese mode/source, not just "non-ASCII",
            // so other CJK input sources are not mistaken for success.
            if let pointer = TISGetInputSourceProperty(source, kTISPropertyInputModeID),
               Unmanaged<CFString>.fromOpaque(pointer).takeUnretainedValue() as String == configuration.japaneseInputModeID {
                return true
            }
            return currentInputSourceID() == configuration.japaneseSourceID
        }
    }

    private func selectViaTIS(_ action: CommandTapAction) {
        switch action {
        case .selectLatin:
            // ABC keylayout is not always enabled (e.g. IME-only setups),
            // so fall back to the IM's Roman mode, then to any ASCII-capable source.
            if !selectSource(property: kTISPropertyInputSourceID, value: configuration.latinSourceID),
               !selectSource(property: kTISPropertyInputModeID, value: configuration.latinInputModeID) {
                selectCurrentASCIICapableSource()
            }
        case .selectJapanese:
            if !selectSource(property: kTISPropertyInputModeID, value: configuration.japaneseInputModeID) {
                _ = selectSource(property: kTISPropertyInputSourceID, value: configuration.japaneseSourceID)
            }
        }
    }

    @discardableResult
    private func selectSource(property: CFString, value: String) -> Bool {
        let filter = [property as String: value] as CFDictionary
        // TISCreateInputSourceList returns nil (not an empty array) when nothing matches.
        guard let unmanagedSources = TISCreateInputSourceList(filter, false) else {
            print("No input source matched \(value)")
            return false
        }

        let sources = unmanagedSources.takeRetainedValue()
        guard CFArrayGetCount(sources) > 0 else {
            print("No input source matched \(value)")
            return false
        }

        let sourcePointer = CFArrayGetValueAtIndex(sources, 0)
        let source = unsafeBitCast(sourcePointer, to: TISInputSource.self)
        let status = TISSelectInputSource(source)
        if status != noErr {
            print("TISSelectInputSource failed for \(value): \(status)")
            return false
        }

        return true
    }

    private func currentInputSourceID() -> String? {
        guard let source = TISCopyCurrentKeyboardInputSource()?.takeRetainedValue(),
              let pointer = TISGetInputSourceProperty(source, kTISPropertyInputSourceID) else {
            return nil
        }

        return Unmanaged<CFString>.fromOpaque(pointer).takeUnretainedValue() as String
    }

    private func selectCurrentASCIICapableSource() {
        guard let source = TISCopyCurrentASCIICapableKeyboardInputSource()?.takeRetainedValue() else {
            print("No ASCII-capable input source available")
            return
        }

        let status = TISSelectInputSource(source)
        if status != noErr {
            print("TISSelectInputSource failed for ASCII-capable fallback: \(status)")
        }
    }
}
