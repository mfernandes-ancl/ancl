# Aether Lens

Aether Lens is a native ANCL general-purpose local-AI desktop.

It is not itself a GGUF inference runtime. V1 talks to model runtimes and APIs, with both Ollama and the zero-dependency Aether Engine supported as native local chat servers.

## Product Boundary and Planning

Lens owns general chat, documents, media, voice, model management/comparison,
performance transparency, and polished conversation UX. Aether Studio owns the
full coding-agent/project environment, while ANCL Pad owns the lightweight ANCL
editor/compiler workflow. Lens may display, copy, save, and export code from a
conversation, but it will not embed an editor, compiler, build/run/debug loop,
or autonomous source editing.

- See [ROADMAP.md](ROADMAP.md) for the ordered product plan.
- See [STATUS.md](STATUS.md) for the current milestone and next checklist.
- See [KNOWLEDGE_INDEX.md](KNOWLEDGE_INDEX.md) for the exact local R3 storage,
  retrieval, citation, and clear-data contract.
- See [PRIVACY_PROOF.md](PRIVACY_PROOF.md) for the R7 endpoint, runtime identity,
  disclosure, retention, and model-free verification contract.
- See [ARENA.md](ARENA.md) for the R5 fair-input, sequential execution, blind
  preference, telemetry, and local-history contract.
- See [VOICE.md](VOICE.md) for the R6 local recording, retention, privacy, and
  staged speech roadmap contract.

## V1 Features

- First launch reads total system RAM locally and offers a conservative curated
  Aether Engine starting model. It explains Full GPU and its fallbacks, stages
  an accepted recommendation without downloading, and leaves Pull as the
  explicit network action.
- Named **Hugging Face (cloud)** backend using the official OpenAI-compatible
  router and the provider-specific `HF_TOKEN` environment variable. Every Send
  discloses the exact host/model and outbound conversation context before it can
  modify the transcript or make a request.
- Standalone native Win32 app written in ANCL
- Two-pane layout: Ollama models on the left, chat on the right
- Ollama model refresh via `/api/tags`
- Ollama model detail pane with size, params, quantization, family, format, capabilities, modified time, and digest
- Deeper Ollama `/api/show` inspection on selected local models, including architecture, context length, embedding size, block count, capabilities, and defaults
- Toggleable chat-side model info panel for glanceable selected-model metadata without scrolling the left details pane
- Scrollable chat-side model info panel for longer Ollama defaults and runtime stats
- Per-reply runtime stats for both Ollama and Aether Engine in the info panel: prompt tokens, reply tokens, total/eval duration, and approximate tokens/sec
- Lens Pulse live telemetry for Aether Engine and Ollama: waiting/streaming/stopped/failed state, local time to first token, elapsed time, live token/s estimates, exact final prompt/reply/context counts, prompt/generation/load timing, stop reason, and a five-reply speed history
- The compact status line retains the final Pulse summary even when the expandable Pulse panel is hidden
- Curated Ollama Library picker for common model tags; selecting one fills the Model field before Pull
- Library picker includes smaller vision candidates such as `moondream`, `granite3.2-vision:2b`, and `qwen2.5vl:3b`
- Ollama model pull via `/api/pull`, with streamed status/percent updates when Ollama provides progress totals
- Ollama model delete via `/api/delete`
- Chat backends:
  - Ollama
  - OpenAI-compatible
  - Anthropic
  - Aether Engine native chat backend
- Aether Engine backend connects to `aether_engine.exe serve` through `/api/chat`, sends structured system/user/assistant history, streams NDJSON reply chunks progressively, and discovers the loaded model through `/api/tags`
- Aether Engine is the default backend; Lens automatically starts a local server when needed, waits for readiness, reuses it across chats, and shuts down only the process Lens owns
- Lens restores the last backend and per-backend model on launch, including the last Aether Engine model instead of reverting to the seed model
- Engine controls, specialist, chat name, vision helper, and Pulse visibility persist in the user-owned config; shutdown harvests any final edited model/URL values
- Engine choices show checkmarks for the active hardware, output, style, reasoning, reply length, speculation, and timing settings
- Qwen3 defaults to Direct answer mode; Think before answering remains available as an explicit 512-token option
- The left-side Engine menu exposes stable user controls: full GPU, conservative GPU, CPU reference, unrestricted/ASCII/digits output, precise/balanced/creative generation, 64–512-token reply ceilings, speculation, and GPU timing
- The Aether Library picker lists exact compatible public tags with download sizes; selecting one fills the Model field before Pull
- Lens distinguishes an installed/inspectable GGUF from a runnable one. Before
  **Use** or local Engine **Send**, it checks the Engine's native `forward status`;
  unsupported or incomplete architectures are blocked with a clear warning and
  the current working model is preserved
