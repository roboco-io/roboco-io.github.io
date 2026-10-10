---
title: "Software Factory Best Practices from Open-Source Projects (2/4): Who Merges?"
date: 2026-10-10T10:00:00+09:00
draft: false
toc: false
images:
tags:
  - software-factory
  - agentic-dev
  - openclaw
  - code-review
  - best-practices
---

> "(Changes to migration, schema, and sync paths get) a real human review before merge — no exceptions, no self-merge, no bot-only approval." – Beads `PR_MAINTAINER_GUIDELINES.md`[^1]

{{< figure src="/posts/images/Dohyun.png" title="Dohyun Jung - Principal Consultant, ROBOCO" style=".author-image">}}

---

This is the second post in the four-part series "Software Factory Best Practices from Open-Source Projects."

**The series**

1. [The Criteria and 12 Repositories: what counts as a factory, and where factories are running](/en/posts/software-factory-best-practices-from-open-source/)
2. Who Merges? Risk-based delegation and permission structures (this post)
3. [Factories That Filter by Evidence: proving a test "fails before the fix"](/en/posts/software-factory-evidence-before-fix/)
4. [Turning Failures into Rules: self-improvement loops and their limits](/en/posts/software-factory-failures-into-rules/)

In [Part 1](/en/posts/software-factory-best-practices-from-open-source/), I reverse-engineered 12 public repositories and classified eight of them as software factories.[^2] Of those, OpenClaw was the only one where I confirmed bots merging into the main branch at scale. In the other factories, final merges were mostly made by people, and those merges were usually concentrated in one person.

This post digs into that difference. Under what conditions did OpenClaw hand merging over to a bot? Why did the projects where I observed merges by human accounts not hand merging to bots, and what do they use instead to limit what agents can do? As in Part 1, all figures were retrieved through the GitHub API on October 10, 2026.

## TL;DR

- OpenClaw grants automation different permissions for each risk tier of change. For documentation changes, an agent pushes directly to main; for ordinary code, a bot merges once the gates pass; for security policy and releases, a person approves. These tiers are defined in policy files and CODEOWNERS.
- In the repositories of the projects where I observed merges by human accounts, I can read three reasons behind that choice: the structural constraint that a GitHub App cannot approve its own PRs, the experience that merges which skipped review caused incidents, and the principle that people decide what to build and whether a change matches the intent.
- A record of a human merge is not a record of a human review. In Bun, 82% of bot PRs were merged while GitHub's approval requirement was still outstanding, and in OpenHands, many PRs met the required approval with nothing more than an AI review bot's approval. What matters more than who holds merge authority is what you make them check before they exercise it.

---

## 1. The Spectrum of Merge Authority

First, I gathered in one table how the projects classified as factories handle merging. "Merge concentration" is the share of merges in the given set of PRs made by the single account that merged the most. Branch rules were confirmed by querying the rules on the main branch through the GitHub API.[^3]

| Project | Merge gate (branch rules) | Observed merger | Merge concentration |
|---|---|---|---|
| OpenClaw | 1 required check, 0 required approvals + approval required only for CODEOWNERS paths | Bots merged 203 of the 300 most recent merges | - |
| Vercel AI SDK | 1 required approval + 4 required checks | All 294 factory PRs in September were merged by people in an approved state | 63% of 294 |
| OpenHands | 1 required check + 1 required approval | All 100 most recent merges were made by people | 69% of 100 |
| Beads | 2 required checks + merge queue | One account merged 296 of the 300 most recent merges | 99% |
| mastra | Could not confirm through the public API | All 434 bot PRs in September were merged by people | 82% |
| Bun | Could not confirm through the public API | People merged 443 of the 446 robobun PRs in September | 78% |
| Astro | Required check list is empty | All 31 factory PRs in September were approved and merged by people | 28 of 31 |

