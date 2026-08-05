---
title: "Products"
description: "Tools ROBOCO builds for the vibe coding era"
date: 2026-05-16T10:00:00+09:00
draft: false
---

## **Built by ROBOCO for the Vibe Coding Era**

ROBOCO turns the insights gained from consulting and training into products of its own. All of them are open for anyone to use, and we welcome feedback and contributions.

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

## **Open Source Tools and Resources**

Some of what ROBOCO builds and refines through consulting, training, and its own research doesn't have a dedicated site yet — but it's all public on GitHub. Every one of these is the output of a real project, a real course, or an experiment that answered the question, "can this really be done at low cost?"

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

### **s3-experiments**

An experimental project exploring how to use Amazon S3 as more than simple storage — as a key-value store, event store, durable RDBMS (Litestream + SQLite), serverless RDBMS (Athena), and a file I/O alternative. It includes deployable code (via CDK) alongside honest trade-off benchmarks against purpose-built services (DynamoDB, RDS, Aurora), so architecture-decision guardrails can be validated at low cost without a dedicated cloud research team.

- GitHub: [roboco-io/s3-experiments](https://github.com/roboco-io/s3-experiments)

### **serverless-autoresearch**

A project that reproduces and extends Karpathy's autoresearch on AWS SageMaker Spot instances. An overnight automated model-improvement experiment that once required occupying a single H100 for eight hours now runs 2.3× faster and 5–18× cheaper, with all 48 experiments completed for $3.94. We've also published a parallel evolution pipeline using the HUGI pattern and an eight-part hands-on tutorial.

- GitHub: [roboco-io/serverless-autoresearch](https://github.com/roboco-io/serverless-autoresearch)

### **vibe-ready-cli**

A CLI that checks, in a single command, how ready your repository is for vibe coding (AI agent-based development). Using the Claude Agent SDK, an LLM explores the repository directly, scores it across six categories, and delivers an overall grade with specific improvement recommendations (run instantly with `npx vibe-ready .`).

- GitHub: [roboco-io/vibe-ready-cli](https://github.com/roboco-io/vibe-ready-cli)

### **ghx-cli**

An extension CLI that fills the gaps left by the official GitHub CLI (`gh`). It lets you manage GitHub Projects v2 views, workflows, and fields, and perform GitHub Discussions CRUD operations, directly through the GraphQL API (`ghx project`, `ghx item`, `ghx field`, `ghx view`, and more) — turning project-management automation, batch processing, and template application into single-command workflows.

- GitHub: [roboco-io/ghx-cli](https://github.com/roboco-io/ghx-cli)

---

## **More Activity**

Beyond the above, we publish a variety of demos, experiments, and training materials.

- [github.com/roboco-io](https://github.com/roboco-io)