- Refresh lists the engine's exe-relative model store; Pull reports live completion percentage and transferred/total bytes while the engine downloads and SHA-256 verifies, while Use restarts the owned server on the selected stored model
- Native Aether model information leads with parameter count, GGUF quantization, file bytes, architecture, context geometry, and compatibility before the Engine settings
- Selecting an installed Aether model shows its store size and native GGUF inspection: version, architecture, layers, embedding, heads, context, tokenizer, tensor count, digest, dtype compatibility, and forward-support status
- Cloud backends show environment API-key status in the model info panel without displaying or storing the key
- Streaming replies for Ollama, Aether Engine, OpenAI-compatible, and Anthropic chat backends
- Specialist routing selector:
  - General
  - ANCL coding
  - Industrial protocols
  - Auto, currently mapped to General as groundwork for trained specialist/model routing
- Named chat save/load under `chats/`
- `Save` quick-saves to the current Chat name; `Save As` opens a `.lens` picker and updates the Chat name from the selected filename
- Load opens a dark saved-chat menu for quick reopen/switching, with `Browse...`, `Open chats folder`, duplicate, rename, and delete actions
- Load also provides safe Branch-to-Chat-name: it requires a saved original,
  refuses existing destinations, preserves the original, and keeps relative
  attachment links valid in the unchanged readable V1 chat format
- Markdown export
- Transcript copy
- Rich Answers presentation for assistant Markdown: headings, bold emphasis, inline code, fenced code, lists, tables, quotations, and compact label-only links while saved chats/exports remain portable plain text
- Read-only HTML/SVG artifact preview for the latest assistant fenced block: fail-closed active-content policy, restrictive CSP, a permissionless sandboxed iframe, portable generated files, and no bundled WebView/browser runtime
- Safe transcript context actions: copy the last assistant answer, copy the last fenced code block, or save that code block using a language-aware extension; Lens never compiles or runs it
- **Add > Document Canvas** offers Markdown, HTML, SVG, and CSV document tasks. Lens
  uses the entire visible answer as the draft—no outer fence is required—and
  opens it in a separate native editable window with Copy, Save, and Save As.
  Markdown previews in-window; HTML/SVG use the existing fail-closed validator
  and permissionless browser sandbox. CSV validates quoting and consistent
  column counts. One complete typed outer fence is removed for small-model
  tolerance. Nothing is written until the user chooses
  a destination
- **Open last answer in Document Canvas** opens an existing reply as Markdown.
  The Canvas is intentionally one local draft,
  not a project editor or document library
- **Add > Local Tools > Calculator** opens a deterministic offline arithmetic
  window with decimals, precedence, parentheses, Copy result, and Insert in
  composer. The same window converts non-negative integers between decimal,
  `0x` hexadecimal, and `0b` binary with Copy/Insert Conversions. It never
  contacts a model or sends the composer automatically
- **Add > Local Tools > Web Reader** asks permission for one exact HTTP/HTTPS
  URL, then performs a bounded no-redirect text-only fetch. Scripts/styles and
  markup are discarded; source URL/time/status remain visible, and Copy/Insert
  preserve attribution without automatically sending
- **Add > Local Tools > Search Google** builds the exact Google query locally,
  shows it for approval, and renders real results in an embedded WebView2 pane.
  The active browser uses an isolated Lens profile; Proof can clear its cookies,
  cache, and site storage. If embedding is unavailable, the approved URL opens
  in the default browser. Native ANCL code discovers the Windows-installed
  Evergreen runtime directly; no WebView2 loader DLL is bundled. Lens never
  scrapes Google or sends the query to a model
- Conversation context actions stage a reversible edit/resend, regenerate through
  the currently selected model, send an explicit continuation, confirm-delete
  only the latest answer, and copy the last user or complete exchange
- A staged edit can be cancelled without losing composer changes; the text is
  retained as a normal new-message draft
- The latest assistant answer can be saved as Markdown and the latest local Pulse
  metadata can be copied; attachment-dependent turns require explicit reattachment
  instead of pretending a one-shot payload is still available
- Bottom-bar Privacy Proof menu: generate a native read-only endpoint/runtime/
  disclosure/storage report without invoking a model or network request
- Privacy Proof computes the configured Aether Engine executable SHA-256 locally,
  reports the selected model digest when inspectable, and labels loopback versus
  network/cloud endpoints before the next message is sent
