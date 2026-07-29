---
title: "Surprisingly, the Ralph Loop Is 9x Cheaper - The Economics of Context Caching"
date: 2026-07-26T10:00:00+09:00
draft: false
toc: false
images:
tags:
  - vibe-coding
  - claude-code
  - token-optimization
  - prompt-caching
  - context-engineering
---

> A single-session loop that just states a goal and runs until done finished the same task at one-ninth the cost of a plan-driven workflow. The secret isn't the loop — it's the cache.

{{< figure src="/posts/images/Dohyun.png" title="Dohyun Jung - Principal Consultant, ROBOCO" style=".author-image">}}

---

The Ralph loop is a simple approach. You specify only the goal and the completion criteria, then let the agent iterate autonomously in a single session until it passes the completion check. No plan document, no task decomposition, no handoff notes between sessions. At first glance it looks unplanned and inefficient.

As vibe coding becomes the norm, many organizations are running short on tokens. I covered token management strategies in an earlier post[^1], but most of those prescriptions were rules of thumb. So we built an experiment repository, [vibecoding-token-experiments](https://github.com/roboco-io/vibecoding-token-experiments)[^2], to put those rules of thumb to the test. It maintains a catalog of hypotheses about token usage and measures them one at a time under controlled conditions, on a fixed benchmark task — implementing the RealWorld App[^3] backend — across three axes: workflow strategy, token habits, and language.

The first axis was workflow strategy. When we measured it, this simple Ralph loop approach completed the same task **roughly 9x more cheaply** than a plan-driven workflow. This post presents the results of the four experiments we've run so far, along with an explanation of **how prompt caching actually works** — the real mechanism that makes the Ralph loop cheap.

## 1. The Experiment: Ralph Loop vs. Plan-Driven Workflow

The shared task is implementing the RealWorld App backend. It requires implementing the REST API of a Medium clone to spec and passing 100% of the official API tests to count as complete. The model was fixed to Claude Opus alone to eliminate confounds from model differences, and the tool was Claude Code. Measurement aggregated the usage fields in session logs, using **billable tokens** (input + output + cache_creation) as the metric.

Here are the two workflows we compared:

- **Ralph loop**: specify only the goal and completion criteria, then let the agent iterate autonomously in a single session until it passes the completion check
- **Plan-then-execute (PTE)**: decompose tasks and document interface contracts in a planning session, then spin up an independent session per task to implement

Before we start, let's be clear about the scope of this experiment. RealWorld App is **a task with fully fixed requirements.** The API spec and the tests are already given, so what the agent does is pure implementation. In real development, by contrast, agents are typically brought in from the requirements-definition and design stages, and at those stages exploration and the planning artifacts themselves are the point. So what this experiment measures is not "is planning necessary" but **the effect of context caching and the cost efficiency of the Ralph loop at the implementation stage.** It looks at how much workflow and context structure drive token cost when what to build is already decided.

## 2. Results: The Ralph Loop Was About 9x Cheaper

| Metric | Ralph loop | Plan-then-execute |
|------|-----------:|------------------:|
| Completion check | Pass | Pass |
| Wall-clock time | **14 min** | 49 min |
| Sessions | **1** | 16 |
| output tokens | **90,877** | 797,845 |
| cache_creation tokens | **233,687** | 2,040,513 |
| **billable total** | **324,775** | **2,839,815** |

Both conditions passed 100% of the API tests. Quality was identical; cost diverged. The Ralph loop finished in 14 minutes, one session, about 320K tokens. On a billable basis that's **1/8.7** of PTE, and 1/3.5 on time. A single PTE planning session (about 360K tokens) cost more than the Ralph loop's entire run.

Breaking down from the logs what costs the Ralph loop avoided, there are four:

1. **Fixed session startup cost**: every time you open a new session, the system prompt and tool definitions are freshly loaded into context. The measured startup tax was about 20.6K tokens per session. PTE had 16 sessions, so it paid 330K tokens; subtracting Ralph's single instance (about 21K), the difference alone — about 310K tokens — nearly matches Ralph's entire run cost (325K).
2. **Re-reading the same files**: each PTE session starts out seeing the repository for the first time. It re-read `src/app.ts` 7 times and the same spec document 5 times. Ralph never re-reads what it has already seen within one context. Read calls were 2 for Ralph vs. 49 for PTE; verification Bash calls were 35 vs. 186.
3. **The production cost of documentation continuity**: 44% of PTE's output was not code but documents for transferring knowledge between sessions (specs, completion records). For Ralph this cost is zero, because the context itself is a living handoff document.
4. **The paradox of atomic decomposition**: in PTE, the smallest task — a single GET endpoint — burned 156K tokens. That's close to half of Ralph's total. The smaller the task, the more the fixed costs (startup tax + getting oriented in the repo + independent verification) dominate.

## 3. The Secret Is Prompt Caching: How It Works

The Ralph loop didn't win because the loop structure is superior. **It won because it reused a context it built once, through the prompt cache, all the way to the end.** Once you understand this mechanism, the result becomes obvious.

**Principle 1: The cache stores the front of the prompt (the prefix) wholesale.** Claude API's prompt caching[^4] caches a contiguous span starting from the very beginning of the prompt. The key is a hash of the content, so if a byte-identical prefix arrives again, the model loads the server-side stored state as-is without reprocessing. In the usage field, `cache_creation_input_tokens` is the tokens newly written to the cache on this request, and `cache_read_input_tokens` is the tokens read from a cache hit.

**Principle 2: Agent conversations are structurally cache-friendly.** An agent's conversation accumulates append-only. Since it never modifies earlier turns and only appends at the end, the entire history up to that point is always a stable prefix. The result is that every turn is billed as "everything before = cache read, only this turn's new input and output at full price." Claude Code automatically caches the system prompt, tool definitions, and conversation history, so there's nothing for the user to configure.

**Principle 3: A cache read costs 0.1x full price.** A cache write carries a small premium at 1.25x base input (on the 5-minute TTL), but a read is only about **0.1x**[^5]. On top of that, the 5-minute TTL resets for free on every hit, so as long as the agent keeps taking turns within 5 minutes, the cache stays alive for the whole session. A single hit is enough to break even.

**Principle 4: The cache is keyed on prefix content, not on the session.** This is exactly why a new session is expensive. Parts that are common across sessions — the system prompt and tool definitions (the ~20.6K startup-tax region measured above) — can be reused if you're within the TTL, but **the conversation history and the files read differ per session**, so that portion is rebuilt as a cache write (1.25x) every time. The cache also has a tools → system → messages hierarchy, so changing tool definitions or the model invalidates everything below it.

Plug these four principles into the measurements and the numbers explain themselves. Ralph's single session (112 messages) racked up 8.4M cache-read tokens. That's the trace of what would have cost full price to reprocess the same context 112 times, absorbed at 0.1x. PTE, by contrast, restarts the prefix every session, so cache_creation exploded to 2.04M tokens (8.7x Ralph's).

The billable metric is an approximation that excludes cache reads, so converting to something closer to the actual bill using Opus rates (input $5/M, output $25/M, cache write $6.25/M, cache read $0.5/M) gives this:

| | Ralph loop | PTE | PTE + Skills |
|---|---:|---:|---:|
| output | $2.27 | $19.95 | $8.71 |
| cache write | $1.46 | $12.75 | $8.59 |
| cache read | $4.21 | $21.26 | $13.44 |
| **Total** | **~$7.9** | **~$54.0** | **~$30.7** |

(The "PTE + Skills" condition in the table is covered in section 4.)

In dollar terms too, the Ralph loop costs 1/6.8 of PTE. One thing worth noting is that even in a single session, cache read is the largest cost line item (53% of Ralph's). Even at 0.1x, you read the entire history every turn, so as the session lengthens the cost accumulates on a quadratic curve. There's no free lunch in the Ralph loop either. This is the quantitative basis for the advice to run `/compact` at the right moments.

## 4. When Splitting Is Unavoidable: Skill-Style Progressive Disclosure

If a task doesn't fit into a single session's context, splitting is unavoidable. We ran an experiment on the prescription for that case too. We applied **Skill-style progressive disclosure** to the same PTE workflow: the planning session wrote domain-level contracts (error strings, validation order, shared infrastructure conventions) as Skill documents of 200 lines or fewer, and each task session loaded only the Skills it needed, when it needed them.

| Metric | Baseline PTE | PTE + Skills | Change |
|------|--------:|----------:|-----:|
| output tokens | 797,845 | 348,232 | -56% |
| billable total | 2,839,815 | 1,723,575 | **-39.3%** |
| Rework loops | 3 sessions (336K) | **0** (passed first try) | -100% |

The workflow was identical and only the context structure changed, yet **it dropped 39.3%.** Limiting what each task session reads to "its own spec + the Skills it needs" eliminated re-reading (Read calls 49 → 25, with 41 Skill invocations), and because the contracts were explicit, it passed the verification gate on the first attempt, wiping out 336K tokens of rework cost entirely.

The interesting part is the experiment in the opposite direction. When we gave the same Skills to **a single-session Ralph**, we couldn't confirm any effect (n=2; a mean difference of +3.5% was entirely buried in the 200K within-condition variation). The reason was clear. A session performing the whole task by itself needs all the contracts anyway, so there were 0 Skill tool invocations — it just read all the Skill documents at the start of the session. Progressive disclosure's savings mechanism only works **when a session needs only a subset of the total context.** Put the other way: a single-session Ralph loop is already near-optimal from a caching standpoint, with no context structure left to tune.

## 5. Why You Need to Know the Size of the Noise

In a separate experiment, we also tested the hypothesis that "running the whole process in English uses fewer tokens than Korean." As a static measurement, the effect is real. Tokenizing documents with the same content, Korean is 2.76x larger for prose and 1.39x larger for a mix of tables and code. In actual work, however, the language effect (mean difference ~29K) was buried in run-to-run trajectory variation (up to 138K), making it impossible to call.

Two runs executed under identical conditions diverged by 1.7x in tokens (191K vs. 329K), and in the fourth experiment by as much as 2x (199K vs. 400K). How deeply the agent "decides" to dig into the spec's edge cases was a far bigger cost variable than language. The fact that most of the output is language-neutral code also lowered the ceiling on the language effect.

This observation has practical implications in its own right. Variation in an agent's work trajectory is constant noise on the order of hundreds of thousands of tokens, so a savings technique at the 10% level cannot be validated by comparing one or two runs. If someone tells you "this setting cut tokens by 15%," the first thing to ask is how many runs that average covers. Conversely, effects like the Ralph loop's 8.7x or Skills' -39.3% exceed this noise band by several multiples, so a single run won't flip the direction.

---

## Conclusion

One conclusion runs through all four experiments. At the implementation stage with fixed requirements, **the dominant variable in token cost is not workflow sophistication but context (cache) reuse.** The Ralph loop's 9x efficiency isn't magic inherent to the loop; it's a direct consequence of the caching structure — "append-only history = stable prefix = 0.1x reuse." Distilled into practical guidance:

1. **If a task with a settled implementation fits in a single session, run it in a single session.** The moment you split sessions, fixed startup costs and context-rebuilding costs accumulate, making the same task 6–9x more expensive.
2. **If splitting is unavoidable, structure your context as Skills.** Making each session load only the subset it needs can cut the tax of splitting by close to 40%. But it has no effect on a single session that needs the whole context — that side is already optimal.
3. **Very long single sessions get expensive again.** Cache reads aren't free; they're billed at 0.1x and accumulate on a quadratic curve. A well-timed `/compact` is quantitatively justified.
4. **Variables at the 10% level, like document language (Korean vs. English), are far smaller than those two decisions.** Because run-to-run variation is larger than that, the right order is to settle workflow and context structure first.

This isn't to say planning is pointless. These results are limited to the implementation stage with fixed requirements and don't generalize as-is to stages like requirements definition or design, where exploration and consensus are themselves the goal. And the plan documents, interface contracts, and per-task completion records that PTE leaves behind are assets — from a maintenance and handoff perspective — that Ralph never produces. As far as the implementation stage goes, though, the approach that looks simplest meshed exactly with the caching structure and came out cheapest. In an era where tokens have become an organizational bottleneck, judging your cost structure by intuition instead of measurement is the most expensive choice of all.

---

[^1]: Token management strategies for vibe coding: /en/posts/vibe-coding-token-management-strategy/
[^2]: vibecoding-token-experiments - the token experiment management repository (hypothesis catalog, experiment designs, and raw logs published openly): https://github.com/roboco-io/vibecoding-token-experiments
[^3]: RealWorld - "The mother of all demo apps": https://github.com/gothinkster/realworld
[^4]: Anthropic official docs - Prompt caching: https://platform.claude.com/docs/en/build-with-claude/prompt-caching
[^5]: Anthropic official docs - Pricing: https://platform.claude.com/docs/en/pricing
