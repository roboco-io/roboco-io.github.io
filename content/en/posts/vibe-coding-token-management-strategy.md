---
title: "A Token Management Strategy for Vibe Coding"
date: 2026-03-19T09:00:00+09:00
draft: false
toc: false
images:
tags:
  - vibe-coding
  - claude-code
  - codex
  - gemini
  - context-engineering
---

> Running out of tokens is rarely a model performance problem. It is usually a problem with how you operate your context.

{{< figure src="/posts/images/Dohyun.png" title="Dohyun Jung - Principal Consultant, ROBOCO" style=".author-image">}}

---

Use a vibe coding tool like Claude Code, Codex, or Gemini long enough and the same symptoms start showing up. Responses slow down, constraints you already agreed on get forgotten, and the model starts touching files that have nothing to do with the task. We usually describe this as "running out of tokens," but what is actually happening is closer to **context pollution**, or context rot.

Reading back through the ideation notes I put together with Perplexity, the core point is clear. In real-world usage, most token consumption comes from **input context** rather than output, which means the best way to solve the problem is not a "bigger model" but a "cleaner context." Building on that material, this post lays out principles for token management centered on **practical operating strategy** rather than a tour of tool features.

## TL;DR

- Running out of tokens is not simply a quota problem; treat it as context pollution caused by conversation, logs, and documents getting tangled together.
- The habits that shrink scope come first: `.claudeignore`, splitting up work documents, `/clear` and `/compact`, and handoff documents.
- Good vibe coding is less about long prompts and more about designing context so the model sees only what it needs right now.

## Why tokens run out first

When a long session keeps accumulating, the problem shows up on two levels. One is simply hitting the token limit; the other, which arrives sooner, is degraded quality. When conversation logs, failed attempts, provisional hypotheses, long build logs, and the context of already-finished work all linger, the model has a harder time distinguishing what matters now from what has already been discarded.

This is not solved by context window size alone. A long context lets you hold more information, but it offers no guarantee that the information inside it is well organized. That is why the heart of token management is **selection** rather than conservation for its own sake.

## Strategy 1: Use `.claudeignore` to block what should never be read in the first place

Measured against real numbers, the single highest-ROI action is configuring `.claudeignore`. In the cases cited in the ideation document, simply excluding `node_modules`, build artifacts, logs, binaries, large images, and lock files is reported to deliver **savings on the order of 30–40%**.[^6][^7]

Here is roughly what it looks like.

```text
node_modules/
.next/
dist/
build/
coverage/
.cache/
*.log
*.db
*.sqlite
.env*
*.png
*.jpg
*.gif
*.mp4
```

The essence of this strategy is not thrift. It is preventing the model from seeing information that would not help it anyway. Lock files and build artifacts in particular eat a lot of tokens while carrying almost no inferential value.

## Strategy 2: Do not cram everything into `tasks.md` — split it into an index structure

One of the most striking cases in the ideation document is a team that divided a single large `tasks.md` into per-domain documents plus an `INDEX.md` structure and achieved **76.1% savings**.[^8]

```text
tasks/
├── INDEX.md
├── backend.md
├── frontend.md
├── infra.md
├── security.md
└── archive/
```

The reason this structure works is simple: not every task requires reading every task. For a general status check, `INDEX.md` is enough; for a specific piece of work, only the relevant domain file needs to be read. Completed history moves to `archive/` and disappears from the current session's workbench.

Token management, in the end, is partly a problem of document information architecture.

## Strategy 3: Do not drag sessions out — use `/clear` and `/compact` deliberately

For Claude Code specifically, the most immediately effective method is using `/clear` and `/compact` strategically.[^1][^2]

- Use `/clear` when you want to reset the working context completely.
- Use `/compact` to summarize the conversation history while keeping only what matters.
- It is an effective habit to run compact right after a long debugging session, when you finish a feature, or when context usage reaches around 70%.[^2]

The key is shaking off the illusion that keeping a long conversation alive is productive. Rather than being drawn out, a session **should be something you can cut short and restart**.

