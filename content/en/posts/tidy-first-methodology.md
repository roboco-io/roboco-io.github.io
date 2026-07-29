---
title: "The Tidy First Methodology: Interpreting and Applying Kent Beck's Augmented Coding"
date: 2025-07-27T06:29:39+09:00
draft: true
toc: false
images:
tags:
  - Vibe Coding
  - Tidy First
  - Kent Beck
---

{{< figure src="/posts/images/Dohyun.png" title="Dohyun Jung - Principal Consultant, ROBOCO" style=".author-image">}}

Lately I've been using Claude Code as my main working tool. The reason Claude Code performs so well is that it doesn't execute a task immediately — it plans the work as a whole, systematically, then breaks it into small, clearly defined steps and carries them out one at a time.

Today I'd like to introduce one more useful methodology on top of that: the approach called "Augmented Coding," proposed by Kent Beck — famous as the originator of TDD (Test Driven Development) — on his blog. Seeing that he, too, is obsessed with coining new terms, it looks like he's in a hurry to grab a piece of the vibe coding wave. That said, since this approach is grounded in the content of a book Kent Beck wrote previously — [Tidy First? by Kent Beck](https://www.hanbit.co.kr/store/books/look.php?p_code=B1474193984) — I've decided, on my own authority, to call it the "Tidy First methodology."

## TL;DR

- Tidy First is an approach that separates structural changes from behavioral changes to lower complexity when coding with AI.
- Tidy the code first and verify it with tests, then introduce functional changes — that's what keeps your workflow from getting shaken up.
- Used together with a tool like Claude Code, it makes it easier for the developer to stay in control of code quality and direction.

## The Core of Augmented Coding and Tidy First

The core of what Kent Beck calls Augmented Coding is clearly dividing coding work into two kinds: structural changes and behavioral changes. Structural changes are things like moving code around, renaming, or extracting a method — work that doesn't alter the behavior of the code. Behavioral changes are work that actually adds to or modifies the functionality of the code.

Beck emphasizes that these two kinds of change must never be mixed into a single commit. In particular, he explains that you should always handle structural changes first, and only introduce behavioral changes once you've lowered the complexity of the code that way and are maintaining a clear test environment.

## The Rules Kent Beck Laid Out

Here are the "Tidy First" rules Kent Beck actually used in his project:

* Always follow the TDD cycle (red → green → refactor) strictly.
* Write the simplest failing test first.
* Make the test pass with the minimum amount of code, and go no further.
* Refactor only after the test passes.
* Separate structural changes from behavioral changes, and keep the commits clearly distinct.
* Commit only when all tests pass, there are no warnings, and the work forms a clear logical unit.
* Thoroughly eliminate duplication in the code, and express intent through clear names and structure.
* Keep methods small, and have each one carry a single responsibility.

If you code while keeping to these clear rules, your code will incrementally become more robust and easier to understand, while avoiding complexity and unnecessary feature additions.

## Applying Tidy First in Practice, and Its Benefits

From applying this "Tidy First methodology" alongside Claude Code in real projects, I found that it worked very effectively in the majority of them. When you start with structural changes to keep the codebase clean and only then introduce behavioral changes, you're far less likely to get lost midway as the code grows complex.

As Kent Beck noted in his [B+ Tree project](https://github.com/KentBeck/BPlusTree3), there are times when AI (GenAI) adds features that aren't needed, or the code becomes complex and development slows down. To prevent this, you should always do the structural tidying work first, and only add the next functional change after that work has been precisely verified by tests.

The "Tidy First methodology" lets the developer maintain control and clarity over the code when working with AI, and it's a great help in managing code quality and complexity.

This methodology will surely be effective in your projects too. I strongly recommend giving it a try.

#### Related Links
- [Augmented Coding: Beyond the Vibes](https://tidyfirst.substack.com/p/augmented-coding-beyond-the-vibes)
- [The rules file for the BPlusTree project](https://github.com/KentBeck/BPlusTree3/blob/main/.claude/system_prompt_additions.md)
- [Tidy First? by Kent Beck](https://www.hanbit.co.kr/store/books/look.php?p_code=B1474193984)
