# ANCL SQL-to-MQTT

A native ANCL **edge gateway**: read a value from a **SQLite** database and publish it to an **MQTT
broker**, from a compact Win32 GUI. The MQTT client is **pure ANCL** (hand-built packet
construction); SQLite runs through the bundled `sqlite3.dll`.

## Run

```
sql_to_mqtt.exe
```

Set the **Broker IP/Port**, **MQTT topic**, **SQLite file**, and **SQL query** in the UI, then click
**PUSH DATA TO CLOUD**. It runs the query, takes the first column of the first row, and publishes it.

## Try it locally — no cloud, no hardware

The `localtest/` folder is a ready-made harness (built by the author):

1. **Run a local broker.** Install [Mosquitto](https://mosquitto.org/) and start it with the
   included config (listens on `127.0.0.1:1883`, anonymous):
   ```
   mosquitto -c localtest\mosquitto_local.conf
   ```
2. **Subscribe** in another terminal: `localtest\listen_local.ps1` (or a live view:
   `localtest\live_dashboard.ps1`).
3. **Push.** Run `sql_to_mqtt.exe`, point it at `127.0.0.1` : `1883` and the bundled
   `industrial_metrics.db`, and hit push — you'll see the value arrive on the subscriber.
   `localtest\reset_local_db.ps1` re-seeds the sample database.

The full walkthrough is in `README.md`.

## What's included

- `sql_to_mqtt.exe` + `sqlite3.dll` (the SQLite engine — the one external dependency)
- `industrial_metrics.db` — a sample database
- `localtest\` — the local MQTT test harness (Mosquitto config + PowerShell scripts)
- `src\` — full source + the libs it needs (compiles standalone: `anclc src\sql_to_mqtt.ancl`)
- `README.md` — the detailed guide

> Note: unlike the other bundles, this one ships `sqlite3.dll` — SQLite is used through it rather
> than reimplemented. The MQTT side is pure ANCL.

## License

MIT © Mário Fernandes. See `LICENSE`.
