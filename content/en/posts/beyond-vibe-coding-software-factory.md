---
title: "Beyond Vibe Coding, Toward the Software Factory"
date: 2026-09-16T10:00:00+09:00
draft: false
toc: false
images:
tags:
  - vibe-coding
  - software-factory
  - ai-transformation
  - agentic-dev
---

> “Week 10: The Software Factory + The Future” — Stanford CS146S, Fall 2026 syllabus[^1]

{{< figure src="/posts/images/Dohyun.png" title="Dohyun Jung - Principal Consultant, ROBOCO" style=".author-image">}}

---

Where is AI transformation, or AX, heading? That is what I want to explore today.

Having AI write code is no longer unfamiliar. You describe what you want to build, check the result, and ask for revisions. Vibe coding has substantially lowered the barrier between an idea and working software.

What comes next? I see something beyond an individual developer talking with AI to produce code: a continuous process that takes customer needs, designs features, implements and verifies them, deploys them, and returns to observing how people respond.

Taken together, my personal experience and various pieces of circumstantial evidence lead me to suspect that our industry is quietly entering the **software factory** stage.

## 1. Where Stanford's final week points

Stanford has published the course overview and weekly schedule for **CS146S: The Modern Software Developer**, offered in Fall 2026. It covers coding agent internals, context engineering, agent skills, code review, and security.[^1]

You can read it as starting from vibe coding, but its scope extends beyond an individual's use of coding tools. The title of the final week especially caught my attention.

**The Software Factory + The Future.**

Its three main topics are:

- Software systems that run and improve themselves
- Operating agents securely after deployment
- The future direction of AI software engineering

I read this structure as a signal of a change in how software is made. The question expands from generating code successfully once to designing a system where development and operations keep moving together. The inclusion of operations and security after deployment is particularly significant. A factory does not finish its job after producing a single item.

## 2. Send feedback, see the product change days later

My colleagues at ROBOCO and I actively send feature requests and feedback about frustrations we encounter while using AI services. Recently, an interesting experience has kept recurring.

We often see related features launch as early as the next day, or within two or three days of sending feedback. Sometimes an entirely new service appears that addresses the problem we had discussed.

These are personal observations, of course. A feature already in development may have happened to launch, or other users may have made the same request. We have not established that our feedback caused the release, or that the company automated its entire development process.

Still, as these experiences accumulate, it is natural to wonder: could a production system already be running somewhere that connects incoming customer feedback to requirements analysis, implementation, testing, and deployment?

The time between a user's frustration and a change in the product is getting shorter. In that speed, I see the possibility of a software factory.

Let me be clear: vibe coding alone cannot explain the pace at which AI services are being updated today.

## 3. From AI that writes code to people who operate development teams

Models such as Anthropic's Claude Fable 5 and OpenAI's GPT-6 Astra make this vision more concrete. Anthropic highlighted Fable 5's ability to handle long, complex tasks, while OpenAI introduced GPT-6 Astra's capabilities in software engineering and multistep work.[^2][^3]

These announcements do not establish that every project can operate with full autonomy. However, I believe it is now realistic to consider letting AI lead each stage of the software development lifecycle in environments with defined quality standards, permissions, and verification processes.

Consider one possible workflow. Customer requests or product usage data reveal a problem worth addressing. Agents define the requirements and success criteria, then design the scope of the change. They implement and test it, while a separate review process examines the result and its risks. Once the agreed conditions are met, the change is deployed. Operational metrics then inform the next improvement.

People need not type the next instruction at every stage. They can define goals and constraints, establish what may be delegated, and intervene when an important decision is needed.

One team might handle customer feedback, another analyze product usage, and a third work on performance or technical debt. This makes it possible to operate multiple automated software development teams working 24 hours a day, seven days a week. Even when some tasks await a human decision, work that does not depend on that decision can continue.

In vibe coding, a person works with AI to build a feature. In a software factory, a person designs the purpose and operating principles of several development workflows.

## 4. A software factory needs a good reporting system

If someone must read every conversation and execution log from several development teams, human review time will soon become the bottleneck. **How information reaches the person making decisions** therefore matters as much as development automation.

People need to know what changed, why it changed, what verification passed, and what risks remain. They also need to know whether a decision is required now. Some will want a short summary, others a dashboard, and others an alert when an important exception occurs. Relevant information should arrive in the preferred format, with detailed evidence available when needed.

For example, a small change to interface wording could deploy automatically after passing agreed checks. Deleting customer data or changing a payment policy could instead require a human decision supported by an account of the impact and recovery options. The scope of automation and the conditions for stopping should match the risks of the work.

Self-improvement also needs a concrete meaning. Failures found in production can become test cases. Recurring mistakes can inform development guidelines, and ineffective procedures can be revised. Those improvements must themselves be verified. If a system arbitrarily changes its own success criteria, the claim that it has improved becomes difficult to trust.

A software factory's productivity ultimately depends on its ability to verify results, handle exceptions, and involve human judgment at the right time, alongside its speed of code generation.

---

## 5. Conclusion: More room for creativity and imagination

Some call this kind of collaboration with AI the outsourcing of thought. If we simply accept results without understanding them, the criticism is fair. Judgment about what we are building, why it is needed, and what outcomes we will accept remains important.

But how much of the software development lifecycle truly requires human creative thought? Does everything we do in a day demand a new insight? How much time do we spend implementing established rules, fixing recurring errors, running tests, and documenting changes?

If AI can take on that work, we can spend more time understanding customers' frustrations and imagining solutions we have not yet tried. We can experiment with ideas previously shelved because of implementation costs, and build several alternatives to compare them in practice.

As the software factory draws closer, what is worth building becomes as important as what we can build. The more ideas we can execute, the more consequential our decisions about direction become.

I believe AI has given people more room to exercise their creativity and imagination.

---

[^1]: Stanford CS146S: The Modern Software Developer, Fall 2026 course overview and Week 10 in the Syllabus tab. Accessed September 16, 2026: https://themodernsoftware.dev/
[^2]: Anthropic, Claude Fable 5 and Claude Mythos 5: https://www.anthropic.com/news/claude-fable-5-mythos-5
[^3]: OpenAI, GPT-6 Astra: A new generation of intelligence: https://openai.com/index/gpt-6-astra/
