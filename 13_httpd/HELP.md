# ANCL httpd — a native web server in ANCL

`httpd` is a tiny HTTP server written entirely in ANCL — a single native `.exe` with no runtime,
no framework, no dependencies. It even serves a page describing ANCL itself, rendered by a
bare-metal executable.

## Run

```
httpd.exe
```

Then open **http://localhost:8080** in your browser.

## What's included

- `httpd.exe` — the server
- `index.html` — the page it serves
- `src\` — the full source: `httpd.ancl` + the two small libs it needs. It compiles standalone:

```
anclc src\httpd.ancl httpd.exe
```

## License

MIT © Mário Fernandes. See `LICENSE`.
