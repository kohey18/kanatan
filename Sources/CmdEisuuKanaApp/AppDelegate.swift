import AppKit
import ApplicationServices

final class AppDelegate: NSObject, NSApplicationDelegate {
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private let inputSourceController = InputSourceController()
    private var commandKeyMonitor: CommandKeyMonitor?

    func applicationDidFinishLaunching(_ notification: Notification) {
        configureStatusMenu()
        startMonitoring(promptForAccessibility: true)
    }

    private func configureStatusMenu() {
        statusItem.button?.title = "英/かな"

        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Retry Monitoring", action: #selector(retryMonitoring), keyEquivalent: "r"))
        menu.addItem(NSMenuItem(title: "Open Accessibility Settings", action: #selector(openAccessibilitySettings), keyEquivalent: ","))
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: "Quit cmd-eisuu-kana", action: #selector(quitApp), keyEquivalent: "q"))
        menu.items.forEach { $0.target = self }
        statusItem.menu = menu
    }

    private func startMonitoring(promptForAccessibility: Bool) {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: promptForAccessibility] as CFDictionary
        let isTrusted = AXIsProcessTrustedWithOptions(options)
        guard isTrusted else {
            statusItem.button?.title = "要許可"
            print("Accessibility permission is required to monitor Command key taps.")
            return
        }

        do {
            let monitor = CommandKeyMonitor(inputSourceController: inputSourceController)
            try monitor.start()
            commandKeyMonitor = monitor
            statusItem.button?.title = "英/かな"
        } catch {
            statusItem.button?.title = "失敗"
            print("Failed to start monitor: \(error)")
        }
    }

    @objc private func retryMonitoring() {
        commandKeyMonitor?.stop()
        commandKeyMonitor = nil
        startMonitoring(promptForAccessibility: false)
    }

    @objc private func openAccessibilitySettings() {
        guard let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") else {
            return
        }

        NSWorkspace.shared.open(url)
    }

    @objc private func quitApp() {
        NSApp.terminate(nil)
    }
}
