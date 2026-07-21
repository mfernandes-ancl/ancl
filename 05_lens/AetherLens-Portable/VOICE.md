# Aether Lens Local Voice Contract

Updated: 2026-07-17

> **Release status — still in development:** Voice is intentionally hidden from
> the current Lens interface. Real microphone testing showed that the legacy
> Windows SAPI recognizer can return unreliable text even when the saved WAV is
> clear. This document now describes retained development code, not a supported
> friend-test feature. A future replacement must remain explicit and preferably
> use an optional local transcription model rather than silently adding cloud
> speech processing.

R6 Stage 3 completes the dependency-free local voice loop: native recording,
offline speech recognition, editable review, and offline speech synthesis. No
speech feature silently falls back to a cloud service.

## Capture

- **Start local recording** uses the native Windows multimedia API at 16 kHz,
  mono, 16-bit PCM and displays a conspicuous red **REC** state.
- **Stop and keep** writes `voice\last-recording.wav`; **Cancel** preserves any
  previous saved recording. A 60-second safety cap automatically stops/saves.
- Play, stop playback, open storage, and confirmed deletion remain explicit.

## Offline transcription and review

- **Transcribe last recording locally** uses the installed Windows SAPI
  in-process recognizer. Its actual identity is shown.
- Recognition can be cancelled and has a 120-second worker ceiling.
- Recognized text opens in editable **Local Voice Review** with Copy, Play WAV,
  Transcribe again, Close, and Insert controls.
- **Insert into composer** never sends. The normal **Send** remains required.

## Offline text-to-speech

- **Read last answer aloud locally** or **Read composer aloud locally** uses the
  installed Windows SAPI voice and shows its actual identity in Lens status and
  Privacy Proof.
- Synthesis happens asynchronously into a transparent 16 kHz mono PCM file at
  `voice\last-spoken.wav`; only the finished local WAV is played.
- **Stop local speech** cancels active synthesis or immediately interrupts WAV
  playback. **Replay last local speech** replays the retained WAV without
  regenerating or contacting anything.
- **Delete synthesized speech** removes only `last-spoken.wav` after confirmation.
- Source text is bounded to 16 KiB and synthesis to 120 seconds. The status line
  discloses truncation when the cap applies.
- `<think>` tags are never spoken. Reasoning text itself is omitted while hidden
  and included only after the user explicitly enables reasoning visibility.

## Privacy boundary

Recording and synthesis run locally in-process. Neither WAV is an attachment or
is sent to a backend. Speech-to-text output reaches a model only after separate
Insert and Send actions. Text-to-speech reads only a user-selected local source:
the latest answer or current composer. There is no network request, model server,
subprocess, .NET runtime, Ollama, or Aether Engine in either speech path.

Privacy Proof reports capture/WAV/STT/TTS state, exact file paths, actual
recognizer/voice identities, and pending reviewed-text bytes without invoking a
model or network.

## Verification

- `tests/test_voice_core.ancl` gates PCM/WAV capture bookkeeping.
- `tests/test_voice_stt.ancl` performs native recognition when its local
  synthetic fixture is generated and skips safely otherwise.
- `tests/test_voice_tts.ancl` silently generates and validates a WAV, checks
  actual runtime identity, cancellation cleanup, and hidden/revealed reasoning
  selection. It never plays audio.
- Clean-root/full-source gates never activate the microphone or speakers. The
  remaining verification is a user-controlled recording and listening feel-test.
