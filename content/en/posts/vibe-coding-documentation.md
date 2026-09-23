---
title: "Documentation in the Vibe Coding Era: What to Keep and How to Make It Accessible"
date: 2026-09-10T10:00:00+09:00
draft: false
toc: false
images:
tags:
  - vibe-coding
  - documentation
  - context-engineering
---

> The purpose of documentation is communication. Vibe coding brings more participants into that conversation.

{{< figure src="/posts/images/Dohyun.png" title="Dohyun Jung - Principal Consultant, ROBOCO" style=".author-image">}}

---

## TL;DR

- The same documentation principles apply to vibe coding. Let agents handle writing and organization to gain the benefits of good practices with less effort.
- Distinguish documents that must stay current from one-off documents whose job ends when their purpose is fulfilled. Not every document needs updating.
- Split documentation into short Markdown files and connect them through folder indexes, rules, and skills. Make them discoverable when the work calls for them.
- Use lists for frequent, quick reference. Use narrative prose when readers need context and careful review.
- Documents let people and agents share intent and decision criteria with one another. People should focus on defining the purpose and judging the results.

---

As I have said several times, the principles of software development still apply to vibe coding. Define the problem and design a solution. Implement and verify it. Review the outcome and improve it. These steps are necessary whether a person or an agent performs them. What changes is who does the work and what it costs.

I made the same point in [“Vibe Coding: Truth or Myth”](/en/posts/vibe-coding-truth/). Practices such as testing, design, and CI/CD remain relevant. In [“Vibe Coding or Engineering Maturity: Which Comes First?”](/en/posts/vibe-coding-vs-engineering-maturity/), I took the argument further. Agents can use an established development process, but they can also help establish it.

Documentation follows the same principle. The benefits of good documentation have not changed. The human effort needed to obtain them has fallen substantially. Agents can extract usage instructions from code, reflect changes, and classify documents. We can build useful documentation with much less time and effort than when people wrote every part themselves.

Two questions should come first in document management. How long will this document remain valid? Who will read it, and for what purpose?

## 1. Documents Give Agents a Starting Point for the Next Task

Documentation matters when people develop software, too. Code alone rarely explains why a particular choice was made. A deadline may have ruled out an alternative. A customer may have agreed to an exception. The implementation shows current behavior. Documentation explains why that behavior was chosen and which conditions must be preserved.

This role becomes more important in vibe coding. People remember at least some of their previous meetings and work. An agent starting a new session is not guaranteed to inherit every previous conversation. Important conditions can disappear when a long conversation is summarized. Handing work to another agent can require the same explanation again.

Suppose the team decided not to retry failed payment requests automatically. It must first check the external payment provider's processing status to avoid duplicate charges. If that context exists only in a conversation, the next agent may propose adding retries as an improvement. Looking only at the code, it may seem that recovery functionality is missing.

Recording the constraint and its reason changes the starting point for the next task. The agent need not repeat the same discussion. A human reviewer can also judge whether the implementation respects the agreed conditions.

The same applies when several agents divide the work. If they operate on different assumptions, each implementation can appear correct while the whole system fails to fit together. Shared API contracts and completion criteria reduce that gap. Documents guide collaboration between people and AI, and between agents themselves.

## 2. Not Every Document Needs Continuous Updates

Development documents fall into two broad categories when viewed through their lifecycle. Some need ongoing maintenance because they describe the current standard. Others are one-off documents that finish their job once communication for a particular moment is complete.

Installation guides, API specifications, descriptions of the current architecture, and operating procedures belong to the first category. Readers treat them as instructions they can apply now. If the execution command changes, the installation guide must change. If incident response procedures change, the operations documentation must follow. It helps to include documentation updates in the completion criteria for related code changes.

Investigation notes for a specific bug, a plan for a single deployment, a review request explanation, and a handoff to the next session belong to the second category. They can be refined while the task is underway. But there is no reason to keep rewriting them to match the present after the task ends. Once they have communicated the situation at that moment, they have fulfilled their purpose.

One-off does not mean “delete immediately.” Meeting notes and decision records can help explain past judgments. They should preserve their historical context. When a decision changes, link the old record to the new decision instead of overwriting it with today's conclusion. Preserving a record and keeping its content current are different jobs.

Without this distinction, every document becomes a maintenance obligation. A single feature change leads to revisions of old plans and investigation notes. People spend time; agents spend tokens. Eventually, writing more documentation appears to create more work. People then avoid producing documents even when an explanation is needed.

