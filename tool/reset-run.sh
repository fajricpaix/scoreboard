#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEFAULT_DEVICE_ID="10DG3G0BJC000U7"

DEVICE_ID="$DEFAULT_DEVICE_ID"
if [ "$#" -gt 0 ]; then
  DEVICE_ID="$1"
  shift
fi

cd "$ROOT_DIR"

echo "[1/4] flutter clean"
flutter clean

echo "[2/4] remove .dart_tool and build"
rm -rf .dart_tool build

echo "[3/4] flutter pub get"
flutter pub get

echo "[4/4] flutter run -d $DEVICE_ID -v $*"
flutter run -d "$DEVICE_ID" -v "$@"