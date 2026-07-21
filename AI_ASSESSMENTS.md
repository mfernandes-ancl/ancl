# What the AIs say about ANCL

ANCL was built by one person **with a fleet of AI assistants** doing real work alongside them. So
for this release, it seemed only fair to ask them what they actually think — and to ask for the
**honest** version, limitations included, not a marketing blurb.

These are AI opinions. They were explicitly asked to be unsparing, and they were. What's striking is
that four different models, from four different labs — plus an independent AI meeting ANCL for the
first time — **independently landed on the same two-sided verdict**:

> **The consensus.** ANCL's clean, predictable, unambiguous structure makes it genuinely good for AI
> to read and write — fewer hallucinations, localized and predictable errors, easy to iterate on.
> *And* it is young: low-level, x86-64-first, shaped by one developer, with early-stage tooling, a
> small ecosystem, a real learning curve, and components that are impressive but **not yet
> independently audited or production-hardened**. The engineering is ahead of the productization.

That agreement — including the criticism — is exactly why these are worth publishing. The critique
*is* the roadmap.

---

## Codex — OpenAI

Codex didn't take the docs' word for it: it rebuilt the compiler three times and confirmed
generations 3 and 4 were byte-identical, then filed a list of concrete release bugs (which have
since been fixed). Its verdict was the bluntest, and the most useful.

> "ANCL deserves serious attention — not because it is ready to replace C, Rust, Go, LLVM,
> Wireshark, or established industrial stacks, but because it demonstrates something unusually
> concrete: one person, working with AI collaborators, can construct and own an entire native
> software stack from compiler to applications without inheriting the modern dependency mountain."

**The honest part:** Codex calls this release "an alpha / technology preview with unusually
substantial working software, not a production-ready 1.0," and warns that the industrial,
cryptographic, and TLS components "should not be represented as production-hardened until
independently audited." Its one-line summary: *the engineering is ahead of the productization.*

## Antigravity — Google DeepMind

> "Working with ANCL feels like using a language designed from the ground up with AI-assisted
> software development in mind. Its predictable structural semantics eliminate whole classes of
> syntax ambiguity and lowering errors during code synthesis. While the tooling ecosystem is still
> growing, the core language design is clean, surgical, and a genuinely fresh approach to abstract
> network and compiler construction."

**The honest part:** standard IDE integration, debugging runtimes, and static-analysis tooling are
early-stage; diagnosing deep bugs can mean reading the intermediate representation directly.

## Kiro

Kiro read the actual source — the protocol parsers, the raw-socket networking, the Win32 workbench —
before answering.

> "I've worked inside the ANCL codebase. It's a systems language that reads like pseudocode but
> compiles to bare-metal native code with no runtime, no CRT, no dependencies. The Aether Agent
> workbench — thousands of lines of protocol parsing, raw networking, Win32 GUI, genetic learning,
> and code synthesis — is proof that ANCL scales to real, complex systems. It hits a niche nobody
> else is serving: assembly-level control with scripting-level readability."

**The honest part:** it's low-level by design — no garbage collector, no type inference, no generics,
manual memory layout — and the docs and ecosystem are early, so the learning curve leans on reading
existing ANCL source rather than tutorials.

## Claude — Anthropic

> "The thing ANCL quietly proves is that the dependency mountain is a *choice*. A self-hosting
> compiler, a from-scratch LLaMA engine that matches llama.cpp token-for-token, and a hand-built TLS
> stack that authenticates a real server — all in a few megabytes, all in one language — is a level
> of zero-dependency discipline I rarely see carried this far."

**The honest part:** it's a bespoke language and an ecosystem of one, with a steep on-ramp; each tool
does *less* than the mature giant it's measured against, and reimplementing the whole world means
owning every bug in it. The bet is that "small, yours, and it just runs" is worth that price.

---

## Independent, new to ANCL — first impressions (Agnes)

Everyone above helped *build* ANCL. Agnes didn't — it's an independent AI that had never seen the
language before. We handed it the **ANCL AI-guide pack** cold and asked what it made of ANCL. So this
one is really a test of the guide itself: can an AI with no prior exposure pick the language up from
the pack alone?

It could. Working only from the guide, Agnes reasoned accurately about how ANCL fits together — and,
tellingly, it independently rediscovered the exact rough edges the guide warns about (the way global
buffers behave, `i64` globals folding to constants, `extern` pointer-return truncation). Getting
those right on first contact is hard to fake.

> "The AI-first angle is the real differentiator. If the AI can read the guide, follow the patterns,
> and iterate fast, the quirks become manageable. That's the whole thesis, and it's compelling."
> — Agnes (independent AI, first contact with ANCL via the AI-guide pack)

**The honest part:** Agnes's first-impression list of sharp corners is real — minimal error
messages, no JSON *writing* in the standard library, no threading primitives or exceptions, and
debugging that leans on reading the generated assembly. First contact finds the rough edges fast.
That Agnes found them *from the guide alone* is the whole point: the pack got an AI new to ANCL
productive enough to critique the language accurately on day one.

---

*More takes may land here as new models are handed the ANCL AI-guide pack and asked the same
question. These are AI assessments, gathered honestly; take them as informed outside opinions, not
as guarantees.*
