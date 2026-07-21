# ANCL v1.0 public release

The first public ANCL release packages a self-hosting native compiler together with substantial software built in the language.

## Highlights

- Native Windows and Linux x86-64 compiler with no C runtime, VM, linker, or LLVM dependency.
- Byte-for-byte self-host fixpoint that can be reproduced with the included script.
- AI-guide pack for teaching an AI assistant to read, write, and debug ANCL.
- Aether Studio native IDE and ANCL Pad editor.
- Aether Engine GGUF inference binaries for Windows and Linux, with CPU execution and optional Vulkan acceleration.
- Aether Lens portable local-AI desktop.
- Industrial protocol libraries, testers, and simulators covering Modbus, S7, IEC-104, IEC-61850/MMS, DNP3, OPC-UA, EtherNet/IP, BACnet, GOOSE, and related workflows.
- Native utilities, games, graphics experiments, spreadsheet tooling, HTTP serving, OPC exploration, and SQL-to-MQTT integration.

## Maturity

This is a **v1.0 alpha / technology preview**: substantial working software intended for public evaluation, not a claim of production hardening. The industrial protocol, cryptography, TLS, and control paths have not been independently audited or safety-certified. Review and test them before any real or safety-critical deployment.

## Verification

From `01_compiler`, run:

```powershell
powershell -ExecutionPolicy Bypass -File src\verify_selfhost.ps1
```

The script builds the ANCL compiler from its included ANCL source, self-compiles it twice, and verifies that the final two binaries are byte-identical.

See `README.md`, `ABOUT.md`, and each component's help file for setup, scope, and known limitations.
