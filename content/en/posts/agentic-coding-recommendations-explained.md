---
title: "Agentic Coding Recommendations, Explained"
date: 2025-06-17T13:38:18+09:00
draft: true
toc: false
images:
tags:
  - productivity
  - tips
  - agentic-coding
  - vibecoding
---

{{< figure src="/posts/images/Dohyun.png" title="Dohyun Jung - Principal Consultant, ROBOCO" style=".author-image">}}

> This post is based on Armin Ronacher's blog article ["Agentic Coding Recommendations"](https://lucumr.pocoo.org/2025/6/12/agentic-coding/).

## Foreword

A few days ago I came across Armin Ronacher's blog post ["Agentic Coding Recommendations"](https://lucumr.pocoo.org/2025/6/12/agentic-coding/) on the developer community [Geek News](https://news.hada.io/topic?id=21435), and it left quite an impression on me. Armin is best known as the creator of the Flask web framework, and his insights on vibe coding line up closely with the direction Roboco is heading. In this post I want to unpack the core ideas in Armin's article in an accessible way, for people just getting started with vibe coding through tools like Claude Code, Cursor, and Windsurf.

## TL;DR

- Agentic coding is a way of working in which you hand a goal to an AI agent and the developer reviews the results and the overall direction.
- Simple languages, fast tools, clear logs, and conservative dependency management all reduce the agent's mistakes.
- The more code AI writes, the more deliberately developers have to think about simplicity, stability, and the right moment to refactor.

## What Is Agentic Coding?

Agentic coding, as Armin uses the term, is a development approach in which much of the coding work is delegated to an AI agent. An agent here means an autonomous program that takes instructions from a developer and carries out work on its own. In this context it refers to an AI program that assists with coding work the way a person would, handling development tasks such as editing files, running commands, and searching the web the way an agent (a delegate) would.

It goes a step beyond typical AI coding assistants (GitHub Copilot autocompletion, code generation with ChatGPT, and so on): you assign the agent a single task goal, and the agent works out and performs the sequence of steps needed to reach it.

Agentic coding was the leading term for AI-driven development until Andrej Karpathy proposed the term vibe coding, and it is still widely used alongside it. Out of respect for the original author's intent, this article uses agentic coding consistently rather than vibe coding.

Put simply: a human developer gives a natural-language instruction like "fix the bug in project X," and the agent takes it from there, understanding the codebase, modifying the code, and running tests to produce a result. What characterizes the process is that the developer does not intervene at each individual step, but waits until the result comes back.

In this approach, the role of the IDE (integrated development environment) we have relied on shrinks considerably too. In Armin's case, the agent handles most of the coding, so he only does the finishing touches in a text editor (something like Vim). That is the extent to which the agent takes the lead in the coding process under agentic coding.

So why do we need agentic coding? First, because used well, it can dramatically increase development productivity. If an agent takes over the repetitive work that eats up a developer's time (refactoring code, making changes across multiple files, getting up to speed on long documents or codebases), the developer can focus on more creative and more important problems. Armin himself stresses that "integrating agents into the development process yields significant productivity gains." This approach is also a way to bring the latest potential of rapidly advancing AI technology into development work.

Finally, agentic coding is not just about "writing code faster." Ultimately, the goal is to write better-quality code and improve maintainability and stability. Armin notes that AI code output, which was poor just a few months ago, has improved considerably, and says it will keep advancing. So if you make good use of tools like Claude Code, which we'll look at later in this article, even a beginning developer can gradually grow into "a developer who collaborates with AI agents."

## Armin's Core Principles for Agentic Coding

In his article, Armin Ronacher offers a number of pieces of advice for using agentic coding effectively. I'll walk through his main recommendations one by one, in a way that readers with only basic programming knowledge can follow:

