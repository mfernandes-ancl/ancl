# Aether Engine — standalone LLM inference engine

**Aether Engine** is a single-file, zero-dependency LLM inference engine — one native `.exe`, no
installer, no runtime, no Python, no CUDA/ROCm downloads. It runs GGUF models on the **CPU** out of
the box and on **any Vulkan GPU** (NVIDIA/AMD/Intel) through the `vulkan-1.dll` already on your
system. It's the same engine that powers **Aether Lens** and **Aether Studio** — shipped standalone
so you can drive it from **your own apps**.

> Ships as a **binary** (the engine's source is not included). The full command-line contract is in
> **`GUIDE.md`** — this file is just the orientation.

## Quick start

```
aether_engine.exe model.gguf "1, 2, 3, 4," 32 gpu     # generate (drop 'gpu' for the CPU path)
aether_engine.exe serve model.gguf 11435 gpu          # run a server
aether_engine.exe models pull gemma3:270m             # download a model
aether_engine.exe models list                         # what's downloaded
aether_engine.exe inspect model.gguf                  # model metadata
```

Point it at any llama / qwen2 / qwen3 / gemma3 / gemma4-family GGUF — **including the blobs Ollama
already downloaded** (pass the blob path directly, no conversion).

## Linux

This bundle also ships a native **Linux (x86-64)** build under **`linux/`** — three *static,
zero-dependency* ELFs (`aether_engine` generate, `aether_engine_serve`, `aether_engine_pull`) that
import nothing at all and produce **token-for-token identical** output to the Windows engine. The
`pull` binary fetches and verifies models over a **pure-ANCL TLS 1.3** stack (no OpenSSL, no libc).
See **`linux/README.md`** for the quick start and an honest rundown of the Linux can-dos and current
limitations (CPU-only in this set; GPU and vision are Windows-only for now).

## Use it as a backend for your own app

That's what it's built for. Two ways:

- **As a server** — `aether_engine.exe serve <model> <port> gpu` exposes Ollama's `/api/generate`
  and `/api/chat` **and** OpenAI's `/v1/*` routes, so any existing client library just works. Point
  your app's "Ollama URL" or "OpenAI base URL" at `http://127.0.0.1:<port>`.
- **As a subprocess** — run it once per prompt and parse the `AETHER_REPLY:` line from stdout
  (stable output contract + documented exit codes — see `GUIDE.md`).

## What's in the full guide (`GUIDE.md`)

Positional args · performance/GPU flags · constrained + sampled decoding · speculative decoding ·
the `serve` mode · the Ollama and OpenAI-compatible routes · **"Integrating the engine into your
own GUI"** · the output contract · exit codes · honest performance numbers.

## ⚠ Experimental — not production-hardened

The Aether Engine is a from-scratch inference engine provided for evaluation. Model outputs can be
wrong — **don't** rely on them for safety-critical or high-stakes decisions without human review.
Its networking and TLS (used for model download) are genuine implementations but have **not** been
independently audited; treat them as experimental.

## License

The Aether Engine binary is distributed under the **MIT License** — the same license as the rest of
ANCL (see the repository `LICENSE`). Its source isn't included in this release (open-core), but MIT
is permissive and doesn't require source: you're free to use and redistribute the binary, including
inside your own products — just keep the copyright/license notice with any copies. © Mário Fernandes.