As the left column shows, the key to allowing bot merges is the branch rules. OpenClaw's main branch requires zero approvals. Instead, it requires approval from the relevant team for paths designated in CODEOWNERS, and it dismisses earlier approvals when new commits are pushed.[^4] By contrast, Vercel AI SDK and OpenHands require at least one approval. Under that condition, a factory App cannot satisfy the approval requirement on a PR it opened itself. It does not, however, stop another bot from approving. In OpenHands, many merges actually happened that way (Section 5).

---

## 2. The Conditions Under Which OpenClaw Let a Bot Merge

The bot that merges in OpenClaw is the maintenance bot ClawSweeper. ClawSweeper does not merge just any PR. The automerge conditions listed in its README are as follows. The review verdict on the latest commit (the exact head) must pass, every required check must pass, and the PR must be in a mergeable state. Security checks, the maintainer's stop and approval states, and the repository's policy gates must all pass as well.[^5] As of the observation date, 576 of the 803 PRs labeled `clawsweeper:automerge` had been merged.

What matters is that this automerge is **opt-in**. A PR becomes eligible for automerge only when a maintainer writes `@clawsweeper automerge` on it, and writing `@clawsweeper stop` halts automerge and adds a human-review label. Only people with write access can use these commands. As of the observation date, 210 items carried the `clawsweeper:human-review` label.[^5]

On top of that, what automation may do depends on the kind of change. Putting the repository's files together reveals the risk tiers below.

| Kind of change | Automation permission | Source file |
|---|---|---|
| Documentation (`docs/*`, README, existing CHANGELOG mirrors) | The Docs Agent may only update existing files in allowed paths and regenerate mirrors. It fails if it adds or deletes files or edits other paths; if it passes, it pushes directly to main with no PR | `docs-agent.yml`[^6] |
| Ordinary code | A bot merges once required checks and bot review pass and a maintainer opts in | ClawSweeper README[^5] |
| PRs auto-generated from issues | Not automerged. A person merges | ClawSweeper README[^5] |
| Sensitive paths (authentication, etc.) | Authors without maintainer permission (agents included) must receive an approval command | `security-review-policy.yml`[^7] |
| Security policy and CI security configuration files | An independent review by the SecOps team is required regardless of author | `CODEOWNERS`[^4] |
| Release and deployment, dependencies, schema and permission changes | Explicit human approval required | `AGENTS.md`[^8] |

`security-review-policy.yml`, which defines the sensitive paths, lists path patterns by category, such as authentication, and excludes test and documentation paths. Under a change made in September 2026, authors without maintainer permission must get a maintainer's approval through a command such as `/allow-security-sensitive-change`. This includes the agent account that runs on the OpenClaw product itself (roboclaw-bot).[^9] The comment on the first line of `CODEOWNERS` reads "Hard security tier: an independent SecOps review is required for every author." It has 18 entries in this tier, and 5 entries owned by the release managers team.[^4]

`AGENTS.md` keeps a list of things that need explicit human approval: protocol and version changes, dependency patches, paid services, releases and deployments, new configuration options, changes that break public contracts, schema, retention, and permission changes, destructive operations, and bulk closures of more than 50 items. Conversely, bug fixes within the scope of the task may proceed without asking for approval again.[^8] The line quoted at the top of Part 1, "fix/ship authority is not release authority," sums up this list.

In short, there were three conditions that let OpenClaw hand merging to a bot. First, the scope of changes a bot may merge is defined in files. Second, high-risk changes, such as security policy files and sensitive paths, are blocked mechanically by CODEOWNERS and security guards. The remaining approval requirements, such as for releases and dependencies, are set as guidelines in `AGENTS.md`, and releases start only through a manually triggered workflow. I could not confirm through the public API whether required reviewers are configured on the release environment. Third, people can withdraw the opt-in and stop the automation at any time.

---

## 3. Why Human Merges Were Kept

Why did the projects where I observed merges by human accounts not hand merging to bots? There are three lines of reasoning I can read from their repositories. In some cases the project states the reason directly; in others I inferred it from the mechanisms in place.