## Strategy 4: Leave a handoff document and move to a new session

If you want to end sessions frequently, the cost of resuming has to be low. The simplest and most powerful approach here is keeping a short handoff document such as `HANDOFF.md`.[^3]

Something like the following is enough.

```text
Goal: fix the race condition in the login flow
Files changed: auth_service.ts, login_controller.ts
Confirmed: not a DB issue — it is a duplicate API call
Failed attempt: applying a mutex caused side effects, rolled back
Next: evaluate an idempotency key approach
Done when: the duplicate-login reproduction test passes
```

The purpose of this document is not to preserve a long record. It is to leave behind **just enough direction for the next session to start working immediately**.

## Strategy 5: Go through Plan mode first and implement later

Throw a large task straight into execution mode and the model handles exploration, design, and implementation all at once within the same cost center. That approach involves a lot of trial and error and burns a lot of tokens. The ideation material concludes that the habit of going through Plan mode first to narrow scope before moving into implementation contributes **20–30% savings**.[^7]

The principle is very simple.

1. First find the relevant files and the scope of impact.
2. Briefly plan the candidate files to modify and the approach.
3. Cut the unnecessary scope out of the plan.
4. Only then implement.

In other words, saving tokens has less to do with the skill of writing short prompts and more to do with **design habits that eliminate unnecessary trial and error up front**.

## Strategy 6: Move repeated explanations into `CLAUDE.md` and manage it hierarchically

Plenty of teams re-explain project structure, style guide, prohibited practices, and testing approach every single session. Over the long run this is the most expensive kind of token waste. The ideation document likewise recommends a pattern of layering `CLAUDE.md` at the global, project, and module levels.[^4]

```text
~/
└── CLAUDE.md
project/
├── CLAUDE.md
├── backend/CLAUDE.md
└── frontend/CLAUDE.md
```

The advantage of this structure is clear. Rules that are always needed sit at the top; information needed only in a specific domain sits in the lower module files. That way, not every session has to carry around the same heavy rules file in its entirety.

The following items are especially useful in `CLAUDE.md`.[^4][^5]

- Core tech stack and architecture
- Coding conventions
- Current sprint goals and blockers
- Information that must survive a compact
- `Load on Demand` links out to more detailed documents

Put differently, a good `CLAUDE.md` is not a document that holds everything. It is closer to **an index that decides what to read right now and what to read later**.

## Strategy 7: Use Skills aggressively to turn documents from "always loaded" into "loaded when needed"

Go one step further and `CLAUDE.md` alone is not enough. Repeatedly invoked workflows, domain-specific procedures, review criteria, deployment checklists, security review routines — things like these are far better **externalized into a skill**.

Anthropic's official Skills guide explains this point quite clearly.[^15] Skills fundamentally have a **three-stage progressive disclosure** structure.

- The YAML frontmatter is always loaded.
- The body of `SKILL.md` is loaded only when that skill is judged to be relevant.
- Linked documents such as those under `references/` are explored further only when needed.

In other words, the core value of a skill is not "packing in a lot of knowledge" but **not packing all of that knowledge in at once**. Combine this with subagents and the effect grows. Anthropic's subagent documentation likewise explains that subagents use a **separate context window** from the main conversation, reducing pollution of the main session.[^16]

One thing does need to be stated precisely here. Anthropic's official documentation does not directly prescribe "keep every document under 200 lines." What the official guide says is a more general principle: `SKILL.md` should hold only the core instructions, detailed documentation should be pulled out into `references/`, and if significant context issues arise, `SKILL.md` should be kept **under 5,000 words**.[^15] The practical rule I want to add on top of that is more aggressive. **Document fragments that will actually be referenced are better split into chunks of under 200 lines.** That keeps the unit from getting too large when a skill picks out only the documents it needs.

For example, a layout like the following works better.

