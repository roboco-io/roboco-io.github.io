---
title: "The Strengths and Weaknesses of Vibe Coding"
date: 2025-06-02T10:40:26+09:00
draft: true
toc: false
images:
tags:
  - vibe-coding
---

{{< figure src="/posts/images/Dohyun.png" title="Dohyun Jung - Principal Consultant, ROBOCO" style=".author-image">}}


As I noted in my earlier [post on the productivity of vibe coding](/en/posts/vibe-coding-productivity/), that productivity hinges on two factors. The first is human productivity — the developer's ability to solve problems and analyze them. The second is the productivity of the tools and processes that complement and amplify that ability. Productivity here does not mean simply writing code fast. It covers the whole range of competence involved in making a plan, analyzing a problem, and finding a solution.

## TL;DR

- The productivity of vibe coding depends not only on the capability of the AI tool but heavily on the developer's analytical skill and ability to design the work.
- It shines on tasks with a clear specification, on porting work, and on script-like tasks where inputs and outputs are well defined.
- Where it is unclear what should be built, or where the context is complex, human judgment and deliberate scoping still matter.

Across a number of real projects I have worked through, I ended up empirically sorting the tasks vibe coding handles well from the ones it does not. With any kind of work, knowing what a tool is good at and what it is bad at is what matters. Put another way, using a tool well requires knowing its character.

Let us start with the tasks vibe coding is unusually good at.

First, tasks with a clearly defined specification. Even when the vibe coder does not know every last detail, if the content of the work and the order of the steps are well documented, the AI produces astonishingly accurate results. Clear documentation is the key that draws out the AI's full capability.

Second, porting work. If a project has already been completed in another language, on another platform, or in another framework, that code itself serves as a perfect specification. The AI can reference the existing code and carry out the port quickly and to a high standard. If the existing project is short on automated tests, it works far more accurately and efficiently to have the AI generate unit tests (UT), integration tests (IT), and end-to-end tests (E2E) first, then apply them to the target project of the port.

Third, simple scripts and utility work. When inputs and outputs are clearly fixed, the AI gets the job done at what feels like the speed of light. Even for one-off work, adopting test-driven development (TDD) lets you move fast while raising reliability.

Not everything is that simple, though. There are also tasks vibe coding does poorly.

First, tasks where it is unclear what should be built. This comes up often in software development: work where the specification has to be refined incrementally through the act of implementing it. DevOps tooling and complex workflow design are examples. For work like this, the smart move is to simulate various scenarios through conversation with a chat-based AI service such as ChatGPT, settle on a direction, and only then implement.

Second, tasks carrying complex context. A monolithic architecture with a complicated relational database, in particular, has context so vast and tangled that even a human can easily get lost in it. Ideally you would break the work apart into microservices, but that is often impractical. In such cases, one option is to use prompt engineering to limit the size of the context the AI has to handle — selecting only the documents or code relevant to each task and supplying them as a rules file. It does mean the tedium of updating the rules dynamically for every task, but with the recent arrival of tools like [TaskMaster AI](https://www.task-master.dev/) and [BMAD-METHOD](https://github.com/bmadcode/BMAD-METHOD), even this part is becoming automatable.

Using vibe coding effectively, then, ultimately comes down to AI and human understanding and exploiting each other's strengths and weaknesses. On clearly defined tasks, the AI's speed and accuracy shine; on complex, ambiguous ones, human judgment and analysis still matter.

Even at this very moment, vibe coders around the world are experimenting nonstop. The tasks that vibe coding can already build are being built, and for the complex problems it cannot yet solve, the attempts keep coming. The tool may have limits, but there is no limit to the creativity and daring of the humans who wield it.
