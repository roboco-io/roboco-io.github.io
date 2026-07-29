---
title: "The Vibe Coding Manual: A Template for AI-Assisted Development"
date: 2025-03-11T06:52:53+09:00
draft: true
toc: false
images:
tags:
  - vibecoding
---
(Version 1.0 – March 2025)

This post is a translation of the [Vibe Coding Manual](https://www.reddit.com/r/ChatGPTCoding/comments/1j5l4xw/vibe_coding_manual/) posted on Reddit.

## TL;DR

- Vibe Coding is a development approach that combines specification, rules, and oversight to build projects together with AI.
- The key to a rules file is clearly separating coding style, tech stack, workflow, and communication expectations.
- It applies to everything from small scripts to large applications, but you have to keep managing the AI's scope creep and context loss.

## Introduction: Core Concepts of Vibe Coding and AI

### What Is Vibe Coding, and What Is It Built On?

Vibe Coding is a collaborative software development approach in which a human uses AI models (e.g., Claude 3.7, GPT-4o) to efficiently build functional projects. Introduced in "[Vibe Coding Tutorial and Best Practices](https://www.youtube.com/watch?v=YWwS911iLhg)," which Matthew Berman published on his YouTube channel, the concept rests on three core pillars:

1. **Specification**: Define the goal (e.g., "build a Twitter clone with login").
2. **Rules**: Set explicit constraints (e.g., "use Python, avoid complexity").
3. **Oversight**: Monitor and adjust the process to ensure consistency.

Building on Berman's foundation, this manual incorporates community insights from YouTube comments (u/nufh, u/robistocco, and others) and Reddit threads (u/illusionst, u/DonkeyBonked, and others) to provide a comprehensive framework for developers at every level.

### Why Is This Framework Useful?

AI models are powerful but prone to chaos such as over-engineering, scope creep, or context loss. This manual addresses the following problems:

- **Chaos control**: Enforces strict adherence to rules, minimizing off-track behavior.
- **Time savings**: Structured steps and summaries reduce rework.
- **Clarity**: Non-technical users can follow along easily, while programmers gain precise control.

### Key Benefits

1. **Clarity**: The rules are organized modularly, making them easy to navigate and adjust.
2. **Control**: The user directly dictates the pace and scope of the AI's work.
3. **Scalability**: Applicable to everything from small scripts (e.g., a calculator) to large apps (e.g., a web platform).
4. **Maintainability**: Documentation and tracking ensure long-term project viability.

## Structure of the Manual: How It Is Organized

The framework consists of four files (or sections), each with its own distinct purpose, in the `.cursor/rules` directory (or `.windsurfrules`):

1. **Coding preferences** – Define code style and quality standards.
2. **Tech stack** – Specify tools and technologies.
3. **Workflow preferences** – Manage the AI's process and execution.
4. **Communication preferences** – Set expectations for AI-human interaction.

We will start with the basics for accessibility and then move on to advanced details for technical depth.

## Core Rules: A Simple Starting Point

### 1. Coding Preferences – "Write Code This Way"

**Purpose**: Ensure clean, maintainable, and efficient code.

**Rules**:
- **Simplicity**: "Always prioritize the simplest solution over complexity." (Matthew Berman)
- **No duplication**: "Avoid repeating code; reuse existing functionality when possible." (Matthew Berman, DRY from u/DonkeyBonked)
- **Organization**: "Keep files concise, under 200-300 lines, and refactor as needed." (Matthew Berman)
- **Documentation**: "After developing a major component, write a brief summary in /docs/[component].md (e.g., login.md)." (u/believablybad)

**Why it works**: Simple code reduces bugs, and documentation provides a readable audit trail.

### 2. Tech Stack – "Use These Tools"

**Purpose**: Restrict the AI to the technologies the user prefers.

**Rules** (Berman's examples):
- "Write the backend in Python."
- "Write the frontend in HTML and JavaScript."
- "Store data in a SQL database, not JSON files."
- "Write tests in Python."

**Why it works**: Maintains consistency and prevents the AI from switching tools mid-project.

### 3. Workflow Preferences – "Work This Way"

**Purpose**: Control the AI's execution process for predictability.

- **Focus**: "Modify only the code I specify; leave everything else untouched." (Matthew Berman)
- **Steps**: "Break large tasks into stages and wait for my approval after each one." (u/xmontc)
- **Planning**: "Before big changes, write a plan.md and wait for my confirmation." (u/RKKMotorsports)
- **Tracking**: "Log completed work in progress.md and next steps in TODO.txt." (u/illusionst, u/petrhlavacek)

**Why it works**: Incremental steps and logs keep the process transparent and manageable.

### 4. Communication Preferences – "Talk to Me This Way"

**Purpose**: Ensure clear, actionable feedback from the AI.

- **Summaries**: "After completing each component, summarize what was done." (u/illusionst)
- **Change scale**: "Classify changes as Small, Medium, or Large." (u/illusionst)
- **Clarification**: "If my request is unclear, ask questions before proceeding." (u/illusionst)

**Why it works**: You get clear information without having to decipher the AI's intent.

## Advanced Rules: Scaling for Complex Projects

### 1. Coding Preferences – Raising Quality

**Extensions**:
- **Principles**: "Follow SOLID principles (e.g., single responsibility, dependency inversion) where applicable." (u/Yodukay, u/philip_laureano)
- **Guardrails**: "Never use mock data in development or production environments — restrict it to tests only." (Matthew Berman)
- **Context check**: "Start every response with a random emoji (e.g., 🐙) to confirm context retention." (u/evia89)
- **Efficiency**: "Optimize output to minimize token usage without sacrificing clarity." (u/Puzzleheaded-Age-660)

**Technical insight**: SOLID ensures modularity (e.g., the login module isn't responsible for handling tweets). The emoji signals when context has exceeded the model's limit (typically 200k tokens for Claude 3.7).

### 2. Tech Stack – Customization

**Extensions**:
- "If you specify additional tools (e.g., Elasticsearch for search), include them here." (Matthew Berman)
- "Never change the stack without my explicit approval." (Matthew Berman)

**Technical insight**: A fixed stack prevents the AI from introducing incompatible dependencies (e.g., switching from SQL to JSON).

### 3. Workflow Preferences – Process Mastery

**Extensions**:
- **Testing**: "Include comprehensive tests for major features and suggest edge case tests (e.g., invalid input)." (u/illusionst)
- **Context management**: "When context exceeds 100k tokens, summarize into context-summary.md and restart the session." (u/Minimum_Art_2263, u/orbit99za)
- **Adaptability**: "Adjust checkpoint frequency based on my feedback (more or less granular)." (u/illusionst)

**Technical insight**: Token limits (e.g., Claude's 200k) mean performance degrades past 100k. Summaries help maintain continuity, and tests catch regressions early.

### 4. Communication Preferences – Precision Interaction

**Extensions**:
- **Planning**: "For Large changes, provide an implementation plan and wait for approval." (u/illusionst)
- **Tracking**: "Always state clearly what is complete and what is pending." (u/illusionst)
- **Emotional signals**: "When I indicate urgency (e.g., 'this is important — don't mess it up!'), prioritize care and precision." (u/dhamaniasad, u/capecoderrr)

**Technical insight**: Change classification (S/M/L) quantifies impact (e.g., Small = under 50 lines, Large = architectural change). Emotional signals may let the AI draw on training data patterns to elicit better compliance.

## A Practical Example: How It Works

**Task**: "Build a note-taking app with save functionality."

1. **Specification**: The user says, "I need an app where I can write and save notes."

2. **AI response**:
   "🦋 Understood. Plan: 1. Backend (Python, SQL storage), 2. Frontend (HTML/JS), 3. Save functionality. Shall I proceed?"

3. **User**: "Yes."

4. **Execution**:
   After the backend: "🐳 Backend complete (Medium change). Notes are stored in SQL. I've updated progress.md and TODO.txt. Next: the frontend?"
   After the frontend: "🌟 Frontend complete. Added docs/notes.md with usage instructions. Done!"

5. **Result**: A working app with logs (progress.md, /docs) for reference.

**Technical note**: Each stage is individually testable (e.g., SQL inserts work), and context is preserved through summaries.

## Advanced Tips: Maximizing the Framework

### Why Four Files?
- **Modularity**: Each file separates a concern (style, tools, process, communication) for easy updates. (Matthew Berman)
- **Scalability**: You can adjust one file without disturbing the others (e.g., tuning the communication style without touching the tech stack). (u/illusionst)

### Customization Options
- **Beginners**: Skip the advanced rules (e.g., SOLID) for simplicity.
- **Teams**: Add team-collaboration.mdc: "Align with the team rules in team-standards.md and summarize for colleagues." (u/deleatanda5910)
- **Large projects**: Increase the frequency of checkpoints and documentation.

### Emotional Prompting
- Try it: "This project is important — please focus!" Anecdotal evidence suggests improved attentiveness, which may stem from training data bias. (u/capecoderrr, u/dhamaniasad)

## Credits and Acknowledgments

This framework owes a debt to the following contributors:

- **Andrej Karpathy**: Coined the term "vibe coding" and introduced it to the broader community in a post on X (February 3, 2025). He described AI-assisted programming focused on intuitive, minimal-effort workflows. His work inspired the foundational concepts of this framework.

- **Matthew Berman**: Core vibe coding rules and philosophy (YouTube, 2025).

- **YouTube community**:
  - u/nufh, u/believablybad (documentation, .md files).
  - u/robistocco (iterative workflow).
  - u/xmontc (checkpoints).

- **Reddit community**:
  - u/illusionst (communication, progress tracking).
  - u/Puzzleheaded-Age-660 (token optimization).
  - u/DonkeyBonked, u/philip_laureano (KISS, DRY, YAGNI, SOLID).
  - u/evia89 (emoji context check).
  - u/dhamaniasad, u/capecoderrr (emotional prompting).

- **Grok (xAI)**: At u/Low_Target2606's request, synthesized this manual by consolidating all the insights into a single coherent framework.

## Conclusion: A Guide to Vibe Coding

This manual is a battle-tested template for putting AI to work in development. Balancing simplicity, control, and scalability, it is ideal for solo coders, teams, or non-technical creators. Use it as is, adapt it to your needs, and share your results — I'd love to see how it evolves! Post your feedback on Reddit and let's improve it together. Happy coding!

---

## Appendix: Example Global Rules and Workspace Rules for Windsurf

### Global rules

#### 1️⃣ Implementation Principles

- Implement using SOLID principles:
  - Single Responsibility Principle
  - Open-Closed Principle
  - Liskov Substitution Principle
  - Interface Segregation Principle
  - Dependency Inversion Principle
- Implement with TDD: write tests first, then implement, following test-driven development.
- Implement using Clean Architecture: clearly separate responsibilities and concerns.

#### 2️⃣ Code Quality Principles

- Simplicity: always prioritize the simplest solution over a complex one.
- No duplication: avoid duplicating code and reuse existing functionality where possible (DRY principle).
- Guardrails: never use mock data in development or production environments, only in tests.
- Efficiency: optimize output to minimize token usage without sacrificing clarity.

#### 3️⃣ Refactoring

- When refactoring is needed, explain the plan, get permission, and then proceed.
- The goal is to improve the code structure, not to change functionality.
- After refactoring, confirm that all tests pass.

#### 4️⃣ Debugging

- When debugging, explain the cause and the solution, get permission, and then proceed.
- What matters is not clearing the error but making it work properly.
- If the cause is unclear, add detailed logs for analysis.

#### 5️⃣ Language

- Communicate in Korean.
- Write documentation and comments in Korean as well.
- Technical terms, library names, and the like may stay in the original language.

#### 6️⃣ Git Commits

- Never use `--no-verify`.
- Write clear, consistent commit messages.
- Keep commits at an appropriate size.

#### 7️⃣ Documentation

- After developing a major component, write a brief summary in /docs/[component].md.
- Update documentation along with the code.
- Explain complex logic or algorithms in comments.

### Workspace rules

#### 1️⃣ Tech Stack - "Use These Tools"

##### Development Tools
- Backend: use Python
- Infrastructure: Pulumi for TypeScript, CloudFormation
- Data storage: MySQL-compatible Aurora Serverless
- Testing: pytest, Jest

##### Additional Notes
- Additional tools may be included here if explicitly requested.
- Do not change the stack without explicit approval.
- Write resource Descriptions in Terraform or CDK in English.

#### 2️⃣ Workflow Preferences - "Work This Way"

##### Basic Process
- Focus: modify only the specified code and leave the rest as is.
- Steps: break large tasks into stages and wait for approval after each one.
- Planning: before big changes, write a design and task overview document [issue-name]_design.md and an implementation plan document [issue-name]_plan.md, then wait for confirmation.
- Tracking: log completed work in progress.md and next steps in TODO.txt.

##### Advanced Workflow
- Testing: include comprehensive tests for major features and suggest edge case tests.
- Context management: when context exceeds 100k tokens, summarize into context-summary.md and restart the session.
- Adaptability: adjust checkpoint frequency based on feedback (more or less granular).

#### 3️⃣ Communication Preferences - "Communicate This Way"

##### Basic Communication
- Summaries: summarize the completed work after each component.
- Change scale: classify changes as small, medium, or large.
- Clarification: if a request is unclear, ask before proceeding.

##### Precision Communication
- Planning: for large changes, provide an implementation plan and wait for approval.
- Tracking: always state what is complete and what is pending.
- Emotional signals: when urgency is indicated (e.g., "this is important — please focus!"), prioritize care and accuracy.

#### 4️⃣ Project Structure

##### Directory Structure
- `docs/`: all documentation files
  - `architecture/`: architecture documents
  - `guides/`: developer guides
  - `runbooks/`: operations manuals
- `src/`: source code
  - `core/`: core business logic
  - `infrastructure/`: infrastructure-related code
  - `api/`: API endpoints
- `tests/`: test files

##### Naming Conventions
- File names: use snake_case (e.g., `user_service.py`)
- Class names: use PascalCase (e.g., `UserService`)
- Function and variable names: use snake_case (e.g., `get_user()`)
- Constants: use UPPER_SNAKE_CASE (e.g., `MAX_USERS`)

#### 5️⃣ How to Use This

This rule set is a template for AI-assisted development. Use it as follows:

1. Reference these rules when starting a project.
2. Adjust the rules as needed.
3. Instruct the AI model to follow the contents of this file.
4. As the project progresses, evaluate how much these rules help.

With this rule set, collaborating with AI will become more efficient and more predictable.
