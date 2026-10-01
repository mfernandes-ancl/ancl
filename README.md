# ANCL

### What if you just didn't bring the runtime?

**A compiler, an AI inference engine, an IDE, and an industrial toolkit — one self-hosting
language, zero dependencies, a few megabytes.**

ANCL's compiler emits native Windows and Linux executables *directly* — no C runtime, no VM,
no garbage collector, no external libraries. The compiler is written in ANCL and reproduces
itself **byte-for-byte**.

Born from real industrial-control work, ANCL has first-class support for the protocols that
run factories and power plants — **Modbus, S7, IEC-104, IEC-61850/MMS, DNP3, OPC-UA,
EtherNet/IP, BACnet, GOOSE** — but it's general-purpose: the same toolchain builds a native
IDE and a complete **LLaMA/GGUF AI inference engine**, entirely in ANCL, with zero ML
dependencies.

Windows and Linux today; a bare-metal, dependency-free OS is the horizon.

---

## Start building in 60 seconds

```
anclc hello.ancl hello.exe     # compile straight to a native executable
hello.exe                      # run it — no runtime, no DLLs to ship
```

## What's in a release

| Download | What it is |
|----------|-----------|
| **Compiler bundle** | the ANCL compiler (`anclc.exe`) + its own source *in ANCL* + `core_lib` + help guide. Rebuild the compiler from source and watch it reproduce itself byte-for-byte. |
| **AI-guide pack** | the compiler + everything needed + the **ANCL AI Guide** — point your AI assistant at it and it writes ANCL fluently. |
| **Aether Studio (IDE)** | a native, self-contained ANCL IDE. Works out of the box. |

Each bundle is standalone — grab only what you need.

## How small is it?

ANCL *contains software instead of dependencies*, so the binaries are tiny — not optimized-small,
*structurally* small, because there's nothing underneath them to ship:

| ANCL tool | Size | Typical equivalent |
|-----------|-----:|--------------------|
| Compiler (`anclc`) | **~0.5 MB** | C++/Rust/Go toolchains: hundreds of MB – multiple GB |
| AI inference engine | **1–6 MB** | Ollama / LM Studio: hundreds of MB – GBs |
| Native IDE (Aether Studio) | **27 MB** | Electron editors ~½ GB; full Visual Studio tens of GB |
| 11 industrial protocols (`multi_tester`) | **1 MB** | Wireshark ~92 MB; commercial OPC stacks hundreds of MB |

This isn't a claim that ANCL beats these mature tools — it does less. The point is that a
zero-dependency, from-scratch stack fits in a few megabytes and still does the core job. Full
numbers, ratios, and sources: **[COMPARISON.md](COMPARISON.md)**.

## Why "AI guide"?

ANCL is unusual, so it ships with a guide written for AI assistants. Prime your Claude / Codex
/ Gemini with `ANCL_AI_GUIDE.md` and it can read, write, and debug ANCL immediately — the
fastest on-ramp to a new language there is.

ANCL was built by one person **with a fleet of AI assistants** (Claude, Codex, Antigravity/Gemini,
Kiro). Since they helped build it, we asked them for an honest, unsugarcoated assessment — strengths
*and* limitations. Their answers are in **[AI_ASSESSMENTS.md](AI_ASSESSMENTS.md)**; more on the story
in **[ABOUT.md](ABOUT.md)**.

## Found a bug? (especially against real hardware)

Several of these tools talk to **real industrial equipment** — PLCs, RTUs, OPC servers, power-quality
meters. Real-world OT gear is messy, so if you point a tester at live hardware and something breaks,
that feedback is gold. **Please [open an issue](https://github.com/mfernandes-ancl/ancl/issues)** and, since every tool keeps a
**session save-log**, **attach that log** — it's the fastest path to a fix. Include the protocol, the
device, and what you expected vs. what happened.

## Status & maturity — read this

For coding and toolchain selection, see the [developer reference](01_compiler/DEVELOPER_REFERENCE.md),
[capability matrix](01_compiler/CAPABILITIES.md) and [core validation report](01_compiler/VALIDATION.md).
An [optional newer bootstrap source](01_compiler/bootstrap/README.md) supports floating-point
storage fixes that are not yet present in the preserved self-hosted release executable.

ANCL is a **self-hosting native systems language** with an unusually broad set of real software
built on top. It is also **young**: shaped largely by one developer (with AI collaborators),
low-level, x86-64-first, and without the optimizer maturity, package ecosystem, platform breadth,
external audits, and years of adversarial testing that established languages have. Treat this
release as an **alpha / technology preview with substantial working software** — the beginning of
public validation, not a production-ready 1.0.

What *is* independently verifiable today: the compiler builds and runs native code, and it
reproduces itself byte-for-byte (self-host fixpoint — you can check it yourself in ~30 seconds,
see the Compiler bundle). Some tools (e.g. the OPC Explorer) are explicitly **work-in-progress**.

> **⚠ Not safety-certified.** The industrial-protocol clients/servers, cryptography, and TLS stack
> are genuine implementations, but they have **not** been independently audited or hardened for
> production or safety-critical use. **Do not** point the writing/command features at live plant
> equipment, or rely on the crypto/TLS to protect anything real, without your own review and
> testing. These are provided for experimentation and evaluation.

## Support the project

ANCL is free and MIT-licensed, and always will be. If it saved you from a dependency headache and
you'd like to chip in for coffee, it's genuinely appreciated — but never expected. There's also a
**❤ Sponsor** button at the top of this repo.

- ☕ **Buy me a coffee / donate:** [paypal.me/mmcfernandes](https://paypal.me/mmcfernandes)

*(Bug reports and questions belong in [Issues](https://github.com/mfernandes-ancl/ancl/issues), not here — that's the fastest path to a fix.)*

## License

MIT © Mário Fernandes. *(The AI inference engine ships as a binary under the same MIT license; its
source is not included in this release.)*
