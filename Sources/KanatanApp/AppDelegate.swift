import AppKit
import ApplicationServices
import ServiceManagement

final class AppDelegate: NSObject, NSApplicationDelegate {
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private let inputSourceController = InputSourceController()
    private var commandKeyMonitor: CommandKeyMonitor?
    private var loginItemMenuItem: NSMenuItem?

    func applicationDidFinishLaunching(_ notification: Notification) {
        configureStatusMenu()
        registerLoginItemIfNeeded()
        startMonitoring(promptForAccessibility: true)
    }

    /// Registers the app as a login item once, on first launch.
    /// After that the user's choice via the "Start at Login" menu wins.
    private func registerLoginItemIfNeeded() {
        let key = "didAttemptAutoLoginItemRegistration"
        guard !UserDefaults.standard.bool(forKey: key) else { return }

        let service = SMAppService.mainApp
        guard service.status == .notRegistered else {
            UserDefaults.standard.set(true, forKey: key)
            return
        }

        do {
            try service.register()
            UserDefaults.standard.set(true, forKey: key)
        } catch {
            // .app バンドル外（swift run など）から実行した場合は登録できない。
            // フラグを立てず、次のバンドル起動時に再試行する。
            print("Failed to auto-register login item: \(error)")
        }
    }

    private func configureStatusMenu() {
        updateStatusIcon(needsAttention: false)

        let menu = NSMenu()
        menu.delegate = self
        menu.addItem(NSMenuItem(title: "Retry Monitoring", action: #selector(retryMonitoring), keyEquivalent: "r"))
        menu.addItem(NSMenuItem(title: "Open Accessibility Settings", action: #selector(openAccessibilitySettings), keyEquivalent: ","))
        menu.addItem(.separator())
        let loginItem = NSMenuItem(title: "Start at Login", action: #selector(toggleLoginItem), keyEquivalent: "")
        menu.addItem(loginItem)
        loginItemMenuItem = loginItem
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: "Quit Kanatan", action: #selector(quitApp), keyEquivalent: "q"))
        menu.items.forEach { $0.target = self }
        statusItem.menu = menu
    }

    private func startMonitoring(promptForAccessibility: Bool) {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: promptForAccessibility] as CFDictionary
        let isTrusted = AXIsProcessTrustedWithOptions(options)
        guard isTrusted else {
            updateStatusIcon(needsAttention: true, toolTip: "Kanatan — アクセシビリティ許可が必要です。許可後にメニューの Retry Monitoring を押してください。")
            print("Accessibility permission is required to monitor Command key taps.")
            return
        }

        do {
            let monitor = CommandKeyMonitor(inputSourceController: inputSourceController)
            try monitor.start()
            commandKeyMonitor = monitor
            updateStatusIcon(needsAttention: false)
        } catch {
            updateStatusIcon(needsAttention: true, toolTip: "Kanatan — 監視を開始できません。メニューの Retry Monitoring を押してください。")
            print("Failed to start monitor: \(error)")
        }
    }

    private func updateStatusIcon(needsAttention: Bool, toolTip: String? = nil) {
        statusItem.button?.image = statusIcon(needsAttention: needsAttention)
        statusItem.button?.toolTip = toolTip ?? "Kanatan — 左⌘で英数、右⌘でかな"
    }

    private func statusIcon(needsAttention: Bool) -> NSImage {
        let size = NSSize(width: 18, height: 18)
        return NSImage(size: size, flipped: false) { rect in
            let appIcon = NSImage(named: "AppIcon") ?? NSApp.applicationIconImage
            appIcon?.draw(in: rect, from: .zero, operation: .sourceOver, fraction: 1)

            if needsAttention {
                let dot = NSRect(x: rect.maxX - 8, y: 0, width: 8, height: 8)
                NSColor.white.setFill()
                NSBezierPath(ovalIn: dot.insetBy(dx: -1, dy: -1)).fill()
                NSColor.systemRed.setFill()
                NSBezierPath(ovalIn: dot).fill()
            }

            return true
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

    @objc private func toggleLoginItem() {
        let service = SMAppService.mainApp
        do {
            if service.status == .enabled {
                try service.unregister()
            } else {
                try service.register()
            }
        } catch {
            // .app バンドル外（swift run など）から実行した場合は登録できない
            print("Failed to toggle login item: \(error)")
        }
    }

    @objc private func quitApp() {
        NSApp.terminate(nil)
    }
}

extension AppDelegate: NSMenuDelegate {
    func menuWillOpen(_ menu: NSMenu) {
        loginItemMenuItem?.state = SMAppService.mainApp.status == .enabled ? .on : .off
    }
}
