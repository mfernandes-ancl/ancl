# Aether Lens Current Status

Updated: 2026-07-17

Current milestone: **R9 friend-test candidate packaged; feature work paused**

Canonical plan: `ROADMAP.md`

## 2026-07-17 Friend-test portable release

- The user declared Lens feature work finished for now and authorized a portable
  build for testing by a friend before a later public GitHub release.
- The clean package contains freshly compiled `aether_lens.exe` and
  `aether_engine.exe`, the offline guide/docs, readable defaults, the complete
  Lens source closure, empty user-data/model directories, and `SHA256SUMS.txt`.
- Release audit passes: every manifest entry matches; no live
  `aether_lens.cfg`, chat, recording, Arena history, GGUF/partial model, or
  token-shaped secret is present. Lens SHA-256 is
  `A512273B0A59E37B06087EE0E03AA2D92B0A86DD0072FD614AB4598424499548`;
  Engine SHA-256 is
  `1B81992A5E025D1E519F58F4A5D1ADAD29C38E697C993072C08AFDC084EE6C6B`.
- This is an unsigned friend-test candidate. Versioning, code signing, broader
  accessibility/DPI testing, and feedback-driven fixes remain before a mass
  public release.

## 2026-07-17 Arena menu and development-bin cleanup

- Arena Options now routes owner-drawn menu messages through the menu renderer,
  so its four real actions display their proper labels instead of all falling
  back to `Copy`: Blind preference mode, Show local preference history, Open
  Arena storage folder, and Clear Arena preference history.
- The Arena child window now also forwards those menu command IDs to the main
  command handler. In particular, Open Arena storage folder opens Explorer even
  when the already-created folder has no preference history yet.
- The development `bin` folder now keeps the runnable `aether_lens.exe` and its
  requested production `aether_lens.asm` listing. Native test executables and
  temporary staged builds were removed; their sources remain under `src`/`tests`.
- Current development executable SHA-256:
  `A512273B0A59E37B06087EE0E03AA2D92B0A86DD0072FD614AB4598424499548`.
  The friend-test portable package now includes this fix.

## 2026-07-17 Voice held for development

- Real microphone/WAV testing showed that the legacy local Windows SAPI
  recognizer can produce unreliable transcripts even when the captured audio is
  clear. The user approved hiding Voice from the release UI rather than exposing
  it as a finished feature.
- Voice source and native tests remain for future work, but the Voice button and
  menu are absent from the normal interface. In-app Help and the offline guide
  label it **still in development** pending a more reliable optional local
  transcription engine. The UI-hidden build is promoted to
  `bin\aether_lens.exe`, SHA-256
  `A512273B0A59E37B06087EE0E03AA2D92B0A86DD0072FD614AB4598424499548`.

## Product direction

Lens is the portable general-purpose local-AI desktop. Coding IDE, compiler,
build/run/debug, autonomous source editing, and compile-fix workflows are
intentionally assigned to Aether Studio and ANCL Pad, not Lens.

Lens may display/copy/save code that naturally appears in a conversation. That
does not make coding workflow integration part of its scope.

## 2026-07-17 R9 first-run guidance

- A clean launch now reads total physical memory through the native Windows API
  and presents a local-only model/hardware explanation after the main window is
  visible.
- The conservative RAM tiers recommend an exact curated Engine tag from
  `qwen2.5:0.5b`, `qwen3:0.6b`, `qwen3:1.7b`, or `qwen3:4b`, with the download
  size disclosed before any network action.
- The prompt explicitly distinguishes system RAM from GPU memory, recommends
  Full GPU's automatic discrete-adapter selection, and points to Conservative
  GPU and CPU reference as ordered compatibility fallbacks.
- Accepting only stages the recommendation and saves it. It never pulls a model
  or starts a download; the existing explicit Pull action remains the network
  boundary. Declining keeps the default.
- The pure tier/tag/download policy passes its native boundary gate, all Lens
  native gates pass (with the microphone fixture correctly skipped), and the
  19-link offline guide has no missing target or external asset.
