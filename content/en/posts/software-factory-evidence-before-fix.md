---
title: "Software Factory Best Practices from Open-Source Projects (3/4): Factories That Filter by Evidence"
date: 2026-10-10T10:00:00+09:00
draft: false
toc: false
images:
tags:
  - software-factory
  - agentic-dev
  - testing
  - code-review
  - best-practices
---

> "Your test is NOT VALID if it passes with `USE_SYSTEM_BUN=1`." – Bun `CLAUDE.md`[^1]

{{< figure src="/posts/images/Dohyun.png" title="Dohyun Jung - Principal Consultant, ROBOCO" style=".author-image">}}

---

This is the third post in the four-part series "Software Factory Best Practices from Open-Source Projects."

**The series**

1. [The Criteria and 12 Repositories: what counts as a factory, and where factories are running](/en/posts/software-factory-best-practices-from-open-source/)
2. [Who Merges? Risk-based delegation and permission structures](/en/posts/software-factory-who-merges/)
3. Factories That Filter by Evidence: proving a test "fails before the fix" (this post)
4. [Turning Failures into Rules: self-improvement loops and their limits](/en/posts/software-factory-failures-into-rules/)

The quote at the top comes from the agent instructions in the Bun repository. `USE_SYSTEM_BUN=1` is a setting that runs the tests against the existing Bun release, before the fix. In other words, the rule says that "a test that also passes on the unfixed code proves nothing."

In [Part 2](/en/posts/software-factory-who-merges/), I concluded that what matters more than who holds merge authority is what must be verified before a merge.[^2] This post covers the substance of that verification. Agents write code quickly, but they just as easily write meaningless tests that always pass and work reports that overstate what was done. And `robobun`, Bun's agent, opened 2,313 PRs in September 2026 alone.[^3] At that scale, no person can read every diff. So factories make people look at the **evidence** before they read any code. As in the earlier posts, all figures were retrieved through the GitHub API on October 10, 2026.

## TL;DR

- Grouping the cases I observed, the evidence factories demand comes in three layers: a reproduction showing that the problem actually exists, a test that fails before the fix and passes after it, and evidence of real behavior beyond unit tests.
- Among these, the "fails before the fix" proof is the mechanism three projects implemented in different ways. Bun attaches the pre-fix failure log to the PR body, mastra's CI runs new tests against the unfixed code to confirm they fail, and the Vercel AI SDK fix PR I observed stacked its commits in the order reproduction → failing test → fix.
- Evidence can be bypassed. In mastra, some PRs were merged while still carrying the failure label from the fails-before-fix gate, and in Astro, a fix confirmed to "work" was reverted because it did not match the intended behavior. In my view, evidence mechanisms have teeth when they are tied to merge conditions and when they also check intent.

---

## 1. Three Layers of Evidence

Grouped by my own criteria, the evidence the observed projects demand from agents falls into three types.

| Type of evidence | Question it asks | Representative mechanisms |
|---|---|---|
| Reproduction | Does the problem actually exist? | Vercel AI SDK's reproduction PRs, Astro's reproduction step |
| Fails before the fix | Does this test really catch that problem? | Bun's evidence block, mastra's gate that tests the unfixed code, Vercel AI SDK's commit order |
| Real behavior | Does it work outside unit tests too? | OpenClaw's behavior-proof labels, OpenHands' live E2E, Astro's preview releases |

I see these three layers as building on one another in order. Without a reproduction, you cannot know what was fixed, and without a failure before the fix, you cannot know what the test proves. And the reason the third layer is needed is that code can break in a real environment even when unit tests pass.

---

## 2. Reproduce First

When Vercel AI SDK's factory receives a bug issue, it first tries to reproduce it. If reproduction succeeds, it creates a draft PR containing an example file and a reproduction record file (`reproduction-replay.json`). The reproduction PR for issue #22412, which I observed, was closed after confirmation.[^4] The reproduction result is recorded as a label. There are labels such as `task-bug-reproduction-success`, `-cannot-reproduce`, `-issue-invalid`, and `-out-of-scope`, and the result is recorded separately for each supported version (v5, v6).[^5] The next step appears to branch on this result, but the factory's internal rules live outside the repository, so I could not confirm this.

