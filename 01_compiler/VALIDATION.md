# Generic core and bootstrap validation

Validated on Windows x86-64, 1 October 2026. Baseline public commit: `ee1a029fcbfcad48b9b8f6dabbb6a14f771ba8b8` (v1.0 public preview). Updated bootstrap source is unversioned; no release number is assigned.

## Executed

- Rebuilt `bootstrap/anclc.cpp` using GCC 16.2.0, C++17, `-O2 -static`.
- Four floating-point regressions: typed f64 struct read/write, f32 storage/FFI, call conventions/conversions, and long decimal literals. All pass with the rebuilt bootstrap.
- Bootstrap feature probe: target conditionals, duplicate normalized imports and `INT64_MIN` decimal formatting.
- Core regression: syntax, multi-file imports, integer structs, file create/write/read/delete, missing-file errors, UTC system time, a native worker thread/wait, region allocator split/coalesce/double-free refusal, SHA-256 and numeric formatting.
- JSON regression: fractional/exponent values, number-token preservation, Unicode and surrogate pairs, member walk, reservation, node/arena exhaustion, recovery, and bounded-copy canaries.
- HMAC-SHA256 (RFC 4231 case 1) and HKDF-SHA256 (RFC 5869 case 1) known-answer vectors; oversize HKDF output refusal.
- Win32/COM import loading, mutex/event lifecycle, system random API and process-local COM initialization.
- Six public examples: hello, constants, FizzBuzz, heap strings, infix operators, structs.
- HTTP client: compiled `tests/test_http.ancl`, successful GET through WinHTTP to a local fixture at `127.0.0.1:18943`.
- HTTP server: compiled public `13_httpd/src/httpd.ancl` with a temporary loopback-only binding/port and path-adjusted imports; received HTTP 200 with the exact local fixture body. The public HTTP server source is unchanged.
- Static Linux hello and updated JSON ELF cross-emission. Cross-emission is not Linux execution.
- Public ANCL self-host source built using both the baseline executable and rebuilt bootstrap, then self-compiled twice. Both paths reach the same stage-3/stage-4 SHA-256: `2bc0e21a13efd9375f178dede7f14cfb5efd6d6e1487a380e45d9e8bcf8a5a46`.

## Failures and corrections

Baseline `anclc.exe` fails the f64 struct test and eight f32 test groups; the f64 call-convention test is rejected at an explicit `void` extern return annotation. These limitations are documented, not hidden by replacing the baseline executable.

The initial new allocator test wrongly expected the whole supplied buffer after alignment; it now compares `heap_span()` with `heap_init()`'s actual aligned span. The updated JSON pool uses ANCL `alloc/free` instead of Windows-only allocation imports, checks initial allocation failure, guards node-byte multiplication, and reserves a terminating NUL in `json_num_copy` (`cap` is the complete destination size). Decimal conversion bounds work for extreme input exponents; overflow yields infinity and very small magnitudes can collapse to zero.

## Reproduce

Build the bootstrap as described in [bootstrap/README.md](bootstrap/README.md), then run `tests/verify_core.ps1 -Compiler <path>` from PowerShell. The script checks compiler/executable exit codes and preserves artifacts in an isolated temporary build directory. It does not run `test_http` without a listening local fixture. To reproduce that test, serve the literal body `ANCL loopback HTTP` on loopback port 18943, compile `test_http.ancl`, and check exit zero. No external endpoints or industrial equipment are required.

## Limits

No Linux distribution was available, so Linux runtime and Linux GUI/service behavior were not tested. No new live industrial, TLS-handshake, database or service-installation tests were performed. Additional platform-specific libraries and simulator changes require separate validation before promotion. Component-specific older library copies remain paired with their existing software; only compiler/AI-guide core bundles are updated here.

The JSON reader remains permissive, recursive and shared-state; capacity protection is not strict malformed-input validation. Number conversion/formatting has stated precision limits. New heap and cryptographic helpers are experimental and not independently audited; their shared scratch is not a concurrency guarantee. ANCL remains an alpha/technology preview.
