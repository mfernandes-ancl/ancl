# Aether Lens Local Knowledge Contract

Updated: 2026-07-14

This document defines the dependency-free R3 knowledge behavior. The user guide
explains the UI; this file records the storage, retrieval, and privacy contract.

## User control

- Lens indexes only a file or folder the user explicitly selects.
- Building a new index replaces the prior copied corpus.
- **Use indexed sources** pauses retrieval without deleting stored data.
- **Clear index** removes Lens's copied documents, manifest, and generated cited
  excerpts after confirmation. Original source files are never modified.

## Portable storage

The index is stored beside Lens:

```text
knowledge\
  index.txt              readable version/root/path/byte manifest
  documents\doc_N.txt   copied source text
  excerpts\cite_*.txt   exact passages exposed in chat citations
```

`index.txt` deliberately remains readable without Lens. Original absolute paths
are metadata; retrieval and citation previews use the portable copied text.

## Supported input and caps

- Plain-text TXT, Markdown, ANCL, CSV, JSON, XML, HTML, LOG, INI, CFG, YAML.
- 256 KiB maximum per source file.
- 4 MiB maximum copied corpus.
- 96 files and folder depth 6.
- Common generated/dependency folders are skipped.
- Files containing NUL bytes are treated as binary and skipped.

These are safety and context controls, not claims about document importance.

## Retrieval

1. Split copied documents into line-aligned chunks targeting 1,200 bytes with a
   hard ceiling of 1,800 bytes.
2. Tokenize the current question into lowercase word terms, discarding short
   terms and a small deterministic stop-word set.
3. Score bounded whole-word occurrences, with a small path/name bonus.
4. Keep only the three highest positive matches.
5. Add those passages to the current prompt with their original path and exact
   line range, instructing the model to cite them as `[K1]`-`[K3]`.

If every score is zero, Lens sends no corpus text and says so in the transcript.
There is no embedding model, vector database, background service, network call,
or opaque semantic threshold.

## Citation transparency

Each assisted turn records exactly which path and line range entered the prompt.
Lens writes the same passage to a portable excerpt and exposes it through a
`lens-knowledge:excerpts\...` link. Only the `excerpts\` relative root is
accepted; absolute paths, alternate schemes/separators, and traversal are
rejected before the native read-only viewer opens the file.

## Product boundary

Indexed content is read-only knowledge assistance. Selection does not authorize
Lens to edit source trees, compile code, run projects, or become an IDE. Those
workflows remain in Aether Studio and ANCL Pad.
