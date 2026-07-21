# Aether Lens Product Roadmap

Updated: 2026-07-14

This is the canonical scope and priority document for Aether Lens. Read
`STATUS.md` for the current implementation state and next concrete task.

## Product definition

Aether Lens is the small, portable, general-purpose local-AI desktop in the
Aether family. Its job is to make private models, conversations, documents,
media, and model performance easy to understand and use.

The product family has intentionally separate lanes:

- **Aether Lens:** general chat, knowledge, media, voice, model management,
  comparison, transparency, and polished conversation UX.
- **Aether Studio:** full project and coding-agent environment.
- **ANCL Pad:** lightweight ANCL editing and compiler workflow.
- **Aether Engine:** private native inference and model-service runtime.

### Boundary that must not drift

Lens will not become a code editor, IDE, compiler front end, build/run/debug
surface, autonomous source editor, or compile-fix agent. Those workflows belong
to Studio and Pad.

Because a general assistant can answer with code, Lens may render, copy, save,
and export code blocks. It must not embed compilation or project editing. A
future one-way **Open in Studio/Pad** handoff is acceptable if it stays an
external handoff rather than duplicating either application.

## Delivery principles

- Keep Aether Engine the clean-install default and preserve Ollama/cloud choice.
- Remain portable, native, fast to start, and honest about every dependency.
- Prefer features that work offline and explain exactly what data is used.
- Keep advanced detail available without making the default UI intimidating.
- Ship narrow, testable milestones; update `STATUS.md` after each milestone.

## Ordered roadmap

### R0 - Engine-first portable baseline - COMPLETE

The native Engine is the default, starts and stops with Lens, supports a curated
model library and user-friendly runtime controls, reports model metadata and
final reply telemetry, and ships as a tiny portable binary bundle without
Aether Engine source.

### R1 - Lens Pulse performance dashboard - CORE COMPLETE

Turn the existing final reply statistics into a clear live view of what the
local model and hardware are doing.

Core presentation:

- Compact always-available summary plus an expandable detail panel.
- Request state: preparing, waiting for first token, streaming, stopped, failed.
- Time to first token (TTFT), live elapsed time, and total time.
- Live and final generation speed, prompt tokens, reply tokens, and totals.
- Context used versus model context limit.
- Prompt-evaluation and token-evaluation duration when the backend exposes them.
- Stop reason, backend, model, quantization, and selected hardware mode.
- Engine-specific GPU/residency and speculation counters when safely exposed.
- A five-reply speed history is shipped; a graphical sparkline remains optional polish.

Implementation sequence:

1. Define one normalized Lens telemetry record for Engine and Ollama.
2. Record request start, first streamed token, latest chunk, completion, and
   failure in the transport/UI boundary.
3. Add the compact Pulse strip without increasing the minimum window size.
4. Add the expandable details/history panel and a persisted visibility choice.
5. Gate Engine, Ollama, stop, timeout, and malformed/partial stream paths.

Shipped in the core pass: normalized local telemetry, live waiting/streaming
states, TTFT, elapsed time, live estimates, exact final token/context/timing
statistics, stop reason, recent speed history, compact status summaries, manual
stop/failure handling, and persisted Pulse visibility. A graphical sparkline and
additional Engine GPU/residency/speculation counters remain optional follow-up
until the Engine exposes those counters cheaply and truthfully.

Acceptance criteria:

- TTFT advances while waiting and freezes on the first visible response token.
- Live speed updates during generation; final counts match server telemetry.
- Stop and failure leave truthful partial measurements rather than stale data.
- Both local backends use the same labels and layout.
- Pulse can be hidden and does not make the normal chat experience feel busy.

### R2 - Rich answers and safe artifacts - COMPLETE; typed Document Canvas packaged

- Render Markdown headings, lists, emphasis, tables, links, and quotations. **Shipped.**
- Provide presented code blocks with Copy and Save actions only. **Shipped.**
- Create a model-authored Markdown document independently of its surrounding
  conversation. **Document Canvas is the approved replacement for fenced-block
  extraction: Add arms the next request, the entire visible reply becomes the
  draft, and a separate native window supports edit/preview/copy/save with no
  automatic file write. Existing answers can be opened through the transcript
  menu. **HTML and SVG modes passed interactive verification using the existing
  fail-closed security policy and sandbox. CSV mode is compiled with `.csv`
  save behavior and deterministic structural validation; its interactive
  cross-app verification passed by loading a Lens-saved file in ANCL Sheet.
  Exactly one whole-response typed code fence is removed
  to tolerate small models without reviving fenced-block extraction.**
