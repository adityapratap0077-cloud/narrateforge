#!/usr/bin/env bash
# tts-lines.sh — voice one narration line per scene with the tts CLI.
#
# Usage: ./tts-lines.sh <narration.txt> <output-dir>
#
#   narration.txt : one line per scene, plain spoken text (see write-narration.md)
#   output-dir    : receives voice/line1.mp3, line2.mp3, ...
#
# The tts CLI is environment-provided (see ../skills/tts-interface.md).
# Default voice: Meta AI "Smooth" (avocado_v2:MAI_03). Pass --voice to use
# another voice from the tts skill's voice_source.json, and --language to
# match non-English scripts.
#
# NOTE: this script calls the tts skill CLI — never edge-tts, never Piper.

set -euo pipefail

SCRIPT="${1:?usage: tts-lines.sh <narration.txt> <output-dir>}"
OUT="${2:?usage: tts-lines.sh <narration.txt> <output-dir>}"
shift 2  # remaining args forwarded to `tts speak` (e.g. --voice, --language)

mkdir -p "$OUT/voice"

i=1
while IFS= read -r line || [ -n "$line" ]; do
  # skip blank lines
  [ -z "$(echo "$line" | tr -d '[:space:]')" ] && continue
  echo "voicing line $i ..."
  tts speak --text "$line" --output "$OUT/voice/line$i.mp3" "$@"
  i=$((i + 1))
done < "$SCRIPT"

echo "done: $((i - 1)) takes in $OUT/voice/"
