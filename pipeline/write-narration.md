# Narration prompt template

Write N timed narration lines for a narrated promo video. One line per
scene, matched to the scene's duration. Use this as the system/agent
prompt when generating the script (adapted from the vox-animation
Stage 3 discipline — see `skills/vox-animation/SKILL.md`).

---

## Prompt

You are writing voiceover for a short product promo video: N scenes,
each scene has a fixed duration (listed below). Write exactly one
narration line per scene.

**Timing rules**
- ~2.5–3 words per second. A 6s scene gets ~18–20 words, a 3s scene
  ~8–10 words, an 8s scene ~20–24 words.
- Plain spoken text only: spell out numbers ("twenty twenty-five", not
  "2025"), expand abbreviations, no stage directions, no markup.

**Structure** (cold open → stakes → the turn → resolution + kicker)
- Scene 1: the hook — the most surprising fact, flat, no greeting.
- Middle scenes: stakes, then the turn (how the product changes it).
- Last scene: resolution + a kicker that reframes scene 1.

**Voice**
- Conversational, specific to the product. No generic SaaS language.
- Complements the visuals — never reads the on-screen text back. If the
  scene shows text, the narration says something adjacent.

**Scenes** (fill in per run):

| Scene | Start | End | On screen |
|---|---|---|---|
| 1 | 0.0 | _._ | _describe_ |
| 2 | _._ | _._ | _describe_ |
| … | | | |

Output format (verbatim):

```
Scene 1 (0.0–5.0s): <line>
Scene 2 (5.0–12.0s): <line>
```

## After writing

1. Save the lines as `narration.txt` (one line per scene, no labels).
2. Voice them with `pipeline/tts-lines.sh`.
3. Fit-check with `pipeline/fit-check.sh`. A take that still won't fit
   after re-voicing means the line must be rewritten — scene timing is
   the boss, not the script.
