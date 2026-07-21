# Aether Studio — Help

**Aether Studio** is a native, zero-dependency IDE for ANCL — written in ANCL itself. Editor,
compiler, build/run, AI-assisted autocomplete, and an AI chat assistant, all in one self-contained
folder. No install, no runtime — the editor and offline op-brain autocomplete need no internet
(AI chat needs a language model; see §3).

---

## 1. Launch it

```
bin\aether_studio.exe
```

That's it — a native Win32 application, dark themed, opens ready to code. Everything it needs
(compiler, AI engine, op-brain models, standard library, templates) is in this folder.

## 2. What it does

- **Edit + build + run** — write ANCL with syntax highlighting; one action compiles (via the
  bundled `ancl_compiler.exe`) and runs. Errors are clickable.
- **Smart compiler** — Fix / Auto-Fix / AI-Repair: mechanical `--fix` corrections, plus deeper
  AI-assisted repair for trickier errors.
- **Op-brain autocomplete + ghost-text** — a local, offline coding model (`.dna`) suggests
  completions and inline ghost-text as you type. No cloud, no account.
- **AI chat assistant** — talk to a local model about your code via the bundled **Aether Engine**
  (a chat model is pulled once, or supplied via Ollama — see §3), or point Studio at another
  backend in **LLM Settings**.
- **Industrial protocol starters** — `starters/` gives you ready client templates for Modbus,
  S7, FINS, IEC-104, IEC-61850, DNP3, OPC-UA, EtherNet/IP, BACnet, and MQTT — the fast path for
  control-system work.
- **Templates** — `templates/` has console-app, window, and hello starting points.
- **Command palette** and the **Ctrl+Shift+A** anomaly check + protocol frame-ID tools (powered
  by the bundled specialist brains).
- **Offline guide** — press **F1** (or open `guide.html`) for the full built-in manual.

## 3. AI features — offline autocomplete + your choice of chat backend

- **Op-brain autocomplete + ghost-text + smart-fix** run **fully offline, out of the box** — the
  coding models (`.dna`) are bundled. Nothing leaves your machine.
- **AI chat** — you pick the backend in **LLM Settings**:
  - **Aether Engine** (bundled, the default) — the same pure-ANCL engine that powers Aether Lens.
    It runs any local GGUF language model. The bundle ships the engine but not a multi-GB model,
    so on first use pull one from Studio's model **Library** (a one-time download). After that,
    chat is fully local — no cloud, no account.
  - **Ollama** — point Studio at an existing Ollama install and use the models you already have.
  - **Remote endpoint** — an OpenAI-compatible or remote Aether Engine URL, if you prefer.

Autocomplete works immediately with the bundled models; chat just needs you to choose a backend
and (for the local engine) pull a model once. The engine is a native `.exe` (source not included).
Studio's ANCL source is included for inspection; the internal offline-completion source modules
used by the original build are not part of this standalone binary bundle.

## 4. What's in this bundle

See `MANIFEST.md`. In short: `bin/` (the IDE + compiler + AI engine + op-brain models + helper
tools + config), `src/` (Studio's inspectable ANCL source snapshot), `core_lib/`, `starters/`,
`templates/`, and `guide.html`.

## 5. License

MIT © Mário Fernandes. The included source, executables, and data artifacts are distributed under
the bundle's `LICENSE`. Aether Engine source is not included in this public release.