1. Choose a simple, stable language: If you get to choose the language the agent will work in, Armin recommends picking one that is as simple as possible. He strongly recommended Go for new backend projects, and his reasoning is clear. Go has simple, predictable syntax, which leaves less room for the agent (the LLM) to make mistakes, and running tests works automatically in one shot. In Go, for instance, the `go test` command runs all the tests you need at once. The agent doesn't get confused about which tests to select. The Go ecosystem also changes slowly and has good backward compatibility, so there's less risk of the AI generating outdated example code. By contrast, a dynamic language full of magic like Python makes it easy for the agent to misread hidden behavior or to stumble through trial and error because of runtime environment issues. So the simpler the language itself and the less its environment shifts, the more reliably the agent can handle the code.

2. Set up agent-friendly development tools: How you arrange your development tooling matters just as much as the language. Armin's advice is that "your tools can be anything, but they must be fast and behave clearly." The agent will be running bash commands, build tools, test runners, and the like in your environment, so you should avoid tools that respond slowly or produce needlessly verbose output. Armin, for example, uses a Makefile in his projects to collect the commands he uses often: `make dev` to bring up the development server, `make tail-log` to view the logs. What matters is that when the agent uses these tools and something goes wrong, it is told immediately (logging), and that there are safeguards such as preventing duplicate execution. As a concrete example, Armin modified his process management tool so that if the server is already running, it cannot be started a second time, and instead clearly prints an "already running" error. That let the agent determine, when it ran `make dev`, whether the server was already up, and move straight on to the next step of examining the logs.

Armin also repeatedly stresses using logging itself as a core tool of agentic coding. For example, if instead of actually sending a verification email at sign-up you print the email content to the console log in development mode, the agent can read that log, find the verification link automatically, and click it. Armin put a note in his CLAUDE.md configuration file saying "in debug mode, emails are printed to the log," and the Claude agent used that to complete the whole flow from sign-up through verification by itself. Clear logs and helpful tool output act as the agent's eyes and ears. Just as we look at the console or the logs to understand a problem while developing, the agent uses logs to understand the situation and decide what to do next.

3. Optimize for speed and efficiency: The bottleneck in agentic coding comes mainly from AI model inference cost and inefficient tool usage. So it's important to speed up responses and cut wasted tokens. As mentioned above, fast-executing tools are the baseline, and beyond that, the code the agent writes and runs on the fly ("emergent tools") should be kept as lightweight as possible. Say the agent writes and runs a throwaway Python script for some task. If that script takes five seconds to run and burns another minute on initialization each time, the whole flow slows down dramatically. Armin describes how, on a real production project (Sentry), the agent was taking too long to reload code, so he built a temporary daemon that "watches for file changes, imports the module automatically, and writes the result to the log" for the agent to use. It let the agent inject code quickly and just check the execution result, without a complicated restart. Tuning your environment with creative approaches like this, to give feedback as close to real time as possible, raises the agent's efficiency. He also advises that logs that are too verbose eat tokens and slow things down, so it's best to tune them to an appropriate level that carries only the important information.

4. Stability and the principle of least surprise: Armin repeatedly comes back to the value of a "stable ecosystem." When AI works on a codebase, it makes far fewer mistakes in an environment with little external churn. LLM agents like long-proven stacks such as Go or Flask, for example. Conversely, in an environment like the JavaScript ecosystem, where dependencies shift constantly and new versions and libraries pour out every day, there's a high risk of the AI generating wrong code based on what was correct a few days ago. Agents also tend to leave their own breadcrumbs, such as comments recording why they made a particular decision while writing code. If we thoughtlessly bump a dependency to its latest version, those comments and code patterns quickly become stale and can muddy the AI's chain of reasoning. This applies to people too, but you have to be especially careful with AI, since it can casually attempt an upgrade on the assumption that "it'll be fine as long as the tests pass, right?" Armin's advice in a nutshell: "upgrade more conservatively than you did before." He also says it's better to use fewer new libraries and implement things directly in code where possible. Since the agent can whip up code quickly anyway, the idea is to write the functionality you need yourself instead of pulling in complex dependencies, and thereby maintain consistency and predictability. Armin had in fact previously written an article titled "why you should write your own code," and he says doing agentic coding has only strengthened that conviction.