- Automated clean-root startup proved the prompt appears before config is
  written. No preserves `gemma3:270m`; Yes selected this machine's 16-31 GiB
  recommendation, `qwen3:1.7b`, with Full GPU. Neither path created a GGUF.
  Interactive visual/wording feel testing remains.
- `package.ps1` includes the first-run source module, and the authorized
  friend-test folder/ZIP rebuild passes its privacy and manifest audits.
- The current development binary is 1,138,176 bytes with SHA-256
  `A512273B0A59E37B06087EE0E03AA2D92B0A86DD0072FD614AB4598424499548`.

## 2026-07-17 R9 Hugging Face cloud picker

- Backend now includes **Hugging Face (cloud)** while retaining the proven
  OpenAI-compatible streaming transport.
- The profile reads only `HF_TOKEN`, fixes
  `https://router.huggingface.co/v1`, and uses Hugging Face's live
  `/v1/models` text-chat catalogue. **Library** and **Refresh** load up to 128
  current choices in the left list; select one and press **Use** to apply the
  explicit `:cheapest` provider-selection policy.
- Each Send asks first with the exact host/model and discloses transcript,
  knowledge, third-party processing, and possible credit use. Declining happens
  before the user turn is appended. The token is never persisted.
- V1 is intentionally text-only. Pull and Delete remain blocked for the remote
  profile; Refresh/Library browse remote models and Use selects a remote model
  without downloading it.
- Bounded `.md`, `.txt`, and `.ancl` attachments are included inline as text
  for HF sends. Images remain blocked; the approval dialog now names queued
  text/code content as outbound context.
- Native policy rejects HTTP, alternate hosts/path suffixes, and image
  attachments while permitting bounded text/code context.
  Clean-root gates prove exact profile restoration, missing-token refusal, and
  permission-decline with zero transcript mutation and no network request.
- The previous live request passed and the cloud-stream duplicate rendering bug
  was fixed. The public catalogue returned 121 models in a read-only integration
  check; all native Lens gates pass (one existing microphone fixture skips). The
  picker build is promoted to `bin\aether_lens.exe`, SHA-256
  `A512273B0A59E37B06087EE0E03AA2D92B0A86DD0072FD614AB4598424499548`.
  Live catalogue, selection, approved Send, streaming, and text-file attachment
  feel-testing passed. The friend-test portable release includes the feature.

## 2026-07-16 Document Canvas decision and implementation

- The user approved **Add > Document Canvas** as the replacement for the fragile
  fenced-document exporter. Canvas mode treats the entire visible answer as the
  Markdown draft, so model compliance with an outer fence is no longer required.
- The generated draft opens in a separate native editable window with local
  Preview/Edit switching, Copy All, Save, Save As, Close, and an unsaved-changes
  confirmation. It never chooses a folder or writes a file automatically.
- The transcript fallback is **Open last answer in Document Canvas**. Ordinary
  Save-last-answer-as-Markdown and fenced code-block Copy/Save remain unchanged.
- The old complete-fence extraction, incomplete-document dialogs, special
  continuation prompt, and automatic stitching have been removed from Lens.
- Canvas V1 is deliberately a single focused Markdown draft, not a project
  editor or persistent document library.
- Markdown Canvas passed the user feel-test, including its corrected button
  labels and immediate Preview/Edit repaint. That exact baseline was packaged
  with the approved native-vision Engine binary.
- Add > Document Canvas now contains Markdown, HTML, SVG, and CSV types. HTML/SVG use
  type-specific no-fence prompts, matching Save extensions, and Safe Preview
  through the existing fail-closed validator and permissionless browser sandbox.
  The standard inert SVG namespace declaration is allowed; other URLs remain blocked.
  The user feel-test confirmed that accepted SVG opens in the sandbox and unsafe
  external HTML fails closed with a visible Canvas explanation.
- Small-model tolerance removes exactly one complete outer `html`, `htm`, `svg`,
  or `csv` code fence; inner fences and surrounding prose are never rewritten.
- CSV Canvas requests raw RFC-4180-style rows, saves as `.csv`, and provides
  native structural validation for quoting and consistent column counts without
  changing the draft.
- CSV passed its interactive cross-app feel-test: Lens generated, validated, and
  saved the draft, and ANCL Sheet loaded the resulting `.csv` into the expected
  rows and columns.
