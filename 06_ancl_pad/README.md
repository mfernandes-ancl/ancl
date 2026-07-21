# ANCL Pad

Native multi-language text/code editor and ANCL build workspace.

V1 includes:

- ANCL, Python, C#, JSON, XML, HTML, SQL, Markdown, INI, PowerShell, log, and text syntax modes
- Python f-string and dotted-decorator coloring
- C# attribute, generic/type, interpolated, and verbatim-string coloring
- Extension-based language auto-detection
- `View > Language` selector for manual coloring mode overrides
- Line-number gutter
- Custom native File/Edit/Build/View/Help menu buttons
- ANCL Sheet-style branded header, custom menu buttons, framed tools/editor/output, and unified status panel
- Open, close, save, save as, new, and load sample
- Unsaved-change confirmation when closing a document
- The three most recently opened files in the File menu
- Up to eight open documents in native tabs
- Independent text, modified state, language mode, caret, and scroll position per tab
- Automatic detection of ANSI, UTF-8, UTF-8 BOM, and UTF-16 LE documents
- Per-tab encoding conversion through `View > Encoding`
- Automatic CRLF/LF/CR detection and per-tab conversion through `View > Line Endings`
- Unicode text is preserved internally as UTF-8 while switching tabs and saving
- Session restoration for open file paths, order, and active tab
- Automatic 15-second recovery snapshots for unsaved tabs, with restore/discard on the next launch after interruption
- `Ctrl+Tab` and `Ctrl+Shift+Tab` tab navigation
- Per-tab close buttons with unsaved-change protection
- `File > New From Starter` for ANCL protocol/app templates
- `Edit > Insert Import` for common bundled core libraries
- Keyboard shortcuts for common editor commands
- Find, Find Next, Replace, Replace All, and Go To Line
- Recursive case-insensitive Find in Files with an editable folder scope
- Clickable file-search results that open the matching file and source line
- Per-document line bookmarks with gutter markers, wraparound navigation, and clear-all
- Read-only side-by-side file comparison with independent syntax coloring, line numbers, selection, and scrolling
- Build menu with Compile, Run, and a captured output pane
- Colorized compiler/run output pane
- `View > Value Converter` for auto-synced unsigned Dec/Hex/Bin/BCD conversion
- Smart mechanical `Build > Fix` using `compiler/anclc.exe --fix --write`
- Clickable compiler diagnostics that jump to a reported `line N`
- Matching bracket-pair highlighting at the caret
- Text selections, including Find results inside brackets, remain intact while bracket highlighting is suspended
- Status line with line/column and modified state
- Status line also reports the active document encoding and line-ending style
- Bundled `core_lib/` helpers for portable ANCL coding
- Root-synchronized `core_lib/`, including JSON, Goose, IEC 61850, and shared UI helpers
- Offline HTML user guide from `Help > User Guide` or `F1`
- Protocol-aware log highlighting for common industrial/tester messages, including Modbus function/field terms and Omron FINS command/header vocabulary
- Build actions remain ANCL-only; every other language is an editor/coloring mode
- Find in Files scans common text/code extensions, skips heavy generated folders, and caps a search at 500 results or 5,000 files

Portable bundle layout:

```text
ancl_pad/
  bin/ancl_pad.exe
  bin/guide.html
  bin/ancl_pad_session.txt   created automatically
  bin/ancl_pad_recovery*     present only while unsaved recovery data exists
  compiler/anclc.exe
  core_lib/        reusable ANCL libraries and starters
  programs/        compiled .exe and .asm files
  sample.ancl
  README.md
```

Share the whole `ancl_pad` folder. `Build > Compile`, `Build > Run`, and
`Build > Fix` use `compiler/anclc.exe`; compiled outputs are written to
`programs/`. Programs saved in the bundle root can import libraries with paths
such as:

```ancl
import "core_lib/cstring.ancl";
import "core_lib/gui_v2.ancl";
```

Build:

```powershell
# Run from this 06_ancl_pad folder.
.\compiler\anclc.exe .\src\ancl_pad.ancl .\bin\ancl_pad.exe
```

Run:

```powershell
.\bin\ancl_pad.exe
```

Possible next additions should remain editor-focused, such as converter width/signed modes or a compact library browser. Compile/Run/Fix remains ANCL-only.
