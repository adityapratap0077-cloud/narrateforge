#!/usr/bin/env bash
# captions.sh — burn a narration .ass into the finished video with libass.
#
# Usage: ./captions.sh <input.mp4> <captions.ass> <output.mp4>
#
# The .ass is generated first — one Dialogue event per narration line,
# timed to the fit-checked VO placement (scene start → start + take
# duration). See examples/captions-flick.ass and captions-brag.ass for
# the exact style used in the two reference videos.
#
# ⚠ GOTCHA (learned the hard way): libass scales fonts by PlayRes.
# PlayResX/PlayResY MUST match the video resolution, or captions render
# gigantic:
#   9:16  vertical → PlayResX: 1080 / PlayResY: 1920
#   16:9 landscape → PlayResX: 1920 / PlayResY: 1080
#
# Caption style rules (accessibility track — verbatim to the voiced lines):
#   - bottom-centered, ~64px font at 1080p (scale proportionally)
#   - 1–2 lines, max ~42 chars/line for 9:16
#   - white on semi-transparent black

set -euo pipefail

IN="${1:?usage: captions.sh <input.mp4> <captions.ass> <output.mp4}"
ASS="${2:?usage: captions.sh <input.mp4> <captions.ass> <output.mp4}"
OUT="${3:?usage: captions.sh <input.mp4> <captions.ass> <output.mp4}"

command -v ffmpeg >/dev/null || { echo "ffmpeg not found"; exit 1; }
[ -f "$ASS" ] || { echo "missing $ASS"; exit 1; }

ffmpeg -y -i "$IN" -vf "subtitles=$ASS" -c:a copy "$OUT"
echo "captioned: $OUT"
