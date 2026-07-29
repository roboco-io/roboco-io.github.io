---
title: "The Line Between Repository Rules and Personal Taste in the Vibe Coding Era"
date: 2026-03-26T17:26:21+09:00
draft: false
toc: false
images:
tags:
  - vibe-coding
  - agents-md
  - openclaw
  - engineering-management
  - ai-adoption
---

> The job of AGENTS.md is not to clone your developers. It is to pin down only the boundaries where accidents must be prevented.

{{< figure src="/posts/images/Dohyun.png" title="Dohyun Jung - Principal Consultant, ROBOCO" style=".author-image">}}

Teams that adopt vibe coding soon run into a similar question. Once you start putting an `AGENTS.md` or `CLAUDE.md` in every repository to tell AI agents the rules, it becomes murky how far you should pin things down as shared rules and where you should leave things to individual taste. Draw that line wrong and two problems appear at once: the safety rules that absolutely must hold get loose, while choices that are really just preferences become needlessly rigid.

A perspective that shows up often in recent vibe coding discussions runs along similar lines. Humans should concentrate on high-level judgment such as system architecture and taste, and hand implementation, boilerplate, and repetitive refactoring to agents. Translated into practical terms, this is simple. Keep in the repository the things that "must come out the same no matter who does the work," and don't force uniformity on the areas where it is fine for people to differ.

