# Aether Studio bundle manifest

- `bin/` — runnable IDE, ANCL compiler, Aether Engine binary, offline completion artifacts, configuration, and helper tools.
- `core_lib/` — bundled ANCL libraries used by projects and templates.
- `starters/` — industrial-protocol starter programs.
- `templates/` — general ANCL project templates.
- `src/` — inspectable Studio source snapshot. Internal offline-completion source modules used by the original build are not included in this standalone binary bundle.
- `guide.html` and `HELP.md` — offline and Markdown documentation.
- `aether_studio.ico` — application icon.
- `LICENSE` — MIT license for the included bundle files.

Large GGUF chat models are intentionally not included. Studio can use Aether Engine, Ollama, or a configured remote endpoint.
