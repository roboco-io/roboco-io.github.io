---
title: "Does Karpathy's LLM Wiki Actually Work? A 72-Run Benchmark"
date: 2026-05-07T11:00:00+09:00
draft: false
toc: false
images:
tags:
  - llm-wiki
  - karpathy
  - claude-code
  - context-engineering
  - agentic-dev
  - benchmark
  - graphrag
---

> "To keep agents from re-deriving everything every time, you need a compiled knowledge artifact." — Andrej Karpathy, *LLM Wiki* (GitHub Gist, 2026-04)[^karpathy]

{{< figure src="/posts/images/Dohyun.png" title="Dohyun Jung - Principal Consultant, ROBOCO" style=".author-image">}}

---

## TL;DR

- We measured whether Andrej Karpathy's **LLM Wiki pattern** ("don't re-read every time; reuse knowledge compiled once"[^karpathy]) is actually a win, using an **8-task × 3-technique × 3-repetition = 72-run** benchmark in a 30-repository migration workspace.
- **LLM Wiki placed first on all three dimensions: tokens, time, and quality.** Versus Vanilla, **54% fewer tokens and 39% less time** (statistically a large effect, §4), with quality equal to Vanilla and better than Graphify.
- **Graphify (GraphRAG) is unsuitable as a default tool.** Negligible token savings, the longest time, and the lowest quality.
- **That said, it's not universal.** Wiki wins decisively on tasks that synthesize multiple sources, but for tasks whose answer sits plainly in a single source (exhaustive grep, looking up a specific table), reading directly is faster and more accurate (§3).
- On receiving these results, the project's default context-retrieval tool was switched to LLM Wiki that same evening.

| Technique | Tokens (avg) | Time (avg) | Quality (out of 25) |
|------|-----------:|-----------:|-----------:|
| Vanilla (direct read/grep) | 755K | 167s | 15.1 |
| **LLM Wiki** | **350K** | **101s** | **16.0** |
| Graphify (GraphRAG) | 617K | 180s | 13.6 |

Below is the experimental design and detailed numbers that support this conclusion.

---

## 1. The Three Techniques Compared

| Technique | How it works | Additional material exposed |
|-----|----------|--------------|
| **Vanilla** | Read/grep files directly with no auxiliary tooling | (none) |
| **LLM Wiki** | Read a markdown wiki pre-compiled by an LLM first | all of `wiki/` + citation rules |
| **Graphify** | Query an entity-relationship graph (GraphRAG) first | `graphify-out/` + CLI |

The core of the LLM Wiki pattern is its difference from RAG. RAG is a **stateless** cycle that repeats embedding, vector search, and chunk injection on every query, so it redoes synthesis, cross-referencing, and contradiction handling from scratch each time. LLM Wiki inverts this: it **compiles once when a new source arrives** (summarizing, cross-referencing, flagging conflicts), and at query time it reads a markdown page that is already synthesized. **Compile once, query many times** — this asymmetric cost allocation is the source of the token savings.

---

## 2. Experimental Design

**Decision question**: "For this migration workload, which technique satisfies both token efficiency and answer quality?" The dependent-variable priority was (1) token cost, (2) answer quality, (3) task time.

**Workload — 8 tasks (T1–T8)**:

| ID | Question focus | Task type |
|----|---------|----------|
| T1 | Number and areas of cyrup's in-house 9folders patches | patch analysis |
| T2 | SNS flow between notifier_go ↔ rework-notify | cross-language dependency |
| T3 | Scale of cyrus-imapd 9folders patches relative to master | large-scale patch analysis |
| T4 | Is pam-jwt called in production | exhaustive grep |
| T5 | Activity comparison across cyrus-imapd's 4 branches | git history |
| T6 | Fit of Stalwart JMAP to Korean business logic | external source integration |
| T7 | Dependent commit SHAs for the 6 R12 PoC scenarios | code analysis |
| T8 | R-items and capability IDs affecting X-AUTH-01 | cross-domain |

**Isolation**: the three techniques were separated into 3 git worktrees, each with a dedicated CLAUDE.md overwritten in place. Submodules, PRD, code, and git were shared; **the only difference was the auxiliary tooling**. Thanks to the separate worktree paths, there was no prompt cache contamination across trials.

**Scoring (Judge) — an external model (codex/GPT-5)**: since the actor was Claude, we scored with an external model to avoid self-evaluation bias. A 4-dimension 0–25 rubric.

| Dimension | Weight | Definition |
|-----|-------|-----|
| Accuracy | 0.4 | match rate against ground truth key facts |
| Completeness | 0.3 | are any key facts missing |
| Citation | 0.2 | explicit `[[wiki/..]]`, `PRD §X`, `9folders <SHA>` |
| Excess (inverse indicator) | 0.1 | rate of unnecessary speculation, hallucination, repetition |