### 3.1 A GitHub App Cannot Approve Its Own PRs

The factories at Astro, mastra, and Vercel AI SDK all create PRs through GitHub Apps. GitHub does not let an App approve a PR it opened itself. So Astro's reviewer persona leaves its verdict as a comment rather than an approving review, and mastra's review agent likewise posts its verdict on its own PRs as a regular comment.[^10][^11] In repositories that require at least one approval, a factory App cannot satisfy the approval requirement on its own PRs, so unless another bot approves, human approval remains. Vercel AI SDK uses a personal token to automerge release PRs, and a comment in the workflow explains why: "this should really be an app token. But for that we would need to register a secondary app, since the vercel=ai-sdk app already creates the pull request and it cannot approve its own pull requests."[^12]

### 3.2 Merges That Skipped Review Caused Incidents

After auditing 440 merged PRs over two months, Beads concluded that the project's worst defects entered through "merges that skipped review, hid their real contents, or overrode an outstanding objection." As a result, it banned self-merging of non-trivial PRs and, as in the quote at the top of this post, required human review with no exceptions for migration, schema, and sync paths.[^1] There is in fact a record of a migration PR, self-merged with zero reviews, that caused data corruption.[^13]

That rule, however, still exists only on paper. As of the observation date, Beads's branch rules require only required checks and a merge queue, with no required review. The document itself says "These paths should be enforced by branch protection (review-required), not just convention," and leaves that work as a task for the project owner.[^1]

### 3.3 Someone Needs to Judge Intent

Astro's factory documentation states that the authoring agent "never merges." The authoring agent responds to reviewers' change requests or CI failures for up to five rounds, and when it has used up that budget, it adds the `factory: needs human` label and steps away.[^10] mastra's server blocks issues that are not bugs (such as feature requests) from moving to the planning stage without a record of human acceptance. As of the observation date, 50 open issues were waiting for that approval.[^11] The principle is that people decide what to build and whether a change matches the intent.

On code review, StrongDM took the opposite approach. StrongDM, too, keeps the points where a person provides the initial specification and answers the agent's questions. But it has a rule that "Code must not be reviewed by humans," and explains that instead of human review, it validates with scenarios kept outside the code repository.[^14] As discussed in Part 1, however, that operation cannot be observed in a public repository.

---

## 4. How to Implement Permissions in Code

Even when people merge, what agents can do still has to be narrowed. The projects I observed implemented this boundary through permission structures, not prompts. The shared principle is that **the agent makes the judgment, and rule-based code performs actions that are hard to undo**.

- **Narrow the write tools and cap how often they can be used.** The issue triage agent in the Claude Code repository can use only a read-only GitHub command wrapper and a label-editing script. The label-editing script can be called at most twice per run, and file editing and web access are prohibited. The reason is that anyone can open an issue and trigger this job.[^15]
- **Have a script perform hard-to-undo actions after a grace period.** In the same repository, actually closing issues is done not by the agent but by a rule-based script. There is a grace period of 3 days for duplicate candidates, 7 days for information requests, and 14 days for stale issues.[^16] A duplicate candidate is not closed if the issue author reacts with a thumbs-down or a new comment is added.[^17] Issues with 10 or more upvotes or with an assignee are excluded from stale-issue handling.[^18]
- **Do not give write tokens to agents.** In Astro's factory, the write token exists only in the workflow code for the commit and push steps. The classifier and the behavior-checking agent have no tools, and the reviewer uses only read-only tools. Review settings and skills are read from the target branch, not the PR's branch. So even if a PR changes the review rules along with its code, those changes do not apply to that PR's own review.[^10] OpenAI Codex's issue automation likewise runs Codex in a read-only sandbox, and a separate job without Codex handles posting comments.[^19]
- **Have the server check state transitions.** mastra's factory server processes every transition of a work card in a revision-checked transaction, and a transition that a person must make passes only if both the requesting actor and the path the request came through are human. Agents cannot move a card to done; only a merge moves a card to done.[^11]
- **Recheck the state right before acting.** Before pushing to a contributor's branch, OpenClaw's ClawSweeper waits 90 seconds, rereads the PR's latest commit, and if it has changed in the meantime, re-queues the work instead of pushing.[^5]

