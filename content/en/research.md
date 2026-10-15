---
title: "Research"
description: "Research on autonomous AI development, a KSAT AI benchmark, automated model training, deep learning efficiency, semiconductor EDA, S3, and AWS relational databases, with observations, conditions, and limitations."
date: 2026-09-25T09:00:00+09:00
draft: false
layout: "research"
aliases:
  - experiments/
---

**We research, experiment, and share what we learn.**

ROBOCO uses real tasks to explore how far small teams can go with AI. We investigate coding-agent completion, automated model training, tools for specialist domains, and cloud infrastructure, recording the conditions alongside the observations. Results that fall short of expectations also inform our next decisions.

- [Ralph loop completion benchmark](#ralph-loop)
- [KSAT AI benchmark](#ksat-benchmark)
- [Serverless autoresearch experiments](#serverless-autoresearch)
- [Topology-based deep learning efficiency experiments](#topology-efficient-dl)
- [Semiconductor EDA experiments](#semiconductor-design)
- [S3 experiments](#s3-experiments)
- [Aurora DSQL comparison](#dsql-experiments)

*Overview as of October 16, 2026. Each project's dashboard and research records provide its latest conditions and status.*

---

## Ralph loop completion benchmark {#ralph-loop}

**Results published · Further experiments ongoing**

**Question:** Can a coding agent take a goal and complete development without human intervention until the result passes verification? How do the model and its execution environment affect that process?

**Method:** Agents implement the same RealWorld backend task. A Ralph loop repeats work and verification, with the official Hurl test suite determining completion. Each experiment records the model, harness, language, and iteration limit; independent re-checks verify the result. A harness is the environment in which the agent uses tools and executes work. This experiment began by measuring an Advisor strategy, in which a stronger model advises and a weaker model executes, and then expanded into a completion comparison across combinations of models and execution environments.

**Observations:** We publish completion outcomes, elapsed time, iteration counts, and token usage across combinations. We also analyze cases where environment settings or the grading process changed the result, separating model capability from experimental conditions.

**Interpretation:** These results concern a specific task and a limited number of repetitions. Execution dates, tool versions, and billing definitions matter. A single ranking cannot establish superiority across every development task.

- [Completion dashboard](https://roboco.io/coding-agent-benchmark/)
- [Experiment designs, results, and code](https://github.com/roboco-io/coding-agent-benchmark)

---

## KSAT AI benchmark {#ksat-benchmark}

**2026 exam results published · 2027 exam to be evaluated right after the test**

**Question:** How well can the latest AI models solve questions from Korea's College Scholastic Ability Test (KSAT), the national university entrance exam? How do accuracy, time, and cost vary by model and execution tool?

**Method:** We render the original odd-numbered-form PDFs of the 2026 KSAT as images and present the questions as they appear, without transcribing them into text. Multiple models from the OpenAI, Anthropic, and open-model families answer 147 unique questions in Korean, mathematics, and English, with tools, search, and plugins disabled. Models may abstain on questions they are unsure about, and abstentions are recorded separately from execution errors.

**Observations:** A dashboard publishes each model's answers and grading results, along with per-question estimates of time, tokens, and cost. Each year, we evaluate the previous year's exam before the test and the new exam right after it, using the same models and protocol to enable year-over-year comparison.

**Interpretation:** Previously published exams may have been included in model training data. We do not convert raw scores into students' standard scores, percentiles, or grades. The English listening section is evaluated using images of the official transcripts, which differs from evaluating audio comprehension. Costs are estimates that divide the cost of batched requests evenly across questions.

- [Results dashboard](https://roboco.io/KSAT-AI-Benchmark/)
- [Project repository](https://github.com/roboco-io/KSAT-AI-Benchmark)

---

## Serverless autoresearch experiments {#serverless-autoresearch}

**Results, code, and tutorials published**

**Question:** Can autoresearch experiments that automatically improve models run on cloud GPUs paid for as needed, without keeping a GPU running continuously?

**Method:** We reproduce and extend Karpathy's autoresearch on AWS SageMaker Spot. We explore training settings on L40S and H100 GPUs, repeating candidate generation, parallel training, result collection, and selection. The HUGI pattern uses GPUs only for training; each experiment records its settings and cost.

**Observations:** Published records cover 48 experiments on L40S and H100. They include H100 validation of settings discovered on L40S, costs and validation metrics by GPU, and the effects of startup delays and Spot availability. Reproduction code and an eight-part hands-on tutorial are also available.

**Interpretation:** These results concern specific models, training budgets, and GPU configurations. The H100 comparison with the original project includes single-run results that require repeated validation. Costs and elapsed time depend on region, Spot availability, and startup time.

- [Project repository](https://github.com/roboco-io/serverless-autoresearch)
- [Experiment settings and results](https://github.com/roboco-io/serverless-autoresearch/tree/main/experiments)
- [Hands-on tutorial](https://github.com/roboco-io/serverless-autoresearch/tree/main/docs/vibe-coding-tutorial)

---

## Topology-based deep learning efficiency experiments {#topology-efficient-dl}

**Track A complete (hypothesis rejected) · See the repository for Track B and C status**

**Question:** Can topology and structural mathematics reduce the computational cost of deep learning models (FLOPs, memory, and training time), or improve performance at the same cost?

**Method:** We test this across three tracks. Track A checks whether Persistent Homology summary features can shrink model size for time-series classification. Track B checks whether Simplicial/Cell Complexes can avoid global attention on graphs. Track C checks whether tensor decomposition can compress weights and reduce computation. Each experiment runs with three seeds on SageMaker Managed Spot Training.

**Observations:** In Track A, the small model (PH-MLP) scored 8–32 percentage points lower in F1 than the baseline model (InceptionTime) on all four datasets, missing the success criterion (a drop within 1 percentage point). Analysis attributed this to temporal patterns being lost during feature transformation and to computation costs growing with long time series. The full set of Track A experiments cost about $0.40.

**Interpretation:** These results are limited to the techniques and datasets in Track A. They do not show that topological approaches are ineffective as a whole. Results for Tracks B and C have not been published as of 2026-10-16.

- [Project repository](https://github.com/roboco-io/topology-efficient-deep-learning)
- [Detailed Track A results](https://github.com/roboco-io/topology-efficient-deep-learning/blob/main/results/track_a_results.md)

---

## Semiconductor EDA experiments {#semiconductor-design}

**Exploratory · Selected track results published**

**Question:** Can we learn specialist knowledge with AI while building useful semiconductor design software and models? How can we establish both correctness and practical time savings?

**Method:** In electronic design automation (EDA), we explore an experiment tracker, a timing analyzer, a design-flow failure diagnostic tool, and a power-supply voltage drop (IR drop) prediction model. We define judgment criteria before implementation and verify against reference data and held-out cases not used for training or development. Each track publishes its plan, protocol, results, and learning tutorial.

**Observations:** Published records include an experiment tracker that met correctness criteria but fell short of its time-saving target. The diagnostic tool performed differently on development and held-out cases. These findings point to the need to evaluate correctness, generalization, and practical usefulness separately.

**Scope:** Tracks are at different stages: some have published results, while others remain exploratory or await work. This overview follows the research log and track records; it does not represent a completed commercial EDA system or a manufactured chip.

- [Project repository](https://github.com/roboco-io/semiconductor-design)
- [Track status, results, and tutorials](https://github.com/roboco-io/semiconductor-design/blob/main/tracks/README.md)
- [Research log](https://github.com/roboco-io/semiconductor-design/blob/main/research-log.md)

---

## S3 experiments {#s3-experiments}

**Research · Selected measurements completed**

**Question:** What options emerge when Amazon S3 is used for key-value storage, event archiving, database storage, or file I/O? Under which conditions does each approach fit, and what are its cost and performance constraints?

**Method:** We distinguish literature research from direct measurements. The S3 Files, Mountpoint for S3, and EFS comparison ran read/write workloads with client caches cleared, recording latency, throughput, and unsupported operations. Mounting conditions in a SageMaker training environment were examined separately.

**Observations:** We publish research reports for the individual patterns and measurements comparing file systems. Results depend on workload and caching conditions. The records show why deployment constraints matter alongside performance when choosing an approach.

**Interpretation:** Implementation and measurement are not complete for every pattern. The file-system report records measurements from May 4, 2026, specifying the instance, region, and cache conditions. Its limitations include the possibility that service-side caches remained warm even after client caches were cleared.

- [Project repository](https://github.com/roboco-io/s3-experiments)
- [Research by pattern](https://github.com/roboco-io/s3-experiments/tree/main/docs/research)
- [File-system results and measurement conditions](https://github.com/roboco-io/s3-experiments/blob/main/docs/research/s3-files.md)

---

## Aurora DSQL comparison {#dsql-experiments}

**12 experiments completed · Adoption decision report and usage guide published**

**Question:** For the same workload, how does Aurora DSQL compare with established relational databases in performance, development and operations effort, cost, and constraints?

**Method:** We compared Aurora DSQL with RDS PostgreSQL Multi-AZ instances, Aurora PostgreSQL Provisioned, and Aurora PostgreSQL Serverless v2. Using the same order workload, consistency requirements, and latency objectives, 12 experiments examined SQL compatibility, contention and consistency, OLTP throughput and latency, connections, failure and recovery, bursts and idle periods, operations work, large queries, and cost. We publish conditions, measurements, and execution code.

**Observations:** With 256 fixed connections, DSQL handled more than 24,541 requests per second within the latency objectives; the best results within the objectives for the comparison services were 11,559 for Aurora Serverless v2, 5,839 for RDS Multi-AZ, and 3,375 for Aurora Provisioned. In exchange, each query took 3–6 times longer than on Aurora (write p95 about 30–40 ms), 16 of 35 existing SQL checks needed changes, and conflict retries and split transactions (3,000 rows, 300 seconds) were mandatory. Cost scaled with requests at about USD 0.31 per million, so DSQL was cheaper than fixed instances when average load stayed below about 1,100 requests per second or when services sat idle for long periods. Point-in-time restore was not available.

**Interpretation:** The experiments ran from September 24 to 29, 2026, in the Seoul Region with one order workload and about 5 GiB of data. Most measurements ran once, and 9 of the 12 experiments covered only part of the plan (MVP). The DSQL throughput is a lower bound close to the load generator's limit, and DSQL and the comparison services were measured on different days with different load generator types.

- [DSQL adoption decision report](https://roboco.io/dsql-experiments/decision/)
- [Aurora DSQL usage guide for people and coding agents](https://roboco.io/dsql-experiments/guide/)
- [Public experiment notes](https://roboco.io/dsql-experiments/)
- [Experiment plan and code](https://github.com/roboco-io/dsql-experiments)

---

## From experiments to your production system

These experiments provide evidence for choosing tools and infrastructure and designing verification criteria and operating conditions. In your environment, we assess fit through real work in a [software factory pilot and setup](/en/solutions/).

[Discuss a pilot using your own work](/en/contact/) · [Explore ROBOCO's tools and methods](/en/products/)
