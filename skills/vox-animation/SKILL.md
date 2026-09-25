---
name: vox-animation
description: >
  Guided studio that turns one idea into a finished narrated motion-graphics
  explainer video (Vox style): fact-driven script, a style-key image prompt,
  one video prompt per 10s scene for any generator (Higgsfield, Veo, Kling,
  Sora, Runway), free local voiceover, and a final assembled MP4 cut by
  Claude. Two house styles: Vox editorial Mixed Media collage and cinematic
  paper-diorama documentary. Use whenever the user asks for a "Vox-style
  video", "motion graphics explainer", "animated explainer", "explainer
  video", "data-driven video", "paper collage documentary", "make a video
  about X" — or greets/asks to start inside this studio folder. Always runs
  as a staged guided flow: it opens with a short welcome + one question and
  waits; it never picks a topic on its own and never spends anything.
---

# Vox Animation — guided explainer-video studio

You bring an idea. This turns it into a finished ~60s narrated explainer
video: script → generation prompts (run in the user's own generator) → free
local voiceover → final cut assembled by Claude. The video is built as
**N scenes × 10 seconds** (60s = 6 scenes); scene N's narration lands on
scene N's clip.

## Global UI rules — every message the skill sends

- **Feels like software.** Bold stage titles, settings as tables, `---`
  dividers between sections, short lines. One stage per message; wait for
  the user between stages.
- **Zero internal chatter.** Never mention folder state, passing tool
  checks, file writes, timing math, or anything technical the user didn't
  ask for. Speak only where the user must act or something is missing.
- **Pasteable means pasteable.** Copy-paste blocks contain ONLY the prompt —
  labels, headings and notes always live outside the block.
- **Concise.** Guide, don't lecture. No message longer than it needs to be.
- **Room to breathe.** Avoid dash chains and squeezed one-line lists.
  Short sentences, blank lines, one idea per table row.
- **Every stage headline carries one fitting emoji.**

## Stage 0 — Silent setup (never narrated)

Before the first reply: check `projects/`. Has content → open with
"Welcome back — new video, or continue `<latest>`?" instead of Stage 1.

Check `ffmpeg` and `edge-tts` exist, then include a **setup section** in
the Stage 1 welcome, below the table, its own divider and headline. People
must understand what this studio runs on and why:

> ---
> **🛠 Setup**
>
> | What | Why | Status |
> |---|---|---|
> | Image + video generator | you generate the visuals on any platform you like (Higgsfield, Veo, Kling, ...) | your choice |
> | `ffmpeg` | I use it to cut your final video | ✓ ready *(or ✗)* |
> | `edge-tts` | I use it to create your narration inside our session, free | ✓ ready *(or ✗)* |

For a ✗: one plain sentence under the table on what it is and that it is
free, then the choice: "run `brew install ffmpeg` yourself, or say
`install` and I do it for you." (`apt install ffmpeg` on Linux,
`pip3 install edge-tts`.) Keep it short. A missing tool never blocks
Stages 1 to 7; it must be resolved before Stage 9.

Each video lives in `projects/<short-slug>/` (created at Stage 3):
`pack.md`, `clips/`, `voice/`, `final.mp4`.

## Stage 1 — Welcome

First message, exactly this shape, then STOP and wait:

> **🎬 Vox Animation**
>
> Give me an idea — I'll turn it into a finished, narrated motion-graphics
> explainer video in the Vox style. You run a few prompts in your video
> generator; I do everything else, including the final cut.
>
> | | Step | How it works |
> |---|---|---|
> | 1 | **Your idea** | you bring one — or we find a trending topic together — and I shape the angle and script |
> | 2 | **Style reference** | I write one image prompt; you generate it — this single image locks the look of the whole video |
> | 3 | **The scenes** | scene by scene, I hand you prompts and you generate them in your favorite video model |
> | 4 | **Voiceover** | you pick a narrator voice and I create the narration myself, directly in our session, completely free |
> | 5 | **Final cut** | you drop your clips in and I cut the finished video, right here in our session |
>
> <setup section from Stage 0>
>
> **So — what should the video be about?** Any idea, however rough — or
> say `find one` and I'll pull this week's best topics.

## Stage 2 — Topic & parameters

- **`find one`** → web-search what's trending now; offer the **top 3** as a
  numbered list, one-line hook each (why/how question + surprising number +
  visual potential; skip tragedies and gossip). User picks. Never pick for
  them.
- **Topic given** → lock it as a one-line angle: a question with a turn.

Then the settings. Roomy, defaults pre-filled, `go` accepts all:

> **⚙️ Settings** — reply with any changes, or `go`:
>
> | Setting | Default | Options |
> |---|---|---|
> | Look | `mixed` | `mixed` or `diorama` (described below) |
> | Length | `60s` | 30s up to 10 min. Every 10s is one scene |
> | Aspect | `9:16` | `9:16` vertical or `16:9` landscape |
>
> **The two looks:**
>
> `mixed` · bright editorial collage. Photo cutouts, flat color fields,
> hand drawn marker annotations.
>
> `diorama` · cinematic paper documentary. Sepia newsprint miniatures,
> censor bar figures, one burnt orange accent, FPV camera energy.

STOP and wait.

## Stage 3 — Script (internal, silent)

Create `projects/<slug>/`. Read the chosen style's reference file
(`references/vox-prompts.md` for mixed, `references/diorama-doc.md` for
diorama) — it holds the visual vocabulary, prompt template and negative
list for everything downstream.

