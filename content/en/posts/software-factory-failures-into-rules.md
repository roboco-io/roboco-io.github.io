---
title: "Software Factory Best Practices from Open-Source Projects (4/4): Turning Failures into Rules"
date: 2026-10-10T10:00:00+09:00
draft: false
toc: false
images:
tags:
  - software-factory
  - agentic-dev
  - agents-md
  - continuous-improvement
  - best-practices
---

> "The lane has no rate gate, and I found no reason for that." – OpenClaw ClawSweeper PR #1855[^1]

{{< figure src="/posts/images/Dohyun.png" title="Dohyun Jung - Principal Consultant, ROBOCO" style=".author-image">}}

---

This is the final post in the four-part series "Software Factory Best Practices from Open-Source Projects."

**The series**

1. [The Criteria and 12 Repositories: what counts as a factory, and where factories are running](/en/posts/software-factory-best-practices-from-open-source/)
2. [Who Merges? Risk-based delegation and permission structures](/en/posts/software-factory-who-merges/)
3. [Factories That Filter by Evidence: proving a test "fails before the fix"](/en/posts/software-factory-evidence-before-fix/)
4. Turning Failures into Rules: self-improvement loops and their limits (this post)

The quote at the top comes from a PR filed after OpenClaw's automatic implementation worker succeeded 52 times and failed 256 times in a single week. That PR added a mechanism that stops automatic implementation when the failure rate is high.[^1] Detect a failure, find its cause, and change a rule or mechanism so it does not happen again. This is the self-improvement loop, the sixth of the criteria defined in [Part 1](/en/posts/software-factory-best-practices-from-open-source/).[^2]

In [Part 3](/en/posts/software-factory-evidence-before-fix/), we saw that even evidence mechanisms can be bypassed or can miss the intent.[^3] This post deals with what happens after such failures. Where, and in what form, do projects feed failures back in? And where does the loop break? As in the earlier posts, all figures were retrieved through the GitHub API on October 10, 2026.

## TL;DR

- The factories I observed feed failures back into four places: agent instructions and skills, CI checks, mechanisms in servers or workflows, and decisions to stop or scale back automation.
- Based on these cases, I recommend three things: record failures together with their evidence, look for causes in the instructions and mechanisms rather than in the agent, and where possible fix the instructions and the CI checks together.
- In this survey of public material, operational records of the last step, verifying the effect, were limited. There are many records of rules being added, but records of automatically and regularly checking whether those rules are followed were hard to find. There is also a case where a reverted decision was not remembered and the same mistake was repeated.

---

## 1. The Four Steps of a Self-Improvement Loop

A self-improvement loop can be divided into four steps: detect the failure, diagnose the cause, turn it into a rule or mechanism, and verify the effect. Here is how each step showed up in the repositories.

| Step | Examples observed in repositories |
|---|---|
| 1. Detection | OpenClaw's failure-rate tally, OpenHands' daily verification, Beads' audit of 440 merged PRs, Vercel AI SDK's `factory-flawed` label |
| 2. Diagnosis | Astro's diagnosis of "room for rationalization," OpenClaw's discovery of truncated instructions, Claude Code's discovery of a permission-mode malfunction |
| 3. Codification | Instruction changes in Beads, OpenClaw, and Bun; skill changes in Astro; a server-side mechanism added in mastra; OpenClaw's circuit breaker |
| 4. Verifying the effect | Limited public records. Astro built skill evaluations (evals) but did not connect them to CI |

The first three steps were observed across several projects. The fourth was barely confirmable from public records alone in this survey. I come back to this gap later in the post.

---

## 2. Record Failures Together with Their Evidence

If you keep the rule but erase the reason, you can no longer judge later whether the rule should stay or go. Agents, too, have to guess the rule's scope. The projects that work well leave the incident that produced a rule right next to the rule.

Beads is the most thorough. The "Merge Discipline" section of its maintainer guidelines was added on June 12, 2026, and cites as its basis a two-month audit of 440 merged PRs.[^4] The "Prior art" section was added on July 27, 2026, and records an incident from the day before as its "Motivating incident." While a 44-day-old PR sat ready to merge for 20 days, a 5-day-old duplicate PR was auto-merged without a single comment. As a result, searching for open PRs on the same topic became mandatory before every review.[^5] The comments in `CODEOWNERS` also record the PR numbers that caused migration incidents.[^6]

Bun used its records in reverse. From the review history of about 2,500 merged PRs where review feedback led to fix commits, it collected only the reasons that blocked merging and turned them into `REVIEW.md`. This file serves as part of the agent instructions. The review bot also appears to use the file as its standard, but I could not confirm the wiring in the public repository.[^7] OpenClaw lists the real defects behind a change in the body of the PR that changes the instructions. One PR in October 2026 enumerated five defects that unit tests had missed, then changed the testing guidelines.[^8]