- One Proof menu opens portable app/chat/knowledge/model locations and exposes
  confirmed narrow clears that preserve saved chats and attachment assets
- Distinct cyan **ARENA** control opens a complete two-model workspace directly:
  choose installed Aether Engine or Ollama contenders from Model A/Model B
  dropdowns, write the dedicated Arena prompt, and run sequentially to protect
  normal GPU VRAM
- Dedicated Model Arena window with shuffled blind left/right answers, side-by-side
  Pulse measurements, one-vote Left/Right/Tie preference, and model reveal
- Readable local `arena/preferences.tsv` stores model identities, vote, prompt
  SHA-256, and performance measurements without retaining prompts or full answers;
  show/open/confirmed-clear controls are available from Arena Options and Privacy Proof
- Voice transcription is **still in development** and intentionally hidden from
  the current release UI: the tested legacy Windows SAPI recognizer was not
  reliable enough for real speech and accents. The local prototype remains in
  source while Lens evaluates a more capable optional offline replacement.
- Backend `<think>` reasoning sections are hidden by default and can be revealed from the transcript menu; that choice persists across launches
- Web links require an explicit confirmation before Lens opens the browser
- Complete offline dark HTML guide opened by Help or F1, with a compact native fallback if `guide.html` is missing
- Persistent local knowledge index under `knowledge\`: explicitly index one text document or a folder snapshot, then reuse it across chats and launches
- Dependency-free deterministic lexical retrieval selects at most three bounded passages per question; no embedding model, vector database, service, or network request is required
- Every knowledge-assisted turn records the exact `[K1]`-`[K3]` source paths and line ranges sent to the model, with portable **Open cited passage** links backed by archived excerpts
- Add-menu knowledge controls index a file/folder, enable or disable retrieval with a checkmark, show the readable index and storage/caps, open its folder, or clear copied data after confirmation
- Knowledge caps are explicit: 256 KiB per file, 4 MiB total, 96 files, folder depth 6, and three 1.2-1.8 KiB retrieval passages per prompt
- Image file attach for vision-capable backends/models
- Native Explorer drag-and-drop queues exactly one PNG, JPG/JPEG, GIF, or WebP
  through the same attachment thumbnail/preview path; a drop is local-only and
  never sends until the user presses Send
- Ollama dual-model image path: when the selected local chat model is text-only and an installed Ollama model advertises `vision`, Lens uses the vision model as a helper and passes its notes to the selected chat/coding model; helper selection prefers `moondream` when installed, then falls back to another vision model
- Add menu includes a persisted Vision helper mode: `Auto`, `Moondream`, `First vision model`, or `Off`
- Text/code file attach for plain-text `.txt`, `.md`, `.ancl`, `.csv`, `.json`, `.xml`, `.html`, `.log`, `.ini`, `.cfg`, and `.yaml` files; content is sent inline with the next message
- Folder snapshot attach for local working folders; Lens sends a bounded recursive text/code snapshot inline with the next message
- Clipboard screenshot/image paste for vision-capable backends/models via Ctrl+V in the composer or Attach > Paste screenshot
- Persistent attachment strip showing queued image and/or text-code file state, with an immediate warning for text-only local Ollama models or a helper hint when a vision model is available
- Attachment strip shows queued image MIME/size, text-code filename/size, or folder snapshot name/size, and the attach menu can clear pending attachments before send
- Queued image attachments expand into a compact thumbnail preview strip while waiting to be sent
- Queued text/Markdown/ANCL attachments open in a dark read-only document viewer from the attachment strip
- Sent images and documents add compact transcript Preview cards; their assets are archived once under `chats\assets\` with validated portable relative links so saved chats can reopen them
- Right-click the transcript and choose **Preview last HTML/SVG artifact** for a safe `html`, `htm`, or `svg` fenced block; unsafe blocks remain available through Copy/Save and are never rewritten or executed
- Clicking a queued image thumbnail opens a larger dark preview window so the user can confirm the intended image before sending
- Sent image turns leave a compact `[lens] Sent image: ...` marker in the saved transcript
- Dual-model image turns leave a compact `[lens] Vision helper: ...` marker in the saved transcript
- Sent text/code file turns leave a compact `[lens] Sent file: ...` marker in the saved transcript
- Sent folder snapshot turns leave a compact `[lens] Sent folder snapshot: ...` marker in the saved transcript
- Enter sends the current prompt; Shift+Enter keeps a newline in the composer
- Transcript display normalizes common UTF-8 punctuation to ASCII and sanitizes unsupported symbols to avoid mojibake
- Transcript display styles chat turns with colored/bold user, assistant, and Lens system labels while saved chats remain plain text
- Styled double-lens app icon for the title bar, taskbar, and embedded executable resource
- Warning when an attached image is sent to an Ollama model that does not advertise `vision` and no local vision helper is available
- Dark Aether-style chrome with compact Studio-like labels, owner-drawn buttons/selectors, dark owner-drawn popup menus, dark native scrollbars, rounded major panels, wrapped chat panes, and reduced default Win32 borders

## Build

From the repository root:

```powershell
.\bin\anclc.exe showcase\aether_lens\src\aether_lens.ancl showcase\aether_lens\bin\aether_lens.exe showcase\aether_lens\aether_lens.ico
```

Run:

```powershell
.\showcase\aether_lens\bin\aether_lens.exe
```

## Portable bundle

During concurrent Engine development, package a specifically validated binary
without recompiling its source:

```powershell
powershell -ExecutionPolicy Bypass -File showcase\aether_lens\package.ps1 `
  -EngineBinary ANCL_LLama_cpp\aether_engine\bin\aether_engine.exe
```

