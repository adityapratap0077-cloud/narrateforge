#!/usr/bin/env bash
# fit-check.sh — check every voice take against its scene window (vox Stage 9 discipline).
#
# Usage: ./fit-check.sh <voice-dir> <scene-list.txt>
#
#   voice-dir      : contains line1.mp3, line2.mp3, ... (from tts-lines.sh)
#   scene-list.txt : one line per scene: "<start_sec> <end_sec>"
#                    e.g.  "0.0 5.0"
#                          "5.0 12.0"
#
# For each take:
#   - take longer than (scene − 0.3s)  → REVOICE with --speed up to 115;
#     still too long → shorten the line, re-voice. Never let narration
#     bleed into the next scene.
#   - take shorter than 60% of scene   → consider --speed 90 or a longer
#     line. Otherwise fine: the line lands at the scene start and the
#     visuals breathe after it.
#
# Prints a report; exits 1 if any take overflows its window.

set -euo pipefail

VOICE="${1:?usage: fit-check.sh <voice-dir> <scene-list.txt}"
LIST="${2:?usage: fit-check.sh <voice-dir> <scene-list.txt}"

i=1
fail=0
while read -r start end; do
  [ -z "$start" ] && continue
  take="$VOICE/line$i.mp3"
  [ -f "$take" ] || { echo "line$i: MISSING $take"; fail=1; i=$((i+1)); continue; }
  dur=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$take")
  window=$(awk "BEGIN{print $end - $start}")
  overflow=$(awk "BEGIN{print ($dur > $window - 0.3) ? 1 : 0}")
  short=$(awk "BEGIN{print ($dur < $window * 0.6) ? 1 : 0}")
  if [ "$overflow" = 1 ]; then
    printf "line%d: OVERFLOW  take=%.2fs window=%.2fs (%.2f-%.2f) → re-voice --speed 115 or shorten line\n" \
      "$i" "$dur" "$window" "$start" "$end"
    fail=1
  elif [ "$short" = 1 ]; then
    printf "line%d: short    take=%.2fs window=%.2fs → ok, or --speed 90 / longer line\n" \
      "$i" "$dur" "$window"
  else
    printf "line%d: fits     take=%.2fs window=%.2fs\n" "$i" "$dur" "$window"
  fi
  i=$((i + 1))
done < "$LIST"

[ "$fail" = 0 ] && echo "all takes fit" || echo "fix overflows before assembly"
exit "$fail"
