# ANCL Compiler — Help Guide

**ANCL** is a self-hosting, zero-dependency language. This bundle is the compiler: a single
native binary that turns `.ancl` source into a native Windows or Linux executable — no C
runtime, no VM, no linker, no DLLs to ship. And the compiler is itself **written in ANCL**,
included here as source that rebuilds itself byte-for-byte.

---

## 1. Quick start

From this folder:

```
anclc.exe examples\hello.ancl hello.exe
hello.exe
```

That's it — `hello.exe` is a standalone native executable. (The example programs live in
`examples\`; `hello.exe` is written to the current folder.)

> **Two equivalent compile forms:** the simple positional `anclc <input.ancl> <output.exe> [icon.ico]`,
> or `anclc build <input.ancl> -o <output.exe>`. Add `--target=…` for other platforms (§2).

## 2. Targets

This bundle ships the compiler for **both** operating systems — `anclc.exe` (Windows) and
`linux/anclc` (a static x86-64 Linux ELF). They are the same compiler; either one can emit
binaries for any of these targets:

| Command | Output |
|---------|--------|
| `anclc.exe prog.ancl prog.exe` | Windows `PE32+` executable (default) |
| `anclc.exe prog.ancl prog --target=linux` | Linux **static** ELF (no libc, no interpreter) |
| `anclc.exe prog.ancl prog --target=linux-dyn` | Linux **dynamic** ELF (links the system loader; for runtime-loaded system libs) |

On Linux, use `linux/anclc` exactly the same way:

```
chmod +x linux/anclc
./linux/anclc hello.ancl hello --target=linux
./hello
```

The Windows binaries import `kernel32.dll` only; the static Linux ELF imports nothing (`file`
reports *statically linked*, `ldd` reports *not a dynamic executable*). No CRT, no garbage
collector, no bundled runtime — the compiler emits machine code directly. The Linux `anclc` in
this bundle was itself cross-emitted **by the Windows `anclc.exe`** — the compiler builds its own
Linux port — and it reproduces itself natively on Linux (§4).

## 3. The self-correcting compiler (`--fix`)

ANCL's compiler can repair common mechanical mistakes in your source instead of just erroring —
stripping `let`/`var` declarators, mapping `bool`→`i64`, `true`/`false`→`1`/`0`, `//`→`#`, and
similar unambiguous fixes. `--fix` takes flags first, then the input file:

```
anclc --fix <input.ancl>            # dry run: report what it WOULD fix
anclc --fix --write <input.ancl>    # heal the source in place
```

Try it — `examples/selfheal.ancl` is deliberately C-flavored and won't compile as-is:

```
anclc --fix --write examples/selfheal.ancl    # -> "10 fix(es) APPLIED", lists each
anclc examples/selfheal.ancl selfheal.exe     # now it compiles
selfheal.exe                                   # returns 41
```

`--fix` is conservative — it applies only unambiguous mechanical corrections and reports each
one; it won't guess at intent. (Deeper AI-assisted repair lives in the Aether Studio IDE.)

There's also `anclc <input.ancl> <output.exe> --check` — an intent-oracle checker.

## 4. Prove it self-hosts (the headline feature)

The compiler in this bundle is written entirely in ANCL (`src/`), and it compiles **its own
source into a byte-for-byte identical copy of itself**. You can verify this yourself in about
30 seconds — this is the proof that ANCL is a real, capable **self-hosting native systems
language**, and that the `anclc.exe` you were given is honestly reproducible from source. The
single-file compiler source (`src\anclc2_all.ancl`) ships **pre-generated**, so no scripts are
needed:

```
cd src

REM 1. BOOTSTRAP: the shipped anclc builds the ANCL-written compiler
..\anclc.exe   anclc2_all.ancl  stage2.exe

REM 2. SELF-COMPILE: that compiler compiles its OWN source
stage2.exe     anclc2_all.ancl  anclc3.exe

REM 3. FIXPOINT: anclc3 compiles itself again — the two MUST be identical
anclc3.exe     anclc2_all.ancl  anclc4.exe
fc /b anclc3.exe anclc4.exe                      REM "no differences encountered"
```

Steps 2 and 3 produce **byte-identical** binaries. The snake has eaten its tail. Or just run the
included one-shot check:

```
powershell -ExecutionPolicy Bypass -File src\verify_selfhost.ps1     REM prints PASS + the fixpoint SHA-256
```

> **Honest note on the bootstrap.** The `anclc.exe` in this bundle was itself first built by a
> small C++ bootstrap compiler, which is **not included here** (the ANCL source is). Every
> self-hosting language needs a prior binary to build the next one (Go, Rust, and others all do);
> what the steps above show is that this binary reproduces itself exactly from the ANCL source you
> can read. If you want a fully independent trust root, the C++ bootstrap is available separately —
> ask.

**On Linux**, the same proof runs with the native `linux/anclc` and the pre-generated Linux
source variant (`src/anclc2_all_linux.ancl`):

```bash
chmod +x linux/anclc
./linux/anclc src/anclc2_all_linux.ancl g2 --target=linux    # the Linux compiler builds itself
chmod +x g2
./g2          src/anclc2_all_linux.ancl g3 --target=linux    # and that build builds itself again
sha256sum g2 g3          # identical — the Linux self-host fixpoint
```

`g2` and `g3` are byte-identical: ANCL self-hosts natively on Linux, too.

## 5. The language, briefly

ANCL is a small, C-flavored systems language: `func`, `struct`, `while`, `if/else`, `match`,
infix arithmetic + bitwise ops, `i64`/`i32`/`ptr`/`f64`, pointer + array access, `@DATA`
constant tables, direct `syscall`, and `import` for modules. `core_lib/` (included) is the
standard library. See the examples in this bundle, and — for the fastest path — the **AI-guide
pack**, which lets your AI assistant write ANCL for you.

## 6. What's in this bundle

See `MANIFEST.md`. In short: `anclc.exe` (the Windows compiler), `linux/anclc` (the Linux
compiler), `src/` (the compiler's own ANCL source — modules + the pre-generated single-file
sources + a one-shot `verify_selfhost.ps1`), `core_lib/` (standard library), and `examples/`.

## 7. License

MIT © Mário Fernandes. See `LICENSE`.

## 8. Optional newer bootstrap and core validation

`bootstrap/anclc.cpp` provides an additional, source-buildable compiler path with newer
floating-point storage/FFI fixes. See `bootstrap/README.md` for its C++17 build command.
The existing self-hosted executable is preserved and is not feature-equivalent: it fails
the new typed f64-struct and f32 regressions. Use the rebuilt bootstrap for those features,
or verify explicit raw-bit access with the selected compiler. The self-host fixpoint still
passes through both toolchains.

`DEVELOPER_REFERENCE.md`, `CAPABILITIES.md`, and `VALIDATION.md` describe API contracts,
evidence, dependency exceptions and remaining limits. The compiler/AI-guide core bundles
now include generic region allocation, SHA-256/HMAC/HKDF, JSON decimal/Unicode/capacity
helpers, numeric formatting fixes and extra Win32/COM imports. Older component-specific
library copies remain paired with their shipped applications.