The task prompts did not expose ground truth; only the judge held it. Inter-rater agreement (Cohen's κ) passed the rubric at a weighted average of 0.86 (only the excess dimension was weak at κ=0.25, but its weight is 0.1).

---

## 3. Winners by Task — The Pattern Isn't Simple

The overall average favors Wiki, but the winner varies by task type. First place by mean score:

| Task | 1st | 2nd | 3rd | Notes |
|------|----|----|----|-----|
| T1 (cyrup patches) | wiki 17.67 | graphify 17.50 | vanilla 16.33 | too close to call |
| T2 (cross-language SNS) | **wiki 18.00** | vanilla 14.50 | graphify 13.17 | wiki dominant |
| T3 (cyrus-imapd patch scale) | graphify 9.50 | vanilla 8.33 | wiki 7.83 | **all poor** |
| T4 (pam-jwt usage) | **vanilla 18.17** | wiki 17.50 | graphify 14.83 | vanilla ahead |
| T5 (cyrus branch activity) | wiki 15.83 | vanilla/graphify 14.17 | — | wiki ahead |
| T6 (Stalwart JMAP fit) | **wiki 16.83** | graphify 11.50 | vanilla 11.33 | wiki dominant |
| T7 (R12 PoC SHAs) | wiki 18.00 | vanilla 17.67 | graphify 16.33 | too close to call |
| T8 (X-AUTH-01 cross-domain) | **vanilla 20.33** | wiki 16.33 | graphify 11.50 | vanilla dominant |

- **Wiki is robust on mixed and synthesis-type tasks.** First place in 5 of 8 (T1, T2, T5, T6, T7). It's especially strong on T2 (cross-language) and T6 (external sources), where multiple sources must be synthesized. Curation earns its keep.
- **There are two tasks where Vanilla wins**: T4 (exhaustive grep) and T8 (cross-domain). In both, **the answer sits plainly in a single source, so curation is a net loss.** T4 is settled by grepping the whole codebase, and for T8 reading the PRD table directly is the most accurate route.
- **Graphify took first place on only one task, T3, and even there at 9.50/25 the absolute score is low.** It also lost badly to wiki on cross-language (T2), where we expected it to shine — INFERRED edges added noise and query overhead inflated the time.

---

## 4. Statistical Significance

Friedman main effects: time p=4.5e-07, quality p=0.0016 (both strong), tokens p=0.093 (marginal).

Wilcoxon pairwise (Bonferroni-corrected):

| Comparison | Dimension | p_corr | Cohen's d | Verdict |
|-----|-----|--------|-----------|------|
| vanilla > wiki | tokens | 0.0105 | +0.842 | **significant (large)** |
| vanilla > wiki | time | 3.93e-05 | +0.975 | **significant (large)** |
| graphify > wiki | time | 3.58e-07 | -1.150 | **significant (large)** |
| wiki > graphify | quality | 0.00678 | +0.666 | **significant (medium-large)** |
| vanilla vs wiki | quality | 0.7312 | -0.216 | no difference |
| vanilla vs graphify | quality | 0.2459 | +0.420 | no difference |

In summary, **Wiki cuts tokens and time versus vanilla with a large effect (quality equal), and beats graphify on both quality and time**. Graphify-first is unsuitable as a default tool for our workload.

---

## 5. So How Do We Operate?

This is the baseline policy we settled on after receiving the benchmark results.

1. **Wiki-first** — for operational facts, read `wiki/index.md` → the relevant notes first.
2. **If it's not there, go straight to the source** — if the wiki doesn't have it, PRD → code read/grep. Never make anything up.
3. **Skip the wiki when single-source retrieval is obvious** — if it doesn't narrow to a single note, move quickly to a direct read (the T4/T8 shape).
4. **Graphify is auxiliary** — use it selectively, only for cross-component dependency tracing.

The biggest lesson from operating this is a separate one. **Getting answers to cite their sources is harder, and more important, than building the wiki.** Early on, note-taking was active but fewer than 10% of answers carried `[[..]]` citations, so only half the wiki's value materialized. A single check rule forcing "is there a wiki citation for this fact?" right before answering brought the citation rate back to normal immediately.

---

## 6. Caveats

- **IRR on the excess dimension is weak** (κ=0.25). Because scoring was done while viewing all techniques' transcripts together, excess scores were uniformly harsh. With a weight of 0.1 the impact on the conclusion is small, but treat the absolute values conservatively.
- **Concern about Wiki bias**: all 8 tasks have ground truth present in the wiki, which may favor it. That said, the judge evaluates the ground truth facts themselves rather than the source.
- **This is a Claude Code-based measurement.** Results may differ in other model and tooling environments. These numbers are the basis for policy in our environment, not a universal claim.

---

## Wrap-Up

In our domain, Karpathy's LLM Wiki pattern delivered **54% fewer tokens, 39% less time, and quality equal or better**, and was statistically significant with a large effect. The decision to switch our default tool to the wiki is backed by data.

That said, don't apply the pattern literally. On tasks whose answer sits plainly in a single source, the cost of curation is a loss, and while Graphify is unsuitable as a default tool, it beats the wiki on certain path queries. **Adopt the pattern, but look at it alongside your own workload's task distribution and source structure.** At 8 tasks × 3 techniques × 3 trials = 72 runs, you'll have an answer within a day or two, so I recommend measuring it yourself.

---

[^karpathy]: Andrej Karpathy, *LLM Wiki* (GitHub Gist, 2026-04). https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f
