# Aether Lens Privacy Proof Contract

Updated: 2026-07-15

The Proof menu is a local inspection and retention surface. Opening it must not
start a model, send a prompt, contact an endpoint, or reveal an API key.

## Reported evidence

- Active backend and exact endpoint.
- Conservative endpoint classification: known loopback hosts are **LOCAL
  LOOPBACK**; every other endpoint is **NETWORK / CLOUD**.
- Selected model and its registry/manifest digest when locally inspectable.
- The configured Aether Engine executable path and a freshly calculated SHA-256
  digest of its bytes using Windows CryptoAPI.
- Whether the selected Engine process is Lens-owned, external/remote, absent,
  or irrelevant to the selected backend.
- Queued image/document state, knowledge-index state, indexed-file count, and
  the last retrieval match count.
- Explorer image drops only populate the same local queued-image state. Dropping
  a file never starts a model or crosses an endpoint; Send remains explicit.
- Native Aether Engine vision availability: direct `gemma4:e4b`, an installed
  local sequential helper, or unavailable for the selected model/settings.
  The current Engine boundary accepts one PNG per message. Lens never silently
  switches an external Engine process to a helper model, and it does not send a
  serialized vision request that reaches the Engine's current 256 KiB envelope.
- Whether native microphone capture or offline transcription is active, whether
  a saved local WAV exists, the exact `voice\last-recording.wav` path, actual
  installed Windows recognizer identity, and pending reviewed-text byte count.
- Capture and transcription require explicit actions. Recognition is local and
  in-process; the WAV is never attached or sent. Reviewed text reaches a backend
  only after separate Insert and Send actions.
- Whether local synthesis is active, the actual installed Windows voice identity,
  whether `voice\last-spoken.wav` exists, and its exact path. Synthesis reads only
  the explicitly selected latest answer or composer, runs in-process, and sends
  neither text nor audio to an endpoint.
- Exact portable app, config, chat/assets, knowledge, Arena preference-history,
  recording/synthesized-voice, and model-store paths.

Cloud provider model digests are reported as provider-managed rather than
invented. A missing Engine/model file produces an unavailable state; Proof does
not download, start, or query it merely to fill the report.

## Retention actions

The Proof menu can open the app, chats, knowledge, Arena, and portable model folders.
Its destructive actions are narrow and confirmed:

- **Clear current conversation** clears only the in-memory transcript. Saved
  `.lens` files and attachment assets remain.
- **Clear local knowledge** uses the existing confirmed knowledge clear path and
  never changes original source documents.
- **Clear generated artifact previews** deletes files only from the Lens-created
  `chats\artifacts\` directory. It does not delete `chats\assets\` or saved chats.
- **Clear Arena preference history** deletes only `arena\preferences.tsv` after
  confirmation. It never deletes the compared models, prompts, chats, or answers.
- Separate Voice-menu deletion actions remove only `voice\last-recording.wav` or
  `voice\last-spoken.wav` after confirmation.

Lens deliberately does not offer a one-click bulk deletion of every saved chat
or model. The Proof menu opens those readable folders so the user remains in
control of durable data removal.

## Verification

`tests/test_privacy_proof.ancl` gates loopback classification, look-alike host
rejection, and the standard SHA-256 `abc` known-answer vector. The portable
package continues to gate absence of live config and private Aether Engine
source/internal artifacts.
