---
title: "Modernizing Legacy Code with Vibe Coding (1/2): 20-Year-Old C/C++ Applications"
date: 2026-10-16T10:00:00+09:00
draft: false
toc: false
images:
tags:
  - vibe-coding
  - legacy-modernization
  - cpp
  - rust
  - agentic-dev
---

> Agents struggle with legacy C/C++ not because the code is complex, but because they have no way to check whether what they did is correct. The first investment in modernization is not a language migration but a verification environment.

{{< figure src="/posts/images/Dohyun.png" title="Dohyun Jung - Principal Consultant, ROBOCO" style=".author-image">}}

---

When I consult on vibe coding adoption, I often hear the same complaint: "Our project is too complex. The agent can't do what we ask it to do." At first, I assumed the cause was a specialized domain or poorly written prompts. But as the cases piled up, a common thread emerged. Most of the teams saying this were working on **C/C++ codebases more than 20 years old**.

The same teams were using agents effectively on newly built Python tools and web admin consoles. So it is more natural to conclude that the problem lies in the codebase rather than in the team's skills or the agent itself. In this post, I lay out how to modernize such legacy projects with vibe coding, drawing on public case studies and research. The source material consists of public case studies, papers, and tool documentation surveyed as of October 15, 2026, and I note that each figure is self-reported by the organization that published it.

This post is the first in a two-part series on modernizing legacy codebases. Part 1 covers legacy applications written in C/C++, and Part 2 will cover modernization strategies for legacy web applications written in PHP.

## TL;DR

- The main reasons agents fail on legacy C/C++ are that the build can't be reproduced, pointer ownership is not expressed in the code, and there are no tests to verify changes (this is my interpretation, based on consulting experience).
- The published success stories (Google giflib, Wiz fastText, Rukuzu) all replaced **narrowly scoped modules under strong verification**. None of them translated millions of lines into another language in one go.
- The recommended approach is incremental modernization, not a full rewrite. Stabilize the existing core with Modern C++, and selectively move only modules with narrow boundaries and frequent memory defects to Rust or another language.
- Agents handle investigation, transformation, testing, and iterative fixes; humans own ownership design, compatibility decisions, and releases.
- The goal for the first 90 days is not a full migration, but to move one representative module into production and prove that the same procedure can be repeated.

## 1. Why Agents Get Lost in Legacy C/C++

A coding agent works in a loop: read the code, change it, run the build and tests, and check the result. If the last step of this loop, "check," is blocked, the agent cannot know whether its change is correct. In the 20-year-old C/C++ projects I have seen in the field, this loop was broken at several points.

First, **the build cannot be reproduced.** Build settings tuned to one developer's PC, vendor SDKs with unpinned versions, and dozens of preprocessor macros and conditional compilation paths are all tangled together. If the agent cannot run the build in a clean environment, it cannot even confirm that its change compiles. Moreover, the code that actually gets compiled for a given function differs depending on which macros are enabled. An agent that reads only the source files, without the real compile options, ends up reasoning from code paths that don't exist.

Second, **pointer ownership is not expressed in the code.** In old C/C++ code, a single `T*` may mean "I must free this object," or it may mean "I'm just borrowing it for a moment." That distinction lives not in the code but in the head of the original author from 20 years ago, or in a wiki that no longer exists. Even if the agent finds the call sites with grep, it cannot tell whether a callback runs after the object is destroyed, or whether a container reallocation invalidates a reference. So the agent's fixes may look plausible while introducing new use-after-free or double-free bugs.

Third, **there are no tests to verify changes.** Even when tests exist, they often cover only a handful of happy paths. Human developers have filled this gap with experience and manual testing, but an agent has no such safety net. As a result, the agent's generation speed only increases the **volume of unverified changes**.

In short, the diagnosis that agents fail because these projects are "too complex" is only half right. A more accurate diagnosis is that the agent has no means of judging whether it succeeded. That is why the first investment in modernization should not be a language migration, but **a verification environment where the agent can build both the original and the new implementation and compare them on the same inputs**.

## 2. What the Public Case Studies Actually Show

There are still few public case studies of modernizing C/C++ with agents, and the numbers are easy to over-read when taken out of context. The table below summarizes the major cases, noting what each figure proves and what it doesn't.

