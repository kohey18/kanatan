#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SDKROOT="$(xcrun --sdk macosx --show-sdk-path)"
mkdir -p "$ROOT_DIR/bin"

swiftc \
  -sdk "$SDKROOT" \
  -framework AppKit \
  -framework ApplicationServices \
  -framework Carbon \
  "$ROOT_DIR"/Sources/CmdEisuuKanaCore/*.swift \
  "$ROOT_DIR"/Sources/CmdEisuuKanaApp/*.swift \
  -o "$ROOT_DIR/bin/cmd-eisuu-kana"

echo "Built $ROOT_DIR/bin/cmd-eisuu-kana"
