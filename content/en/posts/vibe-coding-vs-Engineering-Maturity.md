---
title: "Vibe Coding or Engineering Maturity: Which Comes First?"
date: 2025-07-11T14:46:42+09:00
draft: true
toc: false
images:
tags:
  - vibe-coding
  - engineering-maturity
---

{{< figure src="/posts/images/Dohyun.png" title="Dohyun Jung - Principal Consultant, ROBOCO" style=".author-image">}}

A lot of developers think of vibe coding as nothing more than "a way to generate code automatically." Give the tool an instruction, wait a moment, and beautiful code pops out. Reality is not that simple. In an environment with no automated tests, no solid design, and not even a functioning review process, vibe coding just churns out garbage code faster.

This is not a tooling problem. It is an engineering maturity problem. Software engineering maturity and vibe coding complement each other, and only in an environment with high engineering maturity can vibe coding show what it is really capable of.

## TL;DR

- In organizations weak on engineering fundamentals such as testing, design, and review, vibe coding can actually magnify quality problems faster.
- Conversely, once documentation, test automation, IaC, and a review process are in place, AI tools lift development speed and quality together.
- Vibe coding is a tool that works well only in mature organizations, and at the same time a tool that raises an organization's maturity.

Paradoxically, vibe coding tools are enormously useful for raising engineering maturity. With vibe coding techniques you can organize specification documents, analyze existing code to generate tests automatically, and quickly verify whether those tests satisfy the spec. Implementing infrastructure quickly and accurately as IaC (Infrastructure as Code) is likewise possible without human intervention. Tools like SuperClaude, for example, make it easy to carry out a range of activities including code analysis, documentation, implementation, testing, and security scanning.

The relationship between vibe coding and engineering maturity can be expressed like this.

```mermaid
%%{init: {
  'theme': 'base',
  'themeVariables': {
    'primaryColor': '#3b82f6',
    'primaryTextColor': '#1e293b',
    'primaryBorderColor': '#1e40af',
    'lineColor': '#6366f1',
    'secondaryColor': '#8b5cf6',
    'tertiaryColor': '#ec4899',
    'background': '#ffffff',
    'mainBkg': '#f8fafc',
    'secondBkg': '#e2e8f0',
    'tertiaryBkg': '#cbd5e1'
  }
}}%%
flowchart LR
    A["🚀 Vibe Coding"] 
    B["📈 Higher Software<br/>Engineering Maturity"]
    C["📚 Documentation<br/>System"]
    D["🏗️ IaC-Based<br/>Immutable Infrastructure"]
    E["🔍 Effective<br/>Review Process"]
    F["⚡ Augmented Coding<br/>Approach"]
    
    A --> C
    A --> D
    A --> E
    C --> B
    D --> B
    E --> B
    B --> F
    F --> A
    
    classDef startNode fill:#3b82f6,stroke:#1e40af,stroke-width:3px,color:#ffffff
    classDef processNode fill:#8b5cf6,stroke:#7c3aed,stroke-width:2px,color:#ffffff
    classDef outputNode fill:#10b981,stroke:#059669,stroke-width:2px,color:#ffffff
    classDef maturityNode fill:#f59e0b,stroke:#d97706,stroke-width:3px,color:#ffffff
    
    class A startNode
    class C,D,E processNode
    class F outputNode
    class B maturityNode
```

Here is my advice to anyone about to start with vibe coding. First put your existing project's documentation in order, build test automation, and set up a fully automated CI/CD pipeline along with IaC-based immutable infrastructure. Raising your engineering maturity is the first step toward using vibe coding properly. With software engineering maturity behind you, Kent Beck's [augmented coding approach](https://tidyfirst.substack.com/p/augmented-coding-beyond-the-vibes) can then take the quality and speed that vibe coding delivers to their maximum.
