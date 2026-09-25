#!/usr/bin/env bash
# flick-assemble.sh — flick-style narrated assembly.
#
# Assembles already-rendered Remotion scenes into the narrated cut:
#   1. concatenate scene MP4s in transcript order (no re-render)
#   2. build the continuous VO track (adelay each take to its segment start)
#   3. mix VO over the scene audio (SFX dropped to a supporting level)
#   4. burn captions
#
# Usage: ./flick-assemble.sh <flick-output-dir> <scene-list.txt> <captions.ass> <final.mp4>
#
#   flick-output-dir: flick run dir with scenes/<name>/<name>.mp4 and
#                     voice/<segment-id>.mp3 (or voice/lineN.mp3)
#   scene-list.txt  : one line per scene, in transcript order:
#                     "<scene-name> <start_sec> <end_sec> <voice-file>"
#                     e.g.  "github-printed-hook 0.0 5.5 github-printed-hook.mp3"
#   captions.ass    : Dialogue events timed to segment start → start + take
#   final.mp4       : narrated deliverable
#
# VO takes come from the transcript segments (one per segment, spoken form,
# fit-checked with fit-check.sh). Scene audio keeps its action-matched SFX
# at a supporting level under the voice. No background music (flick rule).
#
# NOTE: see pipeline/README.md for the full pipeline and
# skills/flick/references/narrated.md for the canonical description.

set -euo pipefail

FOUT="${1:?usage: flick-assemble.sh <flick-output-dir> <scene-list.txt> <captions.ass> <final.mp4}"
LIST="${2:?usage: flick-assemble.sh <flick-output-dir> <scene-list.txt> <captions.ass> <final.mp4}"
ASS="${3:?usage: flick-assemble.sh <flick-output-dir> <scene-list.txt> <captions.ass> <final.mp4}"
FINAL="${4:?usage: flick-assemble.sh <flick-output-dir> <scene-list.txt> <captions.ass> <final.mp4}"

command -v ffmpeg >/dev/null || { echo "ffmpeg not found"; exit 1; }

# 1. concatenate scenes in transcript order
concat_list=$(mktemp)
while read -r name start end voicefile; do
  [ -z "$name" ] && continue
  echo "file '$FOUT/scenes/$name/$name.mp4'" >> "$concat_list"
done < "$LIST"
total=$(awk 'END{print $3}' "$LIST")
ffmpeg -y -f concat -safe 0 -i "$concat_list" -c copy "$FOUT/scenes-concat.mp4"
rm "$concat_list"

# 2. VO track: delay each take to its segment start, pad to full length
inputs=(); filter=""; n=0; mix=""
while read -r name start end voicefile; do
  [ -z "$name" ] && continue
  n=$((n + 1))
  inputs+=(-i "$FOUT/voice/$voicefile")
  ms=$(awk "BEGIN{print int($start*1000)}")
  filter="$filter[$((n-1))]adelay=$ms|$ms,apad=whole_dur=$total[a$((n-1))];"
  mix="$mix[a$((n-1))]"
done < "$LIST"
filter="$filter$mix amix=inputs=$n:normalize=0[vo]"
ffmpeg -y "${inputs[@]}" -filter_complex "$filter" -map "[vo]" "$FOUT/voice-track.m4a"

# 3. mix: scene audio (SFX) at 0.45 under the VO
ffmpeg -y -i "$FOUT/scenes-concat.mp4" -i "$FOUT/voice-track.m4a" -filter_complex \
  "[0:a]volume=0.45[sfx]; [1:a]volume=1.0[vo]; [sfx][vo]amix=inputs=2:normalize=0[a]" \
  -map 0:v -map "[a]" -c:v copy -c:a aac -b:a 160k "$FOUT/mixed.mp4"

# 4. burn captions
./captions.sh "$FOUT/mixed.mp4" "$ASS" "$FINAL"
echo "narrated video: $FINAL"
