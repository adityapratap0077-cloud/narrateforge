# Narrated mode (`--narrated`)

Opt-in voiceover for /flick. A plain `/flick` run never
uses this: scenes render with action-matched SFX only, no VO,
no background music (that rule is unchanged).

Narrated mode voices the existing transcript — one TTS take per transcript
segment — fit-checks each take against its scene duration (vox-animation
Stage 9 discipline), then assembles a narrated cut from the already-rendered
scenes. Scenes are never rebuilt for narration.

---

## 1. Prerequisites

- `transcript.json` exists with timestamped segments (Step 1 gate).
- Every approved scene has a rendered MP4 in `scenes/<name>/` (Step 3 gate).
- The user invoked with `--narrated` (or asked for narration in
  that run). Never enable it by default.

## 2. Voice the transcript lines

One take per transcript segment, using the `tts` skill CLI — never
edge-tts, never Piper:

```bash
mkdir -p <output-dir>/voice
tts speak --text "<segment text, spoken form>" \
  --output <output-dir>/voice/<segment-id>.mp3
```

- Default voice: `avocado_v2:MAI_03` (Smooth). Pick another voice from the
  tts skill's `voice_source.json` only for a clear tonal reason; honor an
  explicit user voice request.
- Convert the segment text to **spoken form** first: spell out numbers
  ("eight", not "8"), expand abbreviations, no markup.
- `--language` must match the transcript language (default `en`).

### Fit-check (vox Stage 9 discipline)

ffprobe each take against its segment's `[start, end)` window:

- Take **longer than (segment − 0.3s)** → re-voice with `--speed` up to
  115. Still too long → shorten the line (keep the meaning), re-voice.
  Narration must never bleed into the next scene.
- Take **shorter than 60% of the segment** → consider `--speed 90` or a
  slightly longer line. Otherwise fine: the line lands at the segment start
  and the animation breathes after it.
- Record final take durations; they drive the VO assembly map below.

## 3. Assemble the VO track

Build one continuous narration track over the full video duration:

```bash
# delay each take to its segment start, then mix
ffmpeg -i voice/github-printed-hook.mp3 -i voice/connect-and-read.mp3 \
  -filter_complex "[0]adelay=0|0,apad=whole_dur=24.2[a0]; \
                   [1]adelay=5500|5500,apad=whole_dur=24.2[a1]; \
                   [a0][a1]amix=inputs=2:normalize=0[vo]" \
  -map "[vo]" voice-track.m4a
```

(`adelay` takes milliseconds; `apad=whole_dur=<total>` pads each take to the
full length so nothing gets cut. Adjust input count/delays per run.)

## 4. Mix

Mix the VO over the concatenated scene audio. Scene SFX stay, but dropped
to a supporting level under the voice:

```bash
# scenes.mp4 = scenes concatenated in transcript order (no re-render)
ffmpeg -i scenes.mp4 -i voice-track.m4a -filter_complex \
  "[0:a]volume=0.45[sfx]; [1:a]volume=1.0[vo]; [sfx][vo]amix=inputs=2:normalize=0[a]" \
  -map 0:v -map "[a]" -c:v copy -c:a aac -b:a 160k <name>-narrated.mp4
```

## 5. Delivery

- `<output-dir>/<name>-narrated.mp4` is the narrated deliverable; the
  clean scene MP4s and the non-narrated assembly (if any) are untouched.
- Note the voice used in `flick-plan.md` (e.g. `Voice: Meta AI Smooth
  (avocado_v2:MAI_03)`) so a rerun can match it.

## Failure handling

- `tts` failure → follow the tts skill's retry ladder (same request,
  bounded backoff). Never swap voices or engines to work around it.
- A take that won't fit after speed + rewrite → the segment text was too
  dense; shorten it. Scene timing is the boss, not the script.
- If scene MP4s have no audio stream, skip the SFX mix input and mux VO
  directly: `-map 0:v -map 1:a`.
