---
title: "Products"
description: "Tools ROBOCO builds for the vibe coding era"
date: 2026-05-16T10:00:00+09:00
draft: false
---

## **Built by ROBOCO for the Vibe Coding Era**

ROBOCO turns the insights gained from consulting and training into products of its own. All of them are open for anyone to use, and we welcome feedback and contributions.

This page introduces tools and methods for practical use. Explore our experimental questions and findings in [Research](/en/research/), and our lecture and workshop materials in [Education](/en/education/).

---

## **The Software Factory**

> *Intent into policies and execution plans, results into evidence, feedback into improvement.* — Software factories and organizational design for the AI era.

*The Software Factory — Software Factories and Organizational Design for the AI Era* is a Korean-language book for leaders of software organizations. It uses a pattern language to describe a development approach that turns intent into policies and execution plans, verifies results with evidence, and uses feedback to improve those policies and plans. The book is currently a public draft that you can read on the web, and we welcome feedback through GitHub issues.

Released alongside it, **The Software Factory Demo** is a reference implementation of this approach. Anyone can watch a person request a change in writing, AI implement and verify it, and the change go live in a real service (the RealWorld example blog). The demo also serves as a proof of concept for self-improvement, in which the factory revises its own working rules based on recurring failures.

### Useful if you're

- A leader redesigning the roles and processes of a development organization for the AI era
- Someone who wants to see firsthand how a software factory actually works
- A team looking for a reference implementation that connects requests, verification, deployment, and self-improvement

### Links

