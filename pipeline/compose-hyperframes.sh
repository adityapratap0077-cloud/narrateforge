#!/usr/bin/env bash
# compose-hyperframes.sh — brag-style narrated assembly.
#
# Assembles a Hyperframes composition into the narrated deliverable:
#   1. render the clean composition (music bed + SFX, no VO)
#   2. mix fit-checked voice takes over the render, music bed ducked
#   3. burn captions
#
# Usage: ./compose-hyperframes.sh <output-dir> <scene-list.txt> <music.mp3> <captions.ass> <final.mp4>
#
#   output-dir    : brag-style run dir with voice/lineN.mp3 takes and a
#                   composition/ rendered via Hyperframes
#   scene-list.txt: one line per scene: "<start_sec> <end_sec>"
#   music.mp3     : music bed (already used in the composition at 0.18–0.22
#                   for narrated runs — see skills/brag/references/narrated.md)
#   captions.ass  : Dialogue events timed to VO placement
#   final.mp4     : narrated deliverable
#
# In the Hyperframes composition, wire each VO take as its own <audio>
# element on an ascending track-index above music/SFX (music=10, SFX=11+,
# VO=20+), with data-duration = fit-checked take length:
#
#   <audio id="vo-1" data-start="0.0" data-duration="4.6"
#          data-track-index="20" data-volume="1.0" src="assets/voice/line1.mp3"></audio>
#
# Copy voice takes into composition/assets/voice/ first (Hyperframes serves
# audio from the composition directory). Ducking: narrated runs keep the
# music bed at 0.18–0.22 for the whole video; keep SFX sparse under VO.
#
# NOTE: demo-specific paths below (composition name, track) are examples —
# adapt to your run. See the full pipeline in pipeline/README.md.

set -euo pipefail

OUT="${1:?usage: compose-hyperframes.sh <output-dir> <scene-list.txt> <music.mp3> <captions.ass> <final.mp4}"
LIST="${2:?usage: compose-hyperframes.sh <output-dir> <scene-list.txt> <music.mp3> <captions.ass> <final.mp4}"
MUSIC="${3:?usage: compose-hyperframes.sh <output-dir> <scene-list.txt> <music.mp3> <captions.ass> <final.mp4}"
ASS="${4:?usage: compose-hyperframes.sh <output-dir> <scene-list.txt> <music.mp3> <captions.ass> <final.mp4}"
FINAL="${5:?usage: compose-hyperframes.sh <output-dir> <scene-list.txt> <music.mp3> <captions.ass> <final.mp4}"

command -v ffmpeg >/dev/null || { echo "ffmpeg not found"; exit 1; }
command -v npx >/dev/null || { echo "npx not found (needs Hyperframes)"; exit 1; }

# 1. render the clean composition (no VO) — adapt the hyperframes command
#    to your install; this is the shape used in the reference demo:
echo "rendering clean composition ..."
(cd "$OUT/composition" && npx hyperframes render -o ../render-clean.mp4)

# 2. build a continuous VO track: delay each take to its scene start,
#    pad each to the full duration so nothing gets cut
total=$(awk 'END{print $2}' "$LIST")
inputs=(); filter=""; n=0
while read -r start end; do
  [ -z "$start" ] && continue
  n=$((n + 1))
  take="$OUT/voice/line$n.mp3"
  inputs+=(-i "$take")
  ms=$(awk "BEGIN{print int($start*1000)}")
  filter="$filter[$((n-1))]adelay=$ms|$ms,apad=whole_dur=$total[a$((n-1))];"
done < "$LIST"
for k in $(seq 0 $((n-1))); do mix="$mix[a$k]"; done
filter="$filter$mix amix=inputs=$n:normalize=0[vo]"
ffmpeg -y "${inputs[@]}" -filter_complex "$filter" -map "[vo]" "$OUT/voice-track.m4a"

# 3. mix: clean render audio (music+SFX) under the VO
ffmpeg -y -i "$OUT/render-clean.mp4" -i "$OUT/voice-track.m4a" -filter_complex \
  "[0:a]volume=0.9[sfx]; [1:a]volume=1.0[vo]; [sfx][vo]amix=inputs=2:normalize=0[a]" \
  -map 0:v -map "[a]" -c:v copy -c:a aac -b:a 160k "$OUT/mixed.mp4"

# 4. burn captions
./captions.sh "$OUT/mixed.mp4" "$ASS" "$FINAL"
echo "narrated video: $FINAL"
