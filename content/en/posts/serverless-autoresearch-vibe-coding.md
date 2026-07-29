---
title: "Serverless Autoresearch: A Record of Making an ML Experiment Pipeline Serverless Through Vibe Coding"
date: 2026-03-29T16:00:00+09:00
draft: false
toc: false
images:
tags:
  - vibe-coding
  - agentic-dev
  - ml-engineering
  - aws
  - sagemaker
---

> The real value of vibe coding is not only in writing code fast. It is in designing a way of operating that lets you repeat expensive experiments more cheaply and more quickly.

{{< figure src="/posts/images/Dohyun.png" title="Dohyun Jung - Principal Consultant, ROBOCO" style=".author-image">}}

Most people first associate vibe coding with web app prototyping or CRUD automation. But ROBOCO's [`serverless-autoresearch`](https://github.com/roboco-io/serverless-autoresearch) repository widens that frame considerably. Instead of the "tie up a single H100 for several hours" approach that Andrej Karpathy's `autoresearch` presupposes, this project builds a structure that runs parallel experiments in short, explosive bursts on AWS SageMaker Spot.[^1]

What makes this case interesting is not that the results simply came out cheap. The repository preserves all of it: **the deep interview that sharpened the initial idea**, **plan-driven architecture design**, **cloud infrastructure debugging**, **automation of repeated experiments**, and **the process of converting failures back into documents and skills**. In particular, `docs/vibe-coding-tutorial` is less a code manual than a log showing how conversational AI coding actually hardens into engineering artifacts.[^2]

The numbers are worth sorting out first. The tutorial, centered on the initial run window of March 27-28, 2026, records **25 experiments, $0.44 in total cost, and a best `val_bpb` of 1.0643**.[^2][^10] The repository README, on the other hand, presents an expanded picture: running **83 experiments in about 3.5 hours for roughly $1.33**, emphasizing a structure that is **2.3x faster and 5-18x cheaper** than the original sequential execution.[^1] In other words, "$0.44" is the cost of the initial validation and "$1.33" is the cost of the expanded operating model. The two figures do not conflict; they are results from different stages.

## TL;DR

- `serverless-autoresearch` is a case of extending vibe coding beyond web app automation into the problem of ML experiment pipelines and cloud operations design.
- The core is replacing long-held occupancy of an H100 with SageMaker Spot-based parallel experiments, making cheap failure and fast learning possible.
- Good results come less from volume of generated code than from an operating approach: problem definition, planning, infrastructure validation, and converting failures into documents and skills.

## 1. What This Project Actually Changed

Karpathy's original `autoresearch` runs one experiment at a time and, fundamentally, follows a flow that occupies a high-performance GPU such as an H100 for long stretches. `serverless-autoresearch` changed that flow into **parallel evolution**.[^1][^4]

There are two key points.

- Instead of holding a single experiment for a long time, run many candidates simultaneously and briefly.
- Instead of keeping a GPU on 24 hours a day, spin up Spot instances only when needed and shut them down as soon as they finish.

The repository calls this the **HUGI (Hurry Up and Get Idle)** pattern.[^1] Rather than keeping a server alive for a long time, it computes in a short burst and returns immediately to idle. This simple shift completely changes the cost structure. It shows that "serverless" does not just mean function invocation — it is an operating philosophy applicable to GPU workloads as well.

By the tutorial's account, the actual validation is fairly concrete.

| Segment | Content | Cost |
|---|---|---|
| First successful experiment | First end-to-end success on L40S Spot | $0.06 |
| Batch size trap validation | Eliminated a wrong hypothesis with 4 parallel experiments | $0.07 |
| 5 generations of autonomous evolution | Searched for optimal parameters over 20 experiments | $0.31 |
| Total | 25 experiments | **$0.44** |

The point of this project, then, is not "it runs even on cheap GPUs" but that **you can buy a lot of cheap failure**.[^6][^7][^8][^10]

