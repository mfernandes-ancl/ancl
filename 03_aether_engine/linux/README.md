# Aether Engine on Linux

This folder holds the Aether Engine built for **Linux (x86-64)** — three **static, zero-dependency**
executables. They import *nothing*: `file` reports *statically linked*, `ldd` reports *not a dynamic
executable*. No libc, no interpreter, no shared objects, nothing bundled. Same engine, same model
files, **token-for-token identical output** to the Windows build (it's the same frozen compute core,
cross-compiled by ANCL's own compiler).

```
linux/
  aether_engine        # generate — run a model from the command line
  aether_engine_serve  # serve    — an HTTP endpoint (Ollama-compatible /api/generate)
  aether_engine_pull   # pull     — fetch a model over pure-ANCL authenticated TLS, verify, store
  README.md            # this file
```

Make them executable once: `chmod +x aether_engine aether_engine_serve aether_engine_pull`.

---

## Quick start

**Generate** (point it at any GGUF file):

```bash
./aether_engine /path/to/model.gguf "The capital of France is" 32
```

**Serve** an HTTP endpoint, then call it like Ollama:

```bash
./aether_engine_serve /path/to/model.gguf 11434 &
curl -s http://127.0.0.1:11434/api/generate \
  -d '{"prompt":"The capital of France is","num_predict":32}'
```

**Pull** a model — no `curl`, no `wget`, no OpenSSL, nothing external. The download runs over a
**pure-ANCL TLS 1.3 client** with **pinned root CAs**, and the blob is **SHA-256 verified against
the registry manifest** before it's kept:

```bash
./aether_engine_pull models pull gemma3:270m
# -> [pull] OK: 291545472 bytes, digest verified
# -> [pull] run it:   aether_engine <blob> "your prompt"
```

Pulled models land under `<this-folder>/models/blobs/…` (or `$HOME/.aether/models/…`); the pull
command prints the exact blob path to hand to `aether_engine` / `aether_engine_serve`. It also reads
an existing `~/.ollama` store (read-only), and `aether_engine_pull models hash-local <file>` prints a
file's SHA-256.

---

## What works on Linux (can-dos)

- **Full CPU inference**, **token-for-token identical** to the Windows engine on the same model +
  prompt — the numeric core is the same code, not a re-implementation.
- **Every model family the engine supports** for raw generation: Llama, Llama-3, Mistral, Qwen2,
  Qwen3, Gemma-3, Gemma-4, and Gemma-3n.
- **Self-fetching models, fully zero-dependency**: DNS, TLS 1.3, X.509 chain verification against
  pinned roots, and SHA-256 digest verification are all **pure ANCL** — no system crypto, no libc.
  This is the headline: the engine authenticates a real server and downloads its own weights with
  nothing but the single static binary.
- **Ollama-compatible `POST /api/generate`** from the serve binary.
- **Truly standalone**: copy the one file to any x86-64 Linux box and run it. No install, no runtime,
  no package manager.

## Limitations (honest notes)

- **Three separate binaries**, not the single unified `aether_engine.exe` CLI of the Windows build.
  `generate` and `serve` take a **GGUF file path** (not a pulled model *name*); after a pull, use the
  blob path the pull command prints. The Windows convenience verbs (`inspect`, `run`, `list`,
  `vision-chat`, serve-by-name) are Windows-only in this release.
- **CPU only in this bundle — no GPU.** The GPU path *does* work on Linux and is proven
  token-for-token against CPU on a real NVIDIA RTX — but that build is a **dynamic** ELF that
  runtime-loads the system Vulkan loader (`libvulkan.so.1`) and its driver ICD, exactly the way the
  Windows build loads `vulkan-1.dll`. That's a system dependency, so it is **not** shipped in this
  strictly-zero-dependency set. Two further practical notes: a real GPU needs a **native Linux boot**
  (WSL does not expose an NVIDIA GPU to Vulkan), and GPU only changes *speed* — the output is
  identical to these CPU binaries.
- **No vision on Linux yet.** The image → vision-tower path is Windows-only in this release; the
  Linux binaries are text-only.
- **`serve` answers `/api/generate` only** (raw completion), single-threaded. Chat-template rendering
  (`/api/chat`) is Windows-only for now.
- **x86-64 only.** No ARM/AArch64 build here (that's a separate future port).

---

## How these were built (reproducible)

These Linux ELFs are cross-emitted by **ANCL's own compiler** with `anclc … --target=linux` — the
same compiler shipped in the *ANCL Compiler* bundle, which itself self-hosts on Linux. No GCC, no
Clang, no linker: the compiler writes the ELF directly. That's the whole thesis — the toolchain, the
engine, and even the TLS stack that fetches the models are all ANCL, all the way down.
