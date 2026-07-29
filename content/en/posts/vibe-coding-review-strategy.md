---
title: "A Review Strategy for Vibe Coding"
date: 2025-06-07T12:21:04+09:00
draft: true
toc: false
images:
tags:
  - vibe-coding
  - productivity
---

{{< figure src="/posts/images/Dohyun.png" title="Dohyun Jung - Principal Consultant, ROBOCO" style=".author-image">}}

It is true that adopting vibe coding automates several areas of development and raises productivity. But review is something people have to do, because people are the ones accountable for the outcome — and so the bottleneck ends up moving to review (document review, plan review, code review, and so on). Today I want to talk about review.

## TL;DR

- Vibe coding speeds up generation, but if code, document, and plan reviews stay the same, the bottleneck simply shifts to the review stage.
- To raise review quality, make approval accountability explicit, and use checklists and risk flags so that reviewers judge actively rather than passively.
- The more automation grows, the more deliberately human review has to be designed — you need a structure that attaches meaning and accountability even to small actions.

Let's start with code review.

Bottlenecks in code review usually appear because reviewers feel less accountable, or because they passively click a button. To improve this, it helps to establish a clear rule that "pressing the approve button means you share responsibility for the quality of this code." Having reviewers explicitly confirm a pledge such as "I have verified both the quality and the safety of this code" before approving noticeably raises their sense of psychological accountability.

Organizing review items into a checklist so reviewers examine them thoroughly is also effective. Checking performance, security, code style, and so on item by item in a code review lets you review systematically without missing anything. In fact, limiting a single review to 400 lines of code or fewer and using a checklist is said to raise defect detection rates significantly. Many companies are already getting results from this approach.

It also helps to highlight risk or importance to developers when presenting a review. Adding a note such as "this change touches the payment system, so please look at it very carefully" keeps reviewers from skimming past it and gets them to approach it more responsibly. Sharing real incidents that led to problems because they slipped through review also makes reviewers feel how important their role is, so they pay closer attention.

A culture of social comparison and recognition works well too. Naming a "most active reviewer," or holding small events that praise and reward cases where a review caught a defect, has an effect. If you turn review activity into something game-like, collaborative, and enjoyable, developers come to see the review work itself as a process of achievement.

The same goes for document review. When developers work through a checklist covering technical scenarios, performance concerns, error-handling scenarios, and the like, the quality of the review goes up. Setting a baseline rule before the review starts — something like "let's find at least one improvement in this document" — also gets developers to offer opinions actively during the review. Handing out a short questionnaire so developers read the document in advance and come prepared is another good approach.

In plan review, what matters is that developers supply a realistic perspective. When the plan is overly optimistic, it works well to prompt developers to surface realistic risk factors by asking questions such as "what is the worst-case scenario?" Sharing feedback on how review comments were actually reflected in the project afterward is another important element. Once people see how the outcome of a review played out in reality, they take the next review more seriously.

In the end, review comes down entirely to accountability and engagement. In the age of vibe coding, the more automation grows, the more important accountable human review becomes. So if you make good use of human behavioral psychology when designing your review process, you can raise review quality and productivity naturally. What matters is giving meaning to even a single small action and making people feel accountable for it. Do that, and you will not only ease the review bottleneck but also improve quality.