Omit `-EngineBinary` only when the Engine source tree is known stable and should
be compiled as part of the release build.

Build the shareable folder and ZIP from the repository root:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\showcase\aether_lens\package.ps1
```

Output lands in `showcase\aether_lens\dist`. The bundle places
`aether_lens.exe` and `aether_engine.exe` side by side, includes the complete
Lens source plus its small `core_lib` dependency closure, and deliberately
excludes every Aether Engine source, assembly, test, and internal document.
Empty `models` directories make model downloads portable with the bundle.
The empty `knowledge\documents` and `knowledge\excerpts` directories receive only
files the user explicitly indexes or passages Lens selects. Generated read-only
artifacts are kept under `chats\artifacts\`. See
`ARTIFACT_PREVIEW_SECURITY.md` for the exact fail-closed contract.

Lens normally starts Aether Engine itself at `http://127.0.0.1:11435`. The equivalent manual command is:

```powershell
.\ANCL_LLama_cpp\aether_engine\bin\aether_engine.exe serve gemma3:270m 11435 gpu
```

The model may be any name installed with `aether_engine.exe models pull`, or a compatible GGUF path. If the URL points to an already-running or remote server, Lens uses it without taking ownership or changing its startup flags.

### Native Aether Engine vision

`gemma4:e4b` accepts one PNG per message through the Engine's native
Ollama-compatible `/api/chat` `images[]` field. Lens sends the attached PNG and
question directly when that model is selected—no Ollama, sidecar, separate
projector, or cloud service is involved.

When a text-only Engine model is selected, **Vision helper: Auto** or **First
vision model** runs an installed `gemma4:e4b` against the user's exact image
question, restores the selected chat model, and provides the result as
authoritative pixel-grounded evidence. A bounded evidence excerpt is shown in
the transcript so helper perception and the final answer can be audited
separately. Lens switches
only a loopback Engine process it owns; an external Engine is never silently
reconfigured. **Moondream** remains an Ollama-only preference, and **Off**
disables helper routing without disabling direct `gemma4:e4b` vision.

The current native contract is PNG-only and the CPU float64 vision tower can
take roughly one minute before the first generated token. Lens Pulse shows
**reading image locally** during that prefill. JPEG/GIF/WebP files remain
previewable but are truthfully marked not sent on the Engine path. Lens also
checks the final serialized request against the Engine's current 256 KiB HTTP
envelope; an oversized image/context combination is kept preview-only.

### Engine settings

The Engine button opens these settings while the Aether backend is selected:

| Setting | Effect |
|---|---|
| Full GPU | Recommended. Automatically selects the discrete Vulkan adapter and sizes its VRAM pool; no manual memory value is needed for a 16 GB GPU. |
| Conservative GPU | Uses the GPU for the final vocabulary projection only. Useful as a compatibility fallback. |
| CPU reference | Uses the authoritative float64 CPU path. Correct but much slower for large models. |
| All languages / Unicode | Normal unrestricted vocabulary. |
| ASCII characters | Restricts output characters to printable ASCII. This is not an English-language selector. |
| Digits only | Restricts output to digits and numeric punctuation and greatly reduces the logits cost. |
| Precise / Balanced / Creative | Maps to greedy, temperature 0.4, or temperature 0.8 request sampling presets. |
| Direct answer / Think before answering | Direct answer is the default and uses Qwen3's supported non-thinking template so the token budget produces a visible answer. Thinking is opt-in and raises the ceiling to 512 tokens with non-greedy sampling. |
| Reply length | Sets the per-request ceiling to 64, 128, 256, or 512 tokens. |
| Speculation | Enables or disables prompt-lookup speculative decoding. |
| GPU timing | Adds engine timing diagnostics for performance investigation. |

