# ANCL Elspec Monitor

A native ANCL **Modbus/TCP polling monitor** with a built-in **web dashboard** — it polls float32
registers from Modbus devices (built for Elspec BlackBox power-quality meters, but works with any
Modbus/TCP slave) and serves a live JSON + HTML dashboard. Single native `.exe`, zero-dependency,
full source included.

## Run

```
elspec_monitor.exe
```

Then open **http://localhost:8080** for the live dashboard. Out of the box it polls **one device at
`127.0.0.1:502`** — point it at a real device (or run a Modbus simulator locally) by editing
`elspec_config.ini`.

## Configure (`elspec_config.ini`)

Each device has: `name`, `farm`, `ip`, `unit_id`, `port`, `poll_ms`, `scales`, `enabled`.
`reg_addrs` is the list of 12 Modbus register addresses polled per device (the defaults are the
Elspec BlackBox map). Set `num_devices` and add a block per device.

> Tip: pair it with the **Modbus simulator** from the Industrial Protocol Toolkit to see it working
> against `127.0.0.1:502` with no hardware.

## Source included

`src/` has the full source plus the two small libs it needs, so it compiles standalone:

```
anclc src\elspec_monitor.ancl elspec_monitor.exe
```

## ⚠ Experimental — not safety-certified

This monitor connects to and reads from **live power-quality equipment**. It's provided for
evaluation and diagnostics — **not** independently audited or certified for production or
safety-critical use. Point it only at devices you're authorized to access. (The shipped config uses
a placeholder `127.0.0.1` device — set your own targets.)

## License

MIT © Mário Fernandes. See `LICENSE`.