```text
.claude/
├── CLAUDE.md
├── agents/
│   └── code-reviewer.md
└── skills/
    └── security-review/
        ├── SKILL.md
        └── references/
            ├── auth-checklist.md
            ├── input-validation.md
            └── secrets-policy.md
```

This structure has two advantages. First, all that remains in the main session is "when to use this skill." Second, the detailed documents come in only when they are actually needed. The token savings happen at that second stage.

The measured data points in a similar direction. SkillsBench reports that across seven model/harness combinations, **curated skills produced an average +16.2 percentage point improvement in success rate**.[^17] Claude Code Opus 4.6 went from 30.6% to 44.5%, Codex GPT-5.2 from 30.6% to 44.7%, and Claude Code Sonnet 4.5 from 17.3% to 31.8%.[^17] The more interesting part is tokens. In that study, skills did not unconditionally reduce tokens in every environment. On GPT-5.2 and Gemini 3 Flash, total tokens rose 6–13% as skill context was added. By contrast, Gemini 3 Pro saw total tokens fall about 6%, and Claude Code Opus 4.6 saw observable input tokens **drop about 26%, from 1,947K to 1,448K**.[^17]

What these numbers say is clear. A skill is not "a technique for stuffing in more documentation" but **a technique for reducing exploration and reusing procedures**. A well-designed skill can lower total tokens by cutting trial and error, but conversely, skills that are too large, too numerous, or loaded wholesale become context debt instead.

In conclusion, the core of a skill strategy comes down to these three lines.

- Promote frequently repeated procedures into skills.
- Keep `SKILL.md` short and separate detailed documentation into `references/`.
- Keep the documents that will actually be referenced small enough that on-demand loading is meaningful.

## Strategy 8: Isolate large logs and search work into subagents or separate sessions

Web searches, long log analysis, build output review, and broad code exploration all produce lengthy output. Handling this kind of work directly in the main session pollutes context fast. The ideation material also recommends delegating such high-noise work to a subagent and **taking back only a summary of the results into the main context**.[^9]

This pattern applies just as well to Codex and Gemini CLI as it does to Claude Code. What matters is less which tool you use and more **not mixing noisy work and decision-making work in the same session**.

## Strategy 9: Make search-based context injection the default

In a large codebase, having whole files read in as-is does not hold up for long. The ideation document also introduces an advanced pattern of building a dependency graph at the function or symbol level and supplying only the fragments needed; there are even cases showing that this approach can achieve **savings of over 80%** by measured numbers.[^10]

Of course, not every team needs to build an MCP server or a dependency graph right away. But the principle can be applied immediately.

- Search first.
- Narrow down to the relevant files and symbols.
- Put only those fragments into context.

That is, instead of dumping the entire repository, **search-then-inject** should be the default.

## Strategy 10: An MCP server costs you something just by being switched on

MCP is powerful, but the more servers and tools are active, the more the context and system instructions swell. As the ideation document points out, keeping MCPs unrelated to the current work permanently on is a way of eating into your budget before the first prompt is even sent.[^11]

So the right MCP strategy is not "connect a lot" but "connect only when needed." In the long run, this too is part of progressive disclosure.

## Strategy 11: Separate roles by tool

The ideation material characterizes Claude Code, Codex, and Gemini as each having different traits.[^12][^13][^14]

- Claude Code is strong at complex reasoning and debugging, but session management matters.
- Gemini CLI is advantageous for long-context analysis, but an exclusion strategy such as `.geminiignore` is essential.
- Codex handles relatively large contexts, but is ultimately not exempt from the principles of compaction and scope management.

Which is to say: do not use every tool the same way. **Separating roles** — leaving whole-codebase mapping to the long-context tool and handing the actual edits to short, focused sessions — is better for both cost and quality.

## Antipatterns

Conversely, the following patterns almost always create token debt.

