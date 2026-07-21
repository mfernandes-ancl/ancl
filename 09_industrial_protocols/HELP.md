# ANCL Industrial Protocol Toolkit

Native, zero-dependency **industrial protocol testers + simulators**, written entirely in ANCL —
the reason ANCL exists. Each is a small native Win32 app with **full source included**. Point a
tester at a real device (or the matching simulator) and read/write live process data — no runtime,
no drivers, no vendor SDK.

---

## The unified tester (start here)

`multi_tester\multi_tester.exe` — **one** dark-themed tabbed GUI that speaks **Modbus/TCP, Omron
FINS, Siemens S7comm, IEC 60870-5-104, IEC 61850 MMS, and Allen-Bradley CIP** together. Ready to
run, zero-dependency; press **F1** for its built-in help. (Shipped as a binary; the individual
single-protocol testers below ship with full source.)

## Protocols

| Protocol | Tester | Simulator | Validation |
|---|---|---|---|
| **Modbus TCP** | `modbus_client` | `modbus_sim` | ✅ **real hardware** (Schneider Modbus PLC) |
| **Omron FINS/TCP** | `fins_client` | — | ✅ **real hardware** (Omron FINS PLC) |
| **IEC 60870-5-104** | `iec104_tester` | `iec104_slave_gui` | ✅ **real hardware** (an IEC-104 gateway) |
| **Siemens S7** | `s7_tester` | `s7_simulator` | simulator |
| **DNP3** | `dnp3_tester` | `dnp3_simulator` | simulator |
| **OPC-UA** | `opcua_client` | — | simulator |
| **EtherNet/IP (Allen-Bradley)** | `ab_tester` | `ab_simulator` | simulator |
| **BACnet** | `bacnet_tester` | `bacnet_simulator` | simulator |
| **IEC 61850 / MMS** | `iec61850_tester` | `iccp_simulator` | simulator |
| **IEC 61400-25 (wind)** | `iec61400_25_tester` | `iec61400_25_simulator` | simulator |
| **OPC-DA** | `opc_da_tester` | `opc_da_simulator` | simulator |

**Validation note.** The **Modbus TCP**, **Omron FINS/TCP**, and **IEC-104** clients have been
**tested read/write against real industrial hardware** in an isolated lab. Every other protocol has
been validated against the **simulator included here**. All of them are pure ANCL — the same
zero-dependency stack top to bottom.

## How to use

Each tester is a standalone GUI app:

```
testers\modbus_client\modbus_client.exe
```

Enter the target `host:port` (defaults to `127.0.0.1`), connect, and read/write points. To try a
tester without a device, launch the matching simulator first (it listens on localhost), then point
the tester at `127.0.0.1`:

```
simulators\modbus_sim\modbus_sim.exe        # then connect modbus_client to 127.0.0.1
```

## Source included

Every tester and simulator ships its ANCL **source** under `src/` next to the `.exe` — read it,
learn the protocol, adapt it. This is the clearest reference there is for speaking these protocols
from scratch, with no vendor library in sight.

## Notes

- These are **testing/engineering tools** for use on equipment and networks you are authorized to
  access.

## Found a bug? (especially against real hardware)

Modbus TCP, Omron FINS, and IEC-104 were verified against real hardware — but real OT gear varies
wildly, so if you hit a bug against a live device, please **[open an issue](https://github.com/mfernandes-ancl/ancl/issues)** and
**attach the tool's saved log**, with the protocol + device + what you expected vs. what happened.
It's the fastest path to a fix.

## ⚠ Experimental — not safety-certified

These tools can **read from and write commands to live industrial equipment**. They're provided for
testing, evaluation, and diagnostics — they are **not** independently audited or certified for
production or safety-critical use. Before pointing any write/command feature at equipment that runs
a real process, test it against a simulator or an isolated bench first and be sure you understand
what a command will do. **You are responsible for what you send to a live device.**

## License

MIT © Mário Fernandes. See `LICENSE`.
