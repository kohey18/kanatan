#!/bin/zsh
# Release ビルドして /Applications にインストールする
set -e
cd "$(dirname "$0")/.."

xcodegen generate
xcodebuild -project Kanatan.xcodeproj -scheme Kanatan -configuration Release \
  -derivedDataPath build/DerivedData build | grep -E "error:|warning: .*deprecated|BUILD" || true

APP=build/DerivedData/Build/Products/Release/Kanatan.app
if [ ! -d "$APP" ]; then
  echo "ビルド失敗: $APP がありません" >&2
  exit 1
fi

osascript -e 'tell application "Kanatan" to quit' 2>/dev/null || true
sleep 1
rm -rf /Applications/Kanatan.app
ditto "$APP" /Applications/Kanatan.app
echo "✅ /Applications/Kanatan.app にインストールしました"
