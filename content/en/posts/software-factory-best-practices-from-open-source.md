---
title: "Software Factory Best Practices from Open-Source Projects (1/4): The Criteria and 12 Repositories"
date: 2026-10-10T10:00:00+09:00
draft: false
toc: false
images:
tags:
  - software-factory
  - agentic-dev
  - vibe-coding
  - openclaw
  - best-practices
---

> "fix/ship authority is not release authority" – OpenClaw `AGENTS.md`[^1]

{{< figure src="/posts/images/Dohyun.png" title="Dohyun Jung - Principal Consultant, ROBOCO" style=".author-image">}}

---

In March 2026, I analyzed the OpenClaw repository and distilled [nine vibe coding best practices](/en/posts/openclaw-vibe-coding-best-practices/).[^2] It showed how a single developer could direct several AI agents to run a large monorepo. In September, in [Beyond Vibe Coding, Toward the Software Factory](/en/posts/beyond-vibe-coding-software-factory/), I looked ahead to the next stage.[^3] In that model, everything from understanding requirements through design, implementation, verification, deployment, and production monitoring flows as one continuous stream, and people set goals and constraints and step in only when a judgment call is needed. I called this a **software factory**.

That post was a forecast with no case studies. So this time I went looking for projects that actually run like factories. The method is the same as in the OpenClaw post. I read the agent instruction files, CI workflows, bot configurations, and commit, PR, and issue histories left in public repositories, and reconstructed how each project operates. It is a kind of reverse engineering. Evidence of how a project operates comes mainly from what I could verify in the repository; companies' own accounts, such as blog posts, are quoted separately with their sources. All figures were retrieved through the GitHub API on October 10, 2026, and the sample and period are stated alongside each one.

This is the first post in the four-part series "Software Factory Best Practices from Open-Source Projects." Here I lay out the criteria, the overall results, and the patterns that recurred across projects. Parts 2–4 each take a closer look at one of those patterns.

**The series**

1. The Criteria and 12 Repositories: what counts as a factory, and where factories are running (this post)
2. [Who Merges? Risk-based delegation and permission structures](/en/posts/software-factory-who-merges/)
3. [Factories That Filter by Evidence: proving a test "fails before the fix"](/en/posts/software-factory-evidence-before-fix/)
4. [Turning Failures into Rules: self-improvement loops and their limits](/en/posts/software-factory-failures-into-rules/)

## TL;DR

- I analyzed 12 public repositories (counting Beads and Gas Town separately). Eight of them, or seven projects when grouped (OpenClaw, OpenHands, Beads/Gas Town, mastra, Bun, Astro, Vercel AI SDK), qualified as software factories.
- OpenClaw is the only project where I confirmed bots merging into the main branch at scale. In the other factories, final merges were mostly made by people, and those merges were usually concentrated in one person.
- The shared practices are demanding evidence that a test "fails before the fix," implementing delegation boundaries through permission structures, and turning failures into rules along with the reasons for them. And rather than letting work flow from issue to merge with no one involved, many projects placed boundaries at the points where work starts and where results are confirmed.

---

## 1. What Counts as a Software Factory

The fact that agents write a lot of code is not enough to call something a factory. When one person talks to an agent in a terminal and writes code, an agent is still writing code. What separates a factory from vibe coding is **whether the flow continues without a person giving instructions at every step**. So I turned the definition from the September post into six criteria that can be checked in a repository.

| # | Criterion | What I checked in the repository |
|---|---|---|
| 1 | Automated work intake | Do issues, feedback, and errors become agent work without a person instructing each one? |
| 2 | Multiple parallel streams | Do several agent tasks run at once, with rules that prevent conflicts? |
| 3 | Automated verification gates | Do tests, review bots, and quality gates decide whether a change can merge? |
| 4 | Risk-based delegation | Are changes that may auto-merge separated from changes that need human approval? |
| 5 | Reporting | Can people make decisions without reading every log? |
| 6 | Self-improvement loop | Do failures in operation feed back into tests, instructions, or workflows? |

Each criterion was judged on four levels. **Met** means both the mechanism and traces of it actually running are in the repository. **Partial** means only one of the two is present, or a person performs a key step. **Not met** means there is evidence to the contrary, and **Unverified** means the public repository is not enough to judge.

