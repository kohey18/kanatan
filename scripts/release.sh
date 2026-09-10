#!/bin/zsh
# Build a universal Developer ID app, notarize it, and package a verified DMG.
set -euo pipefail
cd "$(dirname "$0")/.."
APP_NAME=Kanatan
APPLE_TEAM_ID=${APPLE_TEAM_ID:-3U5Y9G26T3}
DEVELOPER_ID_APPLICATION=${DEVELOPER_ID_APPLICATION:-"Developer ID Application: Kohei Kawai (3U5Y9G26T3)"}
SCRIPT_NAME=$0
MODE=${1:---help}
usage() {
  echo "Usage: $SCRIPT_NAME --check | --build-only VERSION BUILD_NUMBER | VERSION BUILD_NUMBER"
  echo "Defaults: Kohei Kawai Developer ID, team 3U5Y9G26T3, Keychain profile macos-notary."
  echo "Override with DEVELOPER_ID_APPLICATION, APPLE_TEAM_ID, and NOTARY_PROFILE."
  echo "--build-only produces a local ad-hoc app, never a distributable DMG."
}
case "$MODE" in
  --help|-h) usage; exit 0 ;;
  --check) ;;
  --build-only) shift ;;
  --*) usage >&2; exit 1 ;;
esac
for tool in xcodegen xcodebuild xcrun codesign security ditto hdiutil lipo; do
  command -v "$tool" >/dev/null || { echo "Missing tool: $tool" >&2; exit 1; }
done
if [[ "$MODE" != --build-only ]]; then
  IDENTITIES=$(security find-identity -v -p codesigning)
  if [[ -z "${DEVELOPER_ID_APPLICATION:-}" || -z "${APPLE_TEAM_ID:-}" ]]; then
    echo 'Set APPLE_TEAM_ID and DEVELOPER_ID_APPLICATION to your distribution team and full certificate name.' >&2
    echo "$IDENTITIES" | /usr/bin/grep 'Developer ID Application:' || true
    exit 1
  fi
  [[ "$DEVELOPER_ID_APPLICATION" == "Developer ID Application: "*" ($APPLE_TEAM_ID)" ]] || {
    echo 'Expected a Developer ID Application identity belonging to APPLE_TEAM_ID.' >&2; exit 1
  }
  echo "$IDENTITIES" | /usr/bin/grep -F -- "\"$DEVELOPER_ID_APPLICATION\"" >/dev/null || {
    echo 'No valid matching certificate and private key in the Keychain.' >&2; exit 1
  }
  NOTARY_PROFILE=${NOTARY_PROFILE:-macos-notary}
  xcrun notarytool history --keychain-profile "$NOTARY_PROFILE" --output-format json >/dev/null
  if [[ "$MODE" == --check ]]; then
    echo 'Developer ID identity and notarization credentials verified.'; exit 0
  fi
fi
[[ $# == 2 ]] || { usage >&2; exit 1; }
VERSION=$1
BUILD_NUMBER=$2
[[ "$VERSION" =~ '^[0-9]+[.][0-9]+[.][0-9]+$' && "$BUILD_NUMBER" =~ '^[1-9][0-9]*$' ]] || {
  echo 'Expected numeric VERSION (e.g. 0.1.1) and positive BUILD_NUMBER.' >&2; exit 1
}
mkdir -p build/distribution
# Isolated products prevent local install builds from being accidentally released.
WORK=$(mktemp -d "$PWD/build/distribution/$APP_NAME-$VERSION.XXXXXX")
echo "Build output: $WORK"
mkdir "$WORK/project"
xcodegen generate --project "$WORK/project"
SIGNING=(CODE_SIGN_STYLE=Manual CODE_SIGN_IDENTITY=- DEVELOPMENT_TEAM=)
if [[ "$MODE" != --build-only ]]; then
  SIGNING=(CODE_SIGN_STYLE=Manual "CODE_SIGN_IDENTITY=$DEVELOPER_ID_APPLICATION"
    "DEVELOPMENT_TEAM=$APPLE_TEAM_ID" 'OTHER_CODE_SIGN_FLAGS=--timestamp')
fi
xcodebuild -project "$WORK/project/$APP_NAME.xcodeproj" -scheme "$APP_NAME" \
  -configuration Release -derivedDataPath "$WORK/DerivedData" \
  -destination 'generic/platform=macOS' 'ARCHS=arm64 x86_64' ONLY_ACTIVE_ARCH=NO \
  "MARKETING_VERSION=$VERSION" "CURRENT_PROJECT_VERSION=$BUILD_NUMBER" \
  "INFOPLIST_FILE=$PWD/Info.plist" ENABLE_HARDENED_RUNTIME=YES CODE_SIGN_INJECT_BASE_ENTITLEMENTS=NO "${SIGNING[@]}" build
APP="$WORK/DerivedData/Build/Products/Release/$APP_NAME.app"
lipo "$APP/Contents/MacOS/$APP_NAME" -verify_arch arm64 x86_64
codesign --verify --deep --strict --verbose=2 "$APP"
if [[ "$MODE" == --build-only ]]; then
  echo "Local build verified (NOT for public distribution): $APP"; exit 0
fi
notarize() {
  local archive=$1 result=$2
  xcrun notarytool submit "$archive" --keychain-profile "$NOTARY_PROFILE" \
    --wait --output-format json > "$result"
  local verdict=$(/usr/bin/plutil -extract status raw -o - "$result")
  if [[ "$verdict" != Accepted ]]; then
    echo "Notarization failed. Submission details: $result" >&2
    local submission=$(/usr/bin/plutil -extract id raw -o - "$result")
    xcrun notarytool log "$submission" --keychain-profile "$NOTARY_PROFILE" "${result%.json}.log.json" || true
    return 1
  fi
}
ditto -c -k --keepParent "$APP" "$WORK/$APP_NAME.zip"
notarize "$WORK/$APP_NAME.zip" "$WORK/app-notary.json"
xcrun stapler staple "$APP"
xcrun stapler validate "$APP"
spctl --assess --type execute --verbose=2 "$APP"
mkdir "$WORK/staging"
ditto "$APP" "$WORK/staging/$APP_NAME.app"
ln -s /Applications "$WORK/staging/Applications"
DMG="$WORK/$APP_NAME-$VERSION.dmg"
hdiutil create -volname "$APP_NAME" -srcfolder "$WORK/staging" -format UDZO "$DMG"
codesign --sign "$DEVELOPER_ID_APPLICATION" --timestamp "$DMG"
notarize "$DMG" "$WORK/dmg-notary.json"
xcrun stapler staple "$DMG"
xcrun stapler validate "$DMG"
codesign --verify --strict --verbose=2 "$DMG"
spctl --assess --type open --context context:primary-signature --verbose=2 "$DMG"
(cd "$WORK" && shasum -a 256 "$APP_NAME-$VERSION.dmg" > "$APP_NAME-$VERSION.dmg.sha256")
echo "Verified release: $DMG"
echo 'Upload the DMG and its .sha256 file to a public GitHub Release after installation testing.'