---

## 5. A Record of a Human Merge Is Not a Record of a Human Review

In Part 1, I wrote that merges are concentrated in one person. Looking more closely, something stands out even more than the concentration: in many cases there is a record of the merge but no record of a review.

- Of the 446 robobun PRs merged in Bun in September, 368 (82%) were merged with maintainer privileges while GitHub still showed the approval requirement as outstanding (`REVIEW_REQUIRED`).[^20] The records cannot tell us how carefully the person who merged actually reviewed them. On the record, the person who merged is the final decision-maker.
- In mastra, there were cases where a person merged a bot PR as-is even though the factory's review agent had most recently requested changes on it. That was 3 of 27 in the sample, and 14 of September's bot PRs by label.[^21]
- OpenHands requires one approval, but 26 of the 40 most recently merged PRs met that requirement with only an AI review bot's approval.[^22] One agent PR merged that way was reverted by a person on the grounds that it could break functionality in another repository.[^23]

By contrast, all 294 of Vercel AI SDK's September factory PRs were merged by people in an approved (`APPROVED`) state. I checked whether the approvers were human in a sample of 20, and all of them were.[^24] In addition, backport PRs for bot PRs assign the person who last reviewed the original PR.[^25] I read this as a mechanism that hands follow-up work to the person who did the review.

---

## 6. Best Practices

Here are the mechanisms I observed, organized in a form other teams can adopt. Each item notes the projects it is based on.

1. **Define risk tiers by kind of change in files, and give automation different permissions for each tier.** Separate documentation, ordinary code, sensitive paths, security policy, and releases, and enforce high-risk tiers such as security policy and sensitive paths mechanically with CODEOWNERS and security guards. (OpenClaw)
2. **Start bot automerge as opt-in, and let people stop it at any time.** Provide a stop command and a human-review label, and restrict who can use that command to people with write access. (OpenClaw)
3. **Do not give agents write tokens; let writes happen only in narrow, dedicated steps.** Limit write tools down to the number of calls. (Astro, Claude Code, OpenAI Codex)
4. **Have rule-based scripts perform hard-to-undo actions, after a grace period and a check for objection signals.** (Claude Code)
5. **Enforce review rules with branch rules, not documents.** A rule that exists only in a document may not be followed. (The lesson from Beads)
6. **Keep a record of approvals and reviews, and assign the person who reviewed to the follow-up work.** (Vercel AI SDK)

Finally, I will add one suggestion that came out of these observations. In the public material, I found no sign that anyone tracks as a metric how heavily merges are concentrated in one person. But as we saw in Part 1, code development at Aider dropped sharply when the maintainer got busy with other work. The issue-cleanup bot is still running, but there is no one to merge code. Simply checking merge concentration and the share of PRs merged without approval on a regular basis is enough to spot a factory's single point of failure in advance. This is not a fact observed in the repositories, but my own suggestion based on those observations.

---

## Conclusion

The answer to "who merges?" turned out to be less simple than I expected. OpenClaw handed merging to a bot, but in exchange it carefully designed risk tiers, branch rules, and opt-in and stop commands. The other projects kept human merges, but what those people actually checked varied widely from project to project.

In the end, what determines a factory's safety is not who you give merge authority to, but what you enforce to be checked before a merge. The next post covers the core of that checking: evidence. I will look at how projects make agents prove that their fixes really solved the problem, focusing on evidence that a test "fails before the fix."

**Next:** [(3/4) Factories That Filter by Evidence: proving a test "fails before the fix"](/en/posts/software-factory-evidence-before-fix/)