- The verified typed build is packaged with the approved native-vision Engine;
  its packaged Engine SHA-256 matches the approved binary exactly.
- Next product discussion starts at R8 general-purpose tools and integrations. The
  replacement USB-microphone STT feel-test remains when the user is ready.

## 2026-07-16 R8 local tools

- **Add > Local Tools > Calculator** opens a separate native offline window.
- The deterministic parser supports decimal arithmetic, parentheses, unary
  signs, and `+`, `-`, `*`, `/` with normal precedence. Syntax errors and
  division by zero are shown locally; no prompt or network request occurs.
- Results can be copied or inserted exactly at the current composer cursor.
  Insertion never sends the message automatically.
- Arithmetic Evaluate, Copy/Insert, dark styling, and monitor-aware side-by-side
  placement passed the user feel-test. Document Canvas now shares the same
  monitor-aware placement instead of fixed desktop coordinates.
- The same window now includes an integer base converter accepting decimal,
  `0x` hexadecimal, and `0b` binary values with optional `_` separators. It
  synchronizes Dec/Hex/Bin and can copy or insert the complete conversion set.
- The calculator/converter core has an independent native regression gate. The
  converter GUI feel-test passed.
- **Add > Local Tools > Web Reader** accepts one explicit HTTP/HTTPS URL and
  asks before every request with the exact host and URL visible.
- Web Reader caps downloads at 128 KiB, uses 15-second network-phase timeouts,
  disables automatic redirects, strips markup plus script/style content, and
  records source URL, local retrieval time, HTTP status, and readable byte count.
  Credentials/fragments/file URLs/malformed ports are rejected before connect.
- Copy Text and Insert Excerpt retain the source. Insert never sends. Stop/Close
  aborts the request and cancelled partial content is discarded.
- URL/extraction gates and a local loopback transport integration test pass.
  The user feel-test confirmed exact permission disclosure, successful HTTPS
  extraction, visible retrieval metadata, and attributed Insert Excerpt.
- The rejected Bing RSS inline-results experiment has been removed because its
  live relevance was unacceptable. Lens does not scrape search-result HTML.
- **Add > Local Tools > Search Google** percent-encodes the query locally, shows
  the exact URL for approval, and renders the real active page in a native ANCL
  WebView2 host. Lens does not scrape the result DOM or send queries to a model.
- The WebView2 Evergreen runtime is shared from Windows. A native ANCL locator
  reads the per-user/per-machine EdgeUpdate runtime state, loads the installed
  x64 `EmbeddedBrowserWebView.dll`, and invokes its environment entry point
  directly. Lens bundles no WebView2 loader DLL or browser runtime.
- Runtime discovery/initialization failure falls back to the already verified
  external-browser handoff.
- Browser cookies, cache, and site storage use an isolated portable
  `webview2-profile` folder. Proof discloses it and provides confirmed clearing
  while the Search window is closed.
- Web Reader remains the explicit attributed path for bringing a chosen result
  page back into Lens. The Google URL builder has an independent native gate;
  the embedded-results GUI passed the user's interactive feel-test with real
  Google results rendered correctly beneath the native Lens search controls.
- The subsequent ANCL-only runtime locator passed a clean-folder smoke test:
  `aether_lens.exe` plus `guide.html`, no `WebView2Loader.dll`, successfully
  launched six fresh WebView2 renderer processes.
- The user then interactively verified the loader-free build: embedded Google
  results still render correctly with the runtime located entirely by ANCL.
  This pure-ANCL integration is the retained design.
- Per user direction, development builds continue without rebuilding the
  portable folder/ZIP until Lens work is declared final.

## Shipped baseline

- Native Win32 Lens UI written in ANCL.
- Aether Engine is the default clean-install backend.
- Lens discovers, starts, waits for, reuses, restarts, and stops only the local
  Engine process that it owns.
- Ollama, OpenAI-compatible, and Anthropic backends remain available.
- Streaming, multi-turn chat, saved chats, export, copy, and attachments.
- Dependency-free Windows Explorer image drop queues exactly one supported PNG,
  JPG/JPEG, GIF, or WebP through the existing preview and explicit-Send path;
  busy, unsupported, and multi-file drops are rejected visibly.
