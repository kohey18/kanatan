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
  "$ROOT_DIR"/Sources/KanatanCore/*.swift \
  "$ROOT_DIR"/Sources/KanatanApp/*.swift \
  -o "$ROOT_DIR/bin/kanatan"

echo "Built $ROOT_DIR/bin/kanatan"
