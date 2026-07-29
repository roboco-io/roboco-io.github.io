---
title: "Vibe Coding: Truth or Myth"
date: 2025-03-27T10:18:33+09:00
draft: true
toc: false
images:
tags:
  - vibecoding
---

{{< figure src="/posts/images/Dohyun.png" title="Dohyun Jung - Principal Consultant, ROBOCO" style=".author-image">}}

I got into programming in 1986 on an Apple II — more precisely, on a "Cheonggyecheon No. 2," a machine built from Apple OEM stock siphoned off and sold on the gray market. I have worked as a professional programmer since 1995, which means I have been coding for close to thirty years now. Over that long stretch I have lived through countless shifts in software development trends, but none as jolting as the arrival of vibe coding. Since December of last year I have been doing actual production development with vibe coding. Looking at social media lately, there seems to be a great deal of both worry and expectation around it. Drawing on my own experience, I want to talk about this new phenomenon.

## TL;DR

- Vibe coding is not simply AI-assisted coding; it is closer to a development style where the human defines the problem and the AI drives the solution.
- Existing engineering skills — software knowledge, problem decomposition, testing, architecture — still matter.
- Rather than a passing fad, it is a current that will keep developing, and companies and developers need an attitude of understanding it and putting it to use.

**First, does vibe coding just mean developing with AI?** Yes and no. Developers have been using AI such as GitHub Copilot and ChatGPT for several years now. The difference is that the previous approach was human-led problem solving, whereas in vibe coding the human defines the problem and the AI takes responsibility all the way through the solution. In automotive terms, development up to now has gone from manual transmission to automatic, and then on to navigation. Vibe coding is closer to autonomous driving: you name the destination and it takes you there.

**Second, is vibe coding really possible without software knowledge?** Here too the answer is both yes and no. AI is extremely effective at solving relatively narrow problems, such as algorithm exercises. But for vibe coding to work well on a project past a certain size, a clear problem definition and well-maintained context boundaries are essential. Today's AI tools struggle with excessively complex context. So the ability to break a problem down into appropriately small pieces — that is, a basic understanding of software engineering — is still required. How long this will remain true is anyone's guess, because LLMs and vibe coding tools are advancing fast. What can be said with confidence is that vibe coding as of today has no trouble at all handling context that goes beyond the function level up to the scale of a microservice for most problem solving.

**Third, is vibe coding a passing fad?** No. Like the internet or the smartphone, it is already out in the world, and there are plenty of developers — myself included — actually building with it. The usefulness of vibe coding has already been demonstrated; it will not vanish like a fad but will keep improving. AI, the core technology underpinning vibe coding, is also advancing rapidly. Problems that feel hard right now will be solved before long. Going forward, vibe coding will establish itself as an important tool not only for software but for solving all sorts of real-world problems with AI. Of course, people will try to abuse it too, so we need to prepare for that.

**Fourth, can vibe coding not be used for large-scale development?** It can. There are limits today given AI's capability, but they are entirely solvable. You divide the development into pieces sized for the AI to handle well. Limiting the context the AI has to consider through prompt engineering, or migrating outright to microservices, are both good approaches. It is perfectly feasible and effective. The important point is that using vibe coding on a project past a certain size requires its own methodology and process.

**Fifth, does vibe coding produce a lot of bugs?** Yes. But so does code written by humans. Human or AI, bugs increase as scale grows. The key is to develop in small enough pieces to keep the implementation at the size where vibe coding works well. This is where a structure that is closed to modification and open to extension — the 'O' in the SOLID principles — really shines. On another front, TDD (test-driven development) is extremely useful in vibe coding as well. The difference is that a human doing TDD writes the test first and then the implementation, whereas the AI produces the test and the implementation almost simultaneously. Test code written this way becomes a sturdy shield against later changes.

**Sixth, is vibe coding a completely new way of developing?** Not yet. Just as cars still have steering wheels even though autonomous driving has arrived, vibe coding inherits the good practices of existing software development. Test code, the SOLID principles, clean architecture, DDD, CI/CD, static code analysis — the established best practices carry over to vibe coding intact. If anything, because AI can adhere to these principles more rigorously, it lets you maximize the benefits those practices bring. That said, I expect vibe coding will soon advance to the point where it no longer shows you the code itself, or can hide it without any problem — much as the steering wheel disappears in a fully autonomous car. Programming languages and frameworks built for AI may even emerge.

**Finally, can vibe coding not be used at large enterprises?** I expect the spread of vibe coding to follow a pattern similar to cloud computing adoption. From a large enterprise's point of view, adopting vibe coding quickly will not be easy. But over time, issues like compliance will be addressed by solutions from the cloud vendors. Companies with insight into technology will confirm the potential and hurry to adopt. Startups, lighter on their feet than large enterprises, are already adopting vibe coding at a rapid pace. Even so, defining and solving business problems remains the human's job.

To sum up, vibe coding is not a passing fad. It still has gaps, but it holds enormous potential and it is evolving without pause. What matters is our own attitude — understanding it and knowing how to use it well.
