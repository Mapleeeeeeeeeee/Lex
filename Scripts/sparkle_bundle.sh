#!/bin/bash
set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "usage: $0 <sign|verify> <app_bundle> [identity]" >&2
  exit 1
fi

COMMAND="$1"
APP_BUNDLE="$2"
SIGN_IDENTITY="${3:--}"
SPARKLE_ROOT="$APP_BUNDLE/Contents/Frameworks/Sparkle.framework/Versions/B"

HELPER_PATHS=(
  "$SPARKLE_ROOT/Autoupdate"
  "$SPARKLE_ROOT/Updater.app"
  "$SPARKLE_ROOT/XPCServices/Downloader.xpc"
  "$SPARKLE_ROOT/XPCServices/Installer.xpc"
)

FRAMEWORK_PATH="$APP_BUNDLE/Contents/Frameworks/Sparkle.framework"

require_paths() {
  local missing=0
  local path

  if [[ ! -d "$APP_BUNDLE" ]]; then
    echo "Missing app bundle: $APP_BUNDLE" >&2
    exit 1
  fi

  for path in "${HELPER_PATHS[@]}" "$FRAMEWORK_PATH"; do
    if [[ ! -e "$path" ]]; then
      echo "Missing Sparkle component: $path" >&2
      missing=1
    fi
  done

  if [[ "$missing" -ne 0 ]]; then
    exit 1
  fi
}

verify_codesign() {
  local path="$1"
  codesign --verify --strict --verbose=2 "$path"
}

sign_component() {
  local path="$1"
  codesign --force --sign "$SIGN_IDENTITY" "$path"
}

sign_bundle() {
  local path
  require_paths

  for path in "${HELPER_PATHS[@]}"; do
    sign_component "$path"
  done

  sign_component "$FRAMEWORK_PATH"
  sign_component "$APP_BUNDLE"
}

verify_bundle() {
  local path
  require_paths

  for path in "${HELPER_PATHS[@]}" "$FRAMEWORK_PATH" "$APP_BUNDLE"; do
    verify_codesign "$path"
  done
}

case "$COMMAND" in
  sign)
    sign_bundle
    ;;
  verify)
    verify_bundle
    ;;
  *)
    echo "unknown command: $COMMAND" >&2
    exit 1
    ;;
esac