---

## 3. Look for Causes in Instructions and Mechanisms

If you conclude that "the agent wasn't good enough" when it makes a mistake, there is nothing to fix. The projects I observed looked for causes in the instructions and mechanisms given to the agent.

### 3.1 The Instructions Allowed Rationalization

PRs created by Astro's factory often arrived without a changeset (a file recording changes for the release notes). Astro diagnosed the cause as instructions worded in a way that let the LLM rationalize skipping the changeset for minor fixes. It then rewrote changeset creation, previously an optional step, as mandatory, deleted the wording that allowed exceptions, and added a step to check `git status` right before finishing the task.[^9] The Astro repository shows a series of such fixes.

| Date | Observed failure | Skill change |
|---|---|---|
| 2026-05-20 | Confirmed the bug early, but wrestled with a stale server, timed out, and never wrote the report | A rule to give up after two failed server starts[^10] |
| 2026-07-20 | Some bot PRs failed lint and type checks | Stricter checks and a token-saving `lint:ai` command[^11] |
| 2026-08-20 | Bot PRs frequently missed changesets | The instruction rewrite described above[^9] |
| 2026-09-28 | Bot PRs included entries from a temporary reproduction environment in `pnpm-lock.yaml` | Lockfile restoration added to the cleanup step[^12] |

In the last case, the fix was merged about four hours after the issue was opened. The factory bot made the fix commit itself.

### 3.2 The Instructions Were So Long They Got Truncated

OpenClaw discovered that `AGENTS.md` was truncated at 20,000 characters when injected into the agent. The agent had been seeing only fragments of the core rules. So the team cut the file from 27,913 characters to 18,900 and moved detailed rules into the skills responsible for each area.[^13] The case shows that instruction files need a length budget too.

The comments in Beads' `CODEOWNERS` carry a different kind of warning. Quietly adding defensive code had piled up eight or more stopgap commits before anyone wrote an architecture decision record (ADR).[^6] I read it as a warning that adding a rule for every symptom, without sorting out the cause, turns the rules themselves into debt.

### 3.3 Fix Instructions and CI Together

There are also many cases of blocking the same failure at two layers. Bun blocks agents from writing verbose code comments with a rule in its instructions, and at the same time runs a CI check (`comment-cop`) that looks for new comments of two or more lines in `src/` changes in agent PRs labeled `claude` and asks for their removal. Comments marked `SAFETY:` are exempt.[^14] The Claude Code repository discovered that its issue-deduplication job had not been running in the intended permission mode because of an older model, and in the same PR added a workflow security check script along with a `CLAUDE.md` rule telling agents not to skip or weaken that check.[^15] When OpenAI Codex's review bot repeatedly and wrongly demanded lockfile changes, the team wrote into `AGENTS.md` that the review bot should not make such demands.[^16] OpenHands defines user paths that cannot be verified with existing tools as "harness gaps," and requires extending the verification tooling itself rather than working around it with one-off scripts.[^17]

---

## 4. Agents Fix Their Own Rules

What is new is that agents edit their own instructions directly. Most of these edits, however, were directed or approved by people.

- OpenClaw's root `AGENTS.md` has been modified 456 times since March 2026. The most frequent author is the maintainer steipete with 320, and roboclaw-bot, an agent running on the OpenClaw product, also files edit PRs directly.[^18] The five-defect PR mentioned earlier was filed by roboclaw-bot.
- Of the 50 commits to Bun's `CLAUDE.md`, 4 were written by robobun and 32 (64%) by a single maintainer.[^19] robobun also built, on its own, a workflow that automatically closes its own PRs that have gone 90 days without an update[^20], and later fixed it twice.[^21][^22]
- Of the 20 commits to mastra's review skill (July 23–September 30, 2026), 3 were written by a bot.[^23] After an incident in which the review bot reused an earlier verdict body and posted a review mixing "approve" and "request changes," the fix that makes it check the verdict against the commit right before posting was also written by the bot. That PR, however, records the person who started the work.[^24]
- Astro's lockfile fix commit was made by the factory bot, and a person opened, approved, and merged the PR.[^12]

Among these, in Astro's case the instruction change came in as an ordinary PR that a person approved and merged, and in mastra's case it also came in as an ordinary PR that a person merged. I think this matters. As long as instruction changes receive the same review as code changes, agents editing their own instructions are less a risk than a way to run the self-improvement loop faster.

---

## 5. Fix or Stop the Automation Itself

When failures repeat, deciding to scale back automation instead of adding rules is also part of the loop.

