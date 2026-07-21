# Aether Engine

A single-file, zero-dependency LLM inference engine. One Windows x64 executable
(~0.6 MB), no installer, no runtime, no Python, no CUDA/ROCm downloads — it runs
GGUF models on the CPU out of the box and on **any** Vulkan-capable GPU (NVIDIA,
AMD, Intel) through the `vulkan-1.dll` already on your system. Ship the `.exe`,
point it at a model, done.

Correctness is the house rule: the CPU path is a float64 reference
implementation verified **token-for-token against llama.cpp/Ollama greedy
output** on eight model families (llama, mistral, llama3, qwen2, qwen3,
gemma3, gemma4, and the gemma4 e-variants a.k.a. Gemma-3n — per-layer
embeddings + shared-KV + BF16), and
every GPU fast path is gated against that reference (bit-exact where the
math order is preserved, tolerance + top-1-token gates where it is not).

```
aether_engine.exe <model.gguf> "<prompt>" [max_new] [flags...]
```

```
aether_engine.exe qwen2.5-7b.gguf "1, 2, 3, 4," 32 gpu
[gpu] Vulkan ready: NVIDIA GeForce RTX 5060 Ti (discrete) | f16 weight pool 2048 MB x 3 slabs VRAM | GEMV self-check OK
...
AETHER_REPLY: tokenizer decoded 32 tokens:  5, 6, 7, 8, 9, 10, 11, ...
```

Models: any llama/qwen2/qwen3/gemma3-family GGUF file works, including the
blobs Ollama already downloaded — pass the blob path directly, no conversion:
`C:\Users\<you>\.ollama\models\blobs\sha256-<digest>`.

---

## Command line

### Positional arguments