This question does not stay theoretical. Looking at the [OpenClaw case study][^1] and the [anatomy of OpenClaw's `AGENTS.md`][^2] I wrote up earlier, what actually produced the productivity was not uniformity of taste but explicitness of boundaries. Steinberger likewise explains that these days he doesn't read all the code, but he keeps his hands on system structure and design.[^3][^4] What OpenClaw pinned down hard was not tabs versus spaces either — it was import boundaries, build gates, multi-agent safety rules, and approval boundaries for irreversible operations.[^5]

The key is not writing a lot, but designing what to close and what to leave open.

## TL;DR

- Repository rules should not be a document that clones the team's taste; they should be a document that pins down the boundaries where accidents are expensive.
- Build, test, security, Git safety rules, and architectural boundaries belong under version control alongside the repository.
- Matters of taste such as naming nuance or comment style are better handled by formatters, linters, templates, and personal prompts.

## Why this distinction matters

AI agents follow rules quickly. The problem is that they cannot tell one kind of rule from another on their own. When repository guidelines mix constraints that must be obeyed — build commands, secret handling, branch safety rules — with taste at the level of "this is how I'd write it," the agent treats both with the same weight. The important rules then get buried, and the less important ones get amplified out of proportion.

For example, merging without getting `pnpm test` to pass produces bugs. Committing a real secret causes an incident. Changing authentication flows or payment authorization logic without adequate review creates operational risk. These are operating contracts, not matters open to debate. Whether to name a function `findUser` or `getUserById`, whether to put test files next to the source or collect them under `__tests__`, in what order to sort imports — these may affect the outcome, but there is usually no single fixed right answer.

If you don't draw this distinction, repository documentation bloats fast. Promote every preference to a central rule and the agent spends more context reading the document, while the team burns unnecessary energy on trivial style agreements. Conversely, treat objective constraints as though they were taste, and in a multi-agent environment you get repeated conflicts and rework.

In the end, a good `AGENTS.md` should not be a dictionary of the team's taste. It should be a document that draws clear boundaries around the areas where accidents are expensive.

## What OpenClaw actually demonstrated

As I laid out in an earlier post, OpenClaw's `AGENTS.md` is not a simple style guide but an operating contract.[^2] What is interesting is that the document focuses far more on "where can an agent cause an accident" than on "how do we clone our developers." Looking at the actual guidelines, changes that could affect build artifacts or module boundaries are required to pass `pnpm build` as a hard gate, and typical evasion patterns such as `@ts-nocheck` are explicitly banned.[^5]

For instance, OpenClaw locks down import boundaries as a rule so that extensions cannot reach directly into internal implementation. It also has multi-agent safety rules such as banning `git stash`, banning arbitrary branch switching, and keeping commits atomic. Build and test are split into hard gates and soft gates, spelling out clearly when verification is mandatory.[^2][^5]

By contrast, that document is not designed around personal taste such as "always use semicolons" or "name functions in this particular tone." In other words, the core of what OpenClaw demonstrated is simple. What repository documentation should address is structural safety, not aesthetic consistency.

## Rules that should be managed alongside the repository

The following are the areas that should be version-controlled along with the repository. They have one thing in common: violating them produces bugs, conflicts, security incidents, or operational confusion.

- Build and test commands
- Git safety rules for multi-agent environments
- Architectural constraints such as public API surface, import boundaries, and package boundaries
- Security boundaries such as secrets, personal data, and production configuration values
- High-risk areas requiring manual review, such as authentication, payments, authorization, and DB schemas
- Change management principles such as PR and commit granularity
- Work sequences that lower the cost of errors, such as Research → Plan → Implement
- Transparency requirements for AI usage
- Quality gates and automation criteria the team has already validated

These items are closer to a repository operating contract than to "recommendations that look nice."

For example, the build command must not be interpreted differently by different people as `npm run build` or `pnpm build`. The automation pipeline and local verification have to run off the same command. The same goes for Git rules. In an environment where multiple agents work simultaneously, arbitrary use of stash, unrequested branch changes, and broad non-atomic commits produce real conflicts.

Security boundaries hardly need explanation. Real phone numbers, production environment variables, private keys, customer data samples — these are a prohibition list, not a team style preference. Content like this should not be left to personal prompts or tacit knowledge; it needs to live in the repository documentation and in automated scanning rules.

Workflow ordering follows the same logic. A procedure that requires reading existing code before implementing, making a plan, and only then making changes is not mere formalism. Agents get faster the fewer questions they ask, but getting faster on top of a wrong assumption comes back more expensively later. So a rule requiring exploration and planning first is not taste; it is a cost-reduction device.

There is one more important point here. If a team already depends on automation, the format that automation expects also becomes a shared rule. For example, if the Conventional Commits format is wired into release notes, changelogs, and CI routing, it is no longer a matter of taste. Conversely, if it is merely a format preference at the level of "it reads nicely," it can be a team-level agreement without needing to be elevated to a core repository rule.

Where to put recurring procedures can be judged by the same standard. Rather than writing complex recurring work such as releases or security checks at length in the body of `AGENTS.md`, OpenClaw separates it out into dedicated skills.[^2][^6] This is a good distinction as well. Leaving principles and boundaries in the core repository document while separating procedural detail into a reusable execution surface holds up longer.

## Areas that can be left to personal taste

Conversely, the following areas can be left to individual or team taste. A team can of course standardize them for consistency, but they don't need to be part of the repository's core safety contract.

- Formatting details such as whether to use semicolons, how much whitespace, and trailing commas
- Fine nuances of function and variable names
- Import sort order
- Style choices about how heavily to comment
- How test files are laid out and how tests are described
- Preference for abstracting early versus late
- Preference between feature-based and layer-based structure
- Detailed choices of error-handling pattern
- Personal working habits such as whether you write long or short prompts

For items like these, different choices can all be reasonable. Some teams prefer `strict` type settings, while others raise strictness gradually to lower onboarding cost. Some teams like the `Result` pattern; others find exception-based flow clearer. Either way, applied consistently, both can be perfectly reasonable.

The important thing is that this is not a call to ignore taste entirely. Taste affects productivity too. What matters is where you put it. Rather than treating it as a core repository contract, it is better handled with lighter instruments such as formatters, linters, templates, sample code, personal prompts, and team playbooks. That way you preserve taste without letting repository guidelines get excessively heavy.

In vibe coding this difference matters even more. Inject every preference forcefully into an agent and code generation actually becomes rigid, with rule conflicts firing on even small changes. Leave taste as loose guidance and pin down hard only the boundaries directly tied to safety and quality, and the agent works far more stably.

OpenClaw gives a good hint here too. What that repository's coding style rules are really blocking is not the choice between tabs and spaces but structural defects such as overuse of `@ts-nocheck`, mixing in dynamic imports, and prototype mutation.[^2][^5] It may look like a style section on the surface, but the actual content is less about taste than about defusing time bombs.

## A one-line test

In practice you don't need to overthink it. This single criterion classifies most cases.

If violating it causes bugs, conflicts, security incidents, or review confusion, it's a repository rule.  
If violating it merely prompts "I wouldn't write it that way," it's taste.

What makes this criterion good is that it stays valid even when the tech stack changes. React or Go, monorepo or single service — as long as humans and agents work together, "rules that prevent accidents" and "rules that express preference" have to be kept apart.

## Practical design: four layers make it clean

I recommend splitting repository operating rules into the following four layers.

First, put only hard guardrails in `AGENTS.md`. Things where getting it wrong causes an accident: build and test commands, forbidden areas, mandatory review conditions, Git safety rules, and approval boundaries for high-risk changes.

Second, put shared team conventions into the code formatter and linter, templates, and example code. Things where consistency matters but which don't need to be read at length as documentation: naming preferences, import order, file layout, comment style.

Third, split complex recurring procedures into skills or playbooks. Rather than stuffing multi-step work such as releases, security checks, and PR operations verbosely into the main document, peel it off as an executable workflow.

Fourth, leave personal working style to local prompts and editor settings. Things like prompt voice, the number of parallel agents, exploration habits, and ad hoc checklists are better left to the domain of individual productivity.

Split this way, the repository gets lighter, team agreements get automated, and individuals can keep the working style that suits them. Above all, the priority of the guidance the agent reads becomes crisp.

## The point is not to clone your developers

The core of vibe coding is not making AI write code the way a person does. It is rather about accepting the areas where it doesn't have to write exactly like a person, and in exchange clearly pinning down only the parts that absolutely must be the same.

Good repository guidelines don't spend paragraphs explaining "our team is made up of people with these tastes." Instead they say, briefly and clearly, "in this repository, these things at least must be observed." Leave taste open; close the boundaries.

That, in the end, is likely the difference between teams that use AI agents well and teams that keep getting worn down even while using AI.

---

[^1]: [OpenClaw: 9 Best Practices from the World's Largest Vibe Coding Project](/en/posts/openclaw-vibe-coding-best-practices/)
[^2]: [The Secret Behind OpenClaw's Productivity: Dissecting AGENTS.md](/en/posts/openclaw-agents-md-productivity-secrets/)
[^3]: Peter Steinberger, [Shipping at Inference-Speed](https://steipete.me/posts/2025/shipping-at-inference-speed)
[^4]: Peter Steinberger, [Just Talk To It - the no-bs Way of Agentic Engineering](https://steipete.me/posts/just-talk-to-it)
[^5]: OpenClaw, [`AGENTS.md`](https://github.com/openclaw/openclaw/blob/main/AGENTS.md)
[^6]: OpenClaw, [`AGENTS.md` Release / Advisory Workflows](https://github.com/openclaw/openclaw/blob/main/AGENTS.md#release--advisory-workflows)