5. Keep code as simple as possible: "Complex code doesn't perform well in an agentic environment. Pick the dumbest-looking solution that works" is a line Armin emphasizes. When an agent works with code, clarity comes first. So developers should aim for a more direct, simpler code style than usual. For example, several functions with long, specific names are easier to understand than complex class inheritance. Overusing highly abstract patterns or magic (magic numbers, reflection, and so on) makes it easy for the AI to lose the thread. Armin goes as far as advising you to "write plain SQL queries directly." Rather than handling the database indirectly through an ORM, having the agent write SQL makes it easier for the AI to line up the SQL output in the logs against its own code and debug. Important logic such as permission checks should also be kept as close to the relevant code as possible. If permission checks are hidden away in a configuration file or a decorator, there's a risk the agent will miss them when adding new functionality and open a security hole. In the end, "simple, clear, consistent code" is good code for both agents and humans.

6. Keep parallelization in mind: A single agent isn't all that fast, but running several at once lets you parallelize the work and raise efficiency. If you need to fix lint errors across hundreds of files at once, for example, rather than having one agent work through them in sequence, you assign several agents a subset of the files each. To do that, you have to structure the project so that contention over shared resources (the filesystem, the database, and so on) is minimized. It isn't easy, but Armin points to early attempts that are emerging, such as isolation tooling using Docker and running background agents in CI (continuous integration) environments. He hasn't fully adopted it in his own workflow yet, but he expects this to be a rapidly advancing area, so it may well become practical before long.

7. Refactor at the right time: In an agentic coding environment, the timing of refactoring matters. Up to a certain point, an agent handles code of moderate complexity without trouble. But once a project's size and complexity cross a threshold, the agent's ability to hold context hits its limits too. Armin gives an example: "early on you can develop quickly with the agent, scattering Tailwind CSS classes all over the frontend, but once your styles are spread across 50 files, it's time to restructure into a component library." Once a codebase gets that sprawling, even the agent struggles to make consistent changes, and large edits can spawn a stream of bugs. So while there's no need to refactor so early that you kill your initial velocity, put it off too long and you reach a point where even the agent can't clean up the mess. Whether human or AI, tidying up the code structure at the right moment is essential to maintainability. In agentic coding, the agent adds new functions and files effortlessly, so at some point the developer has to step in and do a big cleanup, consolidating duplicated code and modularizing, to make future work go smoothly.

These principles are the part Armin emphasizes as "essential concepts that will hold up even as the technology changes." The actual tools and techniques will evolve quickly, but principles like simplicity, stability, observability (logging and so on), and smart parallelization will continue to determine success or failure in agentic coding. Our team at Roboco strongly agrees with these insights, and we believe that for a healthy culture of coding with AI to take root, these fundamental principles of software engineering will only become more important.

## Practical Examples with Claude Code

Now let's look at how the agentic coding described above actually works in practice, using Anthropic's Claude Code. Claude Code is the command-line AI coding agent Armin primarily uses; you run it from a project directory with a terminal command (`claude`). The agent understands the codebase, edits files, and can run test or build commands directly. It also integrates with Git, making it a powerful tool that can help with searching git history, committing, and even creating PRs. Below are a few situational examples using Claude Code.

### Example: Refactoring Code

Say, for example, that we want to improve the performance of a function called `processData()`. Normally the developer would open that function, modify the logic, and verify the behavior of the related parts. With Claude Code, much of this refactoring work can be automated. The developer simply gives an instruction in natural language.

```
Refactor the processData() function so that it uses streaming instead of loading all the data at once.
```

Once you enter the prompt, the Claude Code agent opens the file containing the `processData` function on its own and starts modifying the code. For example, it will change the part that loaded all the data into memory at once to a streaming approach, and if necessary it will also modify the signatures of related functions. After making the changes, Claude Code automatically runs the project's tests to check that the refactoring didn't break existing functionality. If a test fails, the agent may analyze the cause and make further changes to the code. Once all tests pass, Claude Code will show the developer a summary such as "refactoring complete, memory usage is substantially lower, and all existing tests pass." The developer reviews this diff and, if satisfied, can commit right away.

