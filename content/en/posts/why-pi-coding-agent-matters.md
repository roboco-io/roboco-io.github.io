---
title: "Why the Small, Flexible Pi Coding Agent Deserves Attention"
date: 2026-09-25T10:00:00+09:00
draft: false
toc: false
images:
tags:
  - coding-agent
  - pi
  - vibe-coding
  - benchmark
---

> Pi paired with DeepSeek V4.1-Flash completed all three runs of our RealWorld backend implementation experiment. The fastest run took 1.9 minutes, with a Pi-recorded cost estimate of $0.037.[^1]

{{< figure src="/posts/images/Dohyun.png" title="Dohyun Jung - Principal Consultant, ROBOCO" style=".author-image">}}

---

There are plenty of coding agents. Some, like Claude Code and Codex, come from model providers; others connect to multiple models independently. Their feature lists keep growing, yet practical work can still leave you unable to change an agent's behavior or avoid a workflow you do not need. [Pi](https://pi.dev/) stands out here. It keeps the core small and lets users add the capabilities they need.[^2]

This article looks at who built Pi, how it works, and what happened when we used it in our [RealWorld backend benchmark](https://roboco.io/coding-agent-benchmark/).

## TL;DR

- [Mario Zechner](https://mariozechner.at/) built Pi as a small coding agent. Its approach of combining basic tools and adding capabilities as needed recalls the Unix philosophy.
- All five Pi model combinations completed all three runs of our RealWorld backend benchmark. The fastest DeepSeek V4.1-Flash run took 1.9 minutes with a $0.037 cost estimate, but one run does not establish typical performance.
- Pi can reuse project instructions such as `AGENTS.md` and `CLAUDE.md`, and DeepSeek V4.1-Flash's published weights can be deployed in your own environment. Agent-specific settings and self-hosted performance still need separate checks.

## 1. Who built Pi?

Pi's creator, **[Mario Zechner](https://mariozechner.at/)**, has a long history in open-source software. His best-known project, **libGDX**, is a cross-platform game development framework. He also joined **RoboVM**, which enabled JVM applications to run on iOS, early on and developed its debugger. Both projects gave him experience building developer tools and working with open-source communities.[^13]

After building several AI agents and using existing coding tools, Zechner wanted better visibility and control over what was sent to the model. He also found their support for self-hosted models lacking. He built `pi-ai` to connect multiple model providers, `pi-agent-core` for the tool-execution loop, `pi-tui` for the terminal interface, and `pi-coding-agent` to bring them together. His decision to leave features he did not need out of the core took shape during this work.[^3]

**[Armin Ronacher](https://lucumr.pocoo.org/)**, the creator of Flask, used Pi and wrote publicly about it. In April 2026, Zechner brought Pi with him when he joined **Earendil**, where Ronacher works. According to Zechner, he now makes decisions about Pi's technical direction and roadmap with Ronacher and [Colin Hanna](https://www.linkedin.com/in/colindhanna) while continuing to lead its development.[^4][^13]

## 2. A small core you can extend

Pi's basic loop is straightforward. It sends the user's request, active conversation, project instructions, and available tools to a model. When the model requests a tool, Pi runs it and sends the result back. The loop continues until the work is done. Its four basic tools read, write, and edit files, and run shell commands.[^2][^5]

A small core does not mean a narrow range of tasks. According to the official site, extensions can add tools, commands, and interface elements. Pi also supports skills and prompt templates. Features such as subagents and plan mode, which are not built in, can be added when needed. Session history forms a tree, so you can branch from an earlier point; you can also switch models during a session.[^2] Pi is best understood as an **agent environment you can modify**.

This design does not guarantee that every task will run faster. It does give users more room to inspect and adjust the system prompt, tools, and context. That control was central to Zechner's motivation for building Pi.[^3]

The approach reminds me of the **Unix idea of making small tools that each do one job well, then combining them to handle more complex work**. Pi begins with file reading, writing, editing, and shell execution, and adds other capabilities as needed. This is a resemblance I see as a user, not a claim that Pi's developer explicitly adopted Unix philosophy as a design rule.

## 3. What happened in a real backend task?

Our benchmark asks an agent to implement a new **RealWorld backend**. Nobody edits the code during a run. Completion requires passing the official Hurl checks: 13 files and 154 requests. The unit of comparison is a **combination of model, agent, reasoning settings, and connection method**, rather than a model alone.[^6]

We ran Pi with DeepSeek V4.1-Flash, kimi-k3, qwen3.8-max, Claude Opus 5.5, and gpt-6-sol, three times each with an English prompt. All five combinations completed all three runs.[^1][^7]

| Pi combination | Completed | Median session time | Cost-related figure |
|---|---:|---:|---:|
| DeepSeek V4.1-Flash | 3/3 | About 3.3 min | Median Pi-recorded estimate: $0.059 |
| Claude Opus 5.5 | 3/3 | About 3.9 min | Median estimate at published API rates: $0.81 |
| gpt-6-sol | 3/3 | About 4.4 min | Median estimate at published API rates: $0.27 |

The fastest DeepSeek run took **1.9 minutes and had a $0.037 estimate**. At an assumed exchange rate of 1,500 won per dollar, that is about **56 won**. The often-cited “two minutes and 55 won” describes this **single fastest run**, rounded. Across the three runs, the median was about 3.3 minutes and $0.059. The cost is Pi's rate-based estimate, not a verified bill.[^1] The won figure also changes with the exchange rate.

The comparisons with providers' own agents are interesting. Under the English condition, Pi × Opus 5.5 had medians of 3.9 minutes and $0.81, versus 4.2 minutes and $1.25 for Claude Code × Opus 5.5. Pi × gpt-6-sol recorded 4.4 minutes and $0.27, versus 4.9 minutes and $0.43 for Codex × gpt-6-sol.[^7] Both Pi combinations also produced fewer output tokens than their reference runs. But the time ranges overlap. The agent, API path, cache settings, and run dates also differed. **We cannot attribute those differences to Pi alone.** This was one task with only three runs per condition.

The result still matters. Pi completed the same backend task with several models, and some combinations recorded times and estimated costs that compare well with dedicated agents from major model providers. The careful conclusion is that **developers have another option worth testing**, not that Pi has proved universally superior.

I have also been **trying Pi with DeepSeek V4.1-Flash on a range of tasks**. Its quick responses and ability to carry work through to completion have impressed me. This is my experience, separate from the benchmark above; it does not establish that every task will turn out the same way.

Organizations concerned about where data is processed when using DeepSeek's external API have another deployment option to examine. DeepSeek has **published the V4.1-Flash model weights** and provides local inference instructions in its model card. With the required hardware and operational capacity, the model can be deployed in an organization's own environment.[^9] **The benchmark used DeepSeek's API**, however. It does not establish that self-hosting would deliver the same speed or cost.

## 4. How much existing agent configuration can you reuse?

Rebuilding configuration is a nuisance when a project already uses Claude Code or Codex. Pi reduces that work for **project instructions and skills**. Its documentation says it reads `AGENTS.md` and `CLAUDE.md` context files from the working directory and its parents, so existing project rules can also guide Pi.[^10]

Skills require a path check. Pi discovers skills in `.pi/skills/` and the shared Agent Skills location `.agents/skills/`. If your existing skills live only in `.claude/skills/` or `.codex/skills/`, you can add those directories to Pi's `settings.json` skill paths.[^11][^12] For skills shared across agents, keeping them in `.agents/skills/` is simpler.

This does **not import every Claude Code or Codex setting**. Pi manages models, authentication, extensions, and keybindings in its own `.pi/` and `~/.pi/agent/` files.[^10] Instructions or skills that depend on tool-specific names, hooks, or commands need to be checked and adapted. Project rules can carry over easily; tool behavior does not migrate automatically.

## 5. Choosing models with a subscription

Pi supports API keys and login flows from multiple providers. Our gpt-6-sol runs used **ChatGPT subscription OAuth**. A subscriber can therefore try GPT through Pi and compare that experience with Codex when choosing a working environment.[^2][^7]

Claude requires a distinction. Anthropic recommends **Console API keys or supported cloud providers** for third-party tools. Our Pi × Opus 5.5 runs used an Anthropic API key.[^7][^8] ChatGPT subscription use and API-rate estimates should not be treated as the same kind of spending. Subscriptions have usage limits, and the $0.27 shown for gpt-6-sol is an estimate for comparison, not the amount billed for those runs.[^7]

---

## Conclusion

Pi deserves attention for its small core and adaptable workflow. It starts with four tools, supports extensions, and makes it practical to try several models in one agent environment. All five model combinations completed the benchmark's backend task, and DeepSeek's fastest run is striking on both time and estimated cost.

The next step is to go beyond a fast individual run: compare agents while holding the model and API path constant, repeat the trials, and test bug fixes and changes to existing code. Pi has earned a place in that comparison.

---

[^1]: ROBOCO.IO, EXP-029 Pi open-model experiment report: https://github.com/roboco-io/coding-agent-benchmark/blob/main/experiments/029-pi-openweight/report.md
[^2]: Pi official website: https://pi.dev/
[^3]: Mario Zechner, “What I learned building an opinionated and minimal coding agent”: https://mariozechner.at/posts/2025-11-30-pi-coding-agent/
[^4]: Armin Ronacher, “Mario and Earendil”: https://lucumr.pocoo.org/2026/4/8/mario-and-earendil/
[^5]: Pi documentation, “How Pi Works”: https://pi.dev/docs/latest/how-pi-works
[^6]: ROBOCO.IO, coding-agent benchmark overview and methodology: https://github.com/roboco-io/coding-agent-benchmark
[^7]: ROBOCO.IO, EXP-030 Pi frontier-model experiment report: https://github.com/roboco-io/coding-agent-benchmark/blob/main/experiments/030-pi-frontier/report.md
[^8]: Anthropic Help Center, “Log in to your Claude account”: https://support.claude.com/en/articles/13189465-log-in-to-your-claude-account
[^9]: DeepSeek, “DeepSeek-V4.1-Flash” model card and local inference instructions: https://huggingface.co/deepseek-ai/DeepSeek-V4.1-Flash
[^10]: Pi documentation, “Configuration”: https://pi.dev/docs/latest/configuration
[^11]: Pi documentation, “Skills”: https://pi.dev/docs/latest/skills
[^12]: Pi documentation, “Settings Reference”: https://pi.dev/docs/latest/settings
[^13]: Mario Zechner, “I've sold out”: https://mariozechner.at/posts/2026-04-08-ive-sold-out/
