# Aether Lens Portable

Run `aether_lens.exe`. The bundled `aether_engine.exe` is discovered beside it
and started automatically when the configured local endpoint is not already
running.

This friend-test build contains no API token, live configuration, chat, indexed
document, recording, preference history, or model. Windows may show an
unrecognized-app warning because this test build is not code-signed.

On first launch Lens creates `aether_lens.cfg`. It remembers the last backend,
model, Engine hardware/generation choices, specialist, chat name, vision helper,
Pulse visibility, Arena pair/blind mode, and whether reasoning sections are shown. The shipped
`aether_lens.defaults.cfg` is documentation
only, so extracting a future update does not replace the user-owned settings.

The Add menu also owns a persistent, fully local knowledge index. Choose one
readable text file or a folder; Lens copies a bounded snapshot into `knowledge\`,
then deterministically selects at most three relevant passages for later prompts.
The transcript lists the exact `[K1]`-`[K3]` paths and line ranges sent and its
**Open cited passage** links reopen portable archived excerpts. A checked
**Use indexed sources** item can pause retrieval without deleting data. **Show
index**, **Open storage folder**, and **Clear index** make storage and removal
explicit. No embedding model, vector database, network, or third-party runtime
is involved, and original source files are never changed.

Assistant replies use Rich Answers presentation for headings, emphasis, inline
and fenced code, lists, tables, quotations, and links while chats remain plain,
portable text on disk. Right-click a reply to copy the last answer, copy/save
its last fenced code block, or reveal/hide backend reasoning. Links ask before
opening, and code is never compiled or run by Lens.

For a standalone Markdown, HTML, SVG, or CSV document, choose its type under
**Add > Document Canvas**, then write the request normally. Lens opens the entire
visible answer in a separate editable Canvas; it does not depend on the model
producing an outer fence. Markdown has an in-window Preview. HTML and SVG use
Safe Preview, which applies the same fail-closed active/external-content policy
and permissionless browser sandbox as chat artifacts. CSV validates quoted
fields and consistent column counts. Lens tolerates one complete typed outer
code fence from a small model. Copy, Save, and Save As
remain local, and no file is written until you explicitly choose Save.
You can also right-click an existing reply and choose **Open last answer in
Document Canvas**.

For exact arithmetic, choose **Add > Local Tools > Calculator**. It evaluates
decimal expressions locally with parentheses and normal operator precedence.
Copy the result or insert it at the composer cursor. Its integer converter
accepts decimal, `0x` hexadecimal, or `0b` binary and synchronizes all three
representations. Insertion never sends.

For an explicit web page, choose **Add > Local Tools > Web Reader**. Lens names
the exact host and URL before connecting, caps the response at 128 KiB, uses
bounded timeouts, blocks redirects, and displays inert extracted text only.
Copy or insert retains the source URL; nothing is sent automatically.

For a general lookup, choose **Add > Local Tools > Search Google**. Lens builds
the exact Google URL locally, asks for approval, and displays the real active
page in an embedded WebView2 pane. Its cookies, cache, and site storage live in
an isolated `webview2-profile` folder that Proof can clear. If WebView2 is
unavailable, the approved URL opens in the default browser. Lens does not scrape
Google or send the query to a model. ANCL locates the Windows-installed Evergreen
runtime directly, so no WebView2 loader DLL or browser runtime is bundled.

Aether Engine currently caps one reply at 512 generated tokens. The scrollable
chat pane and Canvas do not impose that generation limit; use the ordinary
conversation Continue action when a reply genuinely ends with `reason length`.

The same transcript menu can stage a reversible edit/resend of the last user
turn, regenerate with the model currently selected, continue, or confirm-delete
the latest assistant answer. It also copies the last user or full exchange,
saves the answer as Markdown, and copies local Pulse metadata. Attachment turns
must be explicitly reattached before resend; Lens never pretends their one-shot
payload remains queued.

**Cancel staged edit** abandons the replacement without deleting composer text;
the edited text remains available as a normal new-message draft.

To branch a conversation without changing its original saved file, Save first,
type a new Chat name, then choose **Load > Branch current to Chat name**. Lens
refuses the same/existing destination and preserves portable attachment links.

Help or F1 opens the complete offline `guide.html`. While an Engine model is
being pulled, the Lens status line shows live completion percentage and
downloaded/total size through the same SHA-256-verified transfer.

Native image understanding is available without Ollama: select or install
`gemma4:e4b`, attach/paste one PNG, and send normally. With `gemma4:e4b`
selected, Lens sends the PNG directly to Aether Engine. With another Engine
chat model, Auto/First vision-helper mode can run `gemma4:e4b` first and then
restore the chosen model, but only when Lens owns the local server. The helper
answers the exact user question; Lens shows a bounded evidence excerpt and
marks it as authoritative pixel-grounded context for the final model. The current
Engine path is PNG-only and its CPU vision prefill may take about one minute;
Pulse visibly reports **reading image locally** during that time. Lens checks
the serialized request against the Engine's current 256 KiB HTTP envelope and
keeps an oversized image/context combination preview-only.

You can also drag exactly one PNG, JPG/JPEG, GIF, or WebP image from Windows
Explorer onto Lens. The drop only queues the file through the normal attachment
thumbnail and preview path; it never sends automatically. Unsupported files,
multi-file drops, and drops while a request is busy are refused visibly.

The bottom-bar **Proof** menu generates a native Privacy Proof without starting
a model or contacting any endpoint. It labels the active endpoint local or
network/cloud, hashes the bundled Engine executable locally, shows available
model identity and current context disclosure, and lists every portable storage
path. The same menu opens those folders and offers confirmed narrow clearing for
the current conversation, copied knowledge, and generated artifact previews.
Saved chats and attachment assets are never bulk-deleted silently.

The cyan **ARENA** button opens the full comparison workspace without changing
the current chat. Choose Model A and Model B from the installed-model dropdowns,
write the dedicated Arena prompt, then press **Run Showdown**. The window runs
both contenders sequentially and shuffles blind left/right identities,
places answers and Pulse measurements side by side, and records one Left,
Right, or Tie preference. Its readable `arena\preferences.tsv` retains only
models, vote, prompt SHA-256, and measurements—not the prompt or full answers.
Arena Options and Proof both expose show/open/confirmed-clear controls.

Voice is **still in development** and is intentionally hidden from this build.
The fully local legacy Windows SAPI prototype remains in the included source,
but real-speech testing was not reliable enough to expose it as a finished
feature. Lens does not replace it with a cloud speech service.

Queued images can be enlarged and queued plain-text documents can be read in
a native read-only preview. After send, compact transcript Preview cards reopen
the archived attachment from `chats\assets\`. Those links are relative and
validated, so they survive portable saved-chat moves without accepting arbitrary
paths.

The transcript context menu can preview the latest complete assistant `html`,
`htm`, or `svg` fenced block as a read-only artifact. Lens rejects active or
external content before creating files, adds a restrictive Content Security
Policy, and opens the result inside a permissionless sandboxed iframe. This uses
the Windows default browser and does not bundle or require a WebView, Node.js,
Python, Ollama, or another runtime. The exact policy is documented in
`ARTIFACT_PREVIEW_SECURITY.md`.

Lens is the general-purpose local-AI desktop in the Aether family. Coding IDE,
compiler, build/run/debug, and autonomous source-editing workflows belong to
Aether Studio and ANCL Pad. See `ROADMAP.md` and `STATUS.md` for the canonical
direction and current milestone.

## First model

Models are intentionally not embedded in the small bundle. In Lens, keep the
Aether Engine backend selected, open **Library**, choose a model, and press
**Pull**. Downloads are SHA-256 verified and stored under this folder's
`models\` directory, so the complete installation remains portable.

An installed model is not automatically runnable: shared stores may include
GGUF architectures intended for Ollama or a future Engine release. Lens checks
the native `Forward status` before **Use** or local Engine **Send**. Anything
other than `supported` is blocked with a clear warning while the last working
model remains selected.

If the recipient already has a compatible model in `%USERPROFILE%\.aether\models`
or Ollama's `%USERPROFILE%\.ollama\models`, Aether Engine can discover and serve
it without another download.

## Optional Hugging Face cloud models

Choose **Backend > Hugging Face (cloud)** to use hosted open text-chat models.
Lens fixes the endpoint to `https://router.huggingface.co/v1`, reads `HF_TOKEN`
only from the Windows environment, and never stores it in this folder. Library
loads the live model catalogue; select a row and press Use. Every Send asks for
approval with the exact host/model and outbound context. Bounded `.md`, `.txt`,
and `.ancl` attachments can travel inline as text; images remain blocked.
Hugging Face credits are limited and pricing/free allowances can change.

Create a fine-grained Hugging Face token with permission to call Inference
Providers, save it for future launches, then restart Lens:

```powershell
setx HF_TOKEN "hf_your_token_here"
```

## Hardware

Full GPU is the default and automatically selects a discrete Vulkan adapter.
The Engine menu also provides Conservative GPU and CPU reference fallbacks.

## Source and privacy boundary

The `source\` directory contains the complete Aether Lens ANCL source and the
small `core_lib` dependency closure needed by it. Aether Engine is distributed
only as `aether_engine.exe`; its source, assembly listing, tests, and internal
documentation are deliberately excluded.

To rebuild Lens, place the `source` tree in an ANCL Compiler checkout (or point
`anclc.exe` at it while preserving the directory layout) and compile:

```powershell
anclc.exe source\showcase\aether_lens\src\aether_lens.ancl aether_lens.exe source\showcase\aether_lens\aether_lens.ico
```

No third-party inference runtime is required. Windows system DLLs and a Vulkan
GPU driver are the only runtime dependencies used by Aether Engine.

Release maintainers can pass `-EngineBinary <validated.exe>` to `package.ps1`
while Engine development is happening elsewhere. This packages the approved
binary without compiling or reading the changing Engine source as a build input.