### Example: Summarizing Documents

Agents are useful not just for coding but also for understanding and summarizing documents. Suppose a new developer has joined the project. When they need to get up to speed quickly on a design document called ARCHITECTURE.md, they can ask Claude Code for a summary.

```
Summarize the contents of docs/ARCHITECTURE.md in three lines
```

Claude Code reads the markdown document, pulls out the key points, and summarizes them. For example, it might output something like the following.

```
- This project is built on a client-server architecture, with the server providing a REST API.
- It includes modules for user authentication and permission management, with feature access restricted by role.
- For scalability, a message queue and a cache were introduced so the system can handle growing traffic in the future.
```

With these summarized points, the newly arrived developer can understand the system's structure in a short time. In this way, Claude Code can be used to answer questions or summarize by grasping the context not only of the project's code but of related documents as well. You can also use it as a code Q&A assistant, asking where a particular feature is implemented in a large codebase or what various configuration files do.

### Example: Generating a Function

This time, a code generation scenario for adding new functionality. Suppose we need logic that checks permissions before a user account is deleted. If we want to add a function called `checkPermissionBeforeDelete()` for this, we can ask Claude Code to write it.

```
Create a checkPermissionBeforeDelete(user) function that raises an error if the user does not have delete permission
```

Given this instruction, Claude Code will scan the project's code to work out what permission system it uses. Then it writes the new function in an appropriate location (in the `user_utils.py` file, say). The body of the function will contain logic that takes a user object or ID, checks whether that user has delete permission, and raises an exception if not. Claude Code generates the function while respecting the project's coding conventions (if the project is Django it might use a decorator, or it might be a simple if-check). Once it's done writing, it may run a simple test itself, or suggest whether existing test code needs a section that uses this function. In the end the developer reviews the completed function code and the agent's explanation, makes small tweaks or adds comments if needed, and saves. This is how implementing new functionality can also move quickly through conversation with the agent.

## Using Claude Code with Git

Claude Code is also tightly integrated with Git. It helps with version control work too. Let's look at a simple scenario to see how you can use it.

### Example Scenario: Saving and Sharing Code After Fixing a Bug

1. Understanding the bug: There's a bug reported as a GitHub issue. The developer instructs Claude Code, _"fix the bug described in issue #37."_ The agent reads the issue content using the GitHub CLI (`gh`), or refers to a locally saved issue description, to understand what the problem is. Then it finds the cause of the bug in the codebase and fixes it. If the bug was caused by a missing null check, for instance, it adds a conditional. After making the fix, Claude Code also runs the relevant tests (running CI tests via the gh CLI, for example) to confirm the bug is resolved.

2. Reviewing the code changes: Once the bug is fixed, Claude Code will report something like *"I added a null check to the function that was causing the problem, and all tests now pass."* The developer reviews the code change (diff) Claude Code proposes. If needed, they can give Claude Code further instructions such as _"add a few more comments"_ or *"give this variable a more meaningful name."* The agent will revise the code according to the request.

3. Committing and pushing: Once you're happy with the result, it's time to make a Git commit. An appropriate commit message is generated automatically to match the changes.

For example, the agent could run the `git commit` command to commit the current changes with the message 'Fix null pointer bug in processData function'. Likewise, the `git push` command can be run through the agent. In other words, the agent assists you in a single continuous flow, from code changes all the way through commit and push.

4. Creating a pull request: To get the code into GitHub, you need to create a PR (pull request). Since Claude Code can use the GitHub CLI (`gh`), if you instruct it as follows:

```
Create a PR to merge the bugfix branch into the main branch.
```

the agent will invoke commands such as `gh pr create` on its own and create a PR for the current bugfix branch with a suitable title and body. It can go on to link the issue number in the PR description or write a summary of the changes. As a result, the developer can create a PR entirely from the terminal in natural language, without opening the web interface and clicking through it.