| position | meaning | notes |
|---|---|---|
| 1 | model path | `.gguf` file or an Ollama blob path |
| 2 | prompt | quoted text |
| 3 | `max_new` | tokens to generate, 1..512 (default 32). Generation ends **early** when the model emits its GGUF-declared EOS token (`done` semantics match Ollama's raw mode) — the cap is the ceiling, not the length. |

Long prompts: `promptfile=<path>` reads the prompt from a file (up to 128 KB
text / 8192 tokens — argv can't carry that), and replies exactly as the same
text passed inline would (suite gate). The serve prompt window is also
**8192 tokens** (256 KB request bodies accepted); live-proven with a
4221-token prompt on gemma3 — `usage.prompt_tokens` reports it and the model
answered a fact embedded in the context.

Flags may appear anywhere after the model path (they are position-transparent).

### Performance flags

| flag | effect |
|---|---|
| `gpu` | **The one you want.** All linear layers run on the GPU (parallel-row kernels, quantized weights resident in VRAM, batched command buffers, on-device argmax), the decode hidden state stays resident on the device between passes (norms, residuals, activations — the resident-x layer), and attention runs fused on the GPU for both prompt prefill (QK^T→softmax→AV in one submit, scores never leave the device) and decode (append-only K/V mirrors — attention cost stops growing with context). Every stage falls back per-layer on any miss; no Vulkan / no GPU → the engine silently continues on the CPU; a failed boot self-check also falls back. Output is verified identical either way. |
| `gpufinal` | Conservative mode: GPU only for the final vocab projection, serial kernels, CPU attention. |

### Constrained output (restricted-vocabulary decoding)

| flag | effect |
|---|---|
| `restrict=ascii` | Generation may only pick tokens whose text is printable ASCII (plus tab/newline). |
| `restrict=digits` | Generation may only pick digits and numeric glue (`0-9 space , . - newline`). |
| `stopid=N` | Adds token id N as an extra **stop token** (generation ends before emitting it; up to 4 ids stack). The model's GGUF `eos_token_id` is always armed automatically. Useful for chat end-of-turn ids until template support lands. |
| `stopstr=<text>` | Adds a **text-level stop string**: generation aborts as soon as the decoded text contains it, and the reply is truncated BEFORE the match (`done_reason: "stop"`). Serve requests set these per request via `options.stop` (array or single string, `\n`-style escapes supported, up to 4 × 63 bytes); `stopstr=` is the CLI/serve-wide default. Streaming holds back any tail that could still become a match — a stop string never leaks into the stream. |

### Sampling (temperature decoding)

| flag | effect |
|---|---|
| `temp=0.8` | Arms the **llama.cpp-order sampling chain** (penalties → top_k → top_p → min_p → temperature → draw). `temp=0` or absent = greedy — the default, and byte-identical to every greedy gate. |
| `topk=40` `topp=0.9` `minp=0.05` `repeat=1.1` | Chain knobs; unset values take the Ollama defaults (top_k 40, top_p 0.9, min_p 0, repeat_penalty 1.1 over the last 64 tokens). |
| `seed=42` | Reproducible sampling — the same seed replays the same tokens (suite-gated). Absent = auto-seeded per run. |

While sampling is armed the engine bypasses prompt-lookup speculation and the
GPU argmax (both greedy-by-construction); the logits GEMV still runs on the
GPU — only the pick is CPU-side. Exact RNG parity with llama.cpp is impossible
by construction (mt19937 vs our xorshift64), so sampled outputs are
distribution-faithful, not token-identical to Ollama. **Intentional deviation:
a request with no `temperature` stays greedy (deterministic by default);
Ollama defaults to temperature 0.8 when unset.**

This is **weight-level** restriction: the disallowed rows of the logits
projection are never computed at all (the output tensor is re-packed at load
to just the allowed rows). On a 7B model `restrict=digits` cuts the logits
stage from ~79 ms to under 1 ms per token. A banner reports what happened:

```
[restrict] mode 2: 795/152064 tokens allowed -> logits rows 832
```

Semantics: greedy decoding constrained to the allowed set — by design this
*changes* what the model can say (that is the point). Special tokens always
stay allowed. Models with a suppress-list (gemma4 class) and models whose
tokenizer cannot be loaded decline gracefully:
`[restrict] unavailable for this model -> full vocab`.

### Speculative decoding (default with `gpu`)

Prompt-lookup speculation: when the last three tokens occurred earlier in the
context, the tokens that followed become a draft, verified in one chunk pass —
the output is **identical to plain decode by construction** (greedy
acceptance). On repetitive or structured output (logs, JSON, quoting) it
reaches ~1.3× on a 7B; when no draft is found nothing changes, and a failure
cooldown plus the three-token match bar keep adversarial streams near
break-even. `nospec` opts out; `spec` stays accepted from when it was opt-in.

### Diagnostics

| flag | effect |
|---|---|
| `gputime` | Phase profiler: prefill and decode timing lines with per-stage buckets and dispatch counters. |
| `toplogits` | Prints the top-3 logits before generation (sanity probe). |

### Escape hatches (rarely needed)

| flag | effect |
|---|---|
| `gpunoglue` | Classic per-stage decode instead of the resident-x glue layer (the layer also self-declines per-layer on any miss, so this is for A/B only). `gpuglue` stays accepted from when the layer was opt-in. |
| `gpunoattn` | CPU attention (prefill and decode) instead of the fused GPU kernels. `gpuattn` stays accepted from when attention was opt-in. |
| `gpunochain` | Staged chunk FFN (separate GEMM submits + host activation hops) instead of the single-submit device-chained FFN used by prefill and verify chunks. |
| `gpunosg` | Serial (one-lane-per-row) GEMV kernels instead of parallel-row. |
| `gpunoam` | CPU argmax with full logits readback instead of on-device argmax. |
| `gpunobatch` | One GPU submit per matrix multiply (no command-buffer batching). |
| `gpuhoist` | Experimental per-block load-hoisted Q8 kernel. |
| `gpuwide` `gpumid` `gpusquare` `gpudown` `gpusqwide` `gpudnwide` `gpusqdown` `gpuall` `gpuf32` `gpuf32all` `gf32` | Developer shape/precision matrix for isolating a misbehaving tensor class. |

### Subcommands

| command | effect |
|---|---|
| `aether_engine.exe serve <model> [port] [flags]` | **Ollama-compatible HTTP server** (default port 11435). `<model>` is a `.gguf` path **or a pulled `name[:tag]`** (resolved offline via the store's manifest cache; the name is then what `/api/tags` and every `"model"` field report). Load once — weights stay GPU-resident across requests — then answer `POST /api/generate`, `GET /api/tags`, `GET /api/version`. All engine flags stack (`gpu`, `restrict=`, `nospec`, …). See below. |
| `aether_engine.exe inspect <name[:tag] | path.gguf>` | Print GGUF metadata and whether the engine can run the model. Pulled names resolve through the engine's local manifest store. |
| `aether_engine.exe models pull <name[:tag]>` | **Download a model from the Ollama registry** — manifest fetch, streaming blob download (CDN redirects handled), SHA-256 verified in-engine, stored in the local blob layout with its manifest cached for offline name-resolve. Prints the serve one-liner when done. |
| `aether_engine.exe models list` | List models in the engine's local store. |
| `aether_engine.exe models inspect-local <name> <path>` | Inspect a store entry. |
| `aether_engine.exe models stage-local <name> <path>` | Copy a GGUF into the local store (Ollama-style blob layout) and inspect it. |
| `aether_engine.exe models hash-local <path>` | SHA-256 of a model file. |
| `aether_engine.exe models blob-local <path>` | Place a file into the blob layout by digest. |

The complete zero-to-serving flow, no other software involved:

```
aether_engine.exe models pull gemma3:270m
aether_engine.exe serve gemma3:270m 11435 gpu
curl http://127.0.0.1:11435/api/generate -d "{\"prompt\":\"hello\",\"stream\":false}"
```

A pulled name also works wherever the CLI takes a `.gguf` path:
`aether_engine.exe gemma3:270m "1, 2, 3, 4," 16 gpu`.

**Model store — three roots, resolved in order** (a name works if any root
has it, so every Aether app and Ollama itself share one model pool, no
re-downloads):

1. **Exe-relative** `<exedir>\models\...` — the portable bundle. When a
   bundle ships its own `models\` folder, pulls also *write* here (one
   copy-anywhere folder: engine + models).
2. **Shared user store** `%USERPROFILE%\.aether\models\...` — the default
   write location otherwise, so every Aether app on the machine (Studio,
   Lens, the CLI) sees the same pulled models. Override the location with
   the `AETHER_MODELS` environment variable (it *is* the models dir).
3. **Ollama's own store** `%USERPROFILE%\.ollama\models\...` — **read-only
   reuse**: any model you already `ollama pull`ed serves by name with no
   duplicate download. `models list` tags each entry `[shared]` / `[ollama]`
   and `models pull` short-circuits when Ollama already has the blob.

### `serve` — point any Ollama client at the engine

```
aether_engine.exe serve <model.gguf | pulled-name[:tag]> 11435 gpu
```

- `POST /api/chat` with `{"messages": [{"role": "...", "content": "..."}, …], "stream": …}`
  returns `{"model", "message": {"role": "assistant", "content": "..."}, "done",
  "done_reason"}` (streaming: one line per token, same as generate). The GGUF's
  `tokenizer.chat_template` (Jinja — matched, never executed) is fingerprinted
  to one of the hand-written family templates, llama.cpp-style:
  **ChatML** (qwen2/qwen3), **gemma** (`<start_of_turn>`), **zephyr**
  (TinyLlama), **mistral** (`[INST]`), and **llama3** (`<|start_header_id|>`).
  Control tokens are injected as vocab ids, the family's
  end-of-turn id is armed as a stop token, and system messages fold per the
  family's rules (qwen and zephyr get their canonical default system prompt
  when none is sent; zephyr and mistral fold the system into the last user
  turn; llama3 always emits its dated system header).
  Models with no/unknown template answer `400` — `/api/generate` stays the
  raw-completion endpoint either way. **Gate: decisive prompts answer
  token-for-token identical to Ollama's `/api/chat` at temperature 0 on all
  five families** (open-ended prompts can fork at near-ties — our f64 vs
  their f32/f16 GPU numerics — exactly like the raw-mode gates).

- **Qwen3 reasoning mode:** chat requests may include `"options":{"think":0}`
  to use Qwen3's hard non-thinking template (the engine pre-fills a closed,
  empty `<think>` block), or `"think":1` for native reasoning. Aether Lens
  defaults to direct answers so a short reply ceiling cannot be spent entirely
  inside a reasoning block.

- **Tools (function calling), ChatML family:** send Ollama's `tools` array
  (`[{"type":"function","function":{"name","description","parameters"}}]`)
  with the chat request and the engine renders it into the qwen tools
  preamble exactly like Ollama's template (each function object passed
  through faithfully — including property descriptions, which Ollama 0.32's
  re-marshal drops). When the model answers with `<tool_call>` markup, the
  non-stream reply carries Ollama's shape: `"message":{"role":"assistant",
  "content":"","tool_calls":[{"function":{"index":N,"name":"…","arguments":
  {…}}}]}` (arguments = a JSON object; the random `id` Ollama adds is
  omitted). Echo the assistant tool_calls message + a `{"role":"tool",
  "content":"…"}` result and the next turn renders `<tool_call>` /
  `<tool_response>` blocks per the template. Chat text is encoded with
  llama.cpp `parse_special` semantics (vocab CONTROL/USER_DEFINED tokens
  inside rendered text become single ids — `<tools>`, `<tool_call>`, …).
  **Gate: tool-call name + arguments and the tool-result round's answer are
  token-for-token identical to Ollama at temperature 0 (qwen2.5:7b).**
  Families without tool templates ignore `tools` (intentional deviation:
  Ollama answers 400); streaming requests keep tool markup as text.

- `POST /api/generate` with `{"prompt": "...", "stream": false, "options": {"num_predict": N}}`
  returns `{"model", "response", "done": true, "done_reason": "length"}`.
- Native Ollama-shaped final records for `/api/chat` and `/api/generate` also
  report `prompt_eval_count`, `eval_count`, `total_duration`,
  `prompt_eval_duration`, and `eval_duration` (durations are nanoseconds).
  Streaming carries these fields on the final `done:true` line.
- `stream: true` streams **one NDJSON line per emitted token** —
  `{"model", "response": "<piece>", "done": false}` as each token is generated
  (a speculative-decode burst arrives as one line carrying the whole accepted
  chunk), closed by a final `{"response": "", "done": true, "done_reason":
  "length"}` line. The pieces concatenate to exactly the non-stream response
  (suite-gated); multi-byte UTF-8 split across tokens is held back until
  complete, so every line is valid JSON. Framing is `Connection: close` +
  read-to-close (no Content-Length), which every Ollama client handles.
- `GET /api/tags` lists the loaded model; `GET /api/version` answers health probes.
- One model per server, loaded once — the first request pays the VRAM upload,
  every request after runs weights-resident (a 7B answers a fresh 32-token
  request in ~4 s on the reference RTX box). Requests are handled one at a
  time by design: the GPU is a serial resource.
- `num_predict`: default 128, ceiling 512. Generation stops **early** at the
  model's EOS token (or any `stopid=` id) — `done_reason` is `"stop"` for a
  stop-token end and `"length"` for a cap end, exactly like Ollama. Prompts
  up to **8192 tokens** (256 KB request bodies; long documents and deep
  multi-turn history fit — live-proven at 4221 prompt tokens on gemma3).
- **Sampling per request** via `options`: `temperature`, `top_k`, `top_p`,
  `min_p`, `repeat_penalty`, `repeat_last_n`, `seed` — llama.cpp-order chain,
  seeded runs reproduce exactly (suite gate). No `temperature` (or `0`) =
  greedy, same output the CLI prints for the same prompt (also a suite gate;
  deterministic-by-default is an intentional deviation from Ollama's 0.8).
- **`options.stop`** (array or single string): generation aborts when the
  decoded text contains a stop string; the reply is truncated before the
  match, `done_reason` is `"stop"`, and streaming never emits a byte of a
  potential match (hold-back is suite-gated).

### OpenAI-compatible routes

The same server also speaks the OpenAI dialect, so OpenAI-SDK clients work
by pointing `base_url` at the engine:

- `POST /v1/chat/completions` — rides the chat templates; returns
  `{"id","object":"chat.completion","created","model","choices":[{"message",
  "finish_reason"}],"usage":{prompt/completion/total_tokens}}`. Streaming is
  SSE: `data: {…chat.completion.chunk…}` per token (first delta carries
  `"role":"assistant"`), a finish chunk, then `data: [DONE]`.
- `POST /v1/completions` — the raw-prompt equivalent (`text_completion`).
- `GET /v1/models` — client discovery (lists the served model).
- OpenAI's top-level `temperature` / `top_p` / `seed` / `stop` /
  `max_tokens` map straight onto the sampling + stop machinery; both suite
  gates (JSON + SSE assemble to the exact `/api/generate` reply) and a live
  gemma3 chat/stream/seeded-sampling matrix prove the dialect.
- The full flag set stacks: `restrict=digits` for constrained endpoints,
  `nospec`/`gpunoattn`/… for A/B, plain CPU mode by omitting `gpu`.

---

## Integrating the engine into your own GUI

The engine is designed to be embedded as a **subprocess**. No linking, no API
surface to version — spawn it, read stdout, parse one line.

### The output contract

Everything the engine prints is line-oriented UTF-8 on stdout. Diagnostic
lines carry a bracketed prefix (`[Probe]`, `[gpu]`, `[time]`, `[gputime]`,
`[restrict]`, `[Debug]`, `[OK]`). The line your GUI needs:

```
AETHER_REPLY: tokenizer decoded <N> tokens: <text...>
```

- Take everything after the second `: ` as the generated text. The text may
  itself contain newlines — treat `AETHER_REPLY:` as the start marker and
  read to end-of-stream (it is the last content line before the closing
  `[OK]` line).
- If the model's tokenizer could not decode, the same marker is followed by
  space-separated raw token ids instead of text.

### Exit codes

| code | meaning |
|---|---|
| 0 | success — an `AETHER_REPLY:` line was emitted |
| 1 | file/parse failure (bad path, not a GGUF, unsupported layout) |
| 2 | model loaded but tensor shapes failed validation |
| 3 | generation failed |

### Rules of the road

1. **One GPU-mode engine process at a time.** Each `gpu` process reserves a
   VRAM weight pool; concurrent instances contend for it. Serialize requests
   (a simple queue in your GUI is enough).
2. **Use a generous timeout.** First run of a large model pays a one-time
   load + upload (tens of seconds for a 7B over an eGPU cable) before the
   first token. Small models start in ~1-3 s.
3. **Always pass `gpu`.** It is safe everywhere: machines without Vulkan run
   the identical CPU path automatically. Add `gpuattn` for long prompts.
4. **Cap `max_new` deliberately** (arg 3, 1..512). Generation cost is linear
   in tokens generated, but EOS-stop ends the run early when the model
   finishes its answer — a big cap costs nothing on a model that stops.
5. **Constrained fields**: for numeric/structured GUI fields, run with
   `restrict=digits` (or `restrict=ascii`) — the model cannot emit anything
   outside the set, and the logits stage gets dramatically cheaper.
6. **Model discovery**: point a file picker at `%USERPROFILE%\.ollama\models\blobs`
   (paired with `aether_engine.exe inspect` to label entries) or manage a
   private store via `models stage-local` / `models list`.

### Ballpark performance (honest numbers, RTX 5060 Ti class over OCuLink)

| model class | `gpu` decode speed |
|---|---|
| 0.3B–1B (gemma3:270m, TinyLlama, qwen2.5:0.5b) | ~13–21 tok/s |
| 7B (qwen2.5:7b, fully VRAM-resident) | ~3.5–4.6 tok/s |
| CPU-only fallback | small models usable, 7B-class not recommended |

An integrated APU runs the same binary slower; numbers scale with GPU memory
bandwidth. These figures move with every engine release — trust `gputime` on
your own hardware over this table.

### Aether Lens wiring (Codex)

Everything in the original Lens contract still holds: ship `bin/aether_engine.exe`
only, spawn as a subprocess, parse `AETHER_REPLY:`. Two updates supersede the
old caveats:

- The "small models only" caveat is **obsolete** — pass `gpu` and 7B-class
  models are interactive on GPU boxes, with automatic CPU fallback elsewhere.
- New optional powers worth surfacing in the Lens UI: `restrict=ascii|digits`
  for constrained answers, and `gputime` if you want a perf readout view.

---

## What is inside (for the curious)

Pure ANCL, CRT-free, zero bundled dependencies. The GPU backend emits its own
SPIR-V compute kernels (hand-assembled, walker-audited, generated by scripts
in `tools/`) and drives them through the system Vulkan loader — the same GPU
llama.cpp needs hundreds of MB of vendor blobs to reach. All seven GGUF
quantization formats the supported families use (F16, Q8_0, Q4_0, Q5_0, Q6_K,
Q4_K, Q5_K) are dequantized *inside the shaders* from VRAM-resident raw
blocks. The float64 CPU implementation stays authoritative: every fast path
must match it or decline itself.

Test suite: `run_tests.ps1` (76 checks, SKIP-safe without a GPU).
