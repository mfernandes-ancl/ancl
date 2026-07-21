# Aether OPC Explorer — ⚠ WORK IN PROGRESS

> **This tool is not finished.** It's included as an early preview / work-in-progress — expect rough
> edges and incomplete features. It's here so you can try it, watch it develop, and rebuild it from
> source.

A unified native ANCL Win32 **OPC client/explorer** — one tabbed, dark-themed app for **OPC UA**
(binary/TCP), **OPC DA** (COM/DCOM), and **OPC XML-DA** (HTTP/SOAP): connect, browse a tag tree,
read values, and poll. Single native `.exe`, no runtime.

## Status (WIP — completeness varies by tab)

- **OPC UA** (binary TCP) — connect / browse / read / poll
- **OPC DA** (COM/DCOM) — enumerate / connect / browse / read / poll
- **OPC XML-DA** (HTTP/SOAP) — connect / browse / read

## Run

```
opc_explorer.exe
```

## Source included

`src/` has the source plus the libs it needs, so it compiles standalone:

```
anclc src\opc_explorer.ancl opc_explorer.exe
```

## Found a bug?

It's a work in progress, so — very likely. Please **open an issue on GitHub** describing what you
tried (and attach the log if the tool saved one). Reports against real OPC servers are especially
welcome.

## License

MIT © Mário Fernandes. See `LICENSE`.
