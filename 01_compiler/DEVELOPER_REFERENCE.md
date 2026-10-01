# ANCL developer reference

Evidence baseline: public repository commit `ee1a029fcbfcad48b9b8f6dabbb6a14f771ba8b8`, reviewed against a newer unversioned bootstrap source and representative Windows execution. Prefer the current project's actual compiler and sources over this snapshot.

## Documentation and compiler architecture

- [AI guide](https://github.com/mfernandes-ancl/ancl/blob/main/02_ai_guide_pack/ANCL_AI_GUIDE.md): syntax, types, memory, structs, sums, FFI and pitfalls.
- [Compiler help](https://github.com/mfernandes-ancl/ancl/blob/main/01_compiler/HELP.md): targets, command forms, `--fix`, self-host proof.
- [Compiler sources](https://github.com/mfernandes-ancl/ancl/tree/main/01_compiler/src): lexer → recursive-descent parser → parallel-array AST → hand-encoded x86-64 instructions → PE/ELF writer. No assembler, linker or LLVM is needed for emitted ANCL programs.
- [Core library](https://github.com/mfernandes-ancl/ancl/tree/main/01_compiler/core_lib) and [examples](https://github.com/mfernandes-ancl/ancl/tree/main/01_compiler/examples).
- [Industrial toolkit](https://github.com/mfernandes-ancl/ancl/tree/main/09_industrial_protocols), [HTTP server](https://github.com/mfernandes-ancl/ancl/tree/main/13_httpd), [WinHTTP transport](https://github.com/mfernandes-ancl/ancl/blob/main/04_ide/src/transport.ancl).

The pre-generated `src/anclc2_all.ancl` and `_linux.ancl` are executable self-host sources. Some modular-source documentation predates import support and contains original development paths: do not execute those paths without checking the shipped layout. Rebuilding the newer C++ bootstrap needs a host C++ compiler; running the resulting ANCL applications does not need that compiler.

## Project structure and values

Keep an entry `.ancl`, focused imported modules, a matched `core_lib`, and disposable build outputs. `import "relative/file.ancl";` includes a module relative to the importer. Functions can call later definitions; imports are not namespaces. Observe compiler-specific include-once canonicalization.

Global integer initializers and `buf` sizes accept constant expressions. `i8/i16/i32/i64/ptr` tables use `name: T[N] = { ... };`; treat them as read-only storage. Dynamic collections are explicit buffers plus counts/capacities. Globals named `buf` hold addresses even when their size is eight bytes: use `load64`/`store64` for a stored pointer or counter.

Struct storage is caller-owned. Typed pointer chains perform offset/stride calculations; explicit `T.field` plus load/store is the useful fallback. The baseline compiler fails the typed `f64` struct test, so use the validated newer bootstrap or test raw-bit access. A `sum` value is a heap pointer with a tag and fields, and `match` binds payload values. New bootstrap refuses `f32` sum fields: use `f64` there.

First assignments infer local numeric kind; explicitly annotate when API/ABI matters. Win32 pointer returns require `-> ptr`/`i64` to avoid truncation; ordinary 32-bit returns use their actual declared kind. `extern "library.dll" Function -> ptr;` declares an imported symbol, not typed argument validation. Read the OS ABI and a working ANCL caller. `callp(pointer,args...)` handles indirect calls; COM `vmeth(obj,index)` reads vtables. Never copy hard-coded interface layouts without checking them.

## Core API map

| Concern | Existing API/source | Practical contract |
|---|---|---|
| Integer helpers | `std.ancl`: `imin`, `imax`, `iabs`, `clamp`, `ipow` | Check overflow/domain yourself. |
| Strings | `cstring.ancl`, intrinsics `strlen`, `strcmp`, `str_copy`, `puts_cstr` | Caller owns memory; bounded helpers for external text; copy returns end pointer. |
| Numbers/time text | `numfmt.ancl`: `nf_dtoa`, `nf_ftoa`, fixed-width decimal/date helpers | Bit-pattern APIs take integer bits. Formatting is bounded precision, not universal roundtrip. New `nf_f64_shortish` rounds to nine fractional digits; `nf_f32_g` uses seven significant digits and collapses subnormals. |
| Memory | `alloc`, `free`; new `heap.ancl` | Region allocator is first-fit with splitting/coalescing; `heap_init` aligns the supplied region and returns actual usable span. No thread-safety claim. |
| JSON | `json_parse`, `json_obj_get`, `json_obj_str/int`, `json_arr_first/count`, `json_next` | Shared pool/arena, not reentrant. Missing node is `-1`; check type before access. |
| New JSON helpers | `json_reserve`, `json_obj_first`, `json_key/val`, `json_num_frac/bits/copy`, `json_obj_f64bits` | Parse/reserve invalidates prior DOM/arena state. Numeric token helpers retain source input: keep it alive. `json_num_copy` capacity includes NUL. Fraction/exponent metadata prevents lossy integer re-emission. |
| Files/errors | `win32_api.ancl`, `liblinux.ancl` | `CreateFileA` fails with `-1`; most BOOL APIs fail with zero. Linux raw wrappers return negative errno. Verify bytes transferred, close handles, propagate errors. |
| Date/time | OS `GetSystemTime`, `GetLocalTime`, `GetTickCount`; numeric/OLE helpers | UTC versus local clock is explicit; test structures and field widths. No high-level timezone database confirmed. |
| Threads | Win32 `CreateThread`, `WaitForSingleObject`, handles/events | Native callback address `&worker`, explicit synchronization and lifetime. Imported libraries often use shared scratch and are not automatically thread-safe. |
| HTTP | `13_httpd/src/httpd.ancl`; `04_ide/src/transport.ancl` | Winsock server example; WinHTTP client uses UTF-16 strings, handle cleanup and timeouts. Do not call the transport function `ol_http2` a proof of wire HTTP/2. |
| Processes/UI | `process`, `process_capture`, `gui/gui_v2`, `gdi/gdi_v2`, `rich_edit`, `ui_kit` | Windows OS interfaces; hidden process capture and message loops. |
| Database | `sqlite.ancl` | Requires `sqlite3.dll`; not a dependency-free database engine. |
| Industrial/binary | `mqtt`, `goose`, `iec61850`, toolkit sources | Inspect packet bounds/endian conversions; test fixtures before hardware. Pure MQTT helper is plain transport; CLI TLS helper adds an external program. |
| Cryptographic primitives | new `libsha256.ancl`: SHA-256, HMAC, HKDF | Published test vectors verified; global HMAC/HKDF scratch is not reentrant. This is not a complete TLS implementation or an audit. |

Do not treat a permissive JSON parser as a strict RFC validator. Capacity exhaustion returns `-1` and `json_exhausted()` reports it; malformed-input validation and recursion depth remain limitations. A parsed integer can lose fractional information. Exact decimal copying is the appropriate preservation API; floating conversion uses roughly 17 significant digits.

## Debugging and testing

Reduce failures to one feature and print expected/actual integers or bit patterns. Compare compiler hashes and use the same source/library pair. Inspect `.asm` for integer versus XMM flow, pointer-width returns, call argument placement and loads/stores. Check exit status before running output. The newer bootstrap supports `--diagnostics=json`; validate that flag in the selected compiler. `--fix` is a mechanical repair aid and can rewrite `f32` to `f64`; use dry-run first and review edits.

Test bounds, absence and failure as well as success. For numeric code choose exact binary values when possible and declared tolerances otherwise. Do not reinterpret float bits as lengths. Validate imported modules with a real executable. Self-host equality is useful but does not prove all language features correct; the baseline fixpoint reproduces its known float bugs.

Cross-compile Linux with `--target=linux` and inspect ELF output, but report Linux runtime execution separately. Win32 GUI/WinHTTP imports are not portable merely because the compiler can emit ELF. Static Linux uses direct syscalls; dynamic Linux intentionally needs a system loader/libraries. WebAssembly and browser code generation are absent from the inspected target writers.