Astro's factory works in the order reproduction → diagnosis → intent verification → fix. Each step has a rule for stopping. If starting the server for reproduction fails twice, it gives up and writes a report. If its confidence in the diagnosis is low, it stops there. If the intent verification step judges the behavior to be "intended," it makes no fix.[^6] When confidence is low, there is also a path where, instead of changing the code, it leaves only a failing test and a `// TRIAGE:` comment. It leaves only clues so that a person can pick up the work.

In Bun, the agent posts reproduction results directly on issues. Of the issues created in September 2026, 441 have a comment from robobun, and when it cannot reproduce a problem, it says "cannot reproduce" along with a record of running the official release binary.[^7]

---

## 3. It Must Fail Before the Fix

If a reproduction proves that the problem exists, a failure before the fix proves that the test has value. Three projects implemented this in different ways.

### 3.1 Bun: The Evidence Block in the PR Body

Bun's agent instructions declare a test invalid if it passes on the pre-fix release.[^1] This rule surfaces mechanically in PR bodies. Of the 2,313 PRs robobun opened in September 2026, 1,827 contain an evidence block.[^3] The evidence block contains the run log showing the test "fails on main, without fix," how many times the gate was repeated before passing, and, for each changed file, how many times it was read, edited, and tested.[^8] PR bodies also follow fixed sections such as Problem, Verified, and Downsides. Reviewers look at this evidence before they read the code.

### 3.2 mastra: CI That Runs New Tests Against the Unfixed Code

mastra checks the same principle in CI. `changed-test-gate.yml` checks out the PR's base commit, takes only the test files the PR changed from the PR side, and runs them against the unfixed code. These tests are supposed to fail. The result is applied as a label: `tests: green ✅` if they fail, meaning "the changed tests failed on the base code as expected"; `tests: failing ❌` if they pass; and `tests: no tests added` if there are no tests.[^9]

This workflow was also designed with security in mind. The PR's code runs in an environment without secrets, and the write operation that applies the label is split into a separate workflow. This keeps agent-written test code from reaching a token with write permission.[^9] Of the 434 bot PRs merged in September 2026, the labels were `tests: green ✅` on 354, `tests: no tests added` on 33, and `tests: failing ❌` on 24.[^10]

### 3.3 Vercel AI SDK: Commit Order Becomes Evidence

Vercel AI SDK fix PR #22424, which I observed, stacked its commits in the order "reproduction → failing test → fix." The commit titles are "reproduction (reproduced)," "failing tests," and "fix #22412," in that order. The commit history itself becomes a record that the test failed before the fix. Next, the AI review first checks the result of rerunning the original reproduction, then judges whether the issue was resolved and whether there are side effects or performance risks. On this PR, the AI review requested changes in the first round because the production path had not been fixed, and approved after the fix.[^11] Among the factory's PRs in September 2026, the AI review requested changes in the first round on 20.[^5]

OpenClaw's automated implementation worker and Astro's factory are also instructed to first write a regression test that fails before the fix.[^12][^6]

---

## 4. Unit Tests Alone Are Not Enough

Even a fails-before-the-fix test may ultimately be just a unit test. Several projects went a step further.

In October 2026, OpenClaw recorded that five defects unit tests had failed to catch in recent work had shipped as is, and it changed its instructions. The defects included cache tokens being recorded as zero, results obtained at a cost being thrown away, and a loop that repeated the same processing because a status marker was not saved. The revised instructions put meaningful integration evidence ahead of the number of tests.[^13] The principle in `AGENTS.md` is likewise "Behavior over test count."[^14] A workflow that checks evidence of real behavior runs on PRs from external contributors, and labels such as `proof: sufficient` indicate whether the evidence is sufficient.[^15]

OpenHands' PR template instructs agents: "Just running unit tests is NOT sufficient. Explain exactly what command you ran and include logs, screenshots, or reproduction notes." A PR that changes the frontend must include a screenshot or video of the running app to pass CI.[^16][^17] CI spins up a real agent server, runs live E2E tests, and posts the resulting video as a PR comment.[^18] And every day, an agent re-verifies, through the real UI, only the features that have changed since the baseline.[^19]

Beads' agent instructions state this principle in a single sentence: "Evidence that the change works end-to-end is required; 'unit tests pass' alone is not evidence."[^20]

