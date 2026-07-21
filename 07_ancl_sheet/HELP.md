# ANCL Sheet — Help

**ANCL Sheet** is a native, zero-dependency spreadsheet, written in ANCL — formulas, CSV and XLSX
open/save, no runtime. Source included.

## Launch

```
bin\ancl_sheet.exe
```

Open `bin\guide.html` (or press **F1**) for the full guide, and try the included
`samples\sample.csv` / `samples\sample.xlsx`.

## What's included

- `bin\ancl_sheet.exe` — the spreadsheet · `bin\guide.html` — the manual
- `src\` — the full source: `ancl_sheet.ancl` + the handful of library files it needs
- `samples\` — `sample.csv`, `sample2.csv`, `sample.xlsx`

The `.exe` runs out of the box, offline, zero-dependency — open `.csv`/`.xlsx`/`.db` files
directly. And the source **compiles standalone** — `src/` includes exactly the libraries it needs,
so you can rebuild it with the ANCL compiler:

```
anclc src\ancl_sheet.ancl ancl_sheet.exe
```

## License

MIT © Mário Fernandes. See `LICENSE`.
