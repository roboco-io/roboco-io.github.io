---
title: "Vibe Coding and the XY Problem"
date: 2025-06-06T09:56:25+09:00
draft: true
toc: false
images:
tags:
  - vibe-coding
  - xyproblem
---

{{< figure src="/posts/images/Dohyun.png" title="Dohyun Jung - Principal Consultant, ROBOCO" style=".author-image">}}

Have you ever heard of the XY Problem? Put simply, it's the phenomenon of leaving the real problem (X) untouched while fixating on a solution (Y) you've arbitrarily assumed. Here's an example. Your car won't start, and without properly checking anything, you jump to the conclusion that it's the battery and ask, "How do I hook up the jumper cables?" The real problem is that the car won't start, and while you have no idea whether it's the battery, whether you're out of fuel, or whether it's the electrical system, you're floundering around clinging to Y (connecting jumper cables).

## TL;DR

- The XY Problem crops up easily in vibe coding too, with the AI clinging to the solution the user assumed rather than the real problem.
- An instruction like "make the test pass" can be misread as editing the test rather than fixing the cause of the failure.
- Putting an intent-confirmation step in your rules file gets the AI to ask about the goal before starting work, and cuts down on it heading off in the wrong direction.

This XY Problem shows up in vibe coding fairly often. Vibe coding works by a person giving instructions to an AI, and the AI understanding them and carrying out the work. The trouble is that the instructions people give aren't always clear. As a result, the AI sometimes misreads the intent and wanders off down the wrong path. Let's look at an example.

"The tests are failing — fix them, would you?"

What if the AI hears this and, instead of actually finding out why the tests are failing, just blindly edits the test code to make them pass? That's when things start to unravel. Passing the tests was never the goal; correcting the cause of the failure is the whole point.

Why does this happen? Because AI is fundamentally trained to "infer intent" for the user's convenience. That's what lets it handle things impressively well from just a brief remark — but it also means that, faced with an imprecise instruction, it sometimes takes off in a direction of its own choosing, and an accident happens.

Still, how tedious would it be to explain every last detail to the AI for every single task, or to leave it constantly asking you questions? That's why the smartest way to handle the XY Problem in vibe coding is to add a process to your rules file that confirms the AI has correctly understood your intent.

With this in place, the AI double-checks whether it has fully grasped the user's intent before carrying out an instruction, and asks again when it isn't sure. Below is a simple example of such a rule.

```
Rule: Confirm the clarity of the task's intent

- When the AI receives an instruction from the user, it summarizes the core intent of the instruction and asks the user to confirm it before starting work.
- If the user confirms, it proceeds with the work; if not, it asks again to clarify the exact intent.

Example:

User: "Fix the failing tests in the build."

AI: "To confirm: rather than modifying the test code itself to make the build pass, you want me to find the cause of the failure and correct the error in the original code so the tests pass — is that right?"

User: "Yes. Go ahead."
```

Just doing this can dramatically reduce trouble related to the XY Problem. Misunderstandings between people and AI, along with the trial and error of going down the wrong path, will be minimized as well. I always emphasize approaching vibe coding with the mindset that you're pair programming with the AI. And so the core strategy behind the vibe coding we pursue at ROBOCO is this: **how can we convey our "intent" clearly with the least possible effort?**