## 2. The Real Point the Tutorial Makes

### 2.1 Vague requests have to be narrowed through a deep interview

The first scene of the tutorial is not code but questions. The user pairs a request to "reproduce the autoresearch experiment" with an instruction to conduct a deep interview if needed.[^3] As a result, the goal is redefined from simple reproduction into these three things:

- Serverless execution based on SageMaker Managed Spot Training
- OMC-based autonomous iterative experimentation
- Documentation reusable for teaching and demo purposes

This looks small but it is a very important shift. A vague "reproduction" often ends up merely imitating the original. After an interview, by contrast, "what will we learn," "what will we automate," and "what will we leave behind" become clear. It shows that vibe coding is less the skill of writing long prompts than **the interviewing skill of drawing out a good problem definition**.

### 2.2 Plan mode has to come before implementation

In the second chapter, the AI does not write code right away. It first explores the upstream `autoresearch` codebase and the user's existing SageMaker patterns, then plans a pipeline structure divided into a candidate generator, a batch launcher, a results collector, and a selection module.[^4]

Partway through, when the user adds the condition to "make aggressive use of parallel execution and HUGI, the advantages of the cloud," the design changes from sequential execution to a **population-based parallel evolution** structure.[^4] This passage shows well that vibe coding is not "code the AI wrote on its own" — its usefulness grows only **when you can revise the architecture at the planning stage**.

The tutorial in fact records that 23 files were created in this session and that the entire path was validated with `make dry-run`.[^4] What matters more than the speed of generation is that the structure was agreed on before generation.

### 2.3 Infrastructure problems are not peripheral issues but core design variables

The third chapter is the highlight of this project. The code is ready, but the AWS infrastructure trips it up. The GPU Spot quota defaults to 0, and Spot availability differs enormously by region.[^5][^11]

The most practical lesson in the tutorial is `aws ec2 get-spot-placement-scores`. The same `g7e`-family instance scores 1-2 in `us-west-2` and is nearly impossible to obtain, while in `us-east-1` it scores 9 and is allocated quickly.[^5][^11] Many teams waste time here, because they treat infrastructure problems as "something to solve once the code is done." This repository says the opposite. **Which region you use, which instance you use, and how quickly your quota gets approved are themselves part of pipeline design.**

Another passage that stands out is the difference in approval by GPU type. `g7e` is approved relatively quickly, but `p5` and `p6` can take days of manual review.[^5][^11] This kind of knowledge never shows up inside the code. That is why documentation and operational memory matter more.

### 2.4 Cheap experiments deliver cheap lessons quickly

The fourth and fifth chapters show what "cheap experiments" really means. In the first successful experiment, the L40S did not properly support Flash Attention 3 and threw a runtime CUDA error, which ultimately led to logic that explicitly checks GPU capability and falls back to PyTorch SDPA.[^6] The fix got the first successful experiment running, but MFU stayed at about 20.5%, roughly half of what an H100 achieves.[^6]

It does not end there. In the next experiment, there was VRAM to spare, so raising `DEVICE_BATCH_SIZE` seemed like it should help — but the result got worse instead. The reason is that the total token count did not increase while gradient accumulation simply decreased.[^7][^11] This is a point many ML teams genuinely get confused about. Using more GPU memory does not mean more training happened.

This project validates such misconceptions cheaply. Repeating the same mistake in a big-budget H100 experiment would have cost far more.

### 2.5 Autonomous experimentation paid off through "small adjustments" rather than "bold changes"

The most interesting result of the autonomous evolution stage is not a flashy architectural change but the fact that **conservative learning rate adjustments worked best**. Small changes to `EMBEDDING_LR` and `SCALAR_LR` led to improvements, while medium-scale or larger interventions — increasing `DEPTH`, expanding `TOTAL_BATCH_SIZE`, changing `WINDOW_PATTERN` — mostly made things worse or ended in timeouts.[^8][^10]

