---
title: "How to Hire People with Practical Judgment in the AI-Native Era"
date: 2026-10-03T10:00:00+09:00
draft: false
toc: false
images:
tags:
  - ai
  - hiring
  - software-engineering
  - ai-agents
---

> Practical work judgment means turning an ambiguous task into executable work and taking responsibility for the outcome.

{{< figure src="/posts/images/Dohyun.png" title="Dohyun Jung - Principal Consultant, ROBOCO" style=".author-image">}}

---

Recently, a colleague and I discussed what accounts for differences in productivity after adopting vibe coding. Why do people produce different results with the same AI tools? As we worked through the factors, we concluded that a familiar Korean word captured the difference: **ilmeori**, the practical judgment that helps someone get work done.

But when we tried to define it, we noticed something interesting. Understanding the purpose and context of work, structuring an ambiguous problem, setting priorities, executing, checking the results, and improving them: the definition matched exactly what developers have been doing as they build software.

How, then, can we recognize people with this ability? Years of development experience alone cannot tell us whether someone has it. Today, I want to discuss **how to hire people with practical judgment, regardless of years of experience**.

The starting point is to distinguish the qualities the whole company needs from the practical skills a team needs. Assess company-wide qualities through interviews, and assess the team's practical needs through tailored assignments that use AI. AI is changing both how candidates work and how much it costs companies to create those assignments.

## TL;DR

- Translate practical judgment into observable behaviors: understanding purpose, structuring work, deciding, executing, verifying, and adapting.
- As AI lowers the cost of creating tailored hiring assignments, design tasks that closely resemble the actual work of the team and role.
- Assess company-wide qualities through interviews and practical skills through AI-based assignments, then use interviews about the submissions to examine the reasoning behind candidates' decisions.
- For roles that expect AI use at work, require it in assignments and practical interview exercises. Have candidates work in a company-provided sandbox and preserve logs and commit history.
- Design assessment dimensions, weights, and hiring thresholds for the company and role. Examine actual decisions and results rather than relying on years of experience.

## 1. Name the capability you want to hire

I define ilmeori as follows:

**The ability to quickly understand a task's purpose and context, independently structure the work, and deliver results using appropriate priorities and methods.**

It should also include checking results and revising the plan. A plausible initial plan must change when it does not fit reality.

Suppose someone asks you to investigate rising customer complaints. Practical judgment shows up in how you determine whether complaints really increased, whether order growth explains the change, and whether complaints cluster around a particular product or period. You then choose the first hypothesis to investigate, take action, and check the result. The length of the report tells you little about this process.

AI can draft the report. Deciding which data matters, what problem needs solving, and what evidence justifies action still requires judgment. Hiring should make that judgment observable.

## 2. We have long expected this of good engineers

This definition resembles a familiar software engineering workflow: understand why a requirement exists, clarify ambiguity, decompose the problem, weigh technical trade-offs, implement a solution, and improve it based on operational results.

Engineers also develop a habit of anticipating failure. What if the input is wrong? What if an external service does not respond? How will we detect an incorrect result? Can we roll back when something goes wrong?

These questions are useful beyond software. When planning training, ask what happens if participants' skills differ from expectations. When designing customer support, ask who takes over when the responsible person is absent. In market research, look for contrary evidence that could change the conclusion.

That creates an opportunity. If AI assists with parts of research, documentation, and analysis, engineers may apply their problem-solving abilities to adjacent work. The hypothesis is that software engineering experience can serve as training in broader problem solving.

A developer title does not guarantee this ability, however. People in other professions have it too. Hiring should examine actual behavior rather than an image associated with a profession.

## 3. Examine roles and the cost of failure

Discussions of AI and software often focus on non-developers building services. The reverse direction deserves attention too: developers using AI to prepare customer interview questions, analyze data, or design technical training.

“Replacing another profession” is too broad a description. Drafting market research differs from taking responsibility for an investment decision. Writing technical documentation differs from granting final approval in a security audit.