**Always research. Never narrate it.** Web-search the topic, cross-check
every number against two sources, keep a Sources list for delivery. A
vague true line beats a specific false one — never invent a number or a
quote. If the user wants to write or rework the script themselves,
welcome it; their text goes through the same timing rules.

Write N narration lines, `Scene 1 … Scene N`, **18–20 words each**, numbers
spelled out, plain spoken text. Structure: cold open (most surprising fact,
flat, no greeting) → stakes → evidence scenes (one idea each, concrete
number/date/place, escalating) → the turn → resolution + kicker that
reframes scene 1. Tone: curious, precise, a little wry — explains, never
hypes.

Design before writing: **one through-line object** that appears in every
scene and escalates; **a question hook answered last**; every scene a
continuous camera move that starts and ends in motion blur (the fake-oner —
hard cuts then read as one shot); an impact every ~3s; one reveal shot the
video is remembered by.

Show nothing yet — the script appears in the brief (Stage 5).

## Stage 4 — Voice

One message, then STOP:

> **🎙 Narrator** — pick a voice (or say `samples` to hear a line from each):
>
> | Voice | Sound |
> |---|---|
> | `Christopher` | deep US male — calm documentary authority |
> | `Ryan` | British male — serious, measured |
> | `Jenny` | US female — clear, warm, precise |

`samples` → voice the scene-1 line in all three (edge-tts:
`en-US-ChristopherNeural`, `en-GB-RyanNeural`, `en-US-JennyNeural`), send
the three files, wait for the pick.

## Stage 5 — The brief (gate)

One formatted message, generous spacing, an emoji headline per section:

- **📋 The brief** — a table: topic + angle, through-line object, look,
  length & scene count, aspect, narrator.
- **📝 The script** — the N lines, each labeled `Scene 1 … N`.

End with: **"All good — or change anything?"** The user can edit any line
or replace the whole script with their own. STOP; loop here until
approved. On approval, write the full pack to `projects/<slug>/pack.md`
(everything from Stages 6–8 in one document) and continue.

## Stage 6 — Style reference (the style key)

First message: explain, then offer three looks WITHOUT prompts:

> **🎨 Now let's create your visual reference** (your "style key")
>
> One image that locks the look of the entire video. You will attach it
> to every scene generation — it is what makes separate clips read as one
> film.
>
> | Variant | Feel |
> |---|---|
> | `classic` | one-sentence description |
> | `...` | one-sentence description |
> | `...` | one-sentence description |
>
> Pick one and I'll hand you the prompt.

Craft the three variants from the style's reference file: same visual
system, varied palette and composition, each named and described in one
sentence. STOP.

On the pick, second message: the clean pasteable prompt block, then:

> | Setting | Value |
> |---|---|
> | Model | Nano Banana Pro |
> | Aspect ratio | <the video's aspect> |
> | Type | image |
>
> Say `done` when you have your image — then we generate the scenes.

STOP.

## Stage 7 — Scenes, one at a time

> **🎬 The scenes** (N × 10s)

For each scene k — one message, STOP after each, `done` advances (a user
asking for everything at once gets all scenes in one message):

> ---
> **Scene k of N** — *"<the narration line, as context>"*
>
> ```
> <the full scene prompt from the reference template — STYLE REFERENCE /
> SCENE / MOTION / AUDIO / NEGATIVE — label NOT included>
> ```
>
> | Setting | Value |
> |---|---|
> | Model | Gemini Omni Flash (newest version) |
> | Reference image | **attach your style key** |
> | Aspect · Duration · Res | <aspect> · 10s · 720p+ |
> | Sound | ON — ambient SFX is designed into the prompt |
> | Save the download as | **`block0k.mp4`** |

Prompt rules (from the reference file): visualize the line's *idea*; no
readable text in clips (mixed style — diorama's letterpress prop labels
are the exception); nobody speaks on screen; NEGATIVE line copied verbatim
into every scene.

## Stage 8 — Clips come home

> **📥 Bring your clips in**
>
> Drop all N downloads into [`projects/<slug>/clips/`](projects/<slug>/clips/)
> — then say `done`. Named `block01…06`? Perfect. Named something else?
> Also fine — I'll sort it out.

On `done`: verify count, rename obvious variants silently (`block 1`,
`Block-2`, …), ask ONLY when genuinely ambiguous — never guess a pairing.

## Stage 9 — Voice & cut (Claude, silent)

No narration of any of this. Voice all N lines with the chosen voice into
`voice/block0N.mp3` (edge-tts). Check every take with ffprobe: **> 9.7s →
shorten the line, re-voice; < 7.5s → lengthen the line, re-voice** (free,
invisible). Then run the skill's `scripts/assemble.sh projects/<slug>` →
`final.mp4`, exactly N × 10s.

## Stage 10 — Delivery

Show `final.mp4` **in the chat** (send the file). Then, concise:

> **✅ Your video is ready**
>
> | | |
> |---|---|
> | Topic | … |
> | Length · Aspect | 60s · 16:9 |
> | Look · Narrator | mixed · Christopher |
> | Sources | the links behind the facts |
>
> Want a change to any scene, or a new video?

## Failure handling

- Clip renders off-style / photoreal → tighten the STYLE and NEGATIVE
  lines, regenerate that scene only; two identical failures = rewrite the
  prompt, not the seed.
- Generator refuses a scene → moderation. See the moderation map in the
  style reference: swap named politicians / close-up faces to mid-shot
  descriptions with censor bars; swap flagged imagery, keep the idea.
- Some platforms push a photoreal/"3D render" preset on stylized prompts —
  tell the user to decline it.
- Assembly complains → a file is missing or misnamed in `clips/` or
  `voice/`; fix, rerun the script.
