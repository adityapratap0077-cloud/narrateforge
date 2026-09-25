#!/usr/bin/env bash
# assemble.sh — stitch a Vox prompt-pack project into one final MP4.
#
# Layout expected inside <project_dir>:
#   clips/block01.mp4  block02.mp4 ...   one 10s clip per block, in order
#   voice/block01.wav  block02.wav ...   one voice take per block (wav/mp3/m4a)
#
# Usage:  ./assemble.sh <project_dir>
#
# Per block: the clip is cut to exactly 10s; the voice take starts 0.25s in;
# a long take is tempo-compressed pitch-safely (warning above 1.25x);
# the clip's own ambient/SFX audio is kept underneath at low volume.
# Output: <project_dir>/final.mp4  (total runtime = N x 10s exactly)

set -euo pipefail

DIR="${1:?usage: assemble.sh <project_dir>}"
BLOCK=10          # seconds per block
TARGET=9.7        # compress a long take toward this
command -v ffmpeg >/dev/null || { echo "ffmpeg not found — install it (brew install ffmpeg)"; exit 1; }
command -v ffprobe >/dev/null || { echo "ffprobe not found"; exit 1; }

cd "$DIR"
WORK=".assemble_work"; rm -rf "$WORK"; mkdir -p "$WORK"

clips=(clips/block*.mp4)
[ -e "${clips[0]}" ] || { echo "no clips found at clips/block*.mp4"; exit 1; }

i=0
for clip in "${clips[@]}"; do
  i=$((i+1))
  n=$(printf "%02d" "$i")
  voice=$(ls voice/block${n}.* 2>/dev/null | head -1 || true)
  [ -n "$voice" ] || { echo "missing voice take for block ${n} (voice/block${n}.*)"; exit 1; }

  vdur=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$voice")
  # tempo factor for long takes, pitch-safe; 1.0 for takes that fit
  af="adelay=250|250,apad"
  over=$(python3 -c "d=float('$vdur'); print(f'{d/$TARGET:.3f}' if d>$TARGET else '1.0')")
  if [ "$over" != "1.0" ]; then
    big=$(python3 -c "print(1 if float('$over')>1.25 else 0)")
    [ "$big" = "1" ] && echo "WARN block ${n}: voice ${vdur}s needs ${over}x — rewrite the line shorter"
    af="atempo=${over},adelay=250|250,apad"
  fi

  # does the clip have its own audio stream?
  has_amb=$(ffprobe -v error -select_streams a -show_entries stream=index -of csv=p=0 "$clip" | head -1)
  if [ -n "$has_amb" ]; then
    ffmpeg -v error -y -i "$clip" -i "$voice" -t "$BLOCK" \
      -filter_complex "[0:a]volume=0.22[amb];[1:a]${af}[vo];[amb][vo]amix=inputs=2:duration=first:normalize=0[a]" \
      -map 0:v -map "[a]" -c:v libx264 -preset fast -crf 19 -pix_fmt yuv420p -c:a aac -ar 48000 \
      "$WORK/seg${n}.mp4"
  else
    ffmpeg -v error -y -i "$clip" -i "$voice" -t "$BLOCK" \
      -filter_complex "[1:a]${af}[a]" \
      -map 0:v -map "[a]" -c:v libx264 -preset fast -crf 19 -pix_fmt yuv420p -c:a aac -ar 48000 \
      "$WORK/seg${n}.mp4"
  fi
  echo "block ${n}: clip=$(basename "$clip") voice=$(basename "$voice") (${vdur}s) ok"
  echo "file 'seg${n}.mp4'" >> "$WORK/list.txt"
done

ffmpeg -v error -y -f concat -safe 0 -i "$WORK/list.txt" -c copy final.mp4

rm -rf "$WORK"
echo "done → $DIR/final.mp4  ($((i*BLOCK))s, $i blocks)"
