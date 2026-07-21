# anclc2 — a self-hosting ANCL compiler, written in ANCL

This is the ANCL compiler **written in ANCL** — and it **compiles itself**.

`anclc` (the original, written in C++) emits native Windows `PE32+` executables from
`.ancl` source. The compiler in *this* folder does the exact same job, except every
line of it is ANCL. It has reached the milestone that defines a mature language:

> **Self-hosting fixpoint achieved.** The ANCL-built compiler compiles its own source
> into a **byte-for-byte identical copy of itself**. No C++ in the loop after the
> initial bootstrap.

```
self-hosted compiler: bin/anclc3.exe  ·  193,536 bytes  ·  imports: kernel32.dll only  ·  no CRT/VM/linker
SHA-256 (this build, reproducible):  E9C2E72BC2DB1BC268A3890A1D033E01CF2BCDC38A757569463ABD78331A32E8
```

**The proof is the fixpoint.** The C++ bootstrap builds the ANCL compiler; that compiles
its own source into `anclc3`; `anclc3` compiles the same source again into `anclc4`; and
`anclc3` and `anclc4` are **byte-for-byte identical** (`fc /b` → no differences). The build
is deterministic — two independent from-scratch bootstraps reproduce the same binary — and
it was re-verified bottom-up from the C++ bootstrap, so the equality holds no matter which
stage built which. (Absolute SHA tracks the source; the `anclc3 ≡ anclc4` equality is the
invariant that always holds.)

---

## Verify it yourself (≈30 seconds, from this folder)

```powershell
# 1. (re)generate the single-file source from the 6 modules + core_lib
.\gen_all.ps1                                              # -> src\anclc2_all.ancl

# 2. BOOTSTRAP: the C++ anclc builds the ANCL-written compiler  (~13 MB intermediate)
..\..\bin\anclc.exe  src\anclc2_all.ancl  bin\stage2.exe

# 3. SELF-COMPILE: the ANCL compiler compiles its OWN source     (-> 193 KB)
.\bin\stage2.exe     src\anclc2_all.ancl  bin\anclc3.exe

# 4. FIXPOINT: anclc3 compiles itself again; the two must be identical
.\bin\anclc3.exe     src\anclc2_all.ancl  bin\anclc4.exe
fc /b bin\anclc3.exe bin\anclc4.exe                        # "no differences encountered"

# 5. it's a real, working compiler:
.\bin\anclc3.exe     bin\hello.ancl       bin\hello.exe
.\bin\hello.exe                                            # -> hello from anclc2
```

Steps 3 and 4 produce **byte-identical** binaries — the snake has eaten its tail.

---

## Architecture

The compiler is six ANCL modules, ~3,500 lines total, using a deliberate **struct-free
parallel-array** AST design (flat `i64[]` arrays indexed by node id) so the data model
stays simple enough to compile itself:

| File | Role |
|------|------|
| `src/lexer.ancl` | Tokenizer: source bytes → parallel token arrays (kind/ival/toff/tlen/line) |
| `src/parser.ancl` | Recursive-descent parser → flat AST + function/data/struct/extern tables |
| `src/emit.ancl` | Hand-written x86-64 instruction encoder (REX/ModRM/SIB byte emission) |
| `src/codegen.ancl` | AST walk → x86-64 machine code + emitted runtime helpers |
| `src/pe_writer.ancl` | PE32+ assembler: `.text/.rdata/.data/.idata`, multi-DLL imports, fixups |
| `src/main.ancl` | Entry point: read source → lex → parse → codegen → write `.exe` |

**The build is single-file.** `anclc2` does **not** resolve `import` statements, so
`gen_all.ps1` deterministically concatenates the six modules **plus the inlined
`core_lib` (`std.ancl` + `win32_api.ancl`)** into `src/anclc2_all.ancl`. The six modules
are the source of truth — `anclc2_all.ancl` is a **generated artifact** (don't hand-edit
it; edit a module and re-run `gen_all.ps1`).

---

