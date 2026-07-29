---
title: "Drawing Architecture Diagrams with AI"
date: 2025-06-14T12:35:06+09:00
draft: true
toc: false
images:
tags:
  - productivity
  - tips
  - aws
  - drawio
---

{{< figure src="/posts/images/Dohyun.png" title="Dohyun Jung - Principal Consultant, ROBOCO" style=".author-image">}}

When people do vibe coding, they often assume the code alone is enough. Reality says otherwise. Code without documentation is like setting off on a trip without a map. If nobody knows where the destination is or what the route looks like, nobody will come along. Documentation matters especially in vibe coding because code isn't merely there to run — it exists to convey your ideas and design intent accurately to other people. Documentation smooths collaboration, clarifies where a project is headed, and ultimately forms the foundation of a sustainable development environment.

I strongly recommend managing documentation alongside your code. Markdown and mermaid in particular let you produce simple, clear diagrams quickly. A single diagram can capture complex structures and flows that would otherwise take paragraphs of prose, which makes communication far more effective.

Of course, mermaid alone sometimes falls short. When you need something more refined and complex, you can turn to draw.io. Because draw.io uses the XML-based .drawio file format, it's relatively easy to instruct an AI to generate diagrams directly in that format. The catch is that the IDs for specific icons — AWS icons, for instance — aren't published, so an AI can't readily use them.

So I extracted the IDs of the AWS architecture icons straight from the draw.io client and [documented them](https://github.com/Hands-On-Vibe-Coding/ecs-fargate-fast-scaleout/blob/main/docs/aws-2025-icons-drawio.md) separately. That way I can hand the icon IDs to an AI and have it use exactly the icons I want. You can see the document in action, applied to a real project, in the GitHub repository below.

## TL;DR

- In vibe coding, documentation isn't optional — it's the core work of sharing design intent and the context needed for collaboration.
- Markdown and mermaid are enough for simple structures, but for more refined architecture diagrams you can generate draw.io files together with an AI.
- Supplying the fine-grained details an AI can't be expected to know — such as AWS icon IDs — as a separate document lets you produce the diagram you actually want, far more accurately.

[ECS - Fargate Fast Scaleout](https://github.com/Hands-On-Vibe-Coding/ecs-fargate-fast-scaleout/)

Once a diagram has been generated this way, VS Code's drawio extensions make it easy to preview and edit. Installing the draw.io client also gives you a bundled CLI tool that converts diagrams to SVG or PNG so you can drop them straight into your documents.

![alt text](https://raw.githubusercontent.com/Hands-On-Vibe-Coding/ecs-fargate-fast-scaleout/abbb4dee4d89070692fc4edc0e81a313c910c52b/docs/diagrams/architecture.svg)

Meanwhile, recent versions of mermaid have started supporting a range of architecture icons out of the box, AWS icons included. The [official documentation](https://mermaid.js.org/syntax/architecture.html) will get you going right away. GitHub doesn't support this newer feature yet, though, so the approach I described above will remain the most practical option for the time being.

Good documentation goes beyond being a manual: it raises the quality of collaboration and sustains a project's value over the long run. In vibe coding, documentation is not a choice — it's a requirement.
