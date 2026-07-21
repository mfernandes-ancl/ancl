# How big is ANCL? — an honest size comparison

ANCL's whole thesis is in one line: **it contains software instead of dependencies.** Every tool
here is a single native executable with no runtime, no VM, no interpreter, and (almost always) no
bundled libraries — the compiler emits machine code directly. So the binaries are *small*. Not
"optimized-small" — *structurally* small, because there's nothing underneath them to ship.

This page puts real numbers on that. It is **not** a claim that ANCL beats these tools. It doesn't.
The mainstream tools below are mature, do vastly more, support more platforms, and have decades of
work behind them. The honest pitch is narrower and, we think, more interesting:

> **ANCL tools are 1–3 orders of magnitude smaller, carry zero dependencies, and still do the core
> job.** The size gap is what a zero-dependency, from-scratch stack actually looks like.

---

## Method (so the numbers are fair)

- **ANCL sizes** are the exact bytes of the shipping executable (`stat`/file size), measured on the
  release build. Nothing else needs to be installed to run them.
- **Alternative sizes** are the current official Windows download or on-disk install footprint, each
  with a source link. Where a tool's size varies by version or components, a range is given and the
  basis (installer vs installed-on-disk) is stated. These were verified, not estimated.
- Comparisons are **like-for-role**, not like-for-feature. ANCL's tool usually implements a *subset*
  of the alternative's features (that's the trade). The point is the order of magnitude.