The overall verdict has two thresholds. First, the development flow of the product code must be observable in the public repository. Second, a mechanism must be found for all six criteria; that is, there must be no Not met or Unverified. A project that clears both thresholds counts as a factory regardless of how many criteria it fully meets. I used the number of Met ratings to compare how mature the factories are.

For reference, StrongDM, which was early to use the term "software factory," defines it as "non-interactive development where specs + scenarios drive agents that write code."[^4] It also sets a rule that humans should neither write nor review code. The biggest difference from my criteria is criterion 4. I treat keeping human approval in proportion to risk as a requirement of a factory, while StrongDM chose to remove human review and strengthen the verification harness instead. I will come back to this difference in Part 2.

---

## 2. What 12 Repositories Revealed

I gathered candidates in two ways. One was cases that were already known (OpenClaw, Aider, OpenHands, Codex, Claude Code, StrongDM, Gas Town). The other was repositories with many merged PRs authored by agent bots, found through GitHub search (Vercel AI SDK, Astro, mastra, Bun). Beads belongs to the same team as Gas Town, so I examined them together.

| Project | 1 Intake | 2 Parallel | 3 Gates | 4 Delegation | 5 Reporting | 6 Improvement | Overall verdict |
|---|---|---|---|---|---|---|---|
| [OpenClaw](https://github.com/openclaw/openclaw) | Met | Met | Met | Met | Met | Met | Factory |
| [Beads](https://github.com/gastownhall/beads) | Met | Met | Met | Partial | Met | Met | Factory |
| [Gas Town](https://github.com/gastownhall/gastown) | Met | Met | Met | Partial | Met | Partial | Factory (main idle since July) |
| [mastra](https://github.com/mastra-ai/mastra) | Met | Partial | Met | Partial | Met | Met | Factory |
| [Bun](https://github.com/oven-sh/bun) | Partial | Met | Met | Partial | Partial | Met | Factory |
| [Astro](https://github.com/withastro/astro) | Met | Met | Partial | Partial | Met | Partial | Factory |
| [Vercel AI SDK](https://github.com/vercel/ai) | Met | Partial | Met | Partial | Met | Partial | Factory (engine private) |
| [OpenHands](https://github.com/OpenHands/OpenHands) | Partial | Partial | Met | Partial | Partial | Met | Factory (people start and merge work) |
| [Aider](https://github.com/Aider-AI/aider) | Partial | Not met | Partial | Not met | Met | Partial | Advanced vibe coding |
| [OpenAI Codex](https://github.com/openai/codex) | Partial | Unverified | Met | Partial | Partial | Met | Cannot judge (mirror of an internal repository since late August 2026) |
| [Claude Code](https://github.com/anthropics/claude-code) | Met | Partial | Partial | Partial | Partial | Partial | Cannot judge (product source not public; only issue operations observed) |
| [StrongDM](https://factory.strongdm.ai/) | Unverified | Partial | Partial | Unverified | Unverified | Partial | Not observable (the factory's actual operation is not public) |

The first thing that stands out in the table is column 4. Of the eight repositories judged to be factories, only OpenClaw meets the risk-based delegation criterion. The rest mostly have people merge code changes, so no mechanism that grants different auto-merge scopes by risk came to light. The project that cleared the threshold by the narrowest margin is OpenHands. It meets only two criteria fully, and people both start the implementation work and merge it.

Some figures show the scale. At Bun, the Claude-based agent `robobun` opened 2,313 PRs in September 2026 alone and authored 446 of the 560 PRs merged that month.[^5] At Vercel AI SDK, the factory bot authored 294 (34.8%) of the 845 PRs merged in September.[^6] Vercel's blog says the factory writes 25–35% of weekly merged PRs, and the monthly figure I measured falls within that range. Because the periods differ, though, this is not a direct verification.[^7] At mastra, a bot wrote 434 of the 1,531 PRs merged in September.[^8]

The repositories I could not judge are meaningful too. In the OpenAI Codex repository, 2,170 merged PRs since August 27, 2026 were carried over from an internal repository by a mirroring bot, and the bot opened all of the 200 most recent merged PRs. On September 30, the root `AGENTS.md` and 12 skills were deleted from the public repository.[^9] The Claude Code repository contains no product source; only its issue-operation automation is public. Reverse engineering can see only as much as is made public.

---

## 3. Merge Authority and Where the Engine Lives

Splitting the 12 repositories along two questions makes the structure clearer. One is "who merges into the main branch?" The other is "where do the engine and configuration that run the factory live?"

| Who merges \ Where the engine lives | Outside the repo (private) | Partly public | Public repository |
|---|---|---|---|
| Bots merge into main at scale | | | **OpenClaw** (203 of the last 300 merges) |
| Final merges mostly by people | Vercel AI SDK, Bun | OpenHands | mastra, Astro, Beads, Aider (contrast case) |
| Could not confirm who merges | OpenAI Codex, Claude Code | StrongDM | Gas Town |

OpenClaw, which publishes even its engine, is the only project where I confirmed that bots merge into main at scale. OpenClaw runs its maintenance bot, ClawSweeper, as a separate public repository and spells out in its README the conditions under which the bot may merge.[^10] Astro also keeps its engine in a separate public repository (`withastro/factory`), but people merged all of its factory PRs in September.[^11] At Gas Town, one account merged 173 of 200 merged PRs, and I could not confirm whether that account is a person or a channel for agents. Even where merges were mostly by people, there are exceptions. For example, one of the 446 robobun PRs merged at Bun in September was merged by a different bot account.

Where the engine lives determines how deep reverse engineering can go. In the right-hand column, you can read everything from the agent instructions to the execution engine. In the left-hand column, only the labels, comments, and PRs that bots leave behind are visible. Vercel AI SDK's factory bot is a private GitHub App, so I could not confirm whether its self-improvement loop actually changed its prompts.

---

## 4. OpenClaw, Seven Months Later

The March post analyzed OpenClaw from a vibe coding perspective. Looking at it again against these criteria, OpenClaw was the only project in this study that met all six. Many new mechanisms appeared in the meantime. I cover them in detail in Parts 2–4; here I only point out what differs from the March post.

- **ClawSweeper, the maintenance bot**: Created as a separate repository on April 23, 2026. It receives issue and PR events and reviews, labels, repairs, and merges them. For issues that pass strict bug criteria, it generates PRs automatically with Codex, but PRs created this way are never auto-merged.[^10]
- **Permissions by risk tier**: For changes that touch only documentation, the Docs Agent checks the path allowlist and pushes straight to main.[^12] Ordinary code can be merged with a single required check and a bot review. Sensitive paths are managed separately in a policy file, and the SecOps team approves changes to the security policy files themselves.[^13] Releases are run manually by people. The quote at the top of this post sums up this principle.
- **Failure-rate circuit breaker**: The success rate of the automatic implementation worker fell to 16.9% (52 successes, 256 failures) from October 3 to 9. Afterward, a mechanism was added that halts automatic implementation when the success rate over the last seven days is below 50% with at least 10 runs.[^14]

Some things from the March post have also changed. The `CLAUDE.md` symlink was retired on September 19, 2026, so `AGENTS.md` is now the single source of truth.[^15] The requirement in CONTRIBUTING to disclose AI use was also removed on August 30.[^16] Instead, PRs must include evidence that the change works. The question shifted from whether an agent wrote the code to whether there is evidence it works.

---

## 5. Six Patterns That Recurred Across Projects

The tools and scale differed, but the following six patterns showed up repeatedly in three or more projects.

### 5.1 Merging Is Still a Human Job, and It Falls to One Person

As of September 2026, one person handled 78% of robobun PR merges at Bun, and one person handled 82% of bot PR merges at mastra.[^5][^8] At Astro, one maintainer approved and merged 28 of the 31 factory PRs in September.[^11] Code production has been automated, but the merge decision remains both the throughput bottleneck and a single point of failure. Aider is a case where that single point of failure actually stopped. Aider itself wrote 21–88% of the new code in recent releases, yet once the maintainer got busy with other work, commits almost stopped.[^17] (Covered in Part 2.)

### 5.2 Requiring Evidence That a Test "Fails Before the Fix"

Agents easily produce meaningless tests that always pass. Five projects require or check evidence that a test fails before the fix. Bun attaches the pre-fix failure log to the PR description and treats a test that also passes on the existing release as invalid.[^18] At mastra, CI runs only the tests a PR changed against the pre-fix code to confirm they fail.[^19] The result is only attached as a label, however, and some PRs were merged while carrying the failure label. Vercel AI SDK stacks commits in the order reproduction → failing test → fix, then reruns the original reproduction to judge whether the issue is resolved.[^20] OpenClaw's and Astro's agents are also instructed to write a failing regression test before the fix. (Covered in Part 3.)

### 5.3 Agents Decide; Deterministic Code Executes What Is Hard to Undo

In the Claude Code repository, Claude judges whether an issue is a duplicate, but a rule-based script actually closes the issue after a grace period (three days for duplicates).[^21] Astro's factory does not give the write token to agents; it keeps it only in the workflow code for the commit and push steps.[^11] At mastra, the server prevents agents from moving a work card to "done," and only a merge marks a card as done.[^22] The boundary of delegation is implemented through permission structures rather than prompts. (Covered in Part 2.)

### 5.4 Turning Failures into Rules, Along with the Reasons

Beads' maintainer guidelines record, for each rule, the incident that produced it, with a date and PR number.[^23] Astro diagnosed the reason its agent often left out changesets as "instructions that let the model rationalize skipping it for a trivial fix" and rewrote those instructions.[^24] Bun built `REVIEW.md` by collecting only the reasons merges were blocked from the review history of about 2,500 merged PRs.[^25] Few projects, however, automatically measure whether the rules are actually followed. Astro's skill evaluations (evals) are not connected to CI. (Covered in Part 4.)

### 5.5 Placing Boundaries Where Work Starts and Where Results Are Confirmed

OpenAI Codex removed the workflow that turned issues into PRs in August 2025, citing "design issues."[^26] mastra wrote on its blog that it moved from automatic mode back to manual mode, and 82% of its bot PRs since September 22 record the person who started the work.[^27] Astro generates fixes automatically, but it does not open a PR until a person has confirmed the behavior with a preview release.[^28] OpenClaw limits automatic implementation to strict bugs and added a failure-rate circuit breaker. Many projects automate issue triage but require human confirmation or strict conditions before implementation starts or a PR is created.

### 5.6 Linking Agent Identity to Human Accountability in the Record

OpenHands splits PR descriptions into `HUMAN:` and `AGENT:` sections. Its instructions forbid agents from writing the `HUMAN:` section, and CI checks that the section contains human-written content of at least a minimum length.[^29][^30] Beads leaves an `Agent-Signature:` trailer on agent actions and tells agents to write `unknown-model` rather than guess when they do not know the model.[^31] mastra adds "Opened by @person" to bot PRs, and OpenClaw adds "Worked on by @person." Both what the agent did and who is accountable for the result are recorded together.

---

## 6. Problems Not Yet Solved

Among the public failures were cases where the code worked but missed the intent or effects outside the repository. Unlike code-quality problems, these failures are hard for tests and review bots to catch.

- **"It works" is not the same as "it matches the intent."** Astro's factory treated intended behavior as a bug and fixed it. A person confirmed the behavior and the fix was merged, then reverted before release.[^32] When a new issue was opened about the same problem, the factory produced the same fix again, and that PR was closed.[^33]
- **Effects outside the repository are invisible.** At OpenHands, an agent PR merged with only the AI review bot's approval was reverted because it could have made a feature unusable in another repository (enterprise).[^34] Neither CI nor the review bot could see that repository.
- **The person who merges sets the throughput.** As shown in 5.1, one person's time sets the speed of the entire factory.

I should also note the limits of this study. For projects with private engines, only the outputs are visible. Most figures come from September 2026 alone or from samples of the most recent 100–300 PRs. In projects where agent work is submitted under human accounts (such as OpenHands), the agent share can only be counted from signatures in PR descriptions, so it may be underestimated.

---

## Conclusion

When I analyzed OpenClaw seven months ago, the central question was how one person directs many agents. The projects I examined this time were asking something different: **what filters the agents' output, how far work can be delegated, and how failures are turned into rules**.

Software factories are already running in public repositories. But factories that run without people are still almost nonexistent. People write less of the code directly, but more of their work is now approving where work starts, merging, and turning failures into rules. And that work now sets both the speed and the quality of the factory.

The next post takes up the first question: "who merges?" I will compare the conditions that let OpenClaw hand merging over to bots with the reasons the other projects kept human merges, using the repositories' policy files and permission structures.

**Next:** [(2/4) Who Merges? Risk-based delegation and permission structures](/en/posts/software-factory-who-merges/)

---

[^1]: OpenClaw AGENTS.md: https://github.com/openclaw/openclaw/blob/main/AGENTS.md
[^2]: OpenClaw: Nine Best Practices from the World's Largest Vibe Coding Project: https://roboco.io/en/posts/openclaw-vibe-coding-best-practices/
[^3]: Beyond Vibe Coding, Toward the Software Factory: https://roboco.io/en/posts/beyond-vibe-coding-software-factory/
[^4]: StrongDM, Software Factory: https://factory.strongdm.ai/
[^5]: oven-sh/bun, PRs authored by robobun. PRs created and merged in September 2026, counted via the GitHub API (October 10, 2026): https://github.com/oven-sh/bun/pulls?q=is%3Apr+author%3Arobobun
[^6]: vercel/ai, merged PRs authored by the ai-sdk-factory bot. PRs merged in September 2026, counted via the GitHub API (October 10, 2026): https://github.com/vercel/ai/pulls?q=is%3Apr+is%3Amerged+author%3Aapp%2Fai-sdk-factory
[^7]: Vercel, "Building a software factory for AI SDK": https://vercel.com/blog/building-a-software-factory-for-ai-sdk
[^8]: mastra-ai/mastra, merged PRs authored by the mastra-platform bot. PRs merged in September 2026, counted via the GitHub API (October 10, 2026): https://github.com/mastra-ai/mastra/pulls?q=is%3Apr+is%3Amerged+author%3Aapp%2Fmastra-platform
[^9]: openai/codex PR #49713: https://github.com/openai/codex/pull/49713
[^10]: openclaw/clawsweeper README: https://github.com/openclaw/clawsweeper/blob/main/README.md
[^11]: withastro/factory README: https://github.com/withastro/factory
[^12]: OpenClaw docs-agent.yml: https://github.com/openclaw/openclaw/blob/main/.github/workflows/docs-agent.yml
[^13]: OpenClaw security-review-policy.yml: https://github.com/openclaw/openclaw/blob/main/.github/security-review-policy.yml
[^14]: openclaw/clawsweeper PR #1855: https://github.com/openclaw/clawsweeper/pull/1855
[^15]: OpenClaw commit 9c831c7551, "chore: retire CLAUDE.md files": https://github.com/openclaw/openclaw/commit/9c831c7551
[^16]: OpenClaw PR #132968: https://github.com/openclaw/openclaw/pull/132968
[^17]: Aider issue #4613, "Where is Paul?": https://github.com/Aider-AI/aider/issues/4613
[^18]: oven-sh/bun CLAUDE.md: https://github.com/oven-sh/bun/blob/main/CLAUDE.md
[^19]: mastra changed-test-gate.yml: https://github.com/mastra-ai/mastra/blob/main/.github/workflows/changed-test-gate.yml
[^20]: vercel/ai PR #22424: https://github.com/vercel/ai/pull/22424
[^21]: anthropics/claude-code issue-lifecycle.ts: https://github.com/anthropics/claude-code/blob/main/scripts/issue-lifecycle.ts
[^22]: Mastra Factory README, Board transition policy: https://github.com/mastra-ai/mastra/blob/main/mastracode/factory/README.md
[^23]: gastownhall/beads PR_MAINTAINER_GUIDELINES.md: https://github.com/gastownhall/beads/blob/main/PR_MAINTAINER_GUIDELINES.md
[^24]: withastro/astro PR #17475: https://github.com/withastro/astro/pull/17475
[^25]: oven-sh/bun REVIEW.md: https://github.com/oven-sh/bun/blob/main/REVIEW.md
[^26]: openai/codex PR #2729: https://github.com/openai/codex/pull/2729
[^27]: Mastra, "Announcing Mastra Factory Beta": https://mastra.ai/blog/announcing-mastra-factory-beta
[^28]: withastro/astro factory.yml: https://github.com/withastro/astro/blob/main/.github/factory.yml
[^29]: OpenHands PR template: https://github.com/OpenHands/OpenHands/blob/main/.github/pull_request_template.md
[^30]: OpenHands check_pr_description.py: https://github.com/OpenHands/OpenHands/blob/main/.github/scripts/check_pr_description.py
[^31]: gastownhall/beads AGENT_SIGNING.md: https://github.com/gastownhall/beads/blob/main/engdocs/AGENT_SIGNING.md
[^32]: withastro/astro PR #18030, "Revert forwarding user class to Picture's outer element": https://github.com/withastro/astro/pull/18030
[^33]: withastro/astro PR #18052: https://github.com/withastro/astro/pull/18052
[^34]: OpenHands PR #18048: https://github.com/OpenHands/OpenHands/pull/18048
