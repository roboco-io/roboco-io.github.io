---
title: "Is MCP Really Necessary for Vibe Coding? (feat. CLI)"
date: 2025-04-01T10:28:00+09:00
draft: true
toc: false
images:
tags:
  - vibecoding
  - mcp
  - cli
---

{{< figure src="/posts/images/Dohyun.png" title="Dohyun Jung - Principal Consultant, ROBOCO" style=".author-image">}}

Look around the developer community these days and you will run into plenty of talk about MCP, the Model Context Protocol. The argument goes that if we want AI to work more intelligently and more flexibly, we need an interface like MCP. And honestly, I have been watching this technical trend with real interest. Part of me looks forward to where it goes, and part of me wonders: does MCP actually have to be there right now?

The upside of MCP is clear. When AI is wired into multiple services, the protocol lets it handle work more smoothly and more naturally. But reality is not that simple. Plenty of services still do not support MCP, and using MCP properly requires dedicated server infrastructure. Standing up that infrastructure is not the end of it either — you also need rigorous security management and an operational plan that guarantees high availability. Add it all up and the effort and cost of adopting MCP turn out to be far from trivial.

So what about vibe coding? Is AI ineffective without MCP? Not at all. Remarkably, we have had for a very long time one thoroughly universal tool that AI happens to handle extremely well: the CLI, the command line interface.

## TL;DR

- MCP is useful for connecting AI to external services, but it is not a prerequisite for vibe coding today.
- The CLI is a long-proven, general-purpose interface, and it is the practical channel through which AI can do Git, cloud, IaC, and database work.
- Until the MCP ecosystem and its security operations mature further, leaning hard on the CLI you already know is the realistic choice.

The CLI is less "outdated" than it is a general-purpose interface validated by a long history. Every developer is comfortable with it, and standard input and output let you compose pipelines that handle even complex processing. Write a good shell script once and you can run it yourself any time, no AI required.

When I do vibe coding, I hand a fair amount of work to AI through the CLI. Creating a GitHub repository, managing issues and projects, documenting a wiki — all of that is easy to handle from the command line. Basic operations like generating a commit message, committing, pushing, and merging are things AI performs deftly through the CLI as well.

Beyond that, checking the state of cloud infrastructure, verifying deployment results, and troubleshooting when something breaks all go smoothly through the CLI. Deploying and debugging with IaC tools such as Terraform or CloudFormation works perfectly from the command line too. Complex jobs like analyzing or creating a database schema are more than handled by CLI tooling.

We are in the early, transitional days of MCP adoption. More services will certainly adopt it going forward, but the service ecosystem is not mature yet. Above all, it will take time before solid security policies and management practices for MCP arrive.

Is there any reason to wait until then? Obviously not. If there is a way to use AI as effectively as possible right now, it is to lean into the CLI that is already second nature to us. Once you experience the fantastic combination of AI and the CLI while vibe coding, you will see that you can produce productive, creative results without needing MCP at all.

I have no argument with the claim that MCP is useful as an interface for providing AI services or for AI to consume. But when it comes to vibe coding, we can already use the CLI to let AI take full advantage of the interfaces we have.
