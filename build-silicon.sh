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

# Verify a Mach-O binary is a universal arm64 + x86_64 build; fail fast if not.
check_universal() {
  archs=$(lipo -archs "$1")
  echo "Architectures ($1): $archs"
  for need in arm64 x86_64; do
    case " $archs " in
      *" $need "*) ;;
      *) echo "ERROR: missing $need slice in $1 (got: $archs)" >&2; exit 1 ;;
    esac
  done
}

# Only "--install" (or no argument) is valid; reject anything else up front
# so a typo doesn't silently skip the install after a full build.
if [ -n "$1" ] && [ "$1" != "--install" ]; then
  echo "ERROR: unknown argument: $1" >&2
  echo "Usage: $0 [--install]" >&2
  exit 1
fi

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
check_universal "$APP/Contents/MacOS/SQBS"

if [ "$1" = "--install" ]; then
  DEST="/Applications/SQBS-original.app"
  rm -rf "$DEST"
  cp -R "$APP" "$DEST"
  echo "Installed -> $DEST"
  check_universal "$DEST/Contents/MacOS/SQBS"
fi
