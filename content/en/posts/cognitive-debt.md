---
title: "Cognitive Debt - Managing a New Kind of Debt in the Vibe Coding Era"
date: 2026-07-18T10:00:00+09:00
draft: false
toc: false
images:
tags:
  - cognitive-debt
  - vibe-coding
  - agentic-dev
  - technical-debt
  - human-in-the-loop
---

> "Shipping first time code is like going into debt. A little debt speeds development so long as it is paid back promptly." — Ward Cunningham, OOPSLA '92[^1]

{{< figure src="/posts/images/Dohyun.png" title="Dohyun Jung - Principal Consultant, ROBOCO" style=".author-image">}}

---

Work with vibe coding long enough and a strange moment arrives. This is unmistakably my project, yet when I open the code it feels like someone else's house. The agent designed it, the agent implemented it, and I pressed the approve button. The work got done fast. But when something breaks, I find myself saying: "Why did this happen? The AI wrote it, so I'm not really sure."

This is cognitive debt. Code accumulates but understanding does not. That gap is the debt.

The term is not hyperbole. In 2025, an MIT Media Lab research team measured the brains of people writing essays using EEG. The group that used an LLM showed the weakest neural connectivity, could not properly quote what they had written, and reported the lowest sense of ownership over their own writing. The pattern persisted even after they stopped using AI. The team named the phenomenon "cognitive debt."[^2] The data on the code side points the same way. When GitClear analyzed over 200 million lines of commits, copy-pasted code rose and refactoring fell by more than half over the period AI assistants spread.[^3] Output got faster. Understanding and cleanup got pushed back.

---

## Does Putting a Human in the Loop Solve It?

The usual prescription in the face of this problem is human-in-the-loop: have a human review every artifact. It sounds plausible. In reality it doesn't work.

The reason is simple. Agents produce far faster than humans. If a human is involved every time, the human becomes the bottleneck. A human who is the bottleneck is pressed for time. Under time pressure, they stop looking at the content and just press approve. Review becomes a formality, and a formalized review manufactures an illusion — the illusion that "a human looked at it, so it's fine." That can be worse than nobody looking at all.

This isn't a new discovery. Automation research reached this conclusion 40 years ago. In a 1983 paper, Bainbridge pointed out the ironies of automation. The more something is automated, the fewer chances a person has to practice their skills. What's left is tedious monitoring. Yet the moments when the human must intervene are precisely the hardest ones.[^4] Follow-up research also confirmed that automation complacency is not a novice-only problem. Experts grow just as complacent, and it doesn't respond well to training or instruction.[^5]

Your own sense of things isn't trustworthy either. METR ran a randomized controlled trial with experienced open-source developers in 2025. Developers using AI tools were actually 19% slower, yet they felt they were 20% faster.[^6] The gap between feeling that you understand and actually understanding — cognitive debt grows in exactly that gap.

---

## Debt Is Something You Manage, Not Something You Eliminate

So what should we do? I want to argue that we should treat cognitive debt the same way we treat technical debt.

Ward Cunningham, who coined the term technical debt, never framed debt as evil. Quite the opposite: a little debt speeds development. The problem isn't the debt itself but the interest that accrues when you leave it unpaid.[^1] The same holds for cognitive debt. Demanding that a human fully understand and be able to explain every line of AI-generated code is unrealistic. The moment you take that demand seriously, the point of using AI disappears. Trying to drive the debt to zero fails. The target isn't zero; it's an appropriate level.

What is an appropriate level? It's a state in which, whenever asked, you can explain to a certain depth. You don't need to have every function memorized. But you should be able to say why the system looks the way it does, where the danger lies, and what observation would mean the design has failed. When your understanding drops below that line, it's time to pay down the debt.

The question is how. I use or propose three approaches.

---

## First, the Pop Quiz

There are moments when a design or an implementation is finished and I have the nagging feeling that I don't really know what I just built. That moment is the moment to pay down the debt. When it hits, I ask the agent to give me a pop quiz. This isn't idea-level talk — I've actually built it as a Skill and use it.

There's one core principle: the answers must always come out of my mouth. It's convenient when the agent explains. It's also useless, because hearing an explanation makes you think you understood. The debt remains intact under the illusion. So this quiz is an interview, not a grading exercise. The agent asks a single open-ended question: "Why this approach rather than alternative X?" "What goes wrong if this part isn't there?" It listens to my answer, picks the point where a gap surfaced, and asks a follow-up. The next question isn't decided in advance. My previous answer determines it. Only when the same gap survives two follow-up questions does an explanation finally come.

It doesn't tell me what I left out right away, either. It demands recall: "There's another step — what's missing?" It's uncomfortable. Uncomfortable is normal. Paying down debt has never been comfortable.

## Second, the Literate Code Diff

In 1984, Knuth proposed literate programming with this framing: let us change our traditional attitude to the construction of programs, so that the main task is to explain to human beings what we want the computer to do, rather than to instruct the computer.[^7] Applying that perspective to the diff gives us the literate code diff.