This kind of Git integration is useful for team collaboration as well. For example, when a merge conflict occurs, you can hand the resolution to Claude Code. If you say *"fix the conflicts that were generated automatically,"* the agent finds the conflict markers (`<<<<`, `====`, `>>>>`) and attempts to merge them in the most plausible way. When it's done, it will tell you *"I resolved the conflicts, and the code compiles correctly."*

And on a large project where several developers work simultaneously, you can use agents in parallel to handle multiple issues at once, having each commit to its own branch. For instance, one agent develops feature A while another fixes bug B, and the two results are then put up as separate PRs for code review. In this way, combining Claude Code with Git automates a substantial part of the development cycle that runs from coding to testing to committing to PR.

(As a note, when you first use Claude Code, it will sometimes ask about commands that involve significant system changes, as a safeguard. For actions such as deleting files or making large commits, it asks for the user's permission; advanced users like Armin sometimes skip the process of approving each one with the `--dangerously-skip-permissions` option. But if you're a beginner, I'd recommend leaving the defaults in place and proceeding while watching every action the agent takes.)

## Wrapping Up: Practical Advice for Beginning Developers

The world of agentic coding and Claude Code can feel somewhat unfamiliar and complicated at first. But approached step by step, it's a tool that beginning developers can absolutely make use of, and one that can be a great help to learning and growth. Let me close by pulling together some practical advice for beginners looking to build up their agentic coding skills with Claude Code.

- 1) Start small: At first, rather than handing Claude Code an entire complex project, try it on small units of work. Requests like "add comments to this function" or "write a simple unit test" are a good place to start. Experience some successes and failures this way, and get a feel for the agent's capabilities and limits.

- 2) Always review the results: No matter how smart Claude Code is, a step where a human developer reviews the generated code and changes is essential. Agents can occasionally make an off-target change or leave a small bug, so even as a beginner, get into the habit of reading the output carefully and running additional tests. If you treat the agent's code the way you'd review a senior developer's code, you can turn it into an opportunity to spot mistakes and learn.

- 3) Experiment and tune: Use configuration files like the CLAUDE.md mentioned earlier, along with your project's Makefile and script tooling, to tune the environment so the agent works better. For example, if you write down frequently used commands in CLAUDE.md, or record the project's rules (coding style, branching strategy, and so on), Claude Code can remember and follow them. These environmental improvements also directly improve your own working efficiency, so you get two benefits for the price of one.

- 4) Don't miss the latest developments: As Armin emphasizes, this field is changing very fast. Claude Code itself is continually updated, and comparable alternative tools (OpenAI Codex, Cursor, and so on) are updated quickly too. Even as a beginning developer, it helps a great deal to make time to check relevant news and communities and to keep up with new features and best practices. If you hear that a parallel-agent feature has been added to Claude Code, for instance, try it out right away and build up your experience.

- 5) Fundamentals matter: Finally, keep in mind that agentic coding is not a cure-all. AI helps with a lot, but that's no reason to neglect studying the basic principles of programming, data structures, and algorithms. If anything, the more solid that knowledge is, the better you can direct the agent. Which problem needs solving and what direction a change should take ultimately require the developer's judgment, and that judgment is what lets you give the agent the right instructions. Having the fundamentals also lets you analyze what the agent produces and judge whether it's right or wrong.

As Armin Ronacher's account shows, coding in collaboration with AI agents is less a replacement for the developer's role than a tool that amplifies it. Beginning developers have no reason to feel intimidated: install Claude Code yourself and try it, even on a small project. It feels a little awkward at first, but try thinking of the agent as another teammate or a pair programmer and keep the conversation going. Before you know it, the repetitive work is being handled smoothly, and you'll find yourself focusing on the bigger picture and growing.

Finally, I'd encourage you not to be afraid and to learn adaptively. Armin himself says that "today's workflow may be completely different tomorrow," but he also said the core principles will hold. Keep principles like simplicity, stability, and visibility close, and enjoy this new era of development. Welcome to the world of agentic coding, where AI and people join forces to write better code, and happy vibe coding!


> Armin Ronacher's YouTube live coding video
> {{< youtube sQYXZCUvpIc >}}
