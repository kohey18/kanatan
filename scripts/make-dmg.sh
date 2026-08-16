#!/bin/zsh
# Release ビルドから配布用DMG（ドラッグ&ドロップインストール形式）を作成する
# 使い方: ./scripts/make-dmg.sh [version]   (要: brew install create-dmg)
set -e
cd "$(dirname "$0")/.."

VERSION=${1:-0.1.0}
APP=build/DerivedData/Build/Products/Release/Kanatan.app
if [ ! -d "$APP" ]; then
  echo "ビルドが見つかりません。先に ./scripts/install.sh を実行してください" >&2
  exit 1
fi

STAGING=build/dmg-staging
rm -rf "$STAGING" && mkdir -p "$STAGING"
ditto "$APP" "$STAGING/Kanatan.app"

OUT=build/Kanatan-$VERSION.dmg
rm -f "$OUT"

create-dmg \
  --volname "Kanatan" \
  --volicon "$APP/Contents/Resources/AppIcon.icns" \
  --background "scripts/dmg-background.png" \
  --window-pos 200 150 \
  --window-size 660 420 \
  --icon-size 128 \
  --icon "Kanatan.app" 165 190 \
  --app-drop-link 495 190 \
  --hide-extension "Kanatan.app" \
  "$OUT" "$STAGING"

echo "✅ $OUT を作成しました"
