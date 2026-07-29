---
title: "OpenClaw's Five-Layer Gatekeeping: Quality Control in the Age of AI Agents"
date: 2026-03-27T00:00:00+09:00
draft: false
toc: false
images:
tags:
  - vibe-coding
  - agentic-dev
  - openclaw
  - gatekeeping
  - ci-cd
---

> Thousands of PRs pouring into a 310K-star project, plus parallel commits from eight AI agents. The secret to keeping quality from collapsing amid that chaos is five layers of automated gatekeeping.

{{< figure src="/posts/images/Dohyun.png" title="Dohyun Jung - Principal Consultant, ROBOCO" style=".author-image">}}

---

In an earlier post I analyzed [the productivity principles embedded in OpenClaw's AGENTS.md](/en/posts/openclaw-agents-md-productivity-secrets/). The heart of that piece was "writing the rules down." But writing rules and **enforcing** them are entirely different problems.

OpenClaw is the most-starred repository on GitHub (310K+) and a flagship case study in vibe coding.[^1] The project absorbs two extreme pressures at once. One is the flood of **internal changes** produced by maintainer Peter Steinberger, who runs three to eight AI agents simultaneously. The other is the **thousands of external PRs** submitted by contributors worldwide, most of them AI-assisted.

Writing "don't do this" in AGENTS.md is a soft guardrail. AI agents usually comply, but not always. External contributors may not even know the rules exist. So OpenClaw stacked **five layers of automated enforcement** on top of the rules. This post dissects those layers.

## TL;DR

- OpenClaw's quality control is not just a rules document. It operates as five overlapping layers: pre-commit hooks, `pnpm check`, CI, PR automation, and release gates.
- Problems that can be fixed automatically get fixed by tooling, while dangerous problems — type errors, security issues, architectural boundary violations — get blocked. That split creates defense in depth.
- The goal in the vibe coding era is not to stop AI from ever writing bad code, but to stop bad code from reaching production.

---

## Layer 1: Catch It Before the Commit — Local Pre-Commit Hooks

OpenClaw's first line of defense fires before code ever reaches the repository. [`git-hooks/pre-commit`](https://github.com/openclaw/openclaw/tree/main/git-hooks) is activated automatically through the `prepare` script in `package.json` and runs on every commit.

The order of operations is telling:

1. Filter staged files by type
2. **oxlint** `--type-aware --fix` — **auto-fixes** lint errors
3. **oxfmt** `--write` — **auto-fixes** formatting
4. Re-stage the modified files
5. `pnpm check` — run the full quality gate

The core design idea is **separating auto-fix from blocking**. Mechanically fixable problems such as formatting or lint errors get repaired by the hook and allowed through. Problems that require judgment — type errors, architectural boundary violations — block the commit outright. Without that distinction, agents either stall on trivial formatting issues or sail past structural defects. One or the other.

On top of this, [`.pre-commit-config.yaml`](https://github.com/openclaw/openclaw/blob/main/.pre-commit-config.yaml) defines 17 security and quality hooks that also run in CI's `security-fast` job. `detect-private-key` and `detect-secrets` block secret leakage, `zizmor` audits the security of GitHub Actions workflows, and `pnpm-audit-prod` scans production dependencies for known vulnerabilities.

---

## Layer 2: One Command, Ten Verifications — `pnpm check`

`pnpm check` is the **single quality gate** that runs both in local hooks and in CI. More than ten checks are chained behind that one command.

```
pnpm check =
  check:no-conflict-markers          # No merge conflict markers
  check:host-env-policy:swift         # Swift host environment security policy
  check:base-config-schema            # Config schema drift check
  check:bundled-plugin-metadata       # Plugin metadata consistency
  check:bundled-provider-auth-env-vars # Provider auth env var consistency
  format:check (oxfmt)                # Formatting verification
  tsgo                                # Native TypeScript type checking
  plugin-sdk:check-exports            # Plugin SDK export consistency
  lint (oxlint --type-aware)          # Type-aware linting
  + ~15 custom architectural boundary lint scripts
```

The last line is the most noteworthy part. A typical linter catches code-level problems like unused variables or missing semicolons. OpenClaw's custom boundary guard scripts catch **architecture-level violations**. They detect when an Extension imports core `src/**` directly, references internal paths in the plugin SDK, or reaches outside the package root with relative paths.

This is the code implementation of [the import boundary rule I analyzed in the earlier AGENTS.md post](/en/posts/openclaw-agents-md-productivity-secrets/). What the rules document says not to do, CI actually verifies and blocks. It is a **double barrier of rules and verification**.

---

## Layer 3: Fifteen Parallel Jobs Inspect Every Change — The CI Workflow

OpenClaw's [`ci.yml`](https://github.com/openclaw/openclaw/blob/main/.github/workflows/ci.yml) is the main gatekeeper, running on PRs and pushes to main. It consists of roughly 15 parallel jobs and skips draft PRs.

### Smart Routing: Reconciling Speed and Thoroughness

Running every test on every change is thorough but slow. Running only related tests is fast but leaky. OpenClaw resolves this dilemma with a **preflight job**.

The preflight job detects the scope of changed files and generates a CI manifest. Docs-only changes get docs checks only; touching a Swift file adds a macOS build and test run; changing a single Extension runs only that Extension's tests. This smart routing strikes the balance between "slow but thorough" CI and "fast but incomplete" CI.

### The Full CI Job Structure

| Category | Job | What It Checks |
|---------|-----|---------|
| **Security** | security-fast | Private key detection, Actions security audit, dependency audit |
| **Quality** | check | Full `pnpm check` + strict smoke build |
| **Architecture** | check-additional | 15+ boundary guards, schema drift, SDK API baseline |
| **Build** | build-artifacts | `pnpm build` + UI build |
| **Tests (Linux)** | checks (sharded) | Vitest unit tests, channel tests, Node 22 compatibility |
| **Tests (Windows)** | checks-windows (sharded) | Full test suite |
| **Tests (macOS)** | macos-node (sharded) | Full test suite |
| **Extensions** | checks-fast, extension-fast | Contract tests, targeted tests for changed Extensions |
| **Native apps** | macos-swift, android | Swift/Kotlin build + test + lint |
| **Docs** | check-docs | Formatting, link audit, i18n glossary |
| **Smoke** | build-smoke | CLI `--help`/`--version`, startup memory check |
| **Release** | release-check (main only) | Release content verification |

The architectural boundary guards in the [`check-additional`](https://github.com/openclaw/openclaw/blob/main/.github/workflows/ci.yml) job are especially impressive. Custom scripts detect plugin-to-Extension import violations, references to Extension SDK internal paths, raw `window.open` usage, gateway watch regressions, and more. These are **guardrails purpose-built for a vibe coding environment** — nothing you would find in a conventional CI pipeline.

---

## Layer 4: Triaging Thousands of PRs Without a Human — PR Lifecycle Automation

A 310K-star project attracts thousands of issues and PRs. There is no way a maintainer can triage them one by one. OpenClaw solves this with three automation workflows.

### Auto-Labeling: The Changed Files Are the Label

The [`labeler.yml`](https://github.com/openclaw/openclaw/blob/main/.github/labeler.yml) workflow analyzes changed file paths when a PR opens and assigns labels automatically. It defines 21 channel labels (`channel: discord`, `channel: telegram`, and so on), 4 app labels (`app: ios`, `app: android`, etc.), 8 area labels (`gateway`, `agents`, `security`, etc.), and more than 30 Extension labels.

On top of that, **PR size labels** (XS/S/M/L/XL) are assigned automatically based on line count, **maintainer labels** are derived from team membership, and **beta-blocker labels** are detected from the PR title. These labels then trigger the auto-response system in the next stage.

### Auto-Response: Filtering Noise Automatically

[`auto-response.yml`](https://github.com/openclaw/openclaw/blob/main/.github/workflows/auto-response.yml) processes PRs and issues automatically based on labels. The rules in this workflow accumulated from real operational experience.

**Spam/noise blocking**:
- `r: spam` or `r: moltbook` label → auto-close + lock
- `dirty` label or PRs with more than 20 labels → close with a "noisy PR" message

**Community behavior limits**:
- A non-maintainer with **more than 10 open PRs** → assign `r: too-many-prs` and auto-close
- **Mentioning three or more maintainers** on an issue or PR → spam-ping warning message

**Routing to the right channel**:
- `r: skill` → point skill-related questions to ClawHub, then close
- `r: support` → point support requests to Discord, then close
- `r: no-ci-pr` → reject PRs that only change CI configuration

The **10-PR-per-person cap** matters especially in the vibe coding era. In an environment where AI tools make it easy to mass-produce PRs, it prevents any one person from monopolizing the review queue. CONTRIBUTING.md states the same principle: *"Keep PRs focused (one thing per PR; do not mix unrelated concerns)"*[^2]

### Lifecycle Management: Abandoned PRs Get Cleaned Up Automatically

[`stale.yml`](https://github.com/openclaw/openclaw/blob/main/.github/workflows/stale.yml) runs daily and cleans up abandoned issues and PRs. Issues are marked stale after 7 days and closed 5 days later; PRs go stale after 5 days and close 3 days later. Closed issues are locked after 48 hours. Items labeled `enhancement`, `maintainer`, `pinned`, or `security` are exempt.

It is notable that PRs have a shorter lifespan than issues (5+3 days vs. 7+5 days). Code changes drift further from their context and grow more likely to conflict as time passes.

### The PR Template: Demanding Evidence Structurally

OpenClaw's [PR template](https://github.com/openclaw/openclaw/blob/main/.github/pull_request_template.md) goes beyond the usual "what did you do" and enforces **evidence-based review**.

Among the required sections, these stand out:

- **What did NOT change (scope boundary)**: Explicitly declare what was left untouched. Changes made by AI agents tend to sprawl in scope, so forcing an intentional boundary declaration lets reviewers detect scope creep.
- **Security Impact**: Check **Yes/No individually** for changes to permissions, secrets, network, tool execution, and data access. Instead of a vague "does this affect security?", it walks through concrete surfaces one at a time.
- **Evidence**: At least **one** of a failing-to-passing test, a trace/log, or a screenshot is mandatory.
- **Human Verification**: State the scenarios verified, the edge cases, and — crucially — **what was not verified**.

That last item matters most. If you only ask "what did you test," PR authors list the cases that passed. Ask "what did you not test," and reviewers can immediately locate the risky areas.

---

## Layer 5: Stop Before Irreversible Actions — Release Gates

CI is fully automatic; releases never are. OpenClaw's release pipeline consists of a **manual trigger, environment approval, and multi-stage verification**.

### The NPM Release: A 19-Step Sequence

[`openclaw-npm-release.yml`](https://github.com/openclaw/openclaw/blob/main/.github/workflows/openclaw-npm-release.yml) is triggered only by `workflow_dispatch`. There is no automatic release. Once it runs, it passes through these verifications in order:

1. Tag format validation
2. `pnpm check` + `pnpm build` + `pnpm release:check`
3. npm version uniqueness confirmation
4. **`npm-release` environment approval** → explicit sign-off from a member of the `@openclaw/openclaw-release-managers` team is required
5. Enforced execution from the main branch only
6. Then a 19-step sequence: tag creation → npm preflight → mac preflight (public + private) → actual publish → asset verification → appcast update

### CODEOWNERS: Physically Locking the Security Surface

[`CODEOWNERS`](https://github.com/openclaw/openclaw/blob/main/.github/CODEOWNERS) is a hard guardrail enforced by GitHub itself. If AGENTS.md's "don't touch the security files" is a soft guardrail, CODEOWNERS makes the **merge itself impossible** without review approval from the owning team.

Surfaces protected by **`@openclaw/secops`**:
- Security code: `src/security/`, `src/secrets/`, gateway auth/secrets, agent sandbox
- Security infrastructure: dependabot, CodeQL, `SECURITY.md`
- Security docs: all documentation on authentication, sandboxing, and secrets

Surfaces protected by **`@openclaw/openclaw-release-managers`**:
- Release workflows, publish scripts, release documentation

The CODEOWNERS file itself can only be modified by `@steipete`, the founder. A gatekeeper guarding the gatekeepers.

### Skill Gates for AI Agents

Even the AI agent skills for release and PR management have gates.

The [`$openclaw-pr-maintainer`](https://github.com/openclaw/openclaw/tree/main/.agents/skills/openclaw-pr-maintainer) skill enforces an **evidence standard** for bug-fix PRs. Issue text or the AI's own reasoning is not enough to merge. It requires symptom evidence, a verified root cause at the file/line level, a fix in the relevant code path, and a regression test. Any bulk close/reopen exceeding five items requires explicit user confirmation.

The [`$openclaw-release-maintainer`](https://github.com/openclaw/openclaw/tree/main/.agents/skills/openclaw-release-maintainer) skill requires **operator approval at every step** for both version-number changes and npm publishes. Skills assist with automation, but irreversible actions still end with a human decision.

---

## The Defense in Depth the Five Layers Create

Viewing all five layers as a single picture reveals the **defense in depth** that code must traverse before reaching production.

```
[Developer / Agent]
       ↓
  Layer 1: Pre-commit ──── Auto-fix format/lint, block type/boundary violations
       ↓
  Layer 2: pnpm check ──── 10+ chained checks, 15+ architectural boundary guards
       ↓
  Layer 3: CI ──────────── 15 parallel jobs, cross-platform, security scans
       ↓
  Layer 4: PR automation ─ Label triage, noise filters, evidence-based template, stale cleanup
       ↓
  Layer 5: Release ─────── Manual trigger, environment approval, CODEOWNERS, 19-step verification
       ↓
  [Production]
```

Each layer is independent. If pre-commit fails, CI catches it; if CI is bypassed, PR review catches it; if the PR passes, the release gate blocks it. When one layer is breached, the next one defends.

---

## Seven Design Principles

Here are the design principles distilled from OpenClaw's gatekeeping.

### 1. Separate Auto-Fix from Blocking

Auto-fix formatting and lint errors; hard-block type and boundary violations. This avoids needlessly interrupting the agent's flow while never letting structural defects through.

### 2. Preserve Speed with Smart Routing

Don't run every test on every change. Detect the scope of the change and run only the relevant jobs. Fast feedback and thorough verification can coexist.

### 3. Overlap Rules Documents with Automated Verification

Write "don't do this" in AGENTS.md, and actually detect the violation in CI. The double barrier of soft and hard guardrails creates defense in depth.

### 4. Demand Evidence Structurally in PRs

Ask not only "what did you do" but "what did you not do," "what evidence do you have," and "is there a security impact" — structurally. Make the author supply upfront the information the reviewer needs to judge.

### 5. Filter Community Noise Automatically

A 10-PR-per-person cap, automatic stale closing, label-driven auto-close and routing, maintainer-ping spam detection. Maintainer attention is a finite resource, and automated triage protects it.

### 6. Stop Before Irreversible Actions

CI is fully automatic, but releases need a manual trigger plus environment approval. Even AI agent skills require step-by-step approval for version changes and publishes. "Move fast, but stop before actions you cannot undo."

### 7. Put a Gatekeeper in Front of the Gatekeepers

Only the founder can modify the CODEOWNERS file. Only the release manager team can modify release workflows. Security code cannot be merged without secops approval. There is a meta layer protecting the gatekeeping system itself.

---

## Applying This to Your Own Project

You don't need to adopt all five of OpenClaw's layers at once. Ordered by difficulty:

| Stage | What to Adopt | Effect |
|------|---------|------|
| **Immediately** | Pre-commit hook (lint + format auto-fix) | Eliminates CI failures wasted on trivial errors |
| **Immediately** | Add evidence/security sections to the PR template | Instant improvement in review quality |
| **1 week** | Type check + test gates in CI | Establishes a baseline quality floor |
| **1 week** | Protect security-sensitive files with CODEOWNERS | Hard-locks the security surface |
| **2 weeks** | Stale bot + auto-labeling | Automates PR queue management |
| **1 month** | Custom architectural boundary guard scripts | Prevents architectural erosion |
| **1 month** | Smart routing (CI job selection by change scope) | Optimizes CI speed |
| **1 quarter** | Release environment approval + multi-stage verification | Secures release safety |

The highest-ROI items are the **pre-commit hook** and the **PR template**. Both can be adopted within a day, and the effect is immediate. Add the rest incrementally, calibrated to your project's scale and risk profile.

Quality control in the vibe coding era is not about "keeping AI from writing bad code." AI sometimes writes bad code. So do people. What matters is **keeping bad code from reaching production**. OpenClaw's five-layer gatekeeping shows how.

---

[^1]: [OpenClaw: Nine Best Practices from the World's Largest Vibe Coding Project](/en/posts/openclaw-vibe-coding-best-practices/)
[^2]: [OpenClaw CONTRIBUTING.md](https://github.com/openclaw/openclaw/blob/main/CONTRIBUTING.md)