- Curated Engine and Ollama libraries, native model pull, model selection, and
  Engine SHA-256 verification.
- Engine runtime controls with visible active checkmarks: hardware, output
  constraint, style, reasoning, reply length, speculation, and GPU timing.
- Detailed GGUF/Ollama model inspection including parameters, quantization,
  architecture, context geometry, tensors, digest, capabilities, and support.
- Native Engine model selection now treats installed and runnable as separate
  states. Use and local Send require `Forward status: supported`; an unsupported
  shared-store GGUF is blocked without replacing the current working model.
- Final per-reply prompt/reply counts, timing, and approximate throughput for
  both Engine and Ollama.
- Lens Pulse live/final telemetry for Engine and Ollama: request state, TTFT,
  elapsed time, live estimates, exact final prompt/reply/context counts,
  prompt/generation/load timing, throughput, stop reason, and speed history.
- Compact Pulse summaries remain in the status line when its expanded panel is
  hidden; Pulse visibility is remembered.
- Rich Answers non-destructively presents assistant Markdown headings, bold
  emphasis, inline/fenced code, lists, tables, quotations, and compact links
  while saved chats and exports remain plain portable text.
- Add > Document Canvas marks the next request as a document task and opens the
  entire visible answer as an editable Markdown draft without requiring fences.
  Preview/Edit, Copy, Save, Save As, and unsaved-close protection are local; no
  destination is selected and no file is written automatically.
- The transcript can open any latest answer in Canvas as a fallback. Ordinary
  answer-as-Markdown saving and fenced code-block Copy/Save remain available.
- Help/F1 opens a complete offline HTML guide; the compact native help remains
  available as a missing-file fallback.
- Engine pulls show live percent and transferred/total bytes from truthful
  Engine stream telemetry while SHA-256 verification remains in the same flow.
