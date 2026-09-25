# NarrateForge

**Make the narrated promo video.** A short animated video with a
fit-checked TTS voiceover and a ducked music/SFX bed — no captions —
the exact recipe proven by the three reference cuts in
[`examples/`](#examples).

<video src="examples/banaobot-narrated-9x16.mp4" width="320" controls></video>

*Made with `/narrate` — BanaoBot, 20.5s. "Your customers live on WhatsApp. Your business should answer there."*

## Which skill makes what

| Command | Skill | What you get |
|---|---|---|
| `/narrate <site>` | `skills/narrate/` | Brag-style narrated promo — the easiest command (sample above) |
| `/brag --narrated` | `skills/brag/` + `references/narrated.md` | Same brag-style engine, invoked through `/brag` |
| `/flick --narrated` | `skills/flick/` + `references/narrated.md` | Remotion scene animations voiced from a transcript |

**`/brag --narrated` → PortfolioForge** (18.0s) — 3-scene Hyperframes composition, narration over a ducked music bed.

<video src="examples/portfolioforge-brag-narrated-9x16.mp4" width="270" controls></video>

**`/flick --narrated` → PortfolioForge** (24.2s) — 4 Remotion scenes, transcript voiced over action-matched SFX.

<video src="examples/portfolioforge-flick-narrated-9x16.mp4" width="270" controls></video>

All samples are 1080×1920, H.264 + stereo AAC, voice Meta AI "Smooth".

## The video type

| | |
|---|---|
| **Length** | 15–25 seconds |
| **Aspect** | 9:16 vertical (16:9 / 1:1 work too) |
| **Visual** | Animated scenes — Hyperframes composition (brag-style, reads a project) or Remotion scene animations (flick-style, from a transcript) |
| **Voice** | One narration line per scene, TTS-voiced and fit-checked to its scene — narration never bleeds into the next scene |
| **Mix** | Music/SFX ducked underneath the voice (bed at 0.18–0.22, SFX at a supporting level) |

## Pipeline overview

```
narration script → TTS takes → fit-check → mix over visuals
```

1. **Write** — one timed narration line per scene (~2.5–3 words/sec;
   cold open → stakes → the turn → kicker). Template: `pipeline/write-narration.md`
2. **Voice** — one TTS take per line: `pipeline/tts-lines.sh`
3. **Fit-check** — every take verified with ffprobe against its scene
   window (vox Stage 9 discipline: too long → re-voice faster ≤115% or
   shorten the line; too short → fine, visuals breathe). `pipeline/fit-check.sh`
4. **Assemble** —
   - Brag-style (Hyperframes): VO wired into the composition on high
     track-indexes, music bed ducked, render, mix — `pipeline/compose-hyperframes.sh`
   - Flick-style (Remotion): scenes concatenated, VO track built with
     `adelay`/`apad`, mixed over scene SFX — `pipeline/flick-assemble.sh`

Full stage-by-stage docs: [`pipeline/README.md`](pipeline/README.md).

## Quickstart

```bash
git clone https://github.com/adityapratap0077-cloud/narrateforge.git
cd narrateforge

# 1. write narration.txt — one line per scene (see pipeline/write-narration.md)
# 2. list your scenes:
cat > scene-list.txt <<'EOF'
0.0 5.5
5.5 11.5
11.5 17.5
17.5 24.2
EOF

# 3. voice the lines (bring your own TTS — see skills/tts-interface.md)
./pipeline/tts-lines.sh narration.txt my-video/

# 4. fit-check every take against its scene window
./pipeline/fit-check.sh my-video/voice scene-list.txt

# 5a. brag-style: render your Hyperframes composition, then assemble
./pipeline/compose-hyperframes.sh my-video scene-list.txt music-bed.mp3 my-video-narrated.mp4

# 5b. flick-style: assemble already-rendered Remotion scenes
#     scene-list.txt format: "<scene-name> <start> <end> <voice-file>"
./pipeline/flick-assemble.sh my-flick-run scene-list.txt my-flick-narrated.mp4
```

Requirements: `ffmpeg` + `ffprobe`, a TTS CLI satisfying
[`skills/tts-interface.md`](skills/tts-interface.md), and Hyperframes
and/or Remotion for the visual tracks (their skills live in `skills/`).

## Skills included

The skills this pipeline was built from, copied faithfully:

| Skill | What it contributes | Source / license |
|---|---|---|
| `skills/brag/` | `/brag` — launch video from project code via Hyperframes; `references/narrated.md` is the narrated-mode spec (VO wiring, ducking) | Original work by Aditya Pratap's studio; no separate license — covered by this repo's MIT |
| `skills/flick/` | `/flick` — transcript → Remotion scene animations; `references/narrated.md` is the transcript-voicing spec | Upstream [creatorberry/flick](https://github.com/creatorberry/flick) (MIT); local modifications (narrated mode) are this repo's |
| `skills/vox-animation/` | The narration model: timed lines per scene, fit-check discipline, `assemble.sh` reference | Original studio skill; no separate license — covered by this repo's MIT |
| `skills/tts-interface.md` | Adapter doc for the platform TTS CLI used in the reference runs (not portable, not included) | — |

## Examples

All three reference cuts (1080×1920, H.264 + stereo AAC, voice Meta AI "Smooth") —
see [Which skill makes what](#which-skill-makes-what) above for embedded playback:

- `examples/banaobot-narrated-9x16.mp4` (20.5s) — `/narrate` on BanaoBot:
  brag-style, 4 scenes, voiceover + ducked music, no captions.
- `examples/portfolioforge-brag-narrated-9x16.mp4` (18.0s) — `/brag --narrated`:
  3-scene Hyperframes composition for PortfolioForge, narration with music bed ducked to 0.2.
- `examples/portfolioforge-flick-narrated-9x16.mp4` (24.2s) — `/flick --narrated`:
  4 Remotion scenes for PortfolioForge, VO over action SFX.

## Repo layout

```
narrateforge/
  README.md
  LICENSE
  pipeline/            # the generalized narrated-video pipeline
    write-narration.md # narration prompt template
    tts-lines.sh       # voice one line per scene
    fit-check.sh       # ffprobe takes against scene windows
    compose-hyperframes.sh  # brag-style assembly
    flick-assemble.sh  # flick-style assembly
    README.md          # stage-by-stage pipeline docs
  skills/              # the skills this pipeline is built from
    narrate/           # /narrate — the easy command
    brag/              # /brag + narrated.md + audio.md
    flick/             # /flick + narrated.md
    vox-animation/     # narration model + assemble.sh
    tts-interface.md   # bring-your-own-TTS adapter doc
  examples/            # the three reference narrated cuts
```

## License

MIT — see [LICENSE](LICENSE).