- Read the book: [factory.roboco.io](https://factory.roboco.io)
- Demo service: [roboco.io/the-software-factory-demo](https://roboco.io/the-software-factory-demo/) · [Factory dashboard](https://roboco.io/the-software-factory-demo/factory/)
- GitHub: [roboco-io/the-software-factory](https://github.com/roboco-io/the-software-factory) · [roboco-io/the-software-factory-demo](https://github.com/roboco-io/the-software-factory-demo)

---

## **Intent Engineering**

> *Ship intent, not code.* — A vibe coding paradigm: record your intent clearly, and delegate the rest to AI.

As we move from an era of writing code by hand to an era of communicating intent to AI, expressing precisely "what you're building and why" has become the most important part of the work. Intent Engineering is a practical methodology for documenting that intent, evolving it, and sharing it with your team.

### Useful if you're

- Someone who's watched intent get lost while delegating work to AI
- Someone who wants to build fast without losing sight of a project's "why"
- A leader who wants to establish a shared language for AI collaboration on their team

### Links

- Site: [intent.roboco.io](https://intent.roboco.io)
- GitHub: [roboco-io/intent-engineering](https://github.com/roboco-io/intent-engineering)

---

## **VAF — Vibe Adoption Framework**

> *Where and how should vibe coding adoption start?* — A framework that structures the journey established organizations take toward agent-centric development.

Adopting a few tools doesn't change how you develop software. VAF distills the best practices ROBOCO has accumulated through vibe coding and AX consulting engagements, showing established organizations what to check first and in what order to transform.

- **3 guiding principles**: Agents are workforce leverage · Ownership stays with people · Cognitive debt must be managed
- **6 perspectives**: Strategy · People and ownership · Governance and guardrails · Agent environment · Knowledge · Harness engineering (26 capability items)
- **4 transformation areas**: Code production · Quality assurance · Knowledge · Organization and roles
- **4-stage adoption journey**: Prepare → Diagnose → Pilot → Transform

### Useful if you're

- A CTO or engineering leader who needs to design organization-wide vibe coding adoption
- A team whose pilot succeeded but is stuck scaling company-wide
- An organization that wants to diagnose AI adoption progress capability by capability

### Links

- Site: [vaf.roboco.io](https://vaf.roboco.io)
- GitHub: [roboco-io/vibe-adoption-framework](https://github.com/roboco-io/vibe-adoption-framework)

---

## **VDLC — Vibe-Driven Development Lifecycle**

> *Intent and context are the primary deliverable; code is a secondary artifact regenerable from them.* — A software development lifecycle rebuilt on the premise of vibe coding.

Bolting AI onto the implementation stage of a traditional SDLC has clear limits. VDLC assumes from the start that an AI agent is the one implementing the work, and redesigns the entire development process around that premise.

- **6 principles**: Intent is the source · Humans judge, AI executes · Speed is determined by verification · Context is an asset · Run small, feed back often · Understanding is ownership
- **6-stage lifecycle**: Define intent → Design context → Co-implement → Verify → Deploy and observe → Feed back
- **Weekly cycle**: A team operating rhythm that reinterprets Shape Up for a vibe coding premise (4 days of building + 1 day of cooldown)
- **Practical assets**: Stage-by-stage playbooks, document templates, a maturity model, an adoption roadmap, and measurement metrics

### Useful if you're

- A leader who needs to redefine process and gates for a team where AI writes the code
- A team that feels its existing development rhythm — sprints, reviews, QA — no longer fits
- An organization looking for a way to manage context and documentation as team assets

### Links

- Site: [vdlc.roboco.io](https://vdlc.roboco.io)
- GitHub: [roboco-io/vibe-driven-development-lifecycle](https://github.com/roboco-io/vibe-driven-development-lifecycle)

---

## **VibeMap**

> *From idea to deployment, the full map of vibe coding.* — Explore 60+ concepts — intent engineering, Claude Code, Git, TDD, AWS serverless, and more — as an interactive graph.

The vibe coding ecosystem is expanding fast, and it's often hard to know where to start learning. VibeMap lays out the core concepts and their relationships on a single interactive map, helping learners and teams find where they stand and what to learn next.

### Useful if you're

- Someone just starting with vibe coding who wants to chart a learning path
- A leader who needs to map a team's tools, processes, and capabilities
- An instructor who wants a visual reference for a course or workshop

### Links

- Site: [vibemap.roboco.io](https://vibemap.roboco.io) (Korean)
- GitHub: [roboco-io/vibemap](https://github.com/roboco-io/vibemap)

---

## **token-forge**

> *Run an open-weight model for coding agents in your own AWS account.*

token-forge is an open-source tool that uses AWS CDK to set up EC2 Spot GPUs and a vLLM serving environment. Its OpenAI- and Anthropic-compatible APIs let coding agents such as Claude Code connect to the model. It also shuts down idle GPU capacity and selects regions based on Spot availability.

### Useful if you're

- A team that cannot send code and prompts to an external LLM API
- A development team that uses large volumes of tokens in concentrated bursts
- An organization able to operate its own AWS GPU infrastructure

Spot reclamation can interrupt service, and the first deployment requires AWS GPU Spot quota. It is better suited to development and batch work than to services requiring uninterrupted availability.

### Links

- GitHub: [roboco-io/token-forge](https://github.com/roboco-io/token-forge)

---

## **Vibe Up**

> *Shape Up for the Vibe-Coding Era.* — Even as implementation costs approach zero, bottlenecks don't disappear; they move.

Vibe Up is a guide that reworks Basecamp's Shape Up (Ryan Singer) for the vibe coding era. It examines the new bottlenecks that emerge once implementation becomes dramatically cheaper: verification and review, attention and focus, and complexity debt. It then explains how the original principles of appetite and shaping still hold with only the unit of budget changed, and connects them to the weekly cycle of [VDLC](https://vdlc.roboco.io) (a 4-day build plus a 1-day cooldown). Available in Korean, English, and Japanese.

### Useful if you're

- A team that has run Shape Up but found its cycles and betting criteria no longer fit after adopting AI
- A leader who wants to redefine the roles of planning (shaping) and verification in a vibe coding environment

### Links

- Site: [vibeup.roboco.io](https://vibeup.roboco.io/)
- GitHub: [roboco-io/vibeup](https://github.com/roboco-io/vibeup)

---

## **AI Doc Ready**

> *Reports that are easy for both people and AI to read.* — A structure checker for Markdown and HWPX reports.

AI Doc Ready (`aidocready`) is a CLI that checks whether Markdown and HWPX reports follow AI-friendly writing principles. It started as a way to apply, in actual document writing, the principles presented when Korea's Ministry of the Interior and Safety announced its adoption of AI-friendly reports (titles placed above tables and figures, simple cell merges, prose-style sentences, and so on). It divides the work: structural checks run as reproducible code, while sentence clarity and preservation of meaning are confirmed by comparison with the source text and manual review. HWPX parsing uses the open-source library Kordoc.

### Useful if you're

- Someone who writes reports for public institutions or public-sector projects in HWPX
- A team that wants to restructure documents so AI can read and summarize reports accurately

### Links

- Product page: [roboco.io/aidocready](https://roboco.io/aidocready/)
- Run: `npx aidocready lint report.hwpx`
- GitHub: [roboco-io/aidocready](https://github.com/roboco-io/aidocready)

---

## **Open Source Tools and Resources**

We publish tools and learning resources on GitHub to help with project setup, document conversion, and working with AI agents. These tools and curated resources draw on ROBOCO's consulting and training work and are available for use in your own projects.

### **roboco-cli**

An AI-native development scaffolding CLI for Claude Code and vibe coding. It compresses ROBOCO's consulting methodology — how to start a project and structure a repository so AI agents can work in it effectively — into a single command.

- GitHub: [roboco-io/roboco-cli](https://github.com/roboco-io/roboco-cli)

### **awesome-vibecoding**

An awesome-list curation of vibe coding resources, tutorials, best practices, and examples. It covers both Korean and international material broadly, and is continuously updated with new tools and case studies.

- GitHub: [roboco-io/awesome-vibecoding](https://github.com/roboco-io/awesome-vibecoding)

### **hwp2md**

A tool that converts HWP (Hangul word processor) documents into Markdown that LLMs can work with. Built to solve the document-compatibility problem that's usually the first obstacle to AI adoption in the Korean business environment.

- GitHub: [roboco-io/hwp2md](https://github.com/roboco-io/hwp2md)

### **plugins**

A collection of Skills, Commands, Agents, and Hooks plugins that extend Claude Code's usability. We've packaged the patterns ROBOCO has refined through its consulting and training workflows so anyone can install and use them.

- GitHub: [roboco-io/plugins](https://github.com/roboco-io/plugins)

### **claude-wiki**

A tool that uses Claude Code to generate and maintain an agent-friendly wiki for your codebase. Because the wiki generation logic runs as a Claude Code plugin, it works within your existing Claude subscription without a separate API key. In the terminal and in CI, a thin CLI wrapper (`claude-wiki`) runs the same logic.

- GitHub: [roboco-io/claude-wiki](https://github.com/roboco-io/claude-wiki)

### **DORA AI Guide**

An unofficial study guide that summarizes AI-related research from DORA (dora.dev) in Korean and Japanese. It covers four major reports, the seven capabilities of the AI Capabilities Model, and 12 insight articles, serving as a reference when discussing the effects of AI adoption based on evidence.

- Site: [roboco.io/dora-ai-guide](https://roboco.io/dora-ai-guide/)
- GitHub: [roboco-io/dora-ai-guide](https://github.com/roboco-io/dora-ai-guide)

### **vibe-ready-cli**

A CLI that checks, in a single command, how ready your repository is for vibe coding (AI agent-based development). Using the Claude Agent SDK or Codex CLI, an LLM explores the repository directly, scores it across seven categories, and delivers an overall grade with specific improvement recommendations (run instantly with `npx vibe-ready .`).

- GitHub: [roboco-io/vibe-ready-cli](https://github.com/roboco-io/vibe-ready-cli)

### **ghx-cli**

An extension CLI that fills the gaps left by the official GitHub CLI (`gh`). It lets you manage GitHub Projects v2 views, workflows, and fields, and perform GitHub Discussions CRUD operations, directly through the GraphQL API (`ghx project`, `ghx item`, `ghx field`, `ghx view`, and more) — turning project-management automation, batch processing, and template application into single-command workflows.

- GitHub: [roboco-io/ghx-cli](https://github.com/roboco-io/ghx-cli)

---

## **More Activity**

Beyond the above, we publish a variety of demos, training materials, and open source projects.

- [github.com/roboco-io](https://github.com/roboco-io)
