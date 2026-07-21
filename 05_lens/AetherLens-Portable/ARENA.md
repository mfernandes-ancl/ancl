# Aether Lens Model Arena Contract

Model Arena compares two installed local text models with one reproducible
prompt. Pressing the cyan **ARENA** button opens the complete workspace directly:
two installed-model dropdowns, a dedicated prompt field, Run Showdown, blind
answers, voting, and Options. It is a Lens feature; it does not add a new Engine
command or dependency.

## Fair input

- Both contenders belong to the same active local backend: Aether Engine or
  Ollama.
- Lens sends the exact same Arena prompt text and current Specialist system route
  to both models.
- Normal chat history, local-knowledge excerpts, and attachments are excluded
  from Arena V1 so neither contender receives hidden extra context.
- The Arena prompt remains in place after a run and the normal conversation and
  main composer are not modified.

## Contender selection

- Model A and Model B are chosen inside Arena from dropdowns populated by the
  active Aether Engine or Ollama installed-model list.
- Both selectors use the same flat dark field, border, custom arrow, dark popup,
  and highlighted selection language as Aether Studio.
- The aligned, outlined multiline prompt field shows a muted writing cue only
  while empty; the cue is presentation only and is never sent to a model.
- Lens automatically restores the last valid pair for that backend. If a saved
  model is unavailable, it selects the first two installed models when possible.
- The pair and prompt controls are locked during execution so a running request
  cannot be relabeled or redirected.
- Choosing a new valid pair clears the previous in-memory showdown before the
  next run; preference history is unaffected.

## Execution and hardware safety

- Runs are sequential by default and in the core implementation.
- Ollama receives two `/api/chat` requests with different installed model names.
- For Aether Engine, Lens switches only a local server process it owns, stops it
  between contenders, and restores the user's selected model afterward.
- Arena refuses to switch an external or remote Aether server because Lens does
  not own that process or its loaded-model state.
- Stop aborts the current request and preserves any partial result already
  received.

## Blind preference

- Blind mode is enabled by default and persisted.
- Left and right positions are shuffled for every run.
- The visible A/B selectors disclose the contender set, but not which shuffled
  answer pane belongs to A or B.
- Model identities remain hidden until the user votes Left, Right, or Tie.
- A completed showdown accepts one preference only.
- Turning blind mode off reveals model names but keeps sequential execution and
  input parity unchanged.

## Measurements

Each side shows prompt tokens, reply tokens, elapsed time, and tokens/second
from the same Ollama-compatible telemetry used by Lens Pulse. Measurements are
shown next to the answer and recorded with a vote.

## Local history and privacy

Preferences are written as readable TSV to `arena/preferences.tsv`. Each row
contains:

- local timestamp and backend;
- contender A/B and the actual left-side model;
- left/right/tie choice and resolved winning model;
- SHA-256 of the prompt;
- per-model tokens/second, reply-token count, and elapsed time.

The readable history is capped at 256 KiB; Lens asks the user to copy or clear
it before another vote rather than silently truncating old rows.

The prompt and full answers are deliberately not stored in preference history.
Arena Options can show history in Lens's read-only viewer, open its folder, or
clear it after confirmation. Clearing it does not delete models, chats, prompts,
attachments, or knowledge sources. Privacy Proof lists the exact history path
and exposes the same narrow clear action.

## Verification

`tests/test_arena_core.ancl` gates distinct-pair validation, shuffled-side vote
mapping, ties, invalid choices, and throughput calculation. The UI integration
gate uses `tests/mock_arena_server.py`, a deterministic local
Ollama-compatible server, to prove two sequential requests receive identical
prompt bytes, both panes render, a blind vote maps to the hidden model, history
is written, and no Aether Engine process is started.
