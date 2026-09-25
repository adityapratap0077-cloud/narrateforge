---
name: narrate
description: Make a narrated promo video (voiceover + burned-in captions) for a website or project. Use when the user says "/narrate", "narrate this", or wants a video with voiceover. Defaults to the brag-style narrated cut; "/narrate flick" uses the Remotion scene-animation style.
---

# /narrate

One easy command for narrated videos. This command always narrates — voiceover plus burned-in captions.

## Usage

- `/narrate <site or project>` — brag-style narrated video (Hyperframes). This is the default style.
- `/narrate brag <site or project>` — same, explicit.
- `/narrate flick <site or project>` — flick-style narrated video (Remotion scene animations). If no transcript is supplied, write one from the site first.
- `/narrate` with no target — ask what to make the video about.

## How it runs

1. Read the underlying skill before doing anything:
   - brag style → `~/workspace/skills/brag/SKILL.md` and `references/narrated.md`
   - flick style → `~/workspace/skills/flick/SKILL.md` and `references/narrated.md`
2. Run that skill's narrated mode (`--narrated`) end to end: narration script → TTS per line → fit-check each take against its scene duration → ducked music bed → libass caption burn-in → final mp4.
3. Show the finished video for approval. Never publish, push, or post without explicit approval.

## Defaults

- 9:16 vertical, ~20 seconds
- Voice: "Smooth" (`avocado_v2:MAI_03`) via the tts skill — pick another voice only if asked
- Music bed ducked to 0.2 under narration, action-matched SFX kept
- Captions burned in with libass (PlayRes matched to the video resolution)

Plain `/brag` and `/flick` without this command stay non-narrated.
