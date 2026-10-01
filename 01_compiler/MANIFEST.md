# Compiler bundle manifest

- `anclc.exe` — Windows x86-64 ANCL compiler.
- `linux/anclc` — Linux x86-64 ANCL compiler.
- `src/` — modular compiler source, generated single-file Windows/Linux sources, and the self-host verification script.
- `core_lib/` — reusable ANCL standard and platform libraries.
- `examples/` — small programs for compiling and experimentation.
- `HELP.md` — quick start, targets, language overview, and self-host proof.
- `LICENSE` — MIT license for this bundle.

Generated `stage2.exe`, `anclc3.exe`, `anclc4.exe`, and assembly listings are verification artifacts and are not part of the release.

- `bootstrap/` — optional newer C++17 bootstrap source and build instructions; no replacement release binary.
- `tests/` — floating-point, generic core, JSON, cryptographic and platform regressions, plus a PowerShell validation runner.
- `DEVELOPER_REFERENCE.md`, `CAPABILITIES.md`, `VALIDATION.md` — API reference, evidence-based capability assessment and validation limits.