- When OpenClaw's automatic implementation success rate dropped to 16.9% and failed runs consumed 123 hours of work time, it added a success-rate-based circuit breaker.[^1] Earlier, in July 2026, it scrapped a commit review lane outright after it had not succeeded even once in its final month.[^25]
- mastra said it ran its factory in automatic mode, but when PRs poured in so fast that review became difficult, it switched to manual mode.[^26]
- OpenAI Codex removed a workflow that turned issues into PRs, citing "design problems."[^27]

A decision to stop automation is not an admission of failure but an adjustment that fits the scope of automation to its actual success rate. OpenClaw's circuit breaker turned this adjustment from a human decision into a threshold.

---

## 6. Where the Loop Breaks

That is the part that works well. Looking deeper into the repositories, the points where the loop breaks are also clear.

- **There are no records of regularly measuring the effect.** Astro created 24 evaluation cases for 8 skills, but did not connect them to CI, citing cost and nondeterminism. As of the observation date, 6 of the 8 evaluation files had not changed since they were first added on August 13, 2026, and the missing changesets and lockfile leaks in the table above had not been added as evaluation cases.[^28] Records of manual runs are not kept in the repository, so I could not check them. Within what I could confirm in this survey, rules were created, but there was no mechanism that automatically and regularly checks whether those rules are followed.
- **Reverted decisions are not remembered.** A fix in which Astro's factory treated intended behavior as a bug was reverted after merging. Yet when a new issue was opened about the same problem, the factory produced the same fix again.[^29] As of the observation date, the related skill had not changed. I see this as a case where a reverted decision was not carried over to the next task.
- **Rules live only in documents.** Beads' rule that "schema changes are reviewed by a person, without exception" is not enforced by branch rules.[^30] Bun's `CLAUDE.md` says branch names should start with `claude/`, but robobun's actual branches start with `robobun/`.[^31]
- **Externally reported automation bugs remain.** In the Claude Code repository, bug reports about automatic closing of duplicate issues are open as of the observation date. One reports that the notice says anyone's objection can prevent the automatic close, while the code honors only the issue author's objection. Another reports that the automatic close overwrites the label list with `duplicate` alone, erasing other labels such as area and platform.[^32][^33]
- **The loop disappears outside the repository.** Vercel AI SDK publishes its failure classification as labels (11 `factory-flawed`, 60 `factory-blocked`), but the prompts and evaluation sets that would take those failures and fix them live outside the repository.[^34] OpenAI Codex left a record of an improvement loop between its review bot and `AGENTS.md` running in the public repository, but on September 30, 2026, it deleted `AGENTS.md` and its skills from the public repository.[^35]

In [Beyond Vibe Coding, Toward the Software Factory](/en/posts/beyond-vibe-coding-software-factory/), which I wrote in September, I said: "Those improvements must themselves be verified. If a system arbitrarily changes its own success criteria, the claim that it has improved becomes difficult to trust."[^36] The projects I observed guard against part of this risk. Astro's factory reads the review rules of the target branch rather than those of the PR[^37], and StrongDM explains that it keeps its verification scenarios outside the code repository.[^38] But from public records alone, this survey could not identify any project that regularly measures whether improvements actually worked.

---

## 7. Best Practices

1. **For every rule, record the incident that produced it, with a date and PR number.** It becomes the basis for later deciding whether to keep or remove the rule. (Beads, OpenClaw)
2. **Extract the reasons that blocked merging from review history and turn them into a rules document that both agents and the review bot read.** (Bun)
3. **Look for the cause of failures in the instructions.** Find and delete optional wording and exception clauses that give the agent room to rationalize. (Astro)
4. **Give instruction files a length budget, and split detailed rules into the skills responsible for them.** (OpenClaw)
5. **Block the same failure at two layers: instructions and CI checks.** (Bun, Claude Code)
6. **Put agents' edits to instructions through the same PR review as code changes.** (OpenClaw, Bun, mastra, Astro)
7. **Track the success rate of every automation lane, and stop it automatically when it falls below a threshold.** (OpenClaw)
8. **When you create a new rule, add evaluation cases with it, and run those evaluations regularly.** In the public records of this survey, I could not identify anyone doing this regularly. This is my proposal, based on Astro's case.

---

## Closing the Series

Over four posts, I reverse engineered 12 public repositories. In Part 1, I set out the criteria and judged 8 of them to be software factories. Part 2 covered merge authority, Part 3 covered verification evidence, and this post covered self-improvement loops.

My conclusion across the three topics is a single one. In these cases, the key to protecting a factory's quality was **the mechanisms around the agents**. Those mechanisms are risk tiers that define what may be merged automatically, evidence that stands in for the agent's claims, and the habit of turning failures into rules together with their evidence. And because most of these mechanisms remain as files in public repositories, anyone can read them and adapt them for their own team.