This pattern matters more than it might seem. On a short five-minute training budget, complex structural changes never get the time to converge. So an AI agent in this environment is stronger as "an operator who doggedly tunes small numbers" than as "a bold inventor." It means vibe coding does not always produce creative leaps — it is strong at **rapidly accumulating small improvements inside a short feedback loop**.

## 3. The Way It Converts Failure into Skills Is Especially Good

What makes this repository especially good from ROBOCO's perspective is how it handles the final step. Rather than stopping at summarizing results once the experiments end, it organizes 12 insights in `docs/insights.md` and then connects those to reusable skills for Claude Code.[^9][^11]

What is captured there is not simple notes.

- Spot scores differ enormously by region.
- Smaller instances are not always cheaper.
- `DEVICE_BATCH_SIZE` is closer to VRAM usage than to throughput.
- Cheap Spot GPUs work well enough as a proxy for validating hypotheses before expensive H100 training.

This form of consolidation is what separates levels of maturity in vibe coding. Many teams forget what they learned once the session with the AI ends. Teams that do it well turn failures into documents and turn documents back into skills and rules. Then the quality of the next session goes up. The source of productivity becomes not the model itself but **accumulated operational knowledge**.

## 4. What ROBOCO Takes Away From This

`serverless-autoresearch` shows that vibe coding can go beyond toy-level app building to handle ML experiment pipelines and cloud operations design. And success or failure depends less on volume of generated code than on these four things:

- How well you interview the initial request to narrow the problem
- How clearly you agree on the architecture before implementation
- How quickly you validate the infrastructure and cost structure
- How quickly you convert failures into documents and skills

In the end, this project's core message is simple. Vibe coding does not replace engineering. Instead it moves the center of engineering from **typing directly** to **asking questions, designing, experimenting, and accumulating lessons**. `serverless-autoresearch` is a case that shows well what that shift actually looks like.

Read the original repository and the tutorial together and you will see something far more interesting than "the AI wrote the code." What remains is **the process of designing the experiment system itself together with an AI**.[^1][^2]

---

[^1]: Serverless Autoresearch README: https://github.com/roboco-io/serverless-autoresearch/blob/main/README.md
[^2]: Vibe Coding Tutorial README: https://github.com/roboco-io/serverless-autoresearch/blob/main/docs/vibe-coding-tutorial/README.md
[^3]: Chapter 1, "The Idea": https://github.com/roboco-io/serverless-autoresearch/blob/main/docs/vibe-coding-tutorial/01-the-idea.md
[^4]: Chapter 2, "Building the Pipeline": https://github.com/roboco-io/serverless-autoresearch/blob/main/docs/vibe-coding-tutorial/02-building-the-pipeline.md
[^5]: Chapter 3, "Infrastructure Adventures": https://github.com/roboco-io/serverless-autoresearch/blob/main/docs/vibe-coding-tutorial/03-infrastructure-adventures.md
[^6]: Chapter 4, "First Experiment": https://github.com/roboco-io/serverless-autoresearch/blob/main/docs/vibe-coding-tutorial/04-first-experiment.md
[^7]: Chapter 5, "The Batch Size Trap": https://github.com/roboco-io/serverless-autoresearch/blob/main/docs/vibe-coding-tutorial/05-the-batch-size-trap.md
[^8]: Chapter 6, "Autonomous Evolution": https://github.com/roboco-io/serverless-autoresearch/blob/main/docs/vibe-coding-tutorial/06-autonomous-evolution.md
[^9]: Chapter 7, "Insights & Skills": https://github.com/roboco-io/serverless-autoresearch/blob/main/docs/vibe-coding-tutorial/07-insights-and-skills.md
[^10]: Chapter 8, "Results & Comparison": https://github.com/roboco-io/serverless-autoresearch/blob/main/docs/vibe-coding-tutorial/08-results-and-comparison.md
[^11]: Key Insights: https://github.com/roboco-io/serverless-autoresearch/blob/main/docs/insights.md
