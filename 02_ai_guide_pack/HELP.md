# ANCL AI-Guide Pack — Help

**Write ANCL by letting your AI assistant do it.** ANCL is a small, unusual language — so
instead of asking you to learn it first, this pack ships a guide *written for an AI*. Point your
assistant (Claude, Codex, Gemini, GLM, …) at `ANCL_AI_GUIDE.md` and it can read, write, and
debug ANCL immediately. This pack has everything you need to go from idea → running native
executable, with the AI in the loop.

---

## The workflow (this is the whole idea)

1. **Prime your AI.** Paste `ANCL_AI_GUIDE.md` into your assistant (or attach it / add it to the
   project context). That one file is distilled from the real compiler + test suite, so
   everything in it compiles.
2. **Describe what you want.** "Write an ANCL program that reads a file and prints line counts",
   "a TCP echo server", "parse this Modbus frame". The AI writes `.ancl` source.
3. **Compile it.**
   ```
   anclc myapp.ancl myapp.exe
   myapp.exe
   ```
4. **If it doesn't compile,** you have two fast paths:
   - paste the compiler's error back to the AI (the guide taught it the language, so it fixes
     its own mistakes), or
   - run `anclc --fix --write myapp.ancl` for mechanical fixes (declarators, `//`→`#`, etc.),
     then compile again.
5. **Iterate.** Native `.exe`, no runtime to ship — done.

That's the fastest on-ramp to a new language there is: you don't learn ANCL, your AI already
knows it.

## Quick start (no AI needed to try it)

```
anclc examples\hello.ancl hello.exe
hello.exe
```

See `examples/` for small programs (hello, fizzbuzz, structs, heap/strings, constants, infix
ops, and a `--fix` self-heal demo). Full compiler usage is in the guide and in the Compiler
bundle's help.

## What's in this pack

- `ANCL_AI_GUIDE.md` — the practical, AI-oriented language guide (the reference)
- `anclc.exe` — the compiler (native, zero-dependency)
- `core_lib/` — the standard library
- `examples/` — small, self-contained programs
- `HELP.md` (this) · `LICENSE`

## Tips for good results

- Keep the guide in context for the whole session — the AI stays fluent.
- ANCL compiles to Windows PE by default; add `--target=linux` / `--target=linux-dyn` for Linux
  ELF (tell your AI the target so it uses the right syscalls).
- When the AI is unsure, ask it to check its code against the guide's examples — everything in
  the guide is known to compile.
- For a full IDE experience (editor + build/run + AI repair built in), see the **Aether Studio**
  bundle.

## License

MIT © Mário Fernandes. See `LICENSE`.