Evaluate role expansion against three considerations: **how well existing skills transfer, whether the person has the domain knowledge to verify results, and the cost of failure.**

An internal draft can begin as a small experiment. Decisions that commit money or make promises to customers require deeper expertise and review. Moving developers into another field does not always reduce risk.

Job descriptions should therefore specify the outcomes and expertise required. “Someone who can identify a customer problem, implement a small solution, measure its effect, and improve it” makes the behaviors to assess clearer than “a developer who is good at AI.”

## 4. Separate company-wide qualities from the team's practical needs

Another change that interests me is the substantial reduction in the cost of creating tailored hiring assignments. Turning a team's work into an assignment requires describing the situation, creating sample data, and preparing a starter project and a way to verify the results. AI agents can now help with that preparation too.

For example, the team can describe its product's purpose and the new hire's responsibilities to AI, then work with it to draft a scenario, sample documents, test tools, and assessment criteria. The person responsible reviews whether the draft reflects the actual work and attempts the assignment to adjust its difficulty and expected duration. This reduces the effort required to incorporate each team's particular problems into hiring assignments.

We can then separate two questions in hiring.

| What to assess | Primary assessment method | What to examine |
|---|---|---|
| Qualities needed across the company | A common interview | How the candidate has practiced principles the company values, such as collaboration, responsibility, and attitudes toward customers |
| Practical skills needed by the team | An AI-based assignment tailored to the team and role | Whether the candidate can understand the problem they will own and work with AI to design, implement, and verify a solution |

The common interview should go beyond asking whether someone agrees with abstract values. Ask specifically how they resolved a disagreement, when and to whom they reported a mistake, or how they changed their behavior after feedback. Translate the company's principles into observable behaviors.

The team assesses practical skills through a smaller version of the work the person will do after joining. A team building customer products and a team automating internal operations can create different assignments, even when both are hiring developers. Tailor assignments to the team and role, and apply common expectations and assessment conditions to candidates for the same position.

Consider the two assessments together while keeping their supporting evidence distinct. Explain the team's assessment using the assignment and work records, and explain the company-wide assessment using examples explored in the interview. A follow-up interview about the submission provides a deeper examination of the decisions observed in the assignment.

## 5. Design and submit the project with an AI agent

I have previously used a smaller version of an actual work project as a hiring assignment. Candidates worked on it with a coding agent and kept commit histories and retrospectives that included their prompts. Alongside the final deliverable, we used the process that produced it as assessment material.

Building on that experience, I propose connecting the team's practical assessment in two stages: **candidates design and submit their project with an AI agent, then interview about the submitted project.** Prepare interview questions for company-wide qualities as well.

When hiring people who will use AI at work, require AI use in the practical work of both stages. The assessment examines what they delegate to AI, which decisions they make themselves, and how they verify the results.

For developer hiring, consider an assignment to build a workplace agent system:

> Design an agent system that takes employees' work requests, searches internal documents, and answers with supporting evidence. For requests that require action, it should prepare a plan and call workplace tools after obtaining the necessary approval. Choose a core workflow you can verify within the allotted time, and submit the design and implementation results.

The company supplies sample documents, fictional work data, and test versions of workplace tools. Candidates work with an AI agent to interpret requirements, design the system, implement it, and verify it. The coding agent used to perform the assignment is distinct from the workplace agent system being developed.

Candidates do not need to build every feature from the start. They first need to clarify whose work they are helping with, what should happen when the documents contain no answer, and what approval is needed before executing a tool. They must also choose whether to focus on document search and answers or on completing one small workflow from beginning to end.

The company states in advance the requirements it must assess for the role and the expected submission scope. Candidates choose priorities and methods within those boundaries. For an implementation-focused role, an executable core workflow and tests may carry more weight. For a design-focused role, architecture, reasons for choices, and verification methods may matter more. Provide assignment background and consistent conditions for answering questions to candidates in the same hiring process.

Submissions include the design and code, the assumptions made, what has been implemented, and what remains. Prompts and retrospectives help explain those choices. Asking candidates to perform activities similar to the job connects to work sample assessment. The U.S. Office of Personnel Management (OPM) describes this method and recommends using it for competencies candidates are expected to possess when entering the role.[^1]

