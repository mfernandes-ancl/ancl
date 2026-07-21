# ANCL Sheet

Native Win32 CSV/spreadsheet editor and SQLite table browser built in ANCL, inspired by the C# Nexus Editor workflow.

It also serves as the reference app for `core_lib/gui_v2.ancl`: menus, file dialogs, clipboard text, shortcuts, and ListView in-cell editing.

Build from the repository root:

```powershell
.\bin\anclc.exe showcase\ancl_sheet\src\ancl_sheet.ancl showcase\ancl_sheet\bin\ancl_sheet.exe
Copy-Item showcase\ancl_sheet\sample.csv showcase\ancl_sheet\bin\sample.csv -Force
Copy-Item showcase\ancl_sheet\guide.html showcase\ancl_sheet\bin\guide.html -Force
```

Run:

```powershell
.\showcase\ancl_sheet\bin\ancl_sheet.exe
```

The app loads `sample.csv` next to the executable by default.

Open `showcase/ancl_sheet/sample.xlsx` to exercise the read-only XLSX importer with shared strings, inline text, escaped XML, numbers, booleans, and a cached formula result.

For SQLite testing, open `showcase/ancl_sheet/streaming_test.db`. It contains two tables and 6,000 generated records for exercising table discovery, paging, filtering, sorting, and CSV export.

Current native features:

- Windows-style File, Edit, Data, and Help menus.
- Persistent access to the three most recently opened files directly from the File menu.
- Keyboard shortcuts for common file, edit, find, filter, and row/column actions.
- Open, Save, Save As, New/Close, and Sample reset for CSV files.
- Open the first worksheet in `.xlsx` workbooks read-only, with CSV export.
- Open `.db` / `.sqlite` files as a dependency-free SQLite schema and table browser.
- Choose user tables from a dropdown and move through rows in 39-record pages.
- Decode SQLite text, signed integers, REAL values, NULLs, BLOB markers, and rowid-backed integer primary keys.
- Filter the current database page while keeping its column header visible.
- Sort the current page in memory with numeric-aware ascending and descending comparisons.
- Export the current filtered schema or table page to CSV.
- Edit values on the current SQLite table page and commit them in one transaction.
- Create an automatic `.bak` before a database commit, with database-aware Save As support.
- 40 row x 12 column sheet backing store with `A`-`L` columns.
- Cell editor with row/column navigation.
- Double-click a grid cell to edit its value.
- Lightweight formulas with cell references, ranges, arithmetic, and common aggregate functions.
- Undo/redo single-step snapshots.
- Copy, Paste, Delete, and Select All through the Windows text clipboard.
- Ctrl/Shift-select multiple grid rows to copy them as a TSV block across visible columns.
- Paste tabular or multiline clipboard data from the selected cell; commas in a single value remain in one cell.
- Insert/delete rows and columns.
- Filter by column or all columns.
- Find/Find Next.
- Sort selected column ascending or descending while keeping the first row as a header.
- Open the complete offline HTML user guide from Help or `F1`.

XLSX scope:

- `.xlsx` files open the standard `xl/worksheets/sheet1.xml` worksheet in read-only mode.
- Shared strings, inline strings, XML entities, numbers, booleans, and cached formula values are imported.
- Find, filter, sort, copy, and CSV export remain available; editing, paste, formulas, and structural changes are blocked.
- Import is bounded to the existing 40-row by 12-column grid and a 256 KiB worksheet XML buffer.
- ANCL Sheet streams the XML parts through the Windows archive tool (`tar.exe`) without extracting a workbook tree or shipping a ZIP library. Windows 10 version 1803 or newer is recommended for XLSX import.
- Workbooks without the conventional `sheet1.xml` first worksheet, encrypted workbooks, macros, styles, date formatting, images, and charts are outside this initial reader.

Formula scope:

- Start a Cell Value or in-grid edit with `=` to create a formula, for example `=D2*125` or `=SUM(A2:C2)`.
- References cover `A1` through `L40`; arithmetic supports `+`, `-`, `*`, `/`, unary signs, and parentheses.
- Functions are `SUM`, `AVERAGE`, `MIN`, `MAX`, and `COUNT`, with ranges or comma-separated arguments.
- The grid displays calculated values while selecting the cell puts its formula source back in the editor.
- Formula errors display as `#DIV/0!`, `#REF!`, `#CYCLE!`, or `#ERROR!`.
- CSV save/export writes calculated values for compatibility. Formula source is therefore not preserved after saving and reopening a CSV.
- This first version does not rewrite references when rows or columns are inserted, deleted, or moved, and formula text is limited to 95 characters.

SQLite scope:

- `.db` / `.sqlite` browsing remains dependency-free. Writing first runtime-loads Windows' system `winsqlite3.dll`, then tries a side-by-side `sqlite3.dll` fallback.
- The table dropdown lists user tables only; SQLite-owned tables such as `sqlite_sequence` remain visible in Schema but are intentionally excluded from the dropdown.
- `Schema` shows `type`, `name`, `table`, `rootpage`, and `sql`; `View` opens the selected table.
- `Previous` and `Next` page through table rows without introducing a SQLite DLL dependency.
- Sorting affects only the current in-memory page and never changes the database; reload the page before editing a sorted view.
- Database CSV export includes the header plus only rows matching the active filter.
- Database pages are read on demand, so the executable stays small and databases are not limited to the CSV buffer size.
- The native grid currently displays up to 12 columns and discovers up to 16 user tables.
- SQLite overflow payloads are reported as overflow rows rather than decoded in this first browser version.
- Double-click a value or use Cell Value + Apply to stage an edit on the current table page. Header cells remain read-only.
- Save creates `<database>.bak`, opens the database read/write, applies every staged value update inside `BEGIN IMMEDIATE`, and commits only if all updates succeed. Failure triggers `ROLLBACK`.
- Save As accepts `.db` / `.sqlite` to copy the full database and apply staged edits to the copy, or `.csv` to export the filtered page.
- Unsaved database edits block table/page navigation and opening another file so staged row identities cannot be lost.
- Value editing uses SQLite `rowid`; inserts, deletes, NULL assignment, BLOB editing, schema changes, and `WITHOUT ROWID` tables are outside this first write-enabled version.
- Windows 10 version 1511 or newer is recommended because it supplies `winsqlite3.dll`; no SQLite file needs to ship with ANCL Sheet on supported Windows systems.
- On older or unusual systems, place `sqlite3.dll` beside `ancl_sheet.exe` to enable database writes as a fallback.
- If neither provider is available, ANCL Sheet reports that writing is unavailable while CSV work and dependency-free SQLite browsing continue normally.
- Help > About reports the active writer provider: Windows WinSQLite, side-by-side fallback, or unavailable.

Recent-file scope:

- The last three successful CSV or SQLite opens are kept in most-recent-first order.
- History is stored portably beside the executable in `ancl_sheet_recent.txt`.
- Reopening an existing entry moves it to the top without creating duplicates.

Windows Defender / public release note:

- Small unsigned native tools can trigger Defender false positives, especially when they are newly built and uncommon.
- For public sharing, submit the exact release `.exe` to Microsoft Security Intelligence as a software developer and choose "Incorrectly detected as malware/malicious" if Defender flags it.
- Record the SHA-256, detection name, Defender definition version, source repository URL/commit, and a short explanation that the tool is a native ANCL Win32 CSV/SQLite viewer with no network behavior.
- When a signing certificate is available, sign releases consistently. Microsoft states consistent signing with a trusted-root certificate helps their research systems identify the publisher and apply prior knowledge.
- Do not pack, compress, or obfuscate the release executable; those patterns make false positives more likely.

Scope note: the C# Nexus Editor also opens/saves `.xlsx` through ClosedXML/OpenXML. ANCL Sheet is deliberately CSV-native plus a compact SQLite browser/editor for now; matching XLSX support needs a future native ZIP/XML/OpenXML library stack.
