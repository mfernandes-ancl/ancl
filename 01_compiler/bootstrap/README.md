# Optional C++ bootstrap compiler

This source provides the newer bootstrap feature path alongside the existing self-hosted compiler. The existing `../anclc.exe`, Linux binary and self-host sources retain their identities; this is not a newly numbered ANCL release.

The bootstrap includes floating-point struct and array load/store fixes, `f32` storage/FFI widening, pointer-width return annotations, lexical import canonicalization, target conditionals, JSON diagnostics and signed-minimum decimal formatting. The baseline self-hosted executable is not feature-equivalent: it fails the included `f64` struct/`f32` regressions and rejects one explicit `void` extern annotation. A self-host fixpoint alone does not prove feature parity.

Build from the repository root with a C++17 compiler, for example on Windows using MinGW GCC:

```powershell
New-Item -ItemType Directory -Force build | Out-Null
g++ -std=c++17 -O2 -static 01_compiler/bootstrap/anclc.cpp -o build/anclc-bootstrap.exe
./build/anclc-bootstrap.exe 01_compiler/examples/hello.ancl build/hello.exe
./build/hello.exe
./01_compiler/tests/verify_core.ps1 -Compiler ./build/anclc-bootstrap.exe
```

The bootstrap needs a host C++ toolchain to rebuild. That requirement does not apply to the ANCL applications it emits. On a Linux build host, compile the same portable C++ source and select `--target=linux` for emitted programs. Linux runtime execution of this updated source was not performed in this validation.

See [validation](../VALIDATION.md) for exact evidence and [developer reference](../DEVELOPER_REFERENCE.md) for API contracts. Compiler provenance is identified by source and binary hashes, not an invented version number. Generated executables and `.asm` files belong in a build directory and are not release additions.