| Case | Source and target | Reported results | What these results do not prove |
|---|---|---|---|
| Google giflib[^1] | About 3,000 lines of C → Rust | Regression comparison on over 30 million GIFs, over 200 million differential fuzzing runs, performance-neutral | That large applications can be translated wholesale |
| Wiz fastText[^2] | About 20,000 lines of C++ → Go | 5,434 lines of Go in two days, 100% pass on the team's existing model validation tests | Equivalence across all APIs, platforms, and training features |
| Loxation Rukuzu[^3] | About 200,000 lines of Kuzu C++ → Rust | 15 crates and over 2,700 tests at the time of reporting | Completed functional equivalence for all 200,000 lines |
| Google ID type change[^4] | Cross-cutting change from 32-bit to 64-bit IDs | 74.45% of 595 changes generated by LLM, estimated about 50% reduction in total time | The effect of a full language replacement |
| Bun[^5] | Zig → Rust (not C++) | Over 1 million lines generated in under two weeks, all existing CI passed | Production equivalence (19 regressions found even after passing) |

A pattern repeats across these cases. Google picked a small library without SIMD or assembly, and aimed for a drop-in replacement that preserved the C ABI (the binary-level calling convention). After the initial translation, they found that memory management across the FFI (the cross-language call boundary) was unsound, and experts reviewed the unsafe code directly. Rukuzu had the existing C++ backend and the new Rust backend implement the same abstraction interface, so either could be selected via a build option. In both cases, the teams **first built a replaceable boundary, then compared the old and new implementations behind it**.

The Bun case offers a lesson from the opposite direction. Even after passing all existing CI tests, 19 regressions surfaced in production. The API-equivalent cost was about $165,000. It shows that passing tests is not the same as production equivalence, and that large-scale parallelization is expensive.

The research side tells a similar story. Studies on automated C→Rust translation (ORBIT, ACToR, RustAssure) report test pass rates of around 90% on small benchmarks.[^6] But these figures come from C programs averaging a few hundred lines. C++ templates, inheritance, exceptions, macros, static initialization, and plugin ABIs are a different class of difficulty, so these figures must not be read as the automated migration success rate for multi-million-line C++ products. Also, a translator like C2Rust is only a starting point that moves C code into functionally equivalent **unsafe Rust**. The mere fact that Rust files were generated and compiled does not mean memory safety has been achieved.[^7]

## 3. Five Principles Drawn from the Cases

**Don't treat language migration as the success metric.** Even if the code stays in C++, modernization has succeeded if ownership becomes clear and regressions go down. Conversely, if unsafe blocks have spread and FFI and upstream maintenance costs have grown after a move to Rust, the goal needs to be reassessed. Containerization or service decomposition helps with deployment and blast radius, but does not fix pointer defects themselves.

**Separate translation from redesign.** In the first phase, produce a verifiable migration that preserves structure and external behavior as much as possible. Improvements to ownership, data structures, and the concurrency model come in the next phase. If you do both at once, then when the output differs, you can't tell whether it's a translation mistake or the result of a design change. Anthropic's Code Migration Kit also defaults to structure-preserving migration.[^8]

**Split work between deterministic tools and agent judgment.** API substitutions and syntax fixes that can be precisely identified via the AST (abstract syntax tree) go to deterministic tools like clang-tidy or Clang LibTooling. The agent drafts transformation rules, handles exceptional cases, analyzes failure causes, and strengthens tests. Google's ID change case followed the same structure: static analysis and code search located the change sites, an LLM made context-aware edits, and automated verification preceded human acceptance.[^4]

**Keep tests and acceptance criteria independent of the implementing agent.** If the implementing agent can change expected values, tests, or acceptance criteria, it may take the easy path of relaxing tests to make them pass. Separate out a verification role that generates new inputs, and keep holdout data that is not used during implementation.

**Feed the agent the evidence it needs, not the whole repository.** Instead of stuffing millions of lines into a prompt, provide the real build settings, symbol definitions and references, module contracts, failure logs, and relevant tests. Rules discovered during the work should be recorded in files, not left in chat memory. The next section covers this principle in more detail.

## 4. Making the Codebase Readable for Agents

