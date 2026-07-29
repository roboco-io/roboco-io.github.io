---
title: "Vibe Coding and Security: True or False"
date: 2025-12-30T10:01:21+09:00
draft: true
toc: false
images:
tags:
  - vibecoding
  - security
  - claude-code

---

{{< figure src="/posts/images/Dohyun.png" title="Dohyun Jung - Principal Consultant, ROBOCO" style=".author-image">}}

These days, saying "I code with AI" is no longer special. It is already the new normal. Coding works — that is now a given — and today's AI tools do far more than that in a business.

Even so, many companies hesitate at the adoption stage. The reason is always the same: security. Today I want to sort through the security concerns surrounding AI coding agents from an enterprise perspective — in particular Claude Code, the most widely chosen tool for production-level vibe coding — separating what is true from what is false.

## TL;DR

- Security for AI coding tools should be made concrete in terms of contract terms, data retention, execution environment, and permission controls, not left as vague anxiety.
- Agentic tools like Claude Code have a broader attack surface than autocomplete plugins, which makes isolation and update management essential.
- Enterprises need to look beyond product settings and build an operating model that covers sandboxing, network controls, DLP, and audit logs.

## The Truth About Training Data Leakage

"Put your code into AI and it gets trained on and leaks out" is half right and half wrong. In an enterprise context, what matters is not the vague word 'AI' but the specific contract terms and the distinction between products.

Anthropic's enterprise products have a clear principle. By default, commercial input and output data is not used to train models. The Claude Code documentation also states that alongside a default 30-day data retention policy, there is a Zero Data Retention (ZDR) option that stores no conversation history on the server when a properly configured API key is used.

The consumer side is a different story. Under the consumer terms changed in August 2025, the data retention period can be extended depending on the 'allow training' setting. Enterprises therefore need to clearly confirm and control which scope the service they are currently using falls under (commercial: Work/API/Gov), whether the log retention policy is standard (30 days) or ZDR (0 days), and how far client-side local caching will be permitted. Security starts with identifying the assets you have to protect and defining the means of protecting them.

## Certification Badges and Substantive Security

The belief that "it has SOC 2 and ISO 27001 certification, so it's safe" is likewise only a half-truth. Certification does matter, of course. Through its Trust Center, Anthropic provides compliance artifacts such as SOC 2 Type II and ISO 27001, demonstrating that the organization's security management system is functioning.

But certification does not guarantee that "a breach will never happen." Certification only shows the effectiveness of a management system; it is not magic that removes every technical vulnerability from a product. Enterprises should not treat certification as a simple 'stamp of reassurance.' They should use it instead as a safeguard in the deal. Specific items — data retention periods, access controls, audit logs, incident notification procedures, subprocessor management, regional regulatory compliance — should be locked into contracts and operational policies so that they carry real binding force.

## The New Threats of Agentic Tools

The idea that "Claude Code is just an IDE plugin, so it isn't dangerous" is a dangerous misjudgment. Claude Code is not a simple autocomplete tool but an 'agentic tool' that judges and acts on its own. At the point where the local execution environment, integrations with various tools, and user permissions all intermingle, an attack surface of a different order than before emerges.

The Claude Code-related CVEs reported in 2025 illustrate these threats well. An unauthorized connection issue caused by a WebSocket authentication bypass in the IDE extension (CVE-2025-52882), a vulnerability where malicious code could execute before the user approved the trust dialog (CVE-2025-59536), a similar problem tied to the Yarn plugin (CVE-2025-65099), and a directory restriction bypass caused by insufficient path validation (CVE-2025-54794) are the evidence.

This does not mean Claude itself is dangerous. It is a warning that an enterprise's deployment and operating practices can be dangerous. If updates lag, developer PC environments are fragmented, and running arbitrary files out of the Downloads folder is culturally tolerated, adopting agentic tools can become the trigger that raises the probability of an incident.

## The Speed of Defense, and Automation

The idea that "AI security is a defender's problem only" is also wrong. Attackers are already weaponizing AI too. According to the Threat Intelligence report Anthropic published in August 2025, there were signs that tools including Claude Code had been abused in cyberattacks such as large-scale extortion operations. In November 2025, an even more advanced espionage campaign was disclosed, one that used AI not as a mere advisor but as the executor of the attack.

This reality demands a fundamental change in defensive strategy. Slow defense, where humans respond to everything one by one, cannot stop hackers attacking at AI speed. Automation now has to be introduced across the entire process from detection to response to recovery, so that the speed of defense matches the speed of attack.

## Recommendations for Enterprises: From Product Settings to an Operating Model

In the end, the key is innovation in the 'operating model,' not simple product settings. Anthropic emphasizes sandboxing based on file system and network isolation as a way to reduce permission pop-ups while still ensuring safety. Enterprises should build an execution strategy that is one step more concrete, in line with that direction.

First, **isolating the execution environment** is essential. Wherever possible, run AI tools in a Dev Container, VDI, or isolated VM environment, and even when running them on a local PC, apply file and network isolation sandboxing as the default.

**Network control** should likewise follow a 'deny-all by default' principle. Only domains essential to the work should be whitelisted, and everything else blocked. That is because prompt injection without network isolation can lead directly to immediate data exfiltration.

**Execution from untrusted paths** should be blocked systemically. The attack scenario that many of the CVEs warn about in common is tricking a user into running a tool from an untrusted directory. Execution from Downloads folders, temp folders, and shared folders therefore has to be blocked technically through system configuration, not through policy training.

**Enforced updates** matter too. Updating IDE extensions and CLI tools should not be left to each developer's discretion. Establish a minimum allowed version policy and block execution outright for versions that fall below the bar.

A **data loss prevention (DLP)** system should be built into the stage before prompt input. Making secret scanning and prompt DLP standard infrastructure, so that a mistake by an AI or a human does not turn into an incident, is at the core of enterprise security.

Finally, you need **audit logs and anomaly detection**. Keep records of who called which tool in which repository, and analyze them in real time. Since attackers come at you with automated tools, the defensive system has to secure a commensurate level of speed and visibility.

## Conclusion: Keeping Security From Holding the Business Back

Security is a brake. Without brakes you crash. But if all you do is hold down the brake, you never get anywhere. I often see enterprises come to a stop in front of AI adoption. The decision is, "it might be risky, so let's hold off for now." Holding off does not mean maintaining the status quo. It is not just that your competitiveness erodes — hackers are using AI to attack, too.

Tools like Claude Code are already in the field. The question is not "should we use it or not." Now is the time to think about how to use it safely. And here security is not something that holds the business back. Security becomes the guardrail that lets you pick up speed safely. Rules are what let a team move fast. Guardrails are what let people run without fear.

So the conclusion ROBOCO has reached is simple. Don't trust AI. Don't trust people either. Build systems you can trust instead. At the core of those systems are automated processes and guardrails that the organization can control.
