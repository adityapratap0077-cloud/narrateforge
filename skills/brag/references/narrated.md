# Narrated mode (`--narrated`)

Opt-in voiceover + burned-in captions. A plain `/brag` run never uses this:
no VO, no captions, unless the invocation contains `--narrated` (the older
`--voice` flag is kept as an alias and behaves identically).

Narration follows the vox-animation discipline: N timed lines, one per
scene, each TTS-voiced and fit-checked against its scene's duration before
assembly.

---

## 1. Write the narration script (Step 2, before composition)

After the storyboard is locked, write one narration line per scene into a
`Narration` section of `<output-dir>/brag-plan.md`:

- **One line per scene**, timed to that scene's duration.
- **~18–20 words per ~6s scene** (roughly 2.5–3 words/second). Scale word
  count to scene length: a 3s scene gets ~8–10 words, an 8s scene ~20–24.
- **Plain spoken text**: numbers spelled out ("twenty twenty-five", not
  "2025"), no abbreviations, no stage directions, no markup.
- **Structure** (vox Stage 3): cold open (most surprising fact, flat, no
  greeting) → stakes → the turn → resolution + kicker that reframes scene 1.
- **Complements the visuals, doesn't read them.** If the scene shows text on
  screen, the narration says something adjacent — never the same words.
- Conversational, specific to the product. No generic SaaS language.

Example for a 3-scene, 18s brag (scenes of 5s / 7s / 6s):

```
Scene 1 (0.0–5.0s): Your GitHub profile is already a portfolio. It's just not printed yet.
Scene 2 (5.0–12.0s): PortfolioForge reads your public repos and activity, then lets you tune eight designed themes until it talks like you.
Scene 3 (12.0–18.0s): Download a standalone page, or share your link. PortfolioForge. Print it.
```

## 2. Voice the lines (Step 4, before final assembly)

Use the `tts` skill CLI — never edge-tts, never Piper. One take per line:

```bash
mkdir -p <output-dir>/voice
tts speak --text "Your GitHub profile is already a portfolio. It's just not printed yet." \
  --output <output-dir>/voice/line1.mp3
```

- Default voice: `avocado_v2:MAI_03` (Smooth). Pick another voice from the
  tts skill's `voice_source.json` only if the tone asks for it; honor an
  explicit user voice request.
- `--language` must match the script language (default `en`).
- Copy each take into `<output-dir>/composition/assets/voice/lineN.mp3`
  (Hyperframes serves audio from the composition directory — see
  `references/audio.md` "Critical: copy audio files…").

### Fit-check (vox Stage 9 discipline)

Check every take with ffprobe against its scene's duration:

- Take **longer than (scene − 0.3s)** → re-voice with `--speed` up to 115.
  Still too long → shorten the line, re-voice. Never let narration bleed
  into the next scene.
- Take **shorter than 60% of the scene** → consider `--speed 90` or
  lengthening the line. Otherwise fine — the line lands at the scene start
  and the visuals breathe after it.
- Record final durations in the plan; they drive caption timing.

## 3. Wire VO into the composition

Add one `<audio>` element per line, starting at its scene's start time, on
its own ascending track-index above the music bed:

```html
<audio id="vo-1" data-start="0.0" data-duration="4.6" data-track-index="20" data-volume="1.0" src="assets/voice/line1.mp3"></audio>
<audio id="vo-2" data-start="5.0" data-duration="6.4" data-track-index="21" data-volume="1.0" src="assets/voice/line2.mp3"></audio>
```

`data-duration` = the fit-checked take length. Never share a track-index
between overlapping audio (music stays at 10, SFX at 11+, VO at 20+).

**Ducking:** while any VO plays, the music bed must sit low. Set the bed
volume to **0.18–0.22** for the whole video when narrated (instead of the
usual 0.3–0.4). No sidechain plugins — the static low bed plus a clear VO
is the intended mix. Keep SFX sparse under narration; drop any SFX that
fights the voice.

## 4. Burn captions after render

Captions are burned into the rendered MP4 with ffmpeg libass — never
rendered as HTML text (they must survive any player).

1. Write `<output-dir>/captions.ass` with one Dialogue event per narration
   line, timed to the fit-checked VO placement.
2. **PlayRes must match the video resolution** or libass scales the fonts
   wrong (the classic "gigantic captions" bug):
   `PlayResX: 1080` / `PlayResY: 1920` for vertical, `1920`/`1080` for
   landscape.
3. Style: bottom-centered, ~64px font at 1080p (scale proportionally),
   1–2 lines, max ~42 chars/line for 9:16, high-contrast
   (white on semi-transparent black).
4. Burn: `ffmpeg -i brag.mp4 -vf "subtitles=captions.ass" -c:a copy brag-narrated.mp4`

Keep captions verbatim to the voiced lines (they're the accessibility
track), even where the narration deliberately differs from on-screen text.

## 5. Delivery

- `<output-dir>/brag-narrated.mp4` is the narrated deliverable (in addition
  to the normal `brag.mp4` — always render the clean version too).
- Poster and share copy are written from the clean render, as usual.
- Note the voice used in `share-copy.txt` (e.g. `Voice: Meta AI Smooth
  (avocado_v2:MAI_03)`), so a rerun can match it.

## Failure handling

- `tts` failure → follow the tts skill's retry ladder (same request,
  bounded backoff). Never swap voices or engines to work around a failure.
- A take that won't fit after speed + rewrite → split the scene or cut the
  line harder. The scene timing is the boss, not the script.
- Caption timing drift → re-derive Dialogue times from the final
  `data-start` + fit-checked durations, not from the plan draft.