Distinguish the submission window from the expected working time. Giving everyone a week to submit does not mean everyone has the same amount of time to spend on the assignment. State the expected working time, minimum submission scope, and whether additional implementation affects the assessment. Consider compensation for the assignment where appropriate.

## 6. Preserve work records in the company's sandbox

Assessing the process also means addressing how much we can trust its records. A retrospective prepared just before submission may not accurately reflect decisions made at the time. Prompts and explanations can also be rewritten with AI.

The approach I consider best is to **have candidates work in a company-provided sandbox and preserve the generated logs and commit history so they cannot alter them afterward.** The company provides the environment, AI tools and accounts, and usage costs; candidates carry out the assignment there.

Separate permissions for the workspace and the record archive. Candidates can freely edit code and design documents and create new commits. They cannot modify or delete logs and commit records already collected. Apply the same restrictions to the AI agents used for the work. Corrections to earlier decisions become new records.

For example, the setup could work as follows.

| Record | Collection and preservation | What to examine in the interview |
|---|---|---|
| Requests to AI, responses, and tool calls | Store outside the workspace through a company-managed collection path | What context did the candidate provide, and how did they handle the results? |
| Commits and the corresponding file states | Automatically send to the company's remote repository and separately archive the received history | In what sequence did the design and code change? |
| Execution and test results | Collect logs in the company's execution environment and link them to code versions | Did the candidate actually verify the behavior they said they checked? |
| Retrospectives and final submissions | Freeze the submitted version and record later explanations separately | Does the explanation match the work at the time? |

Separate administrative privileges so candidates and their working agents cannot stop collection or change retention settings. Block force pushes and branch deletion in the remote repository, and do not give candidates permission to bypass protection rules. GitHub's protected branches provide these kinds of restrictions.[^2]

Remote branch protection alone does not preserve all work history inside the sandbox. A candidate could rewrite local history before its first transmission. Collect work logs and code states continuously and retain them with company-side receipt timestamps. Storage that prevents overwriting or deletion during a retention period can protect collected records. S3 Object Lock, for example, provides this protection for specified object versions.[^3]

Explain what will be collected and how long it will be retained before the assignment begins. Limit collection to the assignment environment and give candidates an opportunity to learn the tools. Treat gaps in the records as unverified periods to clarify during the interview.

This setup provides confidence that collected records are difficult to change afterward. Their volume or preservation does not itself demonstrate a candidate's judgment. Follow with **an interview that cross-checks explanations, work records, actual deliverables, and execution results**.

## 7. Interview around the submitted project

The practical follow-up interview starts with the candidate's submitted project. Interviewers review the design, commits, AI usage records, and test results beforehand and choose decision points to explore. Go beyond having candidates present what they built: ask why they made their choices and whether those choices produced the results they describe.

For a workplace agent system, questions might include:

- AI suggested calling a workplace tool directly, but you added an approval step in the final implementation. What problem did you anticipate?
- Your retrospective says you changed the system to withhold an answer when the documents provide no evidence. Which commit and test demonstrate that change?
- You revised the prompt after a test failed. Why did you conclude the prompt was responsible, and how did you investigate possible code or data issues?
- What remains unverified in your submission, and what would you check first before using it for real work?

These questions connect explanations to records. Even when AI helped write a retrospective, interviewers can check whether it accurately describes the work and whether the candidate understands the reasons for the choices.

If useful, introduce a small change request to the submitted project:

> A workplace tool processed a request but failed to return a response. Change the design so the work is not performed twice if the agent retries the same request.

Using the existing project, the candidate works with an AI agent to assess the impact, choose an approach, and make and verify changes within the available scope. Interviewers observe which information the candidate checks first, how they judge AI suggestions, and how accurately they explain unresolved issues. Preserve the interview changes separately from the original submission.