### Aether model Library and Pull

With Aether Engine selected, click **Library**, choose a model, and then click **Pull**. The Library writes the exact public registry tag into the Model field; Pull displays a live percentage plus downloaded/total size while Aether Engine streams the model into its own store and verifies every blob with SHA-256. When the pull completes, Lens restarts the server it owns with that model. **Refresh** shows models already present in the Aether store. **Use** first inspects the selected GGUF and switches only when the report says `Forward status: supported`. A shared store can contain models runnable by Ollama but not by the current Aether Engine; those remain inspectable and installed, but Lens blocks their startup instead of replacing the working model with a server that will fail.

On a clean first launch, Lens uses total system RAM only as a conservative
starting point and recommends one of `qwen2.5:0.5b`, `qwen3:0.6b`,
`qwen3:1.7b`, or `qwen3:4b`. It clearly distinguishes system RAM from GPU
memory. Accepting the suggestion selects the exact Library tag and Full GPU;
it does not contact the registry or start a download. If Full GPU cannot start,
the guidance points to Conservative GPU and then CPU reference as fallbacks.

The curated list covers the engine's supported architectures and practical sizes: Gemma 3 (`270m` through `12b`), native-vision `gemma4:e4b`, Qwen 3 (`0.6b` through `8b`), Qwen 2.5 (`0.5b` through `7b`), Llama 3.2 (`1b` and `3b`), Mistral 7B, and TinyLlama. It is intentionally narrower than Ollama's entire catalog because Aether Engine cannot run every architecture. A typed tag still works when a compatible model is not in the menu.

### Hugging Face cloud open models

Choose **Backend > Hugging Face (cloud)**. Lens uses the fixed HTTPS endpoint
`https://router.huggingface.co/v1` and starts with
`openai/gpt-oss-20b:cheapest`. Press **Library** to load the router's live
text-chat catalogue, select a row, then press **Use** to choose it. Lens adds
the `:cheapest` provider-selection suffix to catalogue choices; **Refresh**
reloads the live list. Create a fine-grained Hugging Face token with permission
to call Inference Providers, then save it for future Lens launches:

```powershell
setx HF_TOKEN "hf_your_token_here"
```

Restart Lens after `setx`. Do not enter the token in the Base URL or Model
fields. Lens reads it from the process environment and never writes it to
configuration or chats. Every cloud Send requires approval showing the exact
host and model and disclosing that the current message, prior transcript, and
matched knowledge excerpts may leave the PC. The initial proof sends bounded
`.md`, `.txt`, and `.ancl` attachments inline as text; images remain blocked.
It does not treat remote models as locally Pullable or deletable.

`gemma4:7b` is not a public Ollama registry tag and therefore returns HTTP 404. Use a Library entry such as `gemma3:4b` or another exact published tag instead.

Click an installed model row to inspect it without switching the running model. Double-click it or select it and press **Use** to make it active. Aether inspection reads the real stored GGUF metadata; it does not guess from the catalog name.

## Configuration

Lens stores non-secret settings in `aether_lens.cfg` beside the application. In
the developer tree that is normally:

```text
showcase\aether_lens\aether_lens.cfg
```

The portable release ships `aether_lens.defaults.cfg` only as a readable
example. Lens creates the live config on first launch, so extracting a newer
bundle cannot overwrite the last model or settings. Rich Answers also remembers
whether backend reasoning sections are hidden or shown.

Saved chats live in:

```text
showcase\aether_lens\chats\
```

API keys are read from environment variables and are never written to the config file:

```text
OPENAI_API_KEY
ANTHROPIC_API_KEY
```

## Notes

The Ollama model manager is local/remote URL based. Point the Ollama base URL at a stronger machine when this PC would lag on larger models.

Chat replies stream progressively for Ollama, Aether Engine, OpenAI-compatible, and Anthropic backends. Aether Engine and text-only Ollama chats resume saved/loaded transcripts as structured `user`/`assistant` message history, so the model is less likely to imitate transcript labels after a load. If an image is queued while a local model is text-only, Lens can first ask an installed native Engine or Ollama vision helper for grounded notes, then send those notes to the selected chat model. Network work runs on worker threads so the window stays responsive. Aether Engine currently has no model-delete subcommand, so Lens leaves its model store intact and reports that limitation instead of deleting files directly.

The model info/details values are static metadata from Ollama `/api/tags` and `/api/show`; they update when the selected model changes or is inspected, not while a reply is being generated. Ollama runtime stats update after each completed local reply.