- Add collapsible reasoning/tool-event sections where a backend exposes them. **Reasoning shipped; structured tool events remain future/backend-dependent.**
- Display inline images and readable document previews. **Shipped as compact sent-attachment Preview cards, a large image viewer, and a native read-only document viewer with portable archived assets.**
- Accept one image dragged from Windows Explorer. **Shipped dependency-free for
  PNG, JPG/JPEG, GIF, and WebP through the existing explicit-send attachment path.**
- Route PNG attachments through native Aether Engine vision. **Shipped for direct
  `gemma4:e4b` and as a sequential helper for text-only Engine models, with no
  Ollama dependency, honest PNG-only disclosure, ownership-safe model restore,
  a visible long-prefill state, exact-question helper prompting, authoritative
  evidence handoff, and a bounded auditable transcript excerpt.**
- Add read-only HTML/SVG artifact preview only after a safe isolation design. **Shipped with a documented fail-closed policy, restrictive CSP, and permissionless sandboxed iframe.**

The core pass keeps the canonical transcript and `.lens`/Markdown exports as
plain portable text, then applies a non-destructive RichEdit presentation layer
to assistant turns. Markdown markers are hidden where practical, links become
compact labels and require confirmation before opening, and `<think>` content is
hidden by default with a persisted reveal choice. The transcript context menu
can copy the last answer, copy its last complete fenced code block, or save that
block with a language-aware extension. No code is executed, compiled, or routed
into a project.