Finish by reflecting on initial assumptions, decisions that changed along the way, and reasons for accepting or rejecting AI suggestions. Combining assignment records with behavior during the interview helps reveal whether the candidate can sustain the same problem-solving approach under unfamiliar conditions.

This connects the assignment and interview: **verify the traces of judgment left in the assignment, then observe how that judgment changes under new conditions.**

The same interview can also assess company-wide qualities. Prepare questions about technical choices and questions about experiences with collaboration and responsibility, and record answers under the appropriate assessment dimensions. The company decides how many interview rounds to run, but the purpose of each question should be clear.

## 8. Design criteria for the company and role

Companies cannot all apply this proposal with identical scoring weights. The decisions that matter depend on the work and responsibilities of the hire. **Each company must design assessment dimensions, weights, and hiring thresholds for the role.**

Define the desired company-wide qualities as interview criteria shared across the organization. Have the hiring team design the assignment and criteria for practical skills together. Recruiters and the team should agree in advance on minimum requirements for each assessment and how to reach the final decision. This keeps a single assignment score or interview impression from overshadowing the rest of the evidence.

Even with the same workplace agent assignment, a product engineer might be assessed primarily on narrowing the user problem and completing the core workflow. A platform engineer might be assessed more deeply on reliable tool execution and recovery from failure, while an architect might be assessed on conflicting requirements and the reasoning behind design choices. Start by deciding what the minimum requirements are for each role.

Then specify the behaviors to observe in understanding purpose, structuring work, setting priorities, delegating to AI, verifying, and adapting. For a role where reliable tool execution matters, “recognized the possibility of duplicate processing,” “explained a prevention method,” and “verified the change with a test” can be recorded as different pieces of evidence. Weight them according to the responsibilities of the role.

Use common assessment dimensions and level descriptions for candidates applying for the same role. Align the core assignment, available information, tool conditions, and difficulty of additional changes. Follow-up questions may differ with each submission, but the definition of good judgment should not vary by interviewer. OPM's guidance on structured interviews also emphasizes predetermined questions and common rating scales.[^4] Apply that principle to the shared questions and criteria in interviews about submitted projects.

Assessing candidates regardless of years of experience means not using tenure alone to judge practical ability. Experience can contribute to recognizing problems quickly and making domain judgments. Distinguish expertise required on entry from knowledge that can be learned after joining, and do not confuse familiarity with industry terminology with the ability to solve problems.

Continue using the criteria after hiring. Assign work with clear purposes, provide feedback from domain experts, and examine the problems actually solved and the quality of results. Comparing hiring assessments with later performance helps reveal what the assignment and interview captured and what they missed.

---

## Conclusion

In the AI era, I want to hire people who understand purpose and context, structure problems, decide what to delegate to AI, verify results, and carry the work through to completion. These are capabilities we have long expected of good software engineers.

With AI lowering the cost of tailored assignments, companies can bring the problems their teams actually solve closer to the hiring process. Let candidates design and carry out projects with AI agents, and provide an environment and records that make the process observable. In the follow-up interview, use the submitted project to examine the reasons behind choices and responses to new conditions.

**Assess the qualities needed across the company through interviews, and the practical skills needed by the team through assignments that use AI.** Which decisions deserve the most weight depends on the company and role. What they share is the need to connect a candidate's words, actions, and results.

**Alongside “What have you done, and for how many years?” ask “Given this ambiguous problem, what would you clarify first, and what result could you deliver with AI?”** Hiring strategy in the AI era can begin with that question.

---

[^1]: U.S. Office of Personnel Management (OPM), Work Samples and Simulations: https://www.opm.gov/policy-data-oversight/assessment-and-selection/other-assessment-methods/work-samples-and-simulations/
[^2]: GitHub Docs, About protected branches: https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches
[^3]: AWS, Locking objects with Object Lock: https://docs.aws.amazon.com/AmazonS3/latest/userguide/object-lock.html
[^4]: U.S. Office of Personnel Management (OPM), Structured Interviews: https://www.opm.gov/policy-data-oversight/assessment-and-selection/structured-interviews/