State a document's purpose and scope of validity when you create it. Make clear whether it defines the current standard or records a particular task. Give one-off documents a date, a target task, and a completion status. Once the task is finished, remove them from the active work index and link to their archive location. Prevent the next agent from reading an old plan as a current instruction.

A one-off document can also produce lasting knowledge. Add a constraint discovered during a bug investigation to the operating guide. Move rules agreed during review into the development guidelines. Promote the useful knowledge into the current standard and preserve the investigation notes as a record. This makes it easier to create documents whenever communication calls for them.

## 3. Documents Must Be Discoverable During the Work

Saving a document does not mean an agent will automatically use it. Connect tasks to the documents they require. In [“A Token Management Strategy for Vibe Coding”]({{< relref "vibe-coding-token-management-strategy.md" >}}), I emphasized a structure that lets agents select what they need to read. Anthropic also describes keeping lightweight references, such as file paths, and loading their contents when needed.[^1]

Markdown is a good default for development documents that agents consult. Headings, paragraphs, and links make the structure visible. Searching and editing individual sections is straightforward. Keeping the documents in the code repository also lets you manage their revision history together.

Keep each document under 300 lines where practical. This is a working guideline, not a technical limit shared by every tool. Equal line counts do not imply equal token counts. Packing sentences onto one line to meet the number achieves nothing. The point is to give each document a single topic and split it by subject when it grows. Do not break the reasoning needed for review merely to satisfy the limit.

Organize folders by purpose, too. For example, put current guides in `docs/guides/`, active task documents in `docs/tasks/`, and completed task records in `docs/archive/`. Give each folder a `README.md` with a brief explanation and links to key documents. A person opening the folder should know where to begin reading.

Agents need an entry point as well. Put common rules and document paths in `AGENTS.md` or `CLAUDE.md`, depending on the tools you use. Explain when to read each document instead of simply listing links. For payment changes, for example, require the agent to check the payment contract and duplicate-processing policy first. If you use both files, establish a single authority for shared rules so their contents do not drift apart.

Connect recurring work through skills. A deployment skill can read the operating procedures and deployment checklist. An API change skill can check the contract and update the specification after the change. Documentation then becomes part of the actual sequence of work.

Once the reference collection grows beyond hundreds of documents, following indexes alone may become burdensome. Introducing an LLM Wiki is one option. Karpathy's LLM Wiki approach has an LLM build and maintain an interconnected Markdown wiki alongside the original sources.[^2] Applied to a project, it can organize concepts and relationships scattered across documents. Preserve source links so readers can return from summaries to the originals. The criterion for adoption is the burden of repeatedly finding and combining the same context, rather than the document count alone.

People do not need to organize this structure by hand, one file at a time. Ask an agent to classify existing documents by purpose, split long files, and create an index in each folder. Include future updates in the working rules. People can decide what should serve as the current standard and check the result. Reduce the repetitive work of organization while ensuring that incorrect information does not become the accepted baseline.

## 4. Use Lists for Documents You Consult Frequently

After deciding how to store and connect documents, decide how to convey their content. The two broad forms are lists and narrative prose. Markdown supports both. A document's lifecycle and its writing form are separate choices.

Without specific instructions, agents often make extensive use of lists and tables. Lists make it easy to scan the whole document quickly. They also help readers locate an item and check for omissions.

Deployment checklists, command references, environment variable descriptions, and API field specifications are good examples. Readers open these documents frequently to check a particular detail. Immediately before a deployment, they need the execution sequence and success criteria. They need not reread a long background explanation every time they follow an agreed procedure.

Lists alone can be insufficient when readers must assess the reasons behind a decision. Suppose a design proposal lists better performance, lower costs, and scalability. It is easy to scan. But it does not say what is slow or by how much. It does not explain which costs will fall. Nor does it show what must be sacrificed to gain scalability.

Readers can see plausible items and feel they understand the proposal. Yet the context needed for a real decision remains in the author's head. Once review starts, each item requires further explanation. Repeatedly reading the same document will not reveal omitted evidence.

When the relationships between items remain hidden, the reasoning can also be hard to recall later. Readers may remember what was decided but forget why. Lists are strong at quick reference. For deeper review, they need sentences that explain the background and reasoning.

## 5. Use Narrative Prose for Documents That Need Careful Review

Narrative prose connects the problem and its conditions, the alternatives, and the conclusion through sentences. Readers organize their own thoughts as they follow that progression. Authors must fill in missing explanations before moving to the conclusion.