- Broad requests like "look at the whole project and figure it out"
- Accumulating exploration, implementation, debugging, and retrospective all in a single session
- A structure that always loads a huge `tasks.md`, a giant rules file, or a bloated skill in its entirety
- A structure that crams all background knowledge into one file inside a skill and effectively never uses `references/`
- The habit of pasting in build logs, diffs, and search results uncompressed
- Configurations that keep MCP servers and tools unrelated to the current work permanently enabled
- The attitude that a large context window means you do not have to tidy up

A long context only lets you hold more garbage. It does not help you pick out the important information any better.

## A realistic order of adoption

The body of this post is largely ordered by savings efficiency, but the order in which you actually start can shift somewhat depending on team size and capacity to invest. In practice, it is usually easiest to think of it in the three stages below.

1. Apply immediately
`.claudeignore`, splitting `tasks.md`, `/clear` and `/compact`, handoff documents
2. Establish within the week
`Plan mode`, slimming down `CLAUDE.md`, promoting repeated procedures into skills
3. Structural investment after that
Subagent isolation, search-based context serving, MCP minimization, role separation by tool

In other words, most teams can feel a big difference by changing nothing more than **document structure and session habits**, well before any advanced infrastructure.

## Conclusion

A token management strategy for vibe coding ultimately comes down to one sentence. **Do not show the model a lot; show it exactly what is needed right now.** Keep sessions short, externalize repeated explanations into documents and skills, break large tasks into an index and a planning stage, and isolate noisy work into separate sessions.

The reason teams that conserve tokens are more productive is not that they spend less money. It is that they left the model less room to get confused. A good vibe coder is not someone who writes long prompts, but **someone who designs context**.

[^1]: Best Practices for Claude Code, Anthropic Docs: https://code.claude.com/docs/en/best-practices
[^2]: Managing Claude Code context to reduce limits: https://mcpcat.io/guides/managing-claude-code-context/
[^3]: 45 Claude Code Tips From basics to advanced: https://github.com/ykdojo/claude-code-tips
[^4]: The Complete Guide to Claude Code Context: https://supatest.ai/blog/claude-context-management-guide
[^5]: Claude Code 컨텍스트 최적화 가이드 - 인포그랩: https://insight.infograb.net/blog/2026/01/14/claudecode-context/
[^6]: 7 Ways to Cut Your Claude Code Token Usage: https://dev.to/boucle2026/7-ways-to-cut-your-claude-code-token-usage-elb
[^7]: How I Reduced Claude Code Token Consumption by 50%: https://32blog.com/en/claude-code/claude-code-token-cost-reduction-50-percent
[^8]: CLAUDE-CODE의 토큰을 절약하기 - tasks.md의 문서 구조 개편: https://developer-youn.tistory.com/196
[^9]: How to Use Claude Code: A Guide to Slash Commands: https://www.producttalk.org/how-to-use-claude-code-features/
[^10]: I cut Claude Code's token usage by 65% by building a ... https://www.reddit.com/r/ClaudeAI/comments/1rby0gt/i_cut_claude_codes_token_usage_by_65_by_building/
[^11]: Tips after using Claude Code daily: context management ... https://www.reddit.com/r/ClaudeCode/comments/1pawyud/tips_after_using_claude_code_daily_context/
[^12]: Best practices for cost-efficient, high-quality context management in long AI chats: https://community.openai.com/t/best-practices-for-cost-efficient-high-quality-context-management-in-long-ai-chats/1373996
[^13]: How to Leverage Gemini CLI's 1M Token Context Window: https://inventivehq.com/knowledge-base/gemini/how-to-leverage-1m-token-context
[^14]: What Is the Token Limit for Codex Requests?: https://apidog.com/blog/token-limit-for-codex-requests/
[^15]: The Complete Guide to Building Skills for Claude, Anthropic: https://resources.anthropic.com/hubfs/The-Complete-Guide-to-Building-Skill-for-Claude.pdf
[^16]: Subagents, Anthropic Docs: https://docs.anthropic.com/en/docs/claude-code/sub-agents
[^17]: SkillsBench: Benchmarking How Well Agent Skills Work Across Diverse Tasks: https://www.skillsbench.ai/skillsbench.pdf
