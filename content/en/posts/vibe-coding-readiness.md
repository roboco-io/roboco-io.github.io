---
title: "Vibe Coding: What Should Change After You Give the Team AI Tools?"
date: 2026-11-03T10:00:00+09:00
draft: false
toc: false
images:
tags:
  - vibe-coding
  - ai-readiness
  - engineering-maturity
---

> Can you verify AI-generated work and apply what you learn to the next task?

{{< figure src="/posts/images/Dohyun.png" title="Dohyun Jung - Principal Consultant, ROBOCO" style=".author-image" >}}

---

## TL;DR

- More AI use can fall short of expectations if review and rework costs rise. Assess both individual judgment and the organization's ability to verify results.
- Readiness becomes visible in real work. Define the goal, failure cases, and verification method for one small task, then examine implementation, review, and corrections.
- Postmortem lessons create value when they inform the next task. Automate evidence collection and action tracking, and incorporate reviewed findings into documentation, tests, and work instructions.

---

In my earlier article on [organizational design for adopting vibe coding]({{< ref "organizational-design-for-vibe-coding.md" >}}), I discussed shared support and accountability. In the article on [hiring in the AI-native era]({{< ref "ai-era-hiring-strategy.md" >}}), I focused on people's ability to structure problems and verify results. Connecting the two raises a question: after hiring capable people and providing tools, what else should an organization do?

This article starts with a Korean study examining organizational and individual readiness alongside generative AI use. I connect it with research on developers to outline what individuals should do, what organizations should support, and how work experience can become organizational learning. Here, vibe coding broadly refers to development using natural-language instructions and AI-generated code.

## 1. Examine Individual and Organizational Readiness Separately

Young Min Park's study analyzed survey responses from 194 municipal government employees in South Korea. It reported positive associations between both organizational and individual readiness and current use and intention for future use. Organizational readiness included strategy, technical foundations, rules, and support; individual readiness included understanding, attitudes toward applying the technology, knowledge, and willingness to learn. As a self-report survey, it does not establish a causal effect on developer productivity.[^1]

Li and colleagues also examined adoption factors among software practitioners through 26 interviews and a survey of 395 respondents. These factors included insufficient training, unclear usage guidelines, and a culture of sharing experience.[^2] Applied to work, the two studies suggest a useful question: when use is low, have we examined individual learning needs and organizational support problems separately?

If a developer cannot explain what to build, they may need practice breaking down the problem. If necessary documentation is unavailable or there is no test environment for checking results, the organization needs to provide those conditions. Training completion and account provisioning alone do not reveal which problems remain.

Experience cannot stand in for readiness either. Field experiments involving 4,867 developers at three companies reported an increase in completed tasks and larger gains among less experienced developers.[^3] In contrast, METR's 2025 experiment found that 16 experienced developers working in familiar repositories took an average of 19% longer to complete tasks when AI was allowed. The studies involved different tasks and tools, and METR also described selection bias and time-measurement problems in its 2026 follow-up.[^4] Neither result can predict our team's performance for us. We need to examine the benefits and additional costs in actual work.

## 2. Assess Readiness Through One Task

Consider a hypothetical starting point: building a small feature with AI to import customer data from a CSV file. Before implementation, define how to handle empty files, incorrect column names, and duplicate records. Also identify the sample data, test environment, and person accountable for the result.

| What to check | What the individual should do | What the organization should provide |
|---|---|---|
| Goal and scope | Explain the required behavior and constraints that must remain intact. | Business rules and reference materials. |
| Verification | Compare the code with execution results and check failure cases. | A test environment and review criteria. |
| Getting unstuck | Report the causes of repeated corrections and what remains unverified. | A contact for questions and time for learning and review. |

Even if AI-generated tests pass, compare the results with the original requirements. Code and tests can share the same misunderstanding. In this example, code and tests may agree on skipping duplicate records, while the business rule actually requires updating existing records. That would still be the wrong feature.