Alternative sizes verified July 2026; sources are linked in **[Sources](#sources)** at the bottom.
"Ratio" is the alternative's size divided by the ANCL binary's, rounded — a rough order-of-magnitude,
not a precise figure. Where the honest comparison basis is on-disk vs installer, the table says which.

---

## The comparison

### Compiler / toolchain

| ANCL | Size | Mainstream equivalent | Its size | Rough ratio |
|------|-----:|-----------------------|---------:|:-----------:|
| `anclc` (Windows) | **0.50 MB** | MSVC C++ build tools (on-disk) | ~2.3–7 GB | **~5,000–12,000×** |
| `anclc` (Linux, static ELF) | **0.38 MB** | GCC toolchain, MSYS2 (on-disk) | ~420 MB | **~1,100×** |
| | | LLVM/Clang (official installer) | ~336 MB | **~670×** |
| | | Rust toolchain, rustup (on-disk) | ~1 GB | **~2,000×** |
| | | Go toolchain (on-disk; 59 MB installer) | ~550 MB | **~1,100×** |

> The ANCL compiler is a **single ~0.5 MB executable** that emits native Windows PE **and** Linux ELF
> binaries with no linker, no assembler, and no C runtime — and it **self-hosts** (it compiles its
> own source into a byte-identical copy of itself). Mainstream toolchains bundle a preprocessor,
> separate compiler/assembler/linker, standard libraries, and platform SDKs — hence the size.

### Local AI (inference engine + desktop app)

| ANCL | Size | Mainstream equivalent | Its size | Rough ratio |
|------|-----:|-----------------------|---------:|:-----------:|
| Aether Engine (Linux, CPU, static) | **1.0 MB** | llama.cpp (prebuilt CPU release zip) | ~17 MB | **~17×** |
| Aether Engine (Windows, vision + GPU) | **6.4 MB** | Ollama (~200 MB installer / ~4 GB on-disk) | ~200 MB–4 GB | **~30–640×** |
| Aether Lens (desktop local-AI app) | **1.1 MB** | LM Studio (installer) | ~150–400 MB | **~140–360×** |

> The engine runs GGUF models on CPU and Vulkan GPU, and on Linux it even **fetches and verifies its
> own models over a pure-ANCL TLS 1.3 stack** — no OpenSSL, no libc, no curl. It supports fewer model
> architectures and quantizations than llama.cpp/Ollama, but the ones it supports run **token-for-token
> identically** in a fraction of the footprint. (Model files are separate and identical for everyone —
> these numbers are the *software*, not the weights.)

### IDE / editor

| ANCL | Size | Mainstream equivalent | Its size | Rough ratio |
|------|-----:|-----------------------|---------:|:-----------:|
| Aether Studio (native IDE) | **27 MB** | Visual Studio Code (~105 MB installer / <500 MB on-disk) | ~105–500 MB | **~4–18×** |
| | | Visual Studio Community (on-disk, common workloads) | ~20–50 GB | **~750–1,900×** |

> Aether Studio is a full native GUI IDE — editor, tabs, compiler integration, an AI chat pane, and
> op-brain autocomplete — with **no Electron, no Node, no Chromium**. It's the largest ANCL binary
> here precisely because it carries its own GUI and AI tooling — and it's still a fraction of an
> Electron editor's on-disk install and a rounding error next to a full Visual Studio. It does less
> than VS Code; it also doesn't pull in a browser engine to edit text.

### Network / industrial (OT) tooling

| ANCL | Size | Mainstream equivalent | Its size | Rough ratio |
|------|-----:|-----------------------|---------:|:-----------:|
| Aether Workbench (protocol analyzer) | **1.4 MB** | Wireshark (Windows installer) | ~92 MB | **~66×** |
| `multi_tester` (11 industrial protocols) | **1.0 MB** | Kepware KEPServerEX (~68 MB installer / ~500 MB on-disk) | ~68–500 MB | **~68–500×** |
| OPC Explorer | **0.31 MB** | | | |
| single protocol client (e.g. GOOSE tap) | **15–300 KB** | | | |
| `httpd` (web server) | **81 KB** | | | |

> These are the tools closest to ANCL's origin (industrial C&I / SCADA). A **1 MB** binary speaks
> Modbus, S7, DNP3, IEC-104, IEC-61850/MMS, EtherNet/IP, OPC UA and more; individual protocol clients
> are tens to hundreds of KB where the commercial equivalents are measured in tens-to-hundreds of MB.
> Zero drivers, zero runtimes to deploy on a plant machine — copy one file.

---

## The honest caveats

- **Fewer features.** Each ANCL tool implements the *core* of its role, not the full surface of the
  mature alternative. That's the deliberate trade for size and zero dependencies.
- **Ecosystem of one.** These tools are young and bespoke. The mainstream tools have huge ecosystems,
  plugins, and community support ANCL simply doesn't have yet.
- **Size isn't everything.** Small is a means (deploy-anywhere, auditable, no dependency hell), not
  the goal. The goal is a stack you fully own, top to bottom.

What the numbers *do* show: the mountain of dependencies most software ships is, to a surprising
degree, **a choice** — not a requirement. ANCL is one existence proof that you can build the whole
stack — compiler, AI engine, IDE, industrial tooling — and have it fit in a few megabytes.

---

## Sources

Alternative sizes verified July 2026. "Installer" = the download you run; "on-disk" = footprint after
install. Several on-disk figures (MSVC, Rust, VS Community) vary widely with selected components and
are given as ranges, not fixed values. Local-AI app footprints exclude model files.

- **GCC (MSYS2 / MinGW-w64)** — ~49 MB download, ~420 MB on-disk single toolchain — <https://www.msys2.org/> · <https://packages.msys2.org/packages/mingw-w64-ucrt-x86_64-gcc>
- **LLVM/Clang 19.1.0** — 335.6 MB installer (GitHub release asset) — <https://github.com/llvm/llvm-project/releases/tag/llvmorg-19.1.0>
- **MSVC / VS Build Tools (C++ workload)** — ~2.3 GB minimum, ~6–7 GB typical on-disk — <https://learn.microsoft.com/en-us/visualstudio/releases/2022/system-requirements>
- **Rust (rustup + stable)** — ~1 GB+ on-disk, component-dependent — <https://users.rust-lang.org/t/how-to-reduce-the-size-of-rustup-dependencies/128196>
- **Go (go1.26.x, windows-amd64)** — 59 MB msi / 71 MB zip download, ~550 MB+ on-disk — <https://go.dev/dl/>
- **llama.cpp (prebuilt CPU release)** — ~17 MB zip (`llama-*-bin-win-cpu-x64.zip`, GitHub release asset) — <https://github.com/ggml-org/llama.cpp/releases>
- **Ollama** — ~200 MB Windows installer, ~4 GB on-disk (binaries, excludes models) — <https://docs.ollama.com/windows> · <https://github.com/ollama/ollama/issues/8005>
- **LM Studio** — ~150–400 MB installer, version-dependent (excludes models) — <https://lmstudio.ai/download>
- **Visual Studio Code** — ~105 MB Windows user installer, <500 MB on-disk — <https://code.visualstudio.com/docs/setup/windows>
- **Visual Studio Community 2022** — ~20–50 GB typical on-disk with common workloads — <https://learn.microsoft.com/en-us/visualstudio/releases/2022/system-requirements>
- **Wireshark 4.6.x** — ~92 MB Windows 64-bit installer — <https://www.wireshark.org/download.html>
- **Kepware KEPServerEX** — ~68 MB installer (mirrored release), ~500 MB on-disk; current versions are behind a PTC trial sign-up — <https://www.ptc.com/en/products/kepware/kepserverex>

> Notes: LLVM and llama.cpp sizes are exact GitHub release-asset byte counts pinned to a specific tag.
> MSVC, Rust, and VS Community on-disk footprints are community/typical estimates, not single official
> values. Kepware's *current* installer size is not publicly citable without a PTC login — the figure
> shown is an older mirrored release for order-of-magnitude reference only.