I compared the two forms in [“Cognitive Debt - Managing a New Kind of Debt in the Vibe Coding Era”]({{< relref "cognitive-debt.md" >}}). The same decision to move session storage to Redis appeared as both a list-based and a narrative ADR. The list version briefly stated the choice and its reasons. The narrative version connected the bottleneck's background, the reasons for rejecting alternatives, and the conditions under which the chosen design would fail. That difference let readers question the reasoning behind the decision. See the “Third, Narrative Documents” section of that article for the concrete comparison.

Amazon is well known for favoring this form. In his 2024 shareholder letter, Andy Jassy described using narrative documents with a main body of up to six pages. They require more effort from the author, but make it easier for readers to understand the substantive issues and ask useful questions.[^3]

The difference becomes clear when the earlier proposal is developed into prose. Consider a hypothetical order system. When an order arrives, it waits for an external service to respond. If that service slows down, order acceptance is delayed too. The team therefore wants to separate acceptance from subsequent processing. But this introduces a delay before completion. Users need to see the processing status. Duplicate requests also need separate handling.

Now reviewers know what to examine. They can judge whether users will accept the delay. They can ask whether improving the external service call alone would suffice. They can weigh the added operational complexity. Connected sentences expose the assumptions and causal relationships that need review.

Narrative documents can take longer to read. But communication cost cannot be measured by character count alone. The time spent organizing a meeting and asking the author to explain a short list also counts. Putting the necessary context into the document lets readers develop their judgment in a single reading.

Following these connections between cause and effect can also help readers recall the reasons for a decision later. That does not mean narrative prose always produces better retention. Meaningful connections help memory; length alone does not. A document that repeats the same point at length gains little from the narrative form.

Writing this way used to be a burden for people. Agents reduce that burden substantially. Give the agent the same material and ask it to connect the background, alternatives, and reasons for the choice. The effort of giving that instruction is little different from requesting a list. Longer output can still take more generation time and tokens. You must also check that plausible sentences have not filled gaps where evidence is missing.

I recommend this form for architecture proposals, technology adoption assessments, explanations of product requirements, and incident analyses. When a document requires stakeholder judgment and agreement, make narrative prose the default. Connect the problem, constraints, alternatives considered, reasons for the decision, and unresolved questions. A short summary or comparison table can support the text.

A TL;DR is useful for both lists and narratives. In a list-based document, it highlights the key items and reduces the time needed to find information. In a narrative, it previews the problem and conclusion so readers can follow the argument more easily. Readers can use the summary to decide whether they need to read the document now. It also helps them recall the main points of something they have already read.

Adding a list-based summary to a narrative document does not undermine its purpose. The summary gives readers a starting point. The body supplies the context and evidence needed for judgment. The TL;DR at the beginning of this article serves that same role. When the purpose is review, however, reading only the summary is not enough. Use it to orient yourself, then examine the assumptions and evidence in the body.

Both forms can support the same deployment task. Write a proposal to change the deployment strategy in narrative form. Write the checklist for executing the agreed strategy as a list. Keep the proposal as a record of the judgment made at the time. Update the checklist to reflect the current procedure. Once you decide separately on the document's lifecycle and its reading purpose, its management becomes much clearer.

---

## Conclusion

The importance of documentation in development is not a new idea. Vibe coding makes it even more important. At the start, people define the purpose, constraints, and completion criteria. At the end, they read the results and verification evidence to judge whether the intended outcome was achieved. Documents sit at the center of both the first and the last stages led by people.

I expect agents to take on more of the execution: implementation, testing, deployment, and routine maintenance. Eventually, execution beyond defining intent and judging results through documents will move into the agents' domain. Human responsibility does not disappear with it. People still decide what to build and which results to accept.

Do not try to maintain every document forever. Actively create one-off documents when communication calls for them. Move knowledge that will remain useful into the current standard. Use lists for frequent reference and prose for careful review. Connect the documents so readers can find them at the right moment.

Ultimately, documentation is about communication. Software development requires people to reach a shared understanding. That now includes people working with AI and agents working with one another. The more implementation we delegate, the more important it becomes to ensure that everyone is working toward the same intent.

---

[^1]: Anthropic, [Effective context engineering for AI agents](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents).
[^2]: Andrej Karpathy, [LLM Wiki](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f).
[^3]: Amazon, [Andy Jassy’s 2024 Letter to Shareholders](https://www.aboutamazon.com/news/company-news/amazon-ceo-andy-jassy-2024-letter-to-shareholders), “Narratives” section.
