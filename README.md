# Kanatan

A tiny macOS menu bar app that makes:

- **Left Command (single tap)** → **ABC / 英数**
- **Right Command (single tap)** → **Japanese / かな**

When Command is used as a real modifier (`⌘C`, `⌘V`, `⌘Tab`, etc.), the app does **nothing** and lets the shortcut behave normally.

## Current status

This repository currently contains the first working prototype:

- menu bar app
- global event tap for left/right Command detection
- single-tap vs chord discrimination
- input source switching through macOS text input APIs

## Behavior

- left Command press + release alone → switch to `ABC`
- right Command press + release alone → switch to Japanese input mode
- Command used together with another key → no input-source switch
- pressing both Command keys cancels single-tap behavior

## Requirements

- macOS 13+
- Accessibility permission for the app
- Japanese input source enabled in macOS

## Install as a Mac app

The app project is generated with [xcodegen](https://github.com/yonaskolb/XcodeGen) (like [editan](https://github.com/kohey18/editan)):

```bash
brew install xcodegen   # first time only
./scripts/install.sh
```

This builds `CmdEisuuKana.app` (Release) and installs it to `/Applications`.

### App icon

Place a 1024x1024 master PNG anywhere and run:

```bash
./scripts/make-icon.sh path/to/icon-1024.png
./scripts/install.sh
```

### Start at Login

The app registers itself as a login item automatically on first launch (macOS 13+, works only when running from the `.app` bundle). Use the menu bar item → **Start at Login** to toggle it afterwards; your choice is respected on subsequent launches.

## Development build (without Xcode project)

### Option A: Swift Package

```bash
swift build
```

### Option B: local dev script

```bash
./scripts/build-dev.sh
./bin/kanatan
```

On first launch, grant **Accessibility** permission when macOS prompts you.

If permission was denied once, open it manually:

- System Settings → Privacy & Security → Accessibility
- enable `Kanatan`

The menu bar item also includes:

- **Retry Monitoring**
- **Open Accessibility Settings**
- **Quit Kanatan**

## Development checks

Core tap-discrimination checks can be run without launching the app:

```bash
./scripts/check-core.sh
```

## Notes

Default input source identifiers are currently:

- Latin: `com.apple.keylayout.ABC`
- Japanese input mode: `com.apple.inputmethod.Japanese`
- Japanese source fallback: `com.apple.inputmethod.Kotoeri.RomajiTyping`

If a machine uses a different Japanese input source configuration, we can make these identifiers configurable next.
