---
title: "The Art of Vibe Coding"
date: 2025-05-04T11:59:09-07:00
draft: true
toc: false
images:
tags:
  - vibecoding
  - gpt
---

{{< figure src="/posts/images/Dohyun.png" title="Dohyun Jung - Principal Consultant, ROBOCO" style=".author-image">}}

Have you ever heard the term vibe coding? It didn't start out as a compliment. It was used with a hint of sarcasm to describe developers who wrote code relying only on intuition and feel, often ignoring rigorous structure or rules. Interestingly, though, it has recently come to be associated with generating code through prompts alone using artificial intelligence (AI) — large language models (LLMs) in particular. Of course, you can write perfectly exemplary, maintainable code even when using an LLM. And if you get code that works well on the first try, without a cycle of trial and error, that means vibe coding did its job — and that you genuinely understand what AI-driven development is about.

I sometimes hear the question, "Isn't AI coding basically the same as a compiler?" On the surface, that's true. Just as a compiler turns code into machine language, an LLM turns a natural language prompt into code. But that's where the resemblance ends. The biggest difference is determinism. A compiler always produces the same output for the same input, whereas an LLM can produce subtly — or completely — different output for the same input. Feed it an incomplete prompt, or one with no context, and you may get something entirely off the mark. Code is an unambiguous language, but human language is not. That's why an LLM always has to "guess" at your intent.

So how can you trust a tool that is this nondeterministic? The answer looks a lot like how we come to trust other probabilistic systems: the concept of convergence. Think of simulated annealing, which allows randomness while gradually narrowing the search for an optimal solution. Stochastic gradient descent, used in machine learning, likewise converges probabilistically toward better and better results. Even we human developers vary in condition and output from day to day, yet good habits and good systems make us converge on trustworthy results. In other words, if you structure things so that the LLM converges on useful results rather than on perfection, it can absolutely be trusted.

## TL;DR

- Vibe coding isn't handing your code over to your gut; it's structuring things so that a nondeterministic LLM converges on useful results.
- Trust doesn't come from eyeballing every line of code. It comes from turning automated verification — tests, linters, formatters — into a repeatable system.
- Good inputs, small steps, and bold simplification determine the quality and maintainability of AI-driven development.

Even setting aside grand topics like convergence, working with an LLM is miserable unless you automate the job of checking whether the generated code is correct. Many people say they can't trust LLM-generated code. As we just saw in comparing it to a compiler, that distrust is entirely natural. But why should human eyes be the ones verifying whether generated code is right? If, when using a technique like a genetic algorithm, you had to manually check whether every gene produced by crossover and mutation was actually valid, nobody would want to use it.

To get real value out of an LLM, you need to follow a few principles.

First, simplify boldly. LLMs often try to build overly complex structures. Delete unnecessary classes, abstractions, and complicated structures, and keep everything in its most minimal form. Simplification reduces the chance of errors and lets you spot problems quickly.

Second, work in small steps. Trying to solve everything at once will fail. Start by writing clear requirements, and unpack anything ambiguous with examples. Have it produce a design document if you need one, and review that document together. Taking it one step at a time this way reduces errors.

Third, lean hard on automation. As soon as you have an example, turn it into a runnable test. It helps to set up a script that automatically runs your code formatter, linter, and unit tests. Leave trivial style issues to the automatic formatter, and get the LLM to run the tests itself after making a change and fix whatever fails. Automation is both cheap and fast.

Finally, provide good inputs. An LLM flounders when it's uncertain. Giving it trustworthy inputs — up-to-date documentation, accurate API information — dramatically reduces endless iteration and uncertainty.

Vibe coding, once an object of ridicule, has emerged as a powerful way of thinking in the age of AI. But intuition alone isn't enough. In the end, this game is about orchestrating convergence well. Simplify, automate, and point clearly in the right direction. Do that, and the model will find the right path and catch the "vibe" on its own.
