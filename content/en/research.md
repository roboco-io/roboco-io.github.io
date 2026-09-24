---
title: "Research"
description: "Research on autonomous AI development, semiconductor EDA, and S3. ROBOCO shares observations, conditions, and limitations."
date: 2026-09-24T09:00:00+09:00
draft: false
layout: "research"
aliases:
  - /en/experiments/
---

**We research, experiment, and share what we learn.**

ROBOCO uses real tasks to explore how far small teams can go with AI. We investigate coding-agent completion, tools for specialist domains, and cloud infrastructure, recording the conditions alongside the observations. Results that fall short of expectations also inform our next decisions.

- [Ralph loop completion benchmark](#ralph-loop)
- [Semiconductor EDA experiments](#semiconductor-design)
- [S3 experiments](#s3-experiments)

*Overview as of September 24, 2026. Each project's dashboard and research records provide its latest conditions and status.*

---

## Ralph loop completion benchmark {#ralph-loop}

**Results published · Further experiments ongoing**

**Question:** Can a coding agent take a goal and complete development without human intervention until the result passes verification? How do the model and its execution environment affect that process?

**Method:** Agents implement the same RealWorld backend task. A Ralph loop repeats work and verification, with the official Hurl test suite determining completion. Each experiment records the model, harness, language, and iteration limit; independent re-checks verify the result. A harness is the environment in which the agent uses tools and executes work.

**Observations:** We publish completion outcomes, elapsed time, iteration counts, and token usage across combinations. We also analyze cases where environment settings or the grading process changed the result, separating model capability from experimental conditions.

**Interpretation:** These results concern a specific task and a limited number of repetitions. Execution dates, tool versions, and billing definitions matter. A single ranking cannot establish superiority across every development task.

- [Completion dashboard](https://roboco.io/coding-agent-benchmark/)
- [Experiment designs, results, and code](https://github.com/roboco-io/coding-agent-benchmark)

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

## From experiments to your production system

These experiments provide evidence for choosing tools and infrastructure and designing verification criteria and operating conditions. In your environment, we assess fit through real work in a [software factory pilot and setup](/en/solutions/).

[Discuss a pilot using your own work](/en/contact/) · [Explore ROBOCO's tools and methods](/en/products/)
