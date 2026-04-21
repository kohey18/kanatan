import Foundation
import Carbon.HIToolbox

#if canImport(CmdEisuuKanaCore)
import CmdEisuuKanaCore
#endif

struct InputSourceConfiguration {
    let latinSourceID: String
    let japaneseInputModeID: String
    let japaneseSourceID: String

    static let `default` = InputSourceConfiguration(
        latinSourceID: "com.apple.keylayout.ABC",
        japaneseInputModeID: "com.apple.inputmethod.Japanese",
        japaneseSourceID: "com.apple.inputmethod.Kotoeri.RomajiTyping"
    )
}

final class InputSourceController {
    private let configuration: InputSourceConfiguration

    init(configuration: InputSourceConfiguration = .default) {
        self.configuration = configuration
    }

    func perform(_ action: CommandTapAction) {
        switch action {
        case .selectLatin:
            _ = selectSource(property: kTISPropertyInputSourceID, value: configuration.latinSourceID)
        case .selectJapanese:
            if !selectSource(property: kTISPropertyInputModeID, value: configuration.japaneseInputModeID) {
                _ = selectSource(property: kTISPropertyInputSourceID, value: configuration.japaneseSourceID)
            }
        }
    }

    @discardableResult
    private func selectSource(property: CFString, value: String) -> Bool {
        let filter = [property as String: value] as CFDictionary
        let sources = TISCreateInputSourceList(filter, false).takeRetainedValue()
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
}
