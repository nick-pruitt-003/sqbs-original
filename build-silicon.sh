#!/bin/sh
# Build a universal (arm64 + x86_64) SQBS.app and optionally install it.
#
# The project was originally Intel-only (VALID_ARCHS = "i386 x86_64",
# MACOSX_DEPLOYMENT_TARGET = 10.10). Those settings are now fixed in the
# project, but a universal binary still requires building for the GENERIC
# macOS destination -- a plain destination-less `xcodebuild` only emits the
# host arch (arm64). This script captures the correct invocation.
#
# Usage:
#   ./build-silicon.sh             # build only -> build/Release/SQBS.app
#   ./build-silicon.sh --install   # build, then install to /Applications/SQBS-original.app
set -e

cd "$(dirname "$0")/SQBS2"
DERIVED="$(pwd)/build"

xcodebuild \
  -project "SQBS2.xcodeproj" \
  -scheme "SQBS" \
  -configuration Release \
  -destination 'generic/platform=macOS' \
  -derivedDataPath "$DERIVED" \
  CODE_SIGN_IDENTITY="-" CODE_SIGNING_REQUIRED=YES CODE_SIGNING_ALLOWED=YES \
  build

APP="$DERIVED/Build/Products/Release/SQBS.app"
echo "Built: $APP"
lipo -archs "$APP/Contents/MacOS/SQBS"

if [ "$1" = "--install" ]; then
  DEST="/Applications/SQBS-original.app"
  rm -rf "$DEST"
  cp -R "$APP" "$DEST"
  echo "Installed -> $DEST"
  lipo -archs "$DEST/Contents/MacOS/SQBS"
fi