A typical code review screen is a list of changed files. The file order is alphabetical and unrelated to the logical order of the change. The reviewer has to reassemble fragmented changes in their head. Faced with a large change made by an agent, that reassembly is frequently abandoned. And then the approve button gets pressed.

The literate code diff inverts the order. It arranges the changes in conceptual order and attaches an explanation to each step. "First I changed the repository interface, because… Then I fixed the call sites, because…" The reader follows the change as a single story. I also think it's worth maintaining these documents like release notes: one literate diff document per PR, with an index in the README to keep them accessible. The history of the codebase then survives not as "who changed what and when" but as "why it came to be this way."

## Third, Narrative Documents

Most documents AI produces are enumerations. A document of neatly aligned bullet points can be taken in at a glance. That's both its virtue and its trap. Because it can be taken in at a glance, it's easy to mistake skimming for reading, and the places where logic is missing don't stand out. It's also quickly forgotten.

Amazon ran this experiment company-wide. In a 2004 executive meeting, Bezos banned PowerPoint and introduced narrative memos. The reasoning is precise: good narrative memos are hard to write because the narrative structure forces better thought about what is more important and how things are connected.[^8] The same applies to the reader. Narrative takes longer to read than enumeration. In exchange, because you read it as a story, the places where the logic breaks become visible, and what you read sticks longer.

Let's compare using an ADR (Architecture Decision Record). An enumerated ADR looks like this:

```markdown
## Decision: Migrate session store to Redis
- Situation: DB session table bottleneck
- Alternatives: Memcached, DynamoDB, Redis
- Choice: Redis
- Rationale: TTL support, existing operational experience
```

Clean. And impossible to verify in any respect. How severe was the bottleneck, why was Memcached eliminated, was "existing operational experience" an important enough condition to justify the decision — this document says none of it. Written as a narrative, the same decision reads like this:

> Last quarter traffic doubled, and lock contention on the session table became the primary cause of response latency. During peak hours, 60% of p99 latency came from session lookups. We needed a cache layer. Memcached was ruled out because a restart wipes all sessions and could trigger a login stampede. DynamoDB met the latency requirement, but its TTL granularity is at the minute level, which doesn't fit our session expiration policy. Redis satisfied both requirements, and since the team has operational experience with it, the incident-response risk is low. That said, it's a single-node configuration, so a Redis failure makes all logins impossible. That is this design's failure condition.

It takes about three times as long to read. In exchange, someone who reads this can ask questions. "Where does the 60%-of-p99 number come from?" "Doesn't Memcached have a persistence option?" These are questions that never surfaced in front of the enumerated document. Only when the logic runs through sentences do the holes in the logic become visible. A document that pays down cognitive debt is not one that reads fast but one you can read critically.

---

## Conclusion

Cognitive debt is not a bug of vibe coding; it's a cost. If you bought speed, you have to pay for it. There is no way to avoid paying. There are only ways to go through the motions of paying, like human-in-the-loop, and going through the motions is generally worse than not paying at all.

Handle it the way you handle technical debt. Don't try to pay it all off. You can't. Instead, keep checking whether the interest is at a manageable level. If you can't explain what you just approved, the interest has exceeded your limit. That's when you take the pop quiz, reread the diff as a story, and rewrite the documents as narrative.

Understanding does not accumulate automatically. Only code does.

---

[^1]: Ward Cunningham, The WyCash Portfolio Management System (OOPSLA '92 Experience Report): https://c2.com/doc/oopsla92.html
[^2]: Nataliya Kosmyna et al., Your Brain on ChatGPT: Accumulation of Cognitive Debt when Using an AI Assistant for Essay Writing Task (MIT Media Lab, 2025): https://arxiv.org/abs/2506.08872 — note that rebuttal commentary on the sample size and EEG analysis methodology has also been published, so it is premature to take the conclusions as settled.
[^3]: GitClear, AI Copilot Code Quality: 2025 Data Suggests 4x Growth in Code Clones (2025): https://www.gitclear.com/ai_assistant_code_quality_2025_research
[^4]: Lisanne Bainbridge, Ironies of Automation (Automatica, 1983): https://en.wikipedia.org/wiki/Ironies_of_Automation
[^5]: Raja Parasuraman & Dietrich H. Manzey, Complacency and Bias in Human Use of Automation: An Attentional Integration (Human Factors, 2010): https://journals.sagepub.com/doi/10.1177/0018720810376055
[^6]: METR, Measuring the Impact of Early-2025 AI on Experienced Open-Source Developer Productivity (2025): https://metr.org/blog/2025-07-10-early-2025-ai-experienced-os-dev-study/
[^7]: Donald E. Knuth, Literate Programming (The Computer Journal, 1984): https://www-cs-faculty.stanford.edu/~knuth/lp.html
[^8]: Jeff Bezos, 2017 Letter to Shareholders (Amazon, 2018): https://www.aboutamazon.com/news/company-news/2017-letter-to-shareholders
