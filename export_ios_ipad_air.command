#!/bin/bash
set -e

DIR="$(cd "$(dirname "$0")" && pwd)"
TEAM_ID="${AESDIVINUS_APPLE_TEAM_ID:-$1}"
BUNDLE_ID="${AESDIVINUS_BUNDLE_ID:-com.aesdivinus.game}"
OUT_DIR="$DIR/builds/ios-ipad-air"
OUT_FILE="$OUT_DIR/AESDIVINUS_iPadAir_iOS12_5_8.zip"
PRESET="$DIR/export_presets.cfg"
BACKUP="$(mktemp /tmp/aesdivinus_export_presets.XXXXXX.cfg)"

if [[ ! "$TEAM_ID" =~ ^[A-Za-z0-9]{10}$ ]]; then
  echo "Informe um Apple Team ID real de 10 caracteres."
  echo "Exemplo: AESDIVINUS_APPLE_TEAM_ID=ABCDE12XYZ ./export_ios_ipad_air.command"
  exit 1
fi

mkdir -p "$OUT_DIR"
rm -f "$OUT_FILE"
cp "$PRESET" "$BACKUP"
restore() {
  cp "$BACKUP" "$PRESET"
  rm -f "$BACKUP"
}
trap restore EXIT

python3 - "$PRESET" "$TEAM_ID" "$BUNDLE_ID" <<'PY'
from pathlib import Path
import re
import sys

preset = Path(sys.argv[1])
team_id = sys.argv[2]
bundle_id = sys.argv[3]
text = preset.read_text()
text = re.sub(r'application/app_store_team_id="[^"]*"', f'application/app_store_team_id="{team_id}"', text)
text = re.sub(r'application/bundle_identifier="[^"]*"', f'application/bundle_identifier="{bundle_id}"', text)
text = re.sub(r'application/identifier="[^"]*"', f'application/identifier="{bundle_id}"', text)
preset.write_text(text)
PY

godot --headless --path "$DIR" --export-release "iOS" "$OUT_FILE"
echo "Projeto Xcode iPad Air/iOS 12.5.8 gerado em: $OUT_FILE"
echo "Abra no Xcode, selecione seu iPad Air conectado, confira Signing & Capabilities e rode no aparelho."
