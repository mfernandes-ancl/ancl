# Aether Workbench

**Aether Workbench** is a native ANCL **industrial-protocol analysis workbench** — a passive network
sniffer + protocol decoder + tester synthesizer for OT/ICS networks. It captures live traffic,
identifies and decodes industrial protocols, maps the devices talking on the wire, and can
synthesize read/write test tools on the fly. Single native `.exe`, no runtime.

> Ships as a **binary** (source private).

## Run

```
aether_workbench.exe
```

**Run as Administrator.** Packet capture uses a **native Windows raw-socket promiscuous tap**
(`SIO_RCVALL`), which requires admin rights — **no Npcap needed** for IP-layer protocols. *(Optional:
IEC-61850 GOOSE and other Layer-2 capture use Npcap/`wpcap.dll` if it's installed — from
[npcap.com](https://npcap.com) — but everything else works without it.)*

## What it does

- **Passive live capture** + protocol identification (rule-based + a learned frame classifier)
- **Rich decode** of industrial protocols — Modbus, S7, FINS, IEC-104, IEC-61850 (MMS + GOOSE),
  DNP3, OPC-UA, EtherNet/IP, BACnet
- **Peer / asset mapping** — who's talking to whom
- **Tester synthesis** — generates read/write test tools for the protocols it finds
- **Anomaly / flow monitoring** (edge IDS)
- List / Star / Table views, live natural-language read-out, HTML report export

## Found a bug? (please report)

If you run this against **real hardware** and hit a bug — and with messy real-world OT gear, you
probably will — please help make it better: the Workbench **saves a session log**, so
**[open an issue on GitHub](https://github.com/mfernandes-ancl/ancl/issues) and attach the saved log**. That log is the fastest path
to a fix.

## ⚠ Experimental — not safety-certified

The Workbench captures live network traffic and can actively probe and **write to** industrial
devices. It's a diagnostic and evaluation tool — **not** independently audited or certified for
production or safety-critical use. Use it only on networks and equipment you're authorized to touch,
and validate any write/command against a simulator or an isolated bench before using it on a live
process.

## License

The Aether Workbench is distributed as a **binary**; its source is not included. Documentation
© Mário Fernandes.
