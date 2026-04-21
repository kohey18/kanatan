# cmd-eisuu-kana

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

- macOS 12+
- Accessibility permission for the app
- Japanese input source enabled in macOS

## Build

### Option A: Swift Package / Xcode

Open the package in Xcode and run the executable product:

```bash
open Package.swift
```

### Option B: local dev script

```bash
./scripts/build-dev.sh
```

This builds a local binary at:

```bash
./bin/cmd-eisuu-kana
```

## Run

After building:

```bash
./bin/cmd-eisuu-kana
```

On first launch, grant **Accessibility** permission when macOS prompts you.

If permission was denied once, open it manually:

- System Settings → Privacy & Security → Accessibility
- enable `cmd-eisuu-kana`

The menu bar item also includes:

- **Retry Monitoring**
- **Open Accessibility Settings**
- **Quit cmd-eisuu-kana**

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
