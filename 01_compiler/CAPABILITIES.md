# ANCL capability matrix

Evidence: public commit `ee1a029fcbfcad48b9b8f6dabbb6a14f771ba8b8`, selected newer generic core/bootstrap sources, and local Windows tests. **Confirmed** means documented/source-backed or locally executed, not production-hardened. The project remains an alpha technology preview.

| Capability | Status | Evidence / limits |
|---|---|---|
| Native CLI | Confirmed | Compiler PE writer; six public examples compiled/run on Windows. |
| Windows applications | Confirmed | Native PE executables, Win32 imports, GUI templates and source. |
| Linux applications | Confirmed with limitations | [Compiler help](https://github.com/mfernandes-ancl/ancl/blob/main/01_compiler/HELP.md), ELF writers and Linux compiler; cross-emission checked, no Linux runtime environment available in this validation. |
| REST/HTTP clients | Confirmed with limitations | [WinHTTP transport](https://github.com/mfernandes-ancl/ancl/blob/main/04_ide/src/transport.ancl); loopback GET executed. REST semantics/authentication remain application-specific. |
| HTTP servers | Confirmed with limitations | [httpd](https://github.com/mfernandes-ancl/ancl/tree/main/13_httpd); compiled/run loopback static GET. Minimal synchronous server, not a hardened framework. |
| JSON | Confirmed with limitations | `core_lib/json.ancl`; DOM, decimals/exponents, Unicode and exhaustion tests. Shared state, permissive syntax, finite pools and recursion. |
| Configuration files | Confirmed with limitations | File APIs and JSON/IDE settings source; schema/validation is application code. |
| Database connectivity | Confirmed with limitations | [SQL-to-MQTT](https://github.com/mfernandes-ancl/ancl/tree/main/12_sqltomqtt), SQLite interop; requires `sqlite3.dll`. Other database drivers not confirmed. |
| Concurrency | Confirmed with limitations | `CreateThread` and wait APIs executed; no intrinsic ownership/thread-safety or portable high-level scheduler confirmed. |
| Scheduled/background processes | Confirmed with limitations | Win32 timers, `Sleep`, native threads/process helpers; durable schedules require application/OS code. |
| Industrial protocols | Confirmed with limitations | [Toolkit](https://github.com/mfernandes-ancl/ancl/tree/main/09_industrial_protocols); documented tester/simulator implementations. No new live hardware tests or production certification. |
| Services/daemons | Confirmed with limitations | Added generic Win32 SCM/dispatcher imports; native Linux process/syscall building blocks. Service lifecycle and daemon deployment were not executed. |
| Desktop UI | Confirmed with limitations | Win32 GUI/GDI libraries, IDE/Pad/games source; Windows GUI. Cross-platform GUI not confirmed. |
| Browser frontend code generation | Not supported | Inspected compiler target dispatch emits PE/ELF/bare images, no JS/browser backend. Can serve separately authored HTML. |
| WebAssembly | Not supported | No Wasm target or writer in inspected compilers. |
| TLS/HTTPS | Confirmed with limitations | WinHTTP secure flag/system TLS in transport source. New SHA/HMAC/HKDF is not a complete TLS stack; this run did not validate an HTTPS handshake. |
| Authentication | Confirmed with limitations | Bearer header handling in transport, COM security imports and protocol auth code. No general identity framework/security audit. |
| Filesystem | Confirmed | Create/write/read/delete/missing-path behavior executed; public Windows/Linux source. |
| Binary protocols | Confirmed with limitations | Width-specific loads/stores, shifts, toolkit packet encoders. Bounds and endian validation remain caller responsibilities. |

Further capabilities (e.g. portable desktop UI, broad database drivers, portable managed task scheduler, authenticated HTTPS server) are **Not confirmed** until supported by precise source or a working test.
