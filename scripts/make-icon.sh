#!/bin/zsh
# 1024x1024 のマスターPNGから AppIcon.appiconset の全サイズを生成する
# 使い方: ./scripts/make-icon.sh path/to/icon-1024.png
set -e
cd "$(dirname "$0")/.."

MASTER="$1"
if [ -z "$MASTER" ] || [ ! -f "$MASTER" ]; then
  echo "使い方: ./scripts/make-icon.sh path/to/icon-1024.png" >&2
  exit 1
fi

DEST=Resources/Assets.xcassets/AppIcon.appiconset

for SIZE in 16 32 128 256 512; do
  sips -z $SIZE $SIZE "$MASTER" --out "$DEST/icon_${SIZE}.png" > /dev/null
  DOUBLE=$((SIZE * 2))
  sips -z $DOUBLE $DOUBLE "$MASTER" --out "$DEST/icon_${SIZE}@2x.png" > /dev/null
done

cat > "$DEST/Contents.json" <<'JSON'
{
  "images" : [
    { "idiom" : "mac", "scale" : "1x", "size" : "16x16", "filename" : "icon_16.png" },
    { "idiom" : "mac", "scale" : "2x", "size" : "16x16", "filename" : "icon_16@2x.png" },
    { "idiom" : "mac", "scale" : "1x", "size" : "32x32", "filename" : "icon_32.png" },
    { "idiom" : "mac", "scale" : "2x", "size" : "32x32", "filename" : "icon_32@2x.png" },
    { "idiom" : "mac", "scale" : "1x", "size" : "128x128", "filename" : "icon_128.png" },
    { "idiom" : "mac", "scale" : "2x", "size" : "128x128", "filename" : "icon_128@2x.png" },
    { "idiom" : "mac", "scale" : "1x", "size" : "256x256", "filename" : "icon_256.png" },
    { "idiom" : "mac", "scale" : "2x", "size" : "256x256", "filename" : "icon_256@2x.png" },
    { "idiom" : "mac", "scale" : "1x", "size" : "512x512", "filename" : "icon_512.png" },
    { "idiom" : "mac", "scale" : "2x", "size" : "512x512", "filename" : "icon_512@2x.png" }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
JSON

echo "✅ $DEST にアイコンを生成しました。./scripts/install.sh で再ビルドしてください。"
