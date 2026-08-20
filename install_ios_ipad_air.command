#!/bin/bash
set -e

DIR="$(cd "$(dirname "$0")" && pwd)"
TEAM_ID="${AESDIVINUS_APPLE_TEAM_ID:-$1}"
BUNDLE_ID="${AESDIVINUS_BUNDLE_ID:-com.aesdivinus.game}"
DEVICE_ID="${AESDIVINUS_IOS_DEVICE_ID:-$2}"
OUT_DIR="$DIR/builds/ios-ipad-air"
PROJECT="$OUT_DIR/AESDIVINUS_iPadAir_iOS12_5_8.xcodeproj"
SCHEME="AESDIVINUS_iPadAir_iOS12_5_8"
DERIVED="$OUT_DIR/DerivedData"

if [[ "$(uname)" != "Darwin" ]]; then
  echo "Instalacao em iPad/iOS precisa rodar no macOS com Xcode instalado."
  exit 1
fi

if [[ ! "$TEAM_ID" =~ ^[A-Za-z0-9]{10}$ ]]; then
  echo "Informe um Apple Team ID real de 10 caracteres."
  echo "Exemplo: AESDIVINUS_APPLE_TEAM_ID=ABCDE12XYZ AESDIVINUS_IOS_DEVICE_ID=UDID ./install_ios_ipad_air.command"
  exit 1
fi

if ! command -v xcodebuild >/dev/null 2>&1; then
  echo "xcodebuild nao encontrado. Instale/abra o Xcode e rode: sudo xcode-select -s /Applications/Xcode.app"
  exit 1
fi

if ! command -v ios-deploy >/dev/null 2>&1; then
  echo "ios-deploy nao encontrado. Para iOS 12.5.8, instale com: brew install ios-deploy"
  exit 1
fi

if [[ -z "$DEVICE_ID" ]]; then
  echo "Dispositivos detectados pelo ios-deploy:"
  ios-deploy -c || true
  echo
  echo "Informe o UDID do iPad Air:"
  echo "AESDIVINUS_APPLE_TEAM_ID=$TEAM_ID AESDIVINUS_IOS_DEVICE_ID=UDID ./install_ios_ipad_air.command"
  exit 1
fi

AESDIVINUS_APPLE_TEAM_ID="$TEAM_ID" AESDIVINUS_BUNDLE_ID="$BUNDLE_ID" "$DIR/export_ios_ipad_air.command" "$TEAM_ID"

xcodebuild \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -configuration Debug \
  -derivedDataPath "$DERIVED" \
  -destination "platform=iOS,id=$DEVICE_ID" \
  DEVELOPMENT_TEAM="$TEAM_ID" \
  PRODUCT_BUNDLE_IDENTIFIER="$BUNDLE_ID" \
  CODE_SIGN_STYLE=Automatic \
  build

APP_PATH="$(find "$DERIVED/Build/Products" -type d -name "${SCHEME}.app" | head -n 1)"
if [[ -z "$APP_PATH" ]]; then
  echo "Build terminou, mas o .app nao foi encontrado em $DERIVED/Build/Products."
  exit 1
fi

ios-deploy -i "$DEVICE_ID" -b "$APP_PATH" --justlaunch
echo "AESDIVINUS instalado e iniciado no iPad Air."