For an agent to handle legacy code well, it first needs access to the same level of information as a human developer. The starting point is recovering the actual compile options. For a CMake project, generate `compile_commands.json`; for other build systems, collect the compile commands with a tool like Bear. With this file, a language server such as clangd can return accurate definitions, references, and type information that reflect macros and conditional compilation. However, with MSVC-specific extensions or cross-compilation, Clang-based analysis may differ from the real build, so you should mark which build variant each analysis result applies to.[^9]

Next, put documentation for the agent inside the repository. These documents are just as useful for new human developers.

| Document | Contents | When to update |
|---|---|---|
| Operating rules such as `AGENTS.md` | Build and test commands, forbidden changes, completion criteria | When the toolchain or verification policy changes |
| Module contracts | Inputs/outputs, errors, ownership, threading, ABI | When an interface changes |
| Symbol mapping ledger | Mapping between original and new symbols, progress, gaps | Each time a task is completed |
| ADRs (architecture decision records) | Decisions on language, boundaries, exceptions, and performance, with rationale | When a design decision is made |
| Defect corpus | Minimal reproducing inputs and regression tests | When a new defect is found |

The Rukuzu case illustrates this approach well. The team summarized progress at every session, cross-checked original and new symbols, documented differences and ownership decisions, and then implemented in dependency order. They ran build, test, and clippy at every step, and kept accumulating the pitfalls they discovered in a command document.[^3] This way, even when the agent's context is reset, the next session doesn't repeat the same mistakes.

## 5. The Core Challenge: Pointers and Object Lifetimes

The hardest part of modernizing legacy C/C++ is uncovering pointer ownership. Telling an agent to "replace raw pointers with smart pointers" across the board is dangerous. For each pointer, you must first establish where it is created, who owns it, how it is freed, its aliases (other pointers to the same object), where it is stored, which threads access it, and its asynchronous termination conditions. The table below shows the default migration direction for each existing pattern.

| Existing pattern | Default migration | Caveats |
|---|---|---|
| Solely owned `T*` | Value type or `unique_ptr` | Identify existing free paths and aliases first |
| Genuinely shared ownership | `shared_ptr`, and `weak_ptr` where needed | Reference cycles and data races are separate problems |
| Temporary non-owning reference | Reference or non-owning pointer | Contractually forbid storing it beyond the original object's lifetime |
| Buffer and length | `vector`, `array`, `span` | `span` is non-owning and does not prove lifetime |
| C SDK handle | Dedicated RAII wrapper | Always use the matching release function and allocator |
| Asynchronous `this` capture | Cancellation, join, weak references | Design unsubscription and shutdown order |

RAII is the C++ technique of tying a resource to an object's lifetime so that it is released automatically. It applies not only to memory but also to files, sockets, locks, threads, and event subscriptions. However, frameworks have their own lifetime rules, such as Qt's QObject parent-child ownership, COM reference counting, and Unreal reflection. Such code must not be uniformly replaced with standard smart pointers.

So I divide the roles like this. The agent traces call, storage, release, and callback paths and produces an ownership table with evidence attached. A human reviews that table and approves the final lifetime design. Lifetimes that could not be confirmed are left as "unresolved," and the instructions explicitly state that the agent must not make changes without evidence. Changes that swap `malloc`/`free` and `new`/`delete` pairs, or that free Rust-allocated memory with C's `free`, are also explicitly forbidden.

Be careful with completion criteria, too. Success is measured not by a reduced count of raw pointers, but by clarity of ownership, defect-reproducing tests, and the absence of new analysis warnings. Raw pointers remaining at non-owning boundaries can be acceptable.

## 6. Which Language Should You Move To?

Not every module needs to move to the same language. The table below shows the default choice by module type, and the conditions under which a different choice is warranted.