After the task, examine review and rework time and remaining defects alongside implementation time. If code was produced quickly but took longer to correct, that cost needs to be visible. When using several agents concurrently, distinguish elapsed time from time spent by people. Compare similar tasks and record the tools, models, and excluded tasks so you can interpret the change.

Use these records to decide what to do next rather than to rank people. If requirements were missed, practice explaining and checking them; if shared rules were hard to find, improve the documentation. Assess readiness for each task. For work with high failure impact or results that are difficult to verify, reduce the scope or establish verification conditions first.

## 3. Make Postmortems Change the Next Task

If the CSV feature missed the duplicate-handling rule, writing “be more careful next time” in a retrospective is insufficient. The team can add the rule to shared documentation, add a regression test for the case, and include it in the next task's checklist. Other teams should be able to find the case when starting similar work.

A postmortem, a retrospective that records experience and analysis after work, can be run as a process that produces these changes. Google SRE also emphasizes examining system conditions rather than assigning personal blame, sharing reviewed findings, and tracking follow-up actions. It describes automating postmortem creation and data extraction to analyze recurring problems.[^5]

The following workflow is a practical proposal for extending incident-retrospective principles to everyday development.

1. **Create a retrospective draft when a task finishes.** Collect the goal, changes, test results, and review findings. Summarize differences between expected and actual outcomes, what went well, and rework, with links to evidence. Keep small-task retrospectives brief and analyze recurring errors or substantial rework more deeply.
2. **Get reviewed lessons to the teams that need them.** A responsible person separates facts from causal hypotheses. Classify retrospectives for search and surface relevant cases when similar work begins. Preserve the original access permissions in summaries and search results.
3. **Turn lessons into improvement actions.** Attach an owner, target date, and completion criteria to proposed changes to documentation, tests, and work instructions. AI can help draft proposals and classify similar cases. For shared-rule changes, check the scope and conflicts with existing rules. Changes with established validation conditions can be applied automatically, while exceptions can go to a responsible person.
4. **Check the effect in the next task.** Automation can collect unfinished actions and recurring errors and flag items for reassessment. Even after an issue closes, check whether similar work required the same corrections. Revise rules that have no effect or create additional burden.

The roles in the earlier [organizational design article]({{< ref "organizational-design-for-vibe-coding.md" >}}) fit this process. Team champions organize local experience, while the central platform team maintains shared documentation and verification tools. Product teams check the results in their own services. In a small organization, one person may hold several roles. What matters is clarity about who will change what after the retrospective.

---

## Conclusion

A team adopting vibe coding should first check the conditions needed to complete one small task. Can individuals explain the goal and verify the result? Does the organization provide the necessary information and verification environment?

Then make the experience useful to the next person. Connect problems identified in postmortems to changes in documentation, tests, and work instructions, and check their effect in the next task. Repeating this process helps a team decide what training and support it needs and where to expand AI use.

---

[^1]: Young Min Park (2026), The Multilevel Effects of Organizational and Individual Readiness on the Utilization of Generative AI and the Intention for Future Use: Focusing on Korean Municipalities. [KCI article information](https://www.kci.go.kr/kciportal/landing/article.kci?arti_id=ART003319925). The relative coefficients in the text and Table 10 require clarification, so this article does not rank organizational and individual readiness by importance.
[^2]: Li et al. (2024), AI Tool Use and Adoption in Software Development by Individuals and Organizations: A Grounded Theory Study. Preprint. https://arxiv.org/abs/2406.17325
[^3]: Cui et al. (2026), The Effects of Generative AI on High-Skilled Work: Evidence from Three Field Experiments with Software Developers. https://doi.org/10.1287/mnsc.2025.00535
[^4]: Becker et al. (2025), Measuring the Impact of Early-2025 AI on Experienced Open-Source Developer Productivity. https://arxiv.org/abs/2507.09089 ; METR (2026-02-24), We are Changing our Developer Productivity Experiment Design. https://metr.org/blog/2026-02-24-uplift-update/
[^5]: Google SRE, Postmortem Culture: Learning from Failure. https://sre.google/sre-book/postmortem-culture/