Verified in the core gate: mixed LF/CRLF model output, headings, bold and inline
code, fenced code, quotation/list/table styling, hidden reasoning persistence,
assistant-only copy, exact fenced-code extraction, and production compilation.
The media slice archives sent image/document assets once under `chats\assets\`,
stores only validated relative links in the canonical transcript, and reopens
them from compact Preview cards after saved-chat reload. Queued text attachments
also open in a native dark read-only viewer. The final slice accepts only
complete assistant `html`/`htm`/`svg` fenced blocks, rejects active or external
content without rewriting it, and opens a generated CSP-protected document
inside a sandboxed iframe. The security contract and regression gate ship with
the source. R2 is complete.

### R3 - Local document and folder intelligence - CORE COMPLETE

- Build a persistent, local, user-controlled knowledge index.
- Start with deterministic text extraction and lexical retrieval; add optional
  embeddings only when they materially improve results.
- Cite filenames and exact passages in answers and open the cited context.
- Show what was indexed, what was sent to the model, and how to clear it.
- Expand supported documents while keeping bounded context and offline use.

This is knowledge assistance, not autonomous source-tree editing.

The core pass stores an explicit user-selected corpus under the portable
`knowledge\` folder as readable copied text plus a manifest of original paths
and byte counts. It supports common plain-text document formats, caps indexing
at 256 KiB per file / 4 MiB total / 96 files / folder depth 6, and skips common
generated dependency folders. Retrieval is deterministic and dependency-free:
meaningful query terms score bounded line-aligned chunks and only the three best
positive matches enter the prompt.

Every assisted turn records exactly which `[K1]`-`[K3]` path and line range was
sent. Each record links to a Lens-created portable excerpt that reopens in the
native read-only viewer. The Add menu exposes index-file, index-folder,
enable/disable with an active checkmark, readable index inspection, storage
folder opening, and confirmed clear. When nothing matches, Lens says so and
sends no corpus text. Original sources are never edited.

Optional future extraction for binary office/PDF formats and optional local
embeddings remain follow-up only when they can preserve portability,
transparency, and a measurable retrieval improvement. They do not block R4.

### R4 - Conversation ergonomics - CORE COMPLETE

- Edit and resend a user turn.
- Regenerate, continue, delete, and retry a reply with another model.
- Branch a conversation without losing the original path.
- Add compact per-message Copy, Save, and metadata actions.
- Preserve branches and attachments in the portable chat format.

The transcript context menu now operates on the latest exchange without adding
a proprietary message database. Edit/resend is reversible until Send: Lens
places the prior user text in the composer and truncates the old path only after
the replacement passes prompt/model validation. Regenerate reuses that user turn
with the model and settings selected now, Continue records an explicit visible
continuation request, and confirmed Delete removes only the latest assistant
answer while preserving its user prompt.

Cancel staged edit removes only the pending replacement flag and keeps any
composer changes as a normal new-message draft, so abandoning an edit never
silently discards text.

Compact actions copy the last user, assistant, or complete exchange, save the
assistant answer as Markdown, copy truthful local Pulse metadata, and retain the
existing fenced-code/artifact controls. One-shot image/file/folder turns cannot
be silently regenerated without their payload; Lens directs the user to Edit,
reattach, and resend instead.

Safe Branch uses the current saved transcript plus a new Chat name. It refuses
unsaved originals, the same path, and existing destinations, switches to the new
portable `.lens` file, leaves the original untouched, and preserves relative
`chats\assets\` links. The readable V1 chat format remains unchanged. Native
regression coverage gates role boundaries, trailing Lens notes, unanswered user
turns, and attachment-marker detection.

### R5 - Model Arena - CORE COMPLETE

- Compare the same prompt across two or more installed models.
- Default to sequential runs so normal GPUs do not exceed VRAM.
- Offer optional parallel runs only when hardware and backends support them.
- Support blind preference selection and side-by-side Pulse measurements.
- Keep a local preference history that the user can inspect or erase.

The cyan **ARENA** control now opens the full workspace directly. Its Model A
and Model B dropdowns select two different installed models from one active
local backend, and its dedicated prompt field sends the same isolated input
sequentially. Selectors and prompt lock during the run. The showdown area
shuffles blind left/right positions and shows each
answer beside normalized Pulse measurements, accepts one Left/Right/Tie vote,
then reveals identities.

Readable `arena/preferences.tsv` history stores the model pair, resolved vote,
prompt SHA-256, and per-model measurements without retaining the prompt or full
answers. Arena Options and Privacy Proof can show/open/confirmed-clear that history.
Normal chat history, knowledge, and attachments are excluded from V1 comparisons
for reproducibility. Aether runs switch only a local Engine process Lens owns and
restore the user's selected model afterward. Hardware-aware parallel execution
remains optional future polish; sequential mode is the safe product default.

### R6 - Local voice conversation - STAGE 3 CORE COMPLETE

- Push-to-talk and clear recording state.
- Local speech-to-text first, with explicit optional system/cloud alternatives.
- Text-to-speech with interruption and replay controls.
- Display transcripts and privacy state before anything is sent.

Stage 1 now supplies dependency-free native Windows capture at 16 kHz mono
16-bit PCM. The bottom-bar Voice menu provides explicit Start, Stop-and-keep,
Cancel, Play, stop-playback, open-storage, and confirmed-delete actions. A red
REC state and live elapsed status make microphone use visible, and a 60-second
safety cap prevents an unbounded capture. Retention is deliberately simple and
inspectable: one `voice/last-recording.wav` file.

Stage 2 feeds the saved WAV to the installed Windows SAPI in-process recognizer:
no network, model server, subprocess, .NET, Ollama, or Aether Engine is used.
Lens displays the actual selected recognizer and opens its result in an editable
Local Voice Review. Insert stages the reviewed text in the composer but never
sends it; the normal explicit Send remains a second required action. Missing
local recognition support fails visibly with the WAV and composer unchanged.

Stage 3 adds asynchronous offline Windows SAPI synthesis for either the latest
assistant answer or current composer. Lens exposes the actual installed voice,
writes one transparent `voice/last-spoken.wav`, immediately stops generation or
playback, replays without regeneration, and confirmed-deletes only that WAV.
Hidden reasoning remains unspoken unless explicitly revealed. Source text and
generation time are bounded.

Privacy Proof reports capture, both WAVs, STT/TTS activity, recognizer/voice
identity, and pending-review state. Audio is never attached or sent. Optional
system/cloud speech paths remain future explicit opt-ins, never silent fallbacks.

### R7 - Privacy Proof - CORE COMPLETE

- Show the active endpoint and an unmistakable Local/Network/Cloud indicator.
- Show model digest, Engine executable digest, and relevant runtime version.
- Reveal which attachments/context excerpts were sent for the current turn.
- Provide one place to inspect storage locations and clear local history/cache.
- Make permissions and external network use opt-in and auditable.

The new bottom-bar **Proof** menu opens one native read-only report generated
without a model or network request. It shows backend and exact endpoint,
conservatively labels loopback versus network/cloud, identifies the selected
model digest when locally inspectable, hashes the configured Aether Engine
executable with Windows CryptoAPI SHA-256, reports ownership/runtime contract,
and reveals queued attachments plus local-knowledge disclosure state.

The same report lists exact portable root, config, chats/assets, knowledge, and
model-store paths. Its menu opens each location and provides confirmed narrow
clears for the current in-memory conversation, copied knowledge, and generated
artifact previews. Saved chats, attachment archives, original knowledge sources,
models, and Engine binaries are never bulk-deleted silently. The precise contract
is `PRIVACY_PROOF.md`; native gates cover endpoint look-alikes and a standard
SHA-256 known-answer vector.

### R8 - General-purpose tools and integrations

- Keep Document Canvas a focused one-draft review/save surface. A persistent
  document library or general workspace remains out of scope unless explicitly
  approved later.
- Add permissioned non-coding tools such as calculator, web lookup, and safe
  document operations when they improve general assistant use. **Native offline
  Calculator arithmetic, Copy/Insert-to-composer, dark styling, and placement
  passed interactive verification. A Dec/Hex/Bin converter is compiled and
  gated in the same window and passed GUI verification. Permissioned Web Reader
  is compiled and locally integration-tested with exact URL approval, bounded
  no-redirect transport, inert text extraction, source attribution, and
  Copy/Insert; its GUI verification passed. The Bing RSS experiment was rejected
  after poor live relevance. Search Google is compiled and natively gated as an
  explicit exact-URL browser handoff. An embedded WebView2 results pane now layers
  on that fallback using isolated clearable browser storage and an ANCL-native
  Evergreen runtime locator with no bundled loader DLL; Lens performs no
  search scraping, and Web Reader remains the attributed inert-text import path.
  The embedded Google GUI and subsequent loader-free ANCL runtime locator both
  passed real-results feel-tests; the pure-ANCL design is retained.**
- Consider an opt-in MCP bridge only after permissions, logs, timeouts, and
  portable dependency behavior are defined.
- Do not add source-edit/build/run tools to Lens; route those users to Studio.

### R9 - Public-release polish (friend-test candidate packaged)

- **First-run model and hardware guidance core is compiled and natively gated.**
  A clean launch reads total system RAM locally, offers a conservative curated
  Engine model, explains Full GPU plus Conservative/CPU fallbacks, and never
  downloads automatically. Accepting only stages the exact tag for the existing
  explicit Pull flow. Native policy, full regression, offline-guide, both
  clean-root decision paths, and interactive use pass.
- **Hugging Face cloud-open-model picker is compiled and safety-gated.** A named
  provider profile reads `HF_TOKEN`, fixes the official HTTPS router, loads its
  live text-chat catalogue from `/v1/models` on Library/Refresh, and lets the
  user select a `:cheapest` model with Use. It asks before every Send with exact
  host, model, outbound context, and credit disclosure. Missing-token and
  declined-permission paths make no request and do not mutate the transcript.
  Live catalogue, selection, streaming, and bounded text-attachment testing pass.
- Accessible keyboard navigation, DPI behavior, and screen-reader labels.
- Crash-safe conversation recovery and actionable diagnostics export.
- Reproducible friend-test packaging is complete. Versioning, code signing, and
  update documentation remain before a mass public release.
- A concise demo path that proves local operation and the portable footprint.

Release hygiene may proceed alongside any roadmap rung when needed; it does not
replace the next product milestone.

## Session rule

At the beginning of every Lens session:

1. Read `STATUS.md`.
2. Read this roadmap.
3. Work only on the stated current milestone unless the user reprioritizes it.
4. Keep compiler/editor/agent work in Studio or Pad.
5. Update `STATUS.md`, this roadmap, and the portable bundle documentation when
   shipped behavior changes.
a proprietary message database. Edit/resend is reversible until Send: Lens
