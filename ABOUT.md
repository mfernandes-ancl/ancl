# About ANCL — and the person who (accidentally) built it

Hi — I'm **Mário Fernandes**. By day I work in **Control & Instrumentation and SCADA**: the
software and systems that talk to PLCs, RTUs, meters, and gateways out in the field.

ANCL was not supposed to be *this*.

It started because I needed a small tool for a real problem at work. When I went to build it, the
tool wanted a runtime, a framework, a package manager, a pile of dependencies — far more machinery
than the actual problem deserved. On a locked-down field box, half of it wouldn't even install. So
I did the reasonable thing and wrote my own tiny native tool. Then I needed another. Then I
figured, if I'm going to keep doing this, I want a **language** that compiles straight to a small
native executable with *nothing else* — no runtime, no VM, no CRT, no dependencies.

That language is ANCL. And then, as the FAQ admits, things escalated.

**What I care about**, and what the whole project is really about:

- **Zero dependencies.** A tool should contain *software*, not a supply chain. One `.exe` you can
  drop on a machine and run.
- **Native and tiny.** The compiler emits x86-64 (and now Linux ELF) directly — no assembler, no
  linker, no LLVM.
- **It should just run.** No installer, no admin ceremony (except where the OS genuinely requires
  it), no "please update your runtime."
- **Industrial reality.** Real OT networks are messy and offline and locked down. The tools here
  are built for that world because that's the world I work in.

Along the way ANCL grew a self-hosting compiler, an IDE, a from-scratch AI inference engine, a pile
of industrial-protocol testers and simulators, and — because why not — some games and a 3D engine.
Most of it was built by one stubborn person with a lot of coffee and a fleet of AI assistants
doing real work alongside me.

## Credits — the fleet

ANCL was built by a human **with AI collaborators**, and I'd rather be honest about that than
pretend otherwise. The ones that did the most heavy lifting, day to day:

- **Claude** (Anthropic)
- **Codex** (OpenAI)
- **Antigravity / Gemini** (Google DeepMind)
- **Kiro**

— plus other models that helped test and stress the language along the way. The design decisions,
the stubbornness, and the bugs are mine; the pair-programming, the reviews, and a lot of the typing
were a team effort.

Because they helped build it, I also asked them for an **honest, unsugarcoated assessment of ANCL** —
strengths *and* limitations. Their answers (including the parts that sting) are in
[AI_ASSESSMENTS.md](AI_ASSESSMENTS.md). Worth a read if you want the outside view before you dive in.

If any of this is useful to you, brilliant. If you find bugs (you will, especially against real
hardware), please tell me — every tool keeps a save-log, so open an issue and attach it.

— Mário

**Get in touch:** mmc.fernandes101@gmail.com (for bug reports, please use GitHub Issues — it's the
fastest path to a fix.)

**Enjoying ANCL?** It's free and always will be. If it saved you from a dependency headache and you'd
like to buy me a coffee, there's a **❤ Sponsor** button at the top of the repo — never expected,
always appreciated.

- ☕ **Buy me a coffee / donate:** [PayPal.me/mmcfernandes](https://www.paypal.com/paypalme/mmcfernandes)