Astro brought people into the evidence gathering. It first publishes the factory's fix as an installable preview package, and the PR opens only after the person who filed the issue or a maintainer confirms the behavior in their own environment. Of the factory's 31 PRs in September 2026, 19 were confirmed by the issue reporter and 12 by a maintainer.[^21]

StrongDM describes taking the opposite extreme. It keeps verification scenarios outside the code repository so that agents cannot adjust the scenarios to fit the code, and it runs the loop until these "holdout scenarios" pass.[^22] This, however, is the company's own account, and I could not verify it in a public repository.

---

## 5. Keeping Evidence from Being Bypassed

Evidence mechanisms can be bypassed. The observed projects were blocking several bypass routes.

- **Flaky tests cannot be used as an excuse.** Bun's PR landing instructions make passing CI on every platform a hard requirement, and anyone who wants to claim "it's probably a flaky test" must attach a link to the same failure occurring on main.[^23] OpenClaw prohibited getting past flaky tests by rerunning them or pushing again, and required a root-cause analysis instead.[^24] OpenAI Codex's PR-watching agent could rerun a flaky failure at most three times.[^25]
- **Reviewers re-create the evidence themselves.** mastra's review agent runs the tests and type checks for the changed packages directly in a sandbox. While doing so, it removes the GitHub token from the environment. It treats CI results only as a reference, and right before posting its verdict, it checks again that the PR's latest commit is the same commit it verified.[^26]
- **Overstated reports are blocked.** Bun's agent instructions say, "Be humble & honest - NEVER overstate what you got done or what actually works in commits, PRs or in messages to the user."[^1] And when a PR gets the `slop` label, a workflow changes its title and closes it. The message it leaves cites these reasons: not verifying that the problem actually exists, not testing whether the fix works, incorrect assumptions about the codebase, and incomplete or misleading changes. No workflow applies this label automatically, so it appears that people apply it. Of the 248 PRs with this label, 228 are robobun's.[^27]

Still, gaps remain.

- **The link between evidence and merge conditions is weak.** mastra's fails-before-the-fix gate applies its result as a label. Yet 83 PRs were merged while carrying the `tests: failing ❌` label.[^10] Branch protection settings cannot be checked through the public API, so I cannot tell whether this was allowed by the rules or whether people bypassed it. In Astro, according to the public API, the list of required status checks for the main branch is empty, and one release PR was merged while the Windows E2E tests were failing.[^28]
- **Evidence that something "works" does not guarantee that it "matches the intent."** In Astro, a factory fix whose behavior a maintainer had confirmed was merged, but it actually changed intended behavior, so it was reverted before release.[^29] This happened even though the behavior had been confirmed.

---

## 6. Best Practices