At the same time, the place of people became clear. In many cases, people approved the start of work, merged, and fixed rules based on failures, and when needed, took part directly in implementation. The problems not yet solved, namely confirming intent, seeing impact outside the repository, and measuring the effect of improvements, are also for people to handle for now. The next stage of factories will probably be decided by how these three are turned into mechanisms.

---

[^1]: openclaw/clawsweeper PR #1855: https://github.com/openclaw/clawsweeper/pull/1855
[^2]: Software Factory Best Practices from Open-Source Projects (1/4): The Criteria and 12 Repositories: https://roboco.io/en/posts/software-factory-best-practices-from-open-source/
[^3]: Software Factory Best Practices from Open-Source Projects (3/4): Factories That Filter by Evidence: https://roboco.io/en/posts/software-factory-evidence-before-fix/
[^4]: gastownhall/beads commit 9a9da38c: https://github.com/gastownhall/beads/commit/9a9da38c
[^5]: gastownhall/beads commit c989b6b8: https://github.com/gastownhall/beads/commit/c989b6b8
[^6]: gastownhall/beads CODEOWNERS: https://github.com/gastownhall/beads/blob/main/.github/CODEOWNERS
[^7]: oven-sh/bun REVIEW.md: https://github.com/oven-sh/bun/blob/main/REVIEW.md
[^8]: OpenClaw PR #168083: https://github.com/openclaw/openclaw/pull/168083
[^9]: withastro/astro PR #17475: https://github.com/withastro/astro/pull/17475
[^10]: withastro/astro PR #16802: https://github.com/withastro/astro/pull/16802
[^11]: withastro/astro PR #17352: https://github.com/withastro/astro/pull/17352
[^12]: withastro/astro PR #18168: https://github.com/withastro/astro/pull/18168
[^13]: OpenClaw PR #163325: https://github.com/openclaw/openclaw/pull/163325
[^14]: oven-sh/bun comment-cop.yml: https://github.com/oven-sh/bun/blob/main/.github/workflows/comment-cop.yml
[^15]: anthropics/claude-code PR #97952: https://github.com/anthropics/claude-code/pull/97952
[^16]: openai/codex PR #29720: https://github.com/openai/codex/pull/29720
[^17]: OpenHands verify-openhands skill: https://github.com/OpenHands/OpenHands/blob/main/.agents/skills/verify-openhands/SKILL.md
[^18]: OpenClaw AGENTS.md commit history: https://github.com/openclaw/openclaw/commits/main/AGENTS.md
[^19]: oven-sh/bun CLAUDE.md commit history. Commits per author tallied via the GitHub API (2026-10-10): https://github.com/oven-sh/bun/commits/main/CLAUDE.md
[^20]: oven-sh/bun PR #27125: https://github.com/oven-sh/bun/pull/27125
[^21]: oven-sh/bun PR #27126: https://github.com/oven-sh/bun/pull/27126
[^22]: oven-sh/bun PR #41079: https://github.com/oven-sh/bun/pull/41079
[^23]: mastra factory-review skill commit history. Commits per author tallied via the GitHub API (2026-10-10): https://github.com/mastra-ai/mastra/commits/main/mastracode/factory/factory-skills/factory-review/SKILL.md
[^24]: mastra-ai/mastra PR #25494: https://github.com/mastra-ai/mastra/pull/25494
[^25]: openclaw/clawsweeper README: https://github.com/openclaw/clawsweeper/blob/main/README.md
[^26]: Mastra, "Announcing Mastra Factory Beta": https://mastra.ai/blog/announcing-mastra-factory-beta
[^27]: openai/codex PR #2729: https://github.com/openai/codex/pull/2729
[^28]: withastro/astro .agents/evals README: https://github.com/withastro/astro/blob/main/.agents/evals/README.md
[^29]: withastro/astro PR #18052: https://github.com/withastro/astro/pull/18052
[^30]: gastownhall/beads PR_MAINTAINER_GUIDELINES.md: https://github.com/gastownhall/beads/blob/main/PR_MAINTAINER_GUIDELINES.md
[^31]: oven-sh/bun CLAUDE.md: https://github.com/oven-sh/bun/blob/main/CLAUDE.md
[^32]: anthropics/claude-code issue #79146: https://github.com/anthropics/claude-code/issues/79146
[^33]: anthropics/claude-code issue #98160: https://github.com/anthropics/claude-code/issues/98160
[^34]: vercel/ai label list. Items per label tallied via the GitHub API (2026-10-10): https://github.com/vercel/ai/labels
[^35]: openai/codex PR #49713: https://github.com/openai/codex/pull/49713
[^36]: Beyond Vibe Coding, Toward the Software Factory: https://roboco.io/en/posts/beyond-vibe-coding-software-factory/
[^37]: withastro/factory README: https://github.com/withastro/factory
[^38]: StrongDM, Software Factory: https://factory.strongdm.ai/