| Target | Default choice | When a different choice is needed |
|---|---|---|
| Existing core | Stabilize with Modern C++ (C++17/20) and RAII | Consider Rust if memory defects persist and boundaries can be separated |
| Input parsers and protocols | Rust pilot behind a narrow interface | Improve the C/C++ first if ABI constraints are heavy or verification data is lacking |
| Business logic and admin features | A managed language suited to the deployment environment (C#, Java, Go, etc.) | Stay native if real-time, memory, or call-overhead constraints are strict |
| Engines that are hard to modify | Isolate behind an adapter or in a separate process | Use an in-process boundary if IPC latency and data copying are unacceptable |

Even when choosing Rust, the paths for C and C++ differ. C-centric modules can be turned into functionally equivalent unsafe Rust with C2Rust and then gradually converted to safe code. For C++-centric modules, it is more realistic to establish a boundary with a narrow C ABI or an interop layer like CXX, and then reimplement in idiomatic Rust according to the interface contract. Avoid mechanically adding `Rc`, `Arc`, and `Mutex` just to get past the borrow checker. That merely hides the original ownership problem in a different form.

When changing languages, also check for differences in numeric handling. Integer overflow, floating point and NaN, endianness, encoding, and locale behavior vary across languages. Behavior that happened to hold in C/C++, or undefined behavior (UB), may change in the target language.

## 7. Step-by-Step Procedure and Exit Criteria

Modernization proceeds through the stages below, and each stage requires evidence before moving on to the next. The stage names are defined for this post.

| Stage | Work by humans and agents | Exit criteria |
|---|---|---|
| G0 Reproduce | Pin toolchain and dependencies, CI build | Build and test logs of the baseline version in a clean environment |
| G1 Understand | Analyze business flows, symbols, and ownership | Contracts confirmed by the owner, plus a list of uncertainties |
| G2 Protect | Characterization tests, failure reproduction, comparison harness | The original can be run repeatedly on the same inputs |
| G3 Design | Decide boundary, language, error, and threading policies | ADRs, interfaces, rollback plan, performance budget |
| G4 Transform | Small changes within a limited set of files | Build, static analysis, and regression tests pass |
| G5 Falsify | Differential execution, fuzzing, concurrency and performance verification | Zero output differences with unclassified causes |
| G6 Cut over | Shadow execution, canary, feature flags | Approved observability metrics and recovery procedures are met |
| G7 Settle | Remove the old version, documentation, upstream management | Owner and operating procedures for the new implementation confirmed |

The stages where agents really pick up speed are G1 (investigation), G2 (writing tests), G4 (transformation), and G5 (generating falsifying inputs). G0, on the other hand, often has to be led by humans, because securing internal SDK licenses, build server access, and vendor toolchains is not something an agent can solve. In my experience, many of the teams that say "the agent can't do the job" are stuck at G0.

Differential execution in G5 runs the original and new implementations on the same inputs and initial state, normalizes the results, and compares them. The comparison covers not just return values but also file and DB changes, error codes, output order, exit status, and memory usage. If the original contains UB, its execution results cannot be treated as the ground truth. So when a difference appears, classify it as a legacy defect, intended compatibility behavior, a new defect, or an environmental difference, and have the business owner and technical owner decide. The Google giflib team also found an out-of-bounds write in the existing C code during this process.[^1] There is no need to preserve the original's memory errors; record discovered defects as intentional behavior changes.

Set a limit on repair iterations. As a default, I suggest three repair attempts per task, or a predefined time and cost budget. If repeated failures, new unsafe blocks, ABI changes, output differences of unknown cause, or test deletions appear, stop the task and return to the diagnosis stage. Require completion reports to include the baseline commit, changed symbols, commands run with their exit codes, and test results. Checks that weren't run are left as "not run," and nothing passes on the agent's natural-language claims alone.

## 8. The First 90 Days, and When to Stop

Below is an example 90-day plan for migrating the first module in a large project. The actual schedule depends on how hard the build is to recover, the gaps in test coverage, and the number of supported platforms.

| Period | Work | Deliverables |
|---|---|---|
| Weeks 1–2 | Diagnose builds, dependencies, failure history, and tests | Baseline and 2–3 candidate modules |
| Weeks 3–4 | Build contracts, a reproduction corpus, and a differential harness | One pilot selected, language and boundary ADRs |
| Weeks 5–8 | Improve or port the module with iterative verification | A comparable new implementation and a defect ledger |
| Weeks 9–10 | Holdout, fuzzing, performance, and operational testing | G5 evidence and a rollback rehearsal |
| Weeks 11–12 | Shadow execution, canary, cutover, retrospective | Production results and a decision on expanding to the next module |

Good first pilot candidates are modules with clear inputs and outputs, such as parsers, converters, computational libraries, and standalone CLIs. Defer cores entangled with UI frameworks, global object graphs shared by multiple threads, and driver or authentication modules to the second round or later. Pick modules with high business value (failure and change frequency), clear boundaries, and high verifiability, and push back modules with high coupling and migration cost. Don't decide on scores alone; actually build the candidate module and run representative inputs to validate your assumptions.

Start simple with the agent setup, too. At first, a single primary agent performs the roles sequentially, with a separate session or person only for the verification stage. Scale the number of parallel agents to build resources and review throughput, not to the number of developers. Don't copy the hundreds-of-agents configurations from public case studies as your starting setup.

If the following conditions appear, don't add more agents; go back to the reproduction, contract, and decomposition stages.

- The build depends on a specific individual's environment, or the original cannot be run.
- No one can decide the expected behavior, and tests only pass when they are cut back.
- Unsafe blocks or shared mutable state keep growing.
- Changes to shared types cause every task to conflict with every other.

Some modules have target platforms, certifications, or vendor support that don't permit the target language, or for which a verification environment can't be built at all. For such modules, it is better to achieve the goal by improving the existing C/C++, isolating the process, or adopting a maintained replacement product instead of migrating languages.

## Closing Thoughts

"Our code is too complex for the agent" is really closer to "Our code is too complex for us to verify whether a change is correct." This problem existed long before agents arrived. Human developers simply filled the gap with experience and caution. Agents have no such experience to fill it with, so they expose the problem faster and more clearly.

That is why modernizing legacy C/C++ should start not by handing translation to an agent, but by building a verification environment in which an agent can work. Once you have reproducible builds, compile context, module contracts, and a differential comparison harness, agents can iterate on investigation, transformation, and falsification far faster than humans. This structure points in the same direction as the [software factory](/en/posts/beyond-vibe-coding-software-factory/) discussed on this blog.[^10] In particular, as covered in [factories that filter by evidence](/en/posts/software-factory-evidence-before-fix/), the bar for accepting a change should be execution evidence, not the agent's claims.[^11]

The schedules, thresholds, and configurations in this post are proposals based on public case studies. Before applying them, diagnose the actual repository and adjust accordingly.

In the next post, I will cover strategies for modernizing legacy web applications, specifically those written in PHP, with vibe coding.

[^1]: Google Bug Hunters, "Scaling Memory Safety: AI Assisted Rewrites of C/C++ Dependencies to Rust" (2026-08-24): https://bughunters.google.com/blog/scaling-memory-safety
[^2]: Anthropic, Wiz customer story (self-reported by the customer): https://claude.com/customers/wiz
[^3]: Loxation, "Rukuzu: Porting a 200,000 line codebase from C++ to Rust" (2026-03-04): https://www.loxation.com/blog/posts/article_porting_workflow/
[^4]: Ziftci et al., "Migrating Code At Scale With LLMs At Google" (FSE 2025): https://arxiv.org/html/2504.09691 , Google Research blog: https://research.google/blog/accelerating-code-migrations-with-ai/
[^5]: Anthropic, "How Anthropic runs large scale code migrations with Claude Code" (2026-07-16): https://claude.com/blog/ai-code-migration
[^6]: ORBIT: https://arxiv.org/html/2604.12048 , ACToR: https://arxiv.org/html/2510.03879 , RustAssure: https://arxiv.org/html/2510.07604 . The three studies use different units and datasets, so their figures cannot be compared directly.
[^7]: C2Rust Manual: https://c2rust.com/manual/
[^8]: Anthropic, Code Migration Kit (explicitly stated to be reference code that is not actively maintained): https://github.com/anthropics/code-migration-kit-with-claude-code
[^9]: clangd installation and compilation context: https://clangd.llvm.org/installation
[^10]: Beyond Vibe Coding, Toward the Software Factory: https://roboco.io/en/posts/beyond-vibe-coding-software-factory/
[^11]: Software Factory Best Practices from Open-Source Projects (3/4): Factories That Filter by Evidence: https://roboco.io/en/posts/software-factory-evidence-before-fix/
