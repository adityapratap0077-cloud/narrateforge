# NarrateForge pipeline

The end-to-end recipe for a **narrated promo video**: an animated visual
track + a fit-checked TTS voiceover + a ducked music/SFX bed. No captions —
narrated mode is voiceover only. This is the generalized form of the
pipeline proven by the two reference demos in `examples/`.

## The video type

- **Visual:** short (15–25s) animated scenes — either a Hyperframes
  composition (brag-style, reads a project site) or Remotion scene
  animations (flick-style, from a transcript).
- **Audio:** one narration line per scene, voiced with TTS and timed to
  its scene; music/SFX ducked underneath.

## Stages

```
1. write-narration.md     → one timed line per scene (prompt template)
2. tts-lines.sh           → voice each line (one mp3 per line)
3. fit-check.sh           → ffprobe each take against its scene window
4. compose-hyperframes.sh → brag-style: render composition, mix VO → final
   OR
   flick-assemble.sh      → flick-style: concat scenes, mix VO → final
```

### 1. Narration script — `write-narration.md`

Prompt template for writing N timed lines: ~2.5–3 words/second,
cold open → stakes → the turn → kicker. Narration complements the
visuals, never reads the on-screen text back.

### 2. Voice the lines — `tts-lines.sh`

```bash
./tts-lines.sh narration.txt <output-dir> [--voice <id>] [--language <code>]
```

One mp3 per line into `<output-dir>/voice/`. Bring your own TTS that
satisfies `skills/tts-interface.md`.

### 3. Fit-check — `fit-check.sh`

```bash
./fit-check.sh <output-dir>/voice scene-list.txt
# scene-list.txt: one line per scene: "<start_sec> <end_sec>"
```

vox Stage 9 discipline: a take longer than (scene − 0.3s) must be
re-voiced faster (≤115%) or the line shortened — narration never bleeds
into the next scene. Takes under 60% of the scene are fine (visuals
breathe after the line lands).

### 4a. Brag-style assembly — `compose-hyperframes.sh`

For Hyperframes compositions (the `/brag` skill path):

1. Wire each VO take into the composition as an `<audio>` element on an
   ascending track-index above music/SFX (music=10, SFX=11+, VO=20+),
   `data-duration` = fit-checked take length.
2. Copy voice files into `composition/assets/voice/` (Hyperframes serves
   audio from the composition directory).
3. Ducking: keep the music bed at **0.18–0.22** for the whole narrated
   video (vs 0.3–0.4 normally); keep SFX sparse under narration.
4. Render clean → mix VO over → final mp4.

Full spec: `skills/brag/references/narrated.md`.

### 4b. Flick-style assembly — `flick-assemble.sh`

For Remotion scene animations (the `/flick` skill path). Scenes are
never rebuilt for narration:

1. Concatenate scene MP4s in transcript order.
2. Build one continuous VO track: `adelay` each take to its segment
   start, `apad=whole_dur=<total>` so nothing gets cut.
3. Mix: scene audio (action SFX) at 0.45 under the VO → final mp4.

Full spec: `skills/flick/references/narrated.md`.

## What the scripts assume

- `ffmpeg` + `ffprobe` on PATH.
- A working TTS per `skills/tts-interface.md`.
- Hyperframes for the brag-style path (needs its own install — the
  `brag` skill's composition steps live in `skills/brag/`).
- Remotion for the flick-style path (`skills/flick/` bootstrap installs
  Remotion, bundled FFmpeg, Whisper, yt-dlp).

Demo-specific values (scene names, durations, music choice) are examples —
adapt `scene-list.txt` to your run.