---

[^1]: gastownhall/beads PR_MAINTAINER_GUIDELINES.md: https://github.com/gastownhall/beads/blob/main/PR_MAINTAINER_GUIDELINES.md
[^2]: Software Factory Best Practices from Open-Source Projects (1/4): The Criteria and 12 Repositories: https://roboco.io/en/posts/software-factory-best-practices-from-open-source/
[^3]: GitHub REST API, querying branch rules with `GET /repos/{owner}/{repo}/rules/branches/main` (2026-10-10): https://docs.github.com/en/rest/repos/rules
[^4]: OpenClaw CODEOWNERS: https://github.com/openclaw/openclaw/blob/main/.github/CODEOWNERS
[^5]: openclaw/clawsweeper README: https://github.com/openclaw/clawsweeper/blob/main/README.md
[^6]: OpenClaw docs-agent.yml: https://github.com/openclaw/openclaw/blob/main/.github/workflows/docs-agent.yml
[^7]: OpenClaw security-review-policy.yml: https://github.com/openclaw/openclaw/blob/main/.github/security-review-policy.yml
[^8]: OpenClaw AGENTS.md: https://github.com/openclaw/openclaw/blob/main/AGENTS.md
[^9]: OpenClaw PR #152415: https://github.com/openclaw/openclaw/pull/152415
[^10]: withastro/factory README: https://github.com/withastro/factory
[^11]: Mastra Factory README: https://github.com/mastra-ai/mastra/blob/main/mastracode/factory/README.md
[^12]: vercel/ai auto-merge-release-prs.yml: https://github.com/vercel/ai/blob/main/.github/workflows/auto-merge-release-prs.yml
[^13]: gastownhall/beads PR #4039: https://github.com/gastownhall/beads/pull/4039
[^14]: StrongDM, Software Factory: https://factory.strongdm.ai/
[^15]: anthropics/claude-code claude-issue-triage.yml: https://github.com/anthropics/claude-code/blob/main/.github/workflows/claude-issue-triage.yml
[^16]: anthropics/claude-code issue-lifecycle.ts: https://github.com/anthropics/claude-code/blob/main/scripts/issue-lifecycle.ts
[^17]: anthropics/claude-code auto-close-duplicates.ts: https://github.com/anthropics/claude-code/blob/main/scripts/auto-close-duplicates.ts
[^18]: anthropics/claude-code sweep.ts: https://github.com/anthropics/claude-code/blob/main/scripts/sweep.ts
[^19]: openai/codex issue-deduplicator.yml: https://github.com/openai/codex/blob/main/.github/workflows/issue-deduplicator.yml
[^20]: oven-sh/bun, PRs authored by robobun. Review states of PRs merged in 2026-09, aggregated through the GitHub API (2026-10-10): https://github.com/oven-sh/bun/pulls?q=is%3Apr+is%3Amerged+author%3Arobobun
[^21]: mastra-ai/mastra, merged PRs authored by the mastra-platform bot. PRs merged in 2026-09, aggregated through the GitHub API (2026-10-10): https://github.com/mastra-ai/mastra/pulls?q=is%3Apr+is%3Amerged+author%3Aapp%2Fmastra-platform
[^22]: OpenHands/OpenHands, review records of the 40 most recently merged PRs, checked through the GitHub API (2026-10-10): https://github.com/OpenHands/OpenHands/pulls?q=is%3Apr+is%3Amerged
[^23]: OpenHands PR #18048: https://github.com/OpenHands/OpenHands/pull/18048
[^24]: vercel/ai, review states of 2026-09 merged PRs authored by the ai-sdk-factory bot, aggregated through the GitHub API (2026-10-10): https://github.com/vercel/ai/pulls?q=is%3Apr+is%3Amerged+author%3Aapp%2Fai-sdk-factory
[^25]: vercel/ai backport.yml: https://github.com/vercel/ai/blob/main/.github/workflows/backport.yml