1. **Declare tests that pass on the unfixed code invalid.** Write the rule into the agent instructions and have the pre-fix failure log attached to the PR body. (Bun)
2. **Check that rule in CI and tie the result to merge conditions.** Run only the tests the PR changed against the unfixed code. If the result is left only as a label, it will be bypassed. (mastra's mechanism; lessons from mastra and Astro)
3. **Commit in the order reproduction → failing test → fix, and judge the resolution by rerunning the original reproduction.** The commit history becomes evidence as is. (Vercel AI SDK)
4. **Put stop conditions on each step of reproduction and diagnosis.** If the problem cannot be reproduced or confidence is low, do not fix it; leave only clues. (Astro)
5. **Require evidence of behavior beyond unit tests.** Require evidence close to the real environment, such as the commands run and their logs, screenshots, live E2E, and confirmation by real users. (OpenClaw, OpenHands, Beads, Astro)
6. **Run agent-written test code where there are no secrets and no write permissions.** (mastra)
7. **Require justification for moving past a test as flaky, and limit the number of retries.** (Bun, OpenClaw, OpenAI Codex)

---

## Conclusion

In an environment where agents open dozens of PRs a day, reviewers cannot protect quality just by reading diffs. The factories I observed moved the starting point of review from code to evidence: a reproduction showing the problem exists, a failure before the fix showing the test catches that problem, and evidence of behavior in a real environment.

But evidence is not a cure-all either. If evidence is not tied to merge conditions, it can be bypassed, and even with evidence that something works, it can still differ from the intent. The next post covers what happens after such failures. It looks at how projects turn failures into rules and instructions, and where that self-improvement loop still breaks down.

**Next:** [(4/4) Turning Failures into Rules: self-improvement loops and their limits](/en/posts/software-factory-failures-into-rules/)

---

[^1]: oven-sh/bun CLAUDE.md: https://github.com/oven-sh/bun/blob/main/CLAUDE.md
[^2]: Software Factory Best Practices from Open-Source Projects (2/4): Who Merges?: https://roboco.io/en/posts/software-factory-who-merges/
[^3]: oven-sh/bun, PRs authored by robobun. PRs created in September 2026 and their PR bodies, counted via the GitHub API (October 10, 2026): https://github.com/oven-sh/bun/pulls?q=is%3Apr+author%3Arobobun
[^4]: vercel/ai PR #22416 (reproduction PR): https://github.com/vercel/ai/pull/22416
[^5]: vercel/ai label list. PR counts per label, counted via the GitHub API (October 10, 2026): https://github.com/vercel/ai/labels
[^6]: withastro/astro .agents/skills (triage skill): https://github.com/withastro/astro/tree/main/.agents/skills
[^7]: oven-sh/bun issue #44276: https://github.com/oven-sh/bun/issues/44276
[^8]: oven-sh/bun PR #40556: https://github.com/oven-sh/bun/pull/40556
[^9]: mastra changed-test-gate.yml: https://github.com/mastra-ai/mastra/blob/main/.github/workflows/changed-test-gate.yml
[^10]: mastra-ai/mastra, distribution of test gate labels on the 434 bot PRs merged in September 2026, and the number of merged PRs carrying the `tests: failing ❌` label, counted via the GitHub API (October 10, 2026): https://github.com/mastra-ai/mastra/pulls?q=is%3Apr+is%3Amerged+label%3A%22tests%3A+failing+%E2%9D%8C%22
[^11]: vercel/ai PR #22424: https://github.com/vercel/ai/pull/22424
[^12]: openclaw/clawsweeper README: https://github.com/openclaw/clawsweeper/blob/main/README.md
[^13]: OpenClaw PR #168083: https://github.com/openclaw/openclaw/pull/168083
[^14]: OpenClaw AGENTS.md: https://github.com/openclaw/openclaw/blob/main/AGENTS.md
[^15]: OpenClaw real-behavior-proof.yml: https://github.com/openclaw/openclaw/blob/main/.github/workflows/real-behavior-proof.yml
[^16]: OpenHands PR template: https://github.com/OpenHands/OpenHands/blob/main/.github/pull_request_template.md
[^17]: OpenHands check_pr_description.py: https://github.com/OpenHands/OpenHands/blob/main/.github/scripts/check_pr_description.py
[^18]: OpenHands ci.yml: https://github.com/OpenHands/OpenHands/blob/main/.github/workflows/ci.yml
[^19]: OpenHands verify-openhands skill, daily.md: https://github.com/OpenHands/OpenHands/blob/main/.agents/skills/verify-openhands/references/daily.md
[^20]: gastownhall/beads AGENTS.md: https://github.com/gastownhall/beads/blob/main/AGENTS.md
[^21]: withastro/astro factory.yml: https://github.com/withastro/astro/blob/main/.github/factory.yml
[^22]: StrongDM, Software Factory: https://factory.strongdm.ai/
[^23]: oven-sh/bun .claude/docs/landing-prs.md: https://github.com/oven-sh/bun/blob/main/.claude/docs/landing-prs.md
[^24]: OpenClaw commit 3b76ad8461: https://github.com/openclaw/openclaw/commit/3b76ad8461
[^25]: openai/codex babysit-pr skill (version before deletion): https://github.com/openai/codex/blob/5e96aabd68dc6194f5ad928cb7f5d0bc71b72df9/.codex/skills/babysit-pr/SKILL.md
[^26]: mastra factory-review skill: https://github.com/mastra-ai/mastra/blob/main/mastracode/factory/factory-skills/factory-review/SKILL.md
[^27]: oven-sh/bun on-slop.yml: https://github.com/oven-sh/bun/blob/main/.github/workflows/on-slop.yml
[^28]: withastro/astro PR #18113: https://github.com/withastro/astro/pull/18113
[^29]: withastro/astro PR #18030: https://github.com/withastro/astro/pull/18030