- Sent image/document turns contain compact Preview cards backed by a single
  archive copy under `chats\assets\`; validated relative links survive saved-chat
  reloads and portable folder moves.
- Native Aether Engine vision sends one PNG directly to `gemma4:e4b` through
  `/api/chat images[]` without Ollama. Text-only Engine models can use an
  installed `gemma4:e4b` sequentially as a helper, after which Lens restores
  the selected chat model. External Engine processes are never switched.
- Lens exposes the Engine's PNG-only/single-image boundary, marks sent versus
  unsent images in the transcript, advertises vision in model info/Library,
  and shows `reading image locally` during the roughly one-minute CPU prefill.
- Native helper routing asks the vision model the user's exact image question,
  passes its answer as authoritative pixel-grounded evidence, and exposes a
  bounded evidence excerpt in the transcript so perception and final-model
  errors can be distinguished.
- Queued text, Markdown, and ANCL files open in a native dark read-only document
  viewer; images continue to use the large native image viewer.
- The latest complete assistant HTML/SVG fenced block can open as a read-only
  artifact after a fail-closed active-content check, restrictive CSP, and a
  permissionless sandboxed iframe; no WebView or third-party runtime is added.
- A persistent, portable local knowledge index copies only explicitly selected
  readable files/folders under `knowledge\`, with a readable original-path and
  byte-count manifest. It is capped at 256 KiB/file, 4 MiB total, 96 files, and
  folder depth 6.
- Dependency-free lexical retrieval sends at most three positive bounded
  matches per prompt. The transcript exposes each `[K1]`-`[K3]` path and exact
  line range, and portable **Open cited passage** links reopen archived excerpts
  in the native read-only viewer.
- Add-menu knowledge controls rebuild from a file/folder, enable or pause with
  a checkmark, inspect index contents/storage/caps, open the storage folder, and
  clear copied data after confirmation. Original sources are never changed.
- The transcript context menu copies the last assistant answer, copies the last
  complete fenced code block, or saves it with a language-aware extension.
- R4 conversation controls edit/resend reversibly, regenerate with the selected
  model, continue, confirm-delete the latest answer, copy the last user/answer/
  exchange, save the answer as Markdown, and copy local reply metadata.
- Safe branching writes the current saved conversation under a new Chat name
  without overwriting the original or an existing destination; portable
  attachment links remain valid because the readable V1 chat format is unchanged.
- The bottom-bar Proof menu generates a native local-only privacy report with
  endpoint classification, selected model identity, Engine executable SHA-256,
  process ownership, current attachment/knowledge disclosure, and exact storage
  locations. Opening it invokes no model and makes no network request.
- Proof also opens the app/chat/knowledge/model folders and provides confirmed,
  narrowly scoped clears for the in-memory transcript, copied knowledge, and
  generated artifact previews while preserving saved chats and attachment assets.
- The distinct cyan ARENA control opens the full comparison workspace directly.
  Installed Model A/Model B dropdowns, a dedicated prompt field, and the cyan
  Run Showdown control keep contender setup inside Arena; the saved pair returns.
- Arena selectors now share Studio's flat dark closed-box/custom-arrow treatment
  and dark highlighted popup; the aligned outlined prompt has a muted empty cue.
- Pair/prompt controls lock while the two local requests run sequentially to
  protect VRAM. The showdown area shuffles blind sides and presents both answers with
  normalized Pulse measurements, records one Left/Right/Tie vote, then reveals
  model identities.
- Readable local Arena history stores model/vote, prompt SHA-256, and measurements
  without prompts or full answers; Arena Options and Proof expose show/open/confirmed-clear.
- R6 Local Voice records dependency-free 16 kHz mono PCM through the
  native Windows API with explicit Start/Stop/Cancel, a red REC state, live
  elapsed time, and a 60-second safety cap.
- Voice retains at most one transparent `voice\last-recording.wav`; playback,
  stop-playback, open-storage, and confirmed delete are available in the same
  menu. Cancel preserves any earlier saved WAV.
- Stage 2 transcribes the saved WAV entirely offline through the installed
  Windows SAPI in-process recognizer, exposes the actual runtime identity, and
  supports cancellation without Ollama, Aether Engine, .NET, or a subprocess.
- Recognized text opens in an editable local review with Copy, Play, transcribe
  again, Close, and Insert. Insert only stages text in the composer; Send remains
  separate. The WAV is never attached or sent to a backend.
- Privacy Proof exposes microphone/WAV/STT state, exact path, recognizer identity,
  and pending reviewed-text bytes without invoking a model.
- Stage 3 reads either the latest answer or composer through the installed SAPI
  voice, exposes its real identity, and retains one transparent 16 kHz mono PCM
  `voice\last-spoken.wav` for immediate Stop, Replay, and confirmed deletion.
- TTS generation is asynchronous, cancellable, capped at 16 KiB/120 seconds,
  and omits hidden reasoning unless the user explicitly reveals it. Neither
  recording nor synthesized audio is attached or sent.
- Backend `<think>` reasoning is hidden by default, can be revealed explicitly,
  and the presentation choice persists. Links require confirmation before the
  browser opens; Lens never compiles or runs code.
- Last backend, per-backend model, Engine settings, specialist, chat name,
  vision helper, and edited model/URL controls survive shutdown and relaunch.
- A tiny portable package containing Lens source and binaries for Lens + Engine,
  while deliberately excluding all Aether Engine source/internal artifacts.

## Current verified release facts

- Current staged/portable Lens production build is 639 functions / 1,251 strings
  (`935,424` bytes; SHA-256
  `A7961BAA00BAD0FA63F3D345E8EB6998E4C58FC77AC21EC4C3ADAD6F68FD5A94`).
  If the development Lens is open, packaging uses these fresh staged bytes and
  leaves the locked older `bin\aether_lens.exe` process untouched.
- The validated native-vision Engine binary from commit `fb0de7e` is `6,717,440`
  bytes with SHA-256
  `1B81992A5E025D1E519F58F4A5D1ADAD29C38E697C993072C08AFDC084EE6C6B`.
  Its neutral-filename red control returned `Red`, `done_reason=stop`, in
  59,622 ms through `/api/chat images[]`; only the exact launched test PID was stopped.
- The corrected full sequential contract passed on the neutral-name red PNG:
  the exact-question `gemma4:e4b` helper returned evidence `Red` in 59,416 ms,
  then `llama3.2:1b` returned `The dominant color is red.` with
  `done_reason=stop`. Both separately launched test PIDs were stopped exactly.
- `package.ps1 -EngineBinary <validated.exe>` can now package a specifically
  approved Engine binary without compiling or touching its changing source.
- The portable app launches `aether_engine.exe` beside Lens with no third-party
  inference runtime.
- The package privacy gate rejects Engine source, assembly, object, map, test,
  and internal-document artifacts.
- The bundle contains the Lens ANCL source and its minimal `core_lib` closure.
- `ROADMAP.md` and `STATUS.md` are included at the bundle root and with the Lens
  source so recipients and future sessions retain the same product direction.
- Models are intentionally downloaded separately into the portable `models/`
  folder, keeping the initial bundle extremely small.
- Live user testing has confirmed model pulling, Engine chat, reasoning control,
  selection checkmarks, model metadata, and final telemetry.
- The R2 mixed-format gate visually verified Markdown presentation and passed
  exact fenced-code copy, assistant-only answer copy, reasoning persistence,
  safe-link confirmation, and the language-aware Save dialog.
- The Engine pull gate emitted monotonic structured progress from 0 through 100
  on a real registry/CDN transfer and completed SHA-256 verification.
- The repository guide passes its offline structure gate: 18 navigation links
  resolve and no external assets are required. The updated copy is packaged.
- The shared artifact policy gate covers safe styled HTML, SVG fragment paint,
  scripts, event handlers, frames, links/resources, unsafe CSS, data schemes,
  forms, metadata, active SVG, and cross-file SVG references.
- A hidden native Lens integration gate proved unsafe assistant HTML is blocked
  before `chats\artifacts\` or any preview file is created.
- Packaging now rebuilds the normal `bin\aether_lens.exe` used by development
  shortcuts and copies that exact binary into the portable release, preventing
  a stale local menu from diverging from the ZIP.
- The final R3 package manifest verifies with zero failures; development and
  packaged Lens hashes match, packaged knowledge-module source matches the
  repository, live config is absent, and Engine source/privacy leaks are zero.
- The R4 transcript module gate passes last-user selection, answer selection,
  Lens notes after answers, unanswered user turns, and one-shot attachment
  marker detection. The packaged source closure compiles independently.
- The final R4 package manifest verifies with zero failures; development and
  packaged Lens hashes match, packaged conversation-module source matches the
  repository, live config is absent, clean-root launch/close passes, and Engine
  privacy leaks are zero in both the folder and ZIP.
- The R7 native proof gate passes strict endpoint classification and the
  standard SHA-256 `abc` known-answer vector; the report path compiles into the
  production Lens without adding an inference or browser runtime.
- A clean-root R7 launch/close smoke passed on a non-Engine configuration and
  confirmed that no `aether_engine.exe` process was started.
- The R5 native Arena gate passes pair validation, shuffled-side vote mapping,
  ties, invalid choices, and throughput math. A deterministic local mock UI gate
  then proved the cyan button opens Arena directly, saved Model A/Model B
  dropdown selections populate, a prompt typed in Arena drives two sequential
  requests with identical bytes, one blind vote writes readable history, and
  zero Aether Engine processes start.
- The exact portable Lens source closure now includes `vision_policy.ancl`,
  `drop_policy.ancl`, `voice_stt.ancl`,
  `voice_tts.ancl`, and their
  `win32_com.ancl` dependency alongside Arena and recording modules, and compiles
  independently to the production 639-function / 1,251-string binary.
- The pre-Canvas native Lens gates pass, including the Aether compatibility guard,
  case-insensitive supported image
  extensions, and disguised-suffix
  rejection for Explorer drops. The SAPI STT gate recognized a locally generated
  synthetic WAV, and a clean real-window gate proved editable review -> exact
  composer character count with no automatic send or Aether Engine process.
- The silent SAPI TTS gate generated/validated a WAV, reported the actual voice,
  purged a cancelled synthesis, removed its temporary file, and gated hidden vs
  explicitly revealed reasoning without playing through the speakers.
- The stable combined folder/ZIP is rebuilt only from the validated Engine
  binary above: 49 files / about 8.4 MB unpacked and an approximately 554 KB ZIP.
  Manifest verification, packaged binary identity, independent packaged-source
  compilation, live-config exclusion, and Engine-source privacy all pass.

## Known gaps

- Pulse uses a five-reply textual speed history; a graphical sparkline is
  optional polish.
- GPU residency and speculation acceptance counters wait on a cheap, truthful
  Aether Engine server telemetry contract.
- Binary PDF/Office extraction and optional local embeddings are future
  retrieval enhancements; the dependency-free cited text index is complete.
- Local recording, offline speech-to-text, editable review-before-send, and
  interruptible/replayable offline text-to-speech are complete. A user-controlled
  Read-last-answer playback feel-test passed; microphone capture/STT still needs
  the user's replacement USB microphone because automation must not activate it.
  Optional hardware-aware parallel Arena runs remain future polish; the shipped
  safe default is sequential comparison.
- Engine store deletion is unavailable because the Engine has no delete command.
- Aether Engine currently caps one generated reply at 512 tokens. Canvas opens
  partial replies honestly; a larger single-reply ceiling and future reviewed
  append/revision flow remain follow-ups.
- Native Engine vision is PNG-only, one image per message, and CPU float64 for
  the vision tower. JPEG/multi-image and vision GPU acceleration are Engine-side
  follow-ups; Lens intentionally reports the current contract instead of faking support.
- Models are not bundled by default, by design.

Coding/compiler integration is not a gap. It is intentionally out of scope.

## R2 Rich Answers verification and next slice

- [x] Present Markdown headings, bold, inline/fenced code, lists, tables,
      quotations, and label-only links without mutating the transcript.
- [x] Correctly map both bare LF model output and CRLF saved-chat boundaries.
- [x] Copy the last assistant answer and copy/save its last fenced code block.
- [x] Hide/reveal `<think>` sections and persist the choice.
- [x] Require confirmation before opening HTTP/HTTPS links.
- [x] Keep compile/run/project editing outside Lens.
- [x] Gate rendering, extraction, assistant isolation, and persistence.
- [x] Present sent images as compact conversation Preview cards with portable assets.
- [x] Add readable local document previews before and after send.
- [x] Keep attachment asset links relative, portable, and traversal-resistant.
- [x] Design, document, implement, and gate isolated read-only HTML/SVG preview.
- [x] Arm Markdown creation explicitly through Add > Document Canvas.
- [x] Open the whole visible answer without requiring a model-authored fence.
- [x] Edit/preview/copy/save locally with no automatic file write.
- [x] Open an existing latest answer in Canvas from the transcript menu.
- [x] Generate/save CSV drafts and validate RFC-4180-style quoting plus
      consistent row widths without rewriting the source.
- [x] Remove only one complete matching typed outer fence for small-model
      tolerance; preserve surrounding prose and nested content unchanged.

## R3 Local knowledge verification

- [x] Persist an explicit user-selected copied corpus and readable manifest.
- [x] Bound file, corpus, traversal, chunk, and per-prompt context sizes.
- [x] Rank locally with deterministic lexical matching and no dependencies.
- [x] Send only positive top-three passages with `[K1]`-`[K3]` citation guidance.
- [x] Record exact paths/line ranges sent and reopen portable cited excerpts.
- [x] Provide enable/disable, show, open-storage, rebuild, and confirmed-clear controls.
- [x] Preserve the read-only Lens/Studio/Pad product boundary.
- [x] Update built-in Help and the full offline HTML guide in the same change.

## R4 Conversation ergonomics verification

- [x] Stage the last user turn in the composer without changing history until Send.
- [x] Cancel a staged edit while keeping composer changes as a normal draft.
- [x] Regenerate through the currently selected model and settings.
- [x] Record Continue as an explicit user turn and confirm before answer deletion.
- [x] Refuse silent regeneration when a one-shot attachment must be reattached.
- [x] Copy user/answer/exchange/metadata and save the last answer as Markdown.
- [x] Branch only from a saved original to a new non-existing Chat name.
- [x] Preserve the V1 readable transcript and relative attachment assets.
- [x] Gate transcript roles, notes, unanswered turns, and attachment markers natively.
- [x] Update built-in Help and the 16-section offline HTML guide in the same change.

## R7 Privacy Proof verification

- [x] Classify exact loopback endpoints separately from network/cloud endpoints.
- [x] Reject look-alike hostnames and hash runtime bytes with native SHA-256.
- [x] Show model/runtime identity, ownership, disclosure, and storage in one report.
- [x] Make report generation model-free and network-free.
- [x] Open each portable storage location from one menu.
- [x] Confirm and narrowly scope conversation, knowledge, and preview clearing.
- [x] Preserve saved chats, attachment assets, original sources, and models.
- [x] Update built-in Help, offline HTML guide, and the privacy contract together.
- [x] Pass all four native Lens gates, the 16-section offline guide gate, and a
      clean-root launch/close without starting Aether Engine.

## R5 Model Arena verification

- [x] Open Arena directly and select two different installed models from its
      Model A/Model B dropdowns on one active local backend.
- [x] Keep the prompt inside Arena and lock pair/prompt controls during execution.
- [x] Send identical isolated prompt bytes sequentially and keep chat unchanged.
- [x] Shuffle blind left/right sides and reveal identities only after one vote.
- [x] Show prompt/reply tokens, elapsed time, and throughput beside each answer.
- [x] Persist only models, vote, prompt SHA-256, and measurements in readable TSV.
- [x] Show/open/confirmed-clear Arena history from Arena and Privacy Proof.
- [x] Refuse attachments, cross-backend pairs, and external Aether model switching.
- [x] Gate pair/vote math natively and complete a deterministic local two-request
      UI integration run without starting Aether Engine.
- [x] Update built-in Help, offline HTML guide, Arena/privacy contracts, and package.

## R6 Local Voice verification

- [x] Capture 16 kHz mono 16-bit PCM through the native Windows multimedia API.
- [x] Require explicit Start and expose Stop-and-keep plus Cancel actions.
- [x] Show a conspicuous red REC state, live elapsed time, and a 60-second cap.
- [x] Retain one readable WAV with Play, stop playback, open, and confirmed delete.
- [x] Release the recording device on stop, cancel, failure, and Lens shutdown.
- [x] Report capture/retention/path state in Privacy Proof without a model call.
- [x] Keep Stage 1 audio outside attachments and model requests.
- [x] Pass the WAV primitive gate, all existing native gates, full Lens compile,
      and startup/close smoke without activating the microphone.
- [ ] Complete an interactive microphone Start/Stop/Play/Cancel feel-test.
- [x] Add cancellable offline Windows SAPI STT with visible runtime identity.
- [x] Open an editable local review before text can enter the composer.
- [x] Require separate Insert and Send actions; never attach or send the WAV.
- [x] Pass standalone SAPI and real-window synthetic-WAV gates without Engine.
- [x] Add offline TTS for the latest answer and composer with actual voice identity.
- [x] Synthesize to one transparent WAV with cancellation, Stop, Replay, and delete.
- [x] Bound source/time and omit hidden reasoning unless explicitly revealed.
- [x] Pass the silent generation, runtime, cancellation, WAV, and reasoning gate.

## Start-of-session checklist

1. Read this file, then `ROADMAP.md`.
2. Native vision and Explorer image drop GUI tests passed. Complete the R6
   microphone capture/STT feel-test with a working input device when convenient.
3. Use `docs/handoff_brief.md` for implementation history, not product scope.
4. Preserve the Lens/Studio/Pad product boundary.
5. Do not modify the user's live `aether_lens.cfg` while building or testing.
6. After a milestone, move its verified facts into **Shipped baseline**, update
   **Known gaps**, and advance **Current milestone**.

## Sources of truth

- `showcase/aether_lens/ROADMAP.md` - scope, order, and acceptance criteria.
- `showcase/aether_lens/STATUS.md` - current milestone and verified state.
- `showcase/aether_lens/README.md` - build/use reference and shipped features.
- `docs/handoff_brief.md` - compact cross-project engineering handoff/history.
- `showcase/aether_lens/BUNDLE_README.md` - recipient-facing portable guide.
