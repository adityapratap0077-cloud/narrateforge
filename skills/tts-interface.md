# tts interface

NarrateForge's narrated pipeline voices narration lines with a TTS CLI.
The `tts` skill used in the reference demos is a **platform-provided
tool** (bundled with the agent environment) and is not portable — it is
not included in this repo. Bring your own TTS that satisfies this
interface.

## Required interface

The pipeline scripts (`pipeline/tts-lines.sh`) call:

```bash
tts speak --text "<plain spoken text>" --output <path/to/lineN.mp3> [--voice <id>] [--language <code>]
```

Your substitute must support:

| Flag | Meaning |
|---|---|
| `--text` | the line to speak (plain spoken text: numbers spelled out, no markup) |
| `--output` | output audio path (mp3 preferred) |
| `--voice` | voice id (optional; default "Smooth"-style narrator) |
| `--language` | language code, default `en`; must match the script language |
| `--speed` | speaking speed percent, default `100` (used up to 115 for fit fixes) |

## Notes from the reference runs

- Default voice used: Meta AI "Smooth" (`avocado_v2:MAI_03`).
- On TTS failure: retry the **same** request on a bounded backoff
  (~5m, ~10m, ~30m, ~1h) — never swap voices or engines to work around a
  failure. If it still fails after ~1h, stop and report.
- A take that won't fit after speed (≤115) + line rewrite means the line
  is too dense — shorten it. Scene timing is the boss, not the script.
- `pipeline/fit-check.sh` verifies takes with ffprobe against scene
  windows; it only needs the audio files, not the TTS backend.