## Language supported by the self-hosted compiler

Everything `anclc2`'s own source needs — which, since a compiler exercises the whole
language, is most of ANCL:

- Types `i8/i16/i32/i64/ptr/str`; decimal + `0x` hex + `'c'` char literals; `#` comments.
- `+ - * / %`, comparisons `== != < <= > >=`, short-circuit `&& || !`.
- Bitwise **intrinsics** `band/bor/bxor/shl/shr`; memory `load8/16/32/64` + `store8/16/32/64`.
- `if / else if / else`, `while`/`loop`, `break`, `continue`; functions of any arity + recursion.
- `struct` declarations with `Struct.field` compile-time offsets and `sizeof(T)`.
- `@DATA` globals (`i64` consts, `str`, `buf = N`), `syscall 1, …` type-aware print,
  `extern "dll" fn;` FFI, and `&func` address-of.
- Runtime helpers it emits: print, `memcpy/memset/strlen/strcmp`, `int_to_str/str_to_int/str_copy/puts_cstr`.

Not supported (deliberately, and worked around by `gen_all.ps1`): multi-file `import`
resolution — the bootstrap concatenates instead.

---

## The road to self-hosting — bugs that had to fall

Getting a compiler to reproduce itself is brutal: its source uses *every* feature, so a
single latent bug miscompiles the compiler itself. The ones that stood between "compiles
hello" and "compiles itself":

1. **Multi-argument calls didn't parse** — the argument-list comma loop bailed after the
   first arg. (`syscall`'s loop was written correctly, which masked it.)
2. **Intrinsics miscompiled to 0** — root cause was **AST aliasing**: the call-arg
   "next" pointer lived in `g_nd_b`, the *same* slot the intrinsic codegen read its 2nd
   argument from. Moving the arg link to `g_nd_c` fixed `band/shl/store/load/...` (found
   by disassembling the emitted machine code).
3. **Nested `else-if` collided** — the `if` node's else-head shared a slot with another
   field; relocated it.
4. **`sizeof` + struct field access** — added the struct/field tables and compile-time
   offset resolution the source relies on.
5. **Input truncated at 64 KB** — `main`'s source buffer + `ReadFile` cap grew to 2 MB
   (the compiler's own source is ~160 KB and the loaded blob is larger).
6. **Capacities too small for its own source** — raised: tokens 8 K→65 K, AST nodes
   2 K→32 K, data vars 127→511, functions 63→255, externs 31→255, string pool→256 KB,
   code buffer 64 KB→1 MB, label/fixup tables→16 K, image buffer→4 MB.
7. **PE writer wrote zero-init `.data` into the file** — set `.data` `SizeOfRawData=0`
   (the loader zero-fills from `VirtualSize`), else the file ballooned past the image buffer.
8. **PE writer corrupted the import table** — single-pass DLL grouping overwrote later
   DLLs' regions when a DLL's imports weren't contiguous (kernel32 externs after ws2_32
   builtins); rewritten as a 2-pass per-DLL collection.
9. **Stack frame ignored callee arity** — the outgoing-argument area was sized from the
   caller's own params only, so calling a >4-arg function clobbered the caller's locals;
   added a max-call-args scan (`argbase = max(4, nparams, maxCallArgs) * 8`).

---

## Notes

- `bin/anclc3.exe` is the deliverable — the **self-hosted ANCL compiler** (193 KB,
  native, `kernel32`-only, CRT-free). `bin/anclc4.exe` is kept as the fixpoint proof.
- The bootstrap intermediate is ~13 MB only because the C++ `anclc`'s PE writer reserves
  `.data` in the file; the ANCL `pe_writer` does not, so `anclc3`/`anclc4` are compact.
- Usage:  `anclc3 <input.ancl> <output.exe>`  (positional — no flags).
- This compiler was brought to self-hosting via a multi-agent bootstrap effort and the
  fixpoint was then **independently re-verified** from the C++ bootstrap (every ANCL-built
  stage is byte-identical to the hash above).
