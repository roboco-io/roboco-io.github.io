---
title: "Security Will Accelerate Software Factory Adoption"
date: 2026-10-15T10:00:00+09:00
draft: false
toc: false
images:
tags:
  - software-factory
  - security
  - agentic-dev
  - ai-security
---

> "AI needs no rest. It does not sleep, and it has no holidays and no vacations." – Park Moon-beom, CPO of 78ResearchLab (translated from Korean)[^1]

{{< figure src="/posts/images/Dohyun.png" title="Dohyun Jung - Principal Consultant, ROBOCO" style=".author-image">}}

---

On September 30, 2026, Shinhan Bank reported a leak of customer data to Korea's financial regulators. Two weeks later, on October 14, the regulators' tally of the damage had grown to about 100,000 records across 16 companies, including banks, savings banks, capital (consumer finance) companies, and virtual asset service providers.[^2] On the 6th of the same month, Yoido Full Gospel Church and SaRang Church disclosed signs that hackers had leaked their members' data.[^3] Earlier, on September 3, a government investigation team announced that about 39.54 million accounts had leaked from the streaming service TVING.[^4]

The financial-sector incident comes with a story that AI was used. But as of October 15, 2026, this is **not an established fact.** The regulators are still investigating whether AI was involved.[^2] What is confirmed is only that several security vendors reported traces of an LLM-based automated penetration tool on the attack infrastructure.[^5] Even so, I do not think these signs can be taken lightly. If attackers have already started working with agents, a defense that works at human speed cannot hold out for long.

This post makes one argument. **I expect security pressure to bring forward the adoption of the software factory.** Attacks are getting faster. Vendors that use AI to find vulnerabilities now name remediation capacity as the bottleneck. Regulators are shortening remediation deadlines. I think these pressures all point toward a development system in which people are not the bottleneck between discovery and fix-and-deploy, that is, the software factory. This does not mean "a factory that runs without people," though. People set the rules, and machines execute within those rules without rest.

## TL;DR

- In recent incidents in Korea, the causes that investigations confirmed or that multiple outlets reported were not new attack techniques. They were places where basic controls were missing: access keys left in source code, bypassed authentication steps, and security patches that were never applied.
- What AI changes is less the kind of attack than its speed and scale. When attackers find gaps in basic controls faster, the time it takes to find and close those gaps becomes the key metric of defense.
- The pressure is already moving. Remediation cannot keep pace with the speed at which AI finds vulnerabilities, regulations in the US, the EU, and Korea are shortening remediation deadlines or lowering the barriers to fast patching, and AI tools that also produce fixes have arrived. Adoption is still early, however, and trust in automated fixes is cited as one of the barriers.
- I see the software factory as a strong candidate for a system that cuts that time. It turns discovered problems into tasks, has agents fix them, verifies the fixes with evidence, and turns failures into rules.
- But the factory itself becomes a new attack surface. A factory built without mechanisms such as risk tiers, separation of write permissions, and a human stop command increases threats instead of improving security.

## 1. What Is Happening in Korea

The table below summarizes the major incidents disclosed through October 15, 2026. It separates causes stated by government investigations or the affected organizations from causes reported or claimed by the press or security vendors.

| Incident | Disclosed | Scale | Cause and investigation status |
|---|---|---|---|
| Chain of financial-sector leaks | First reported 2026-09-30 | 16 companies, about 100,000 records (as of 10-14)[^2] | Under regulatory investigation. Multiple outlets consistently report that authentication was bypassed in a separate lookup service that Shinhan Bank ran for loan brokers[^6] |
| TVING | 2026-06-03 | About 39.54 million accounts[^4] | Government findings: a developer's access key was stolen and the source code leaked, and the attacker got in using 43 production access keys contained in that source code. A vulnerability found in a 2024 penetration test had not been fixed[^4] |
| Coupang | 2025-11 (findings 2026-02-10) | 33,673,817 records[^7] | Government findings: a former employee abused a signing key hard-coded in the source code. The key was not rotated after the employee left[^7] |
| Yoido Full Gospel Church and SaRang Church | 2026-10-06 | About 850,000 people per the church's announcement (Yoido Full Gospel Church)[^3] | No official cause announced. Security vendors attribute it to a web shell and hijacked accounts[^3] |

The statistics point the same way. According to Korea's Ministry of Science and ICT and KISA (Korea Internet & Security Agency), breach reports in the first half of 2026 numbered 1,236, up 19.5% year over year, and ransomware reports among them rose 76.8%.[^8]

### How Much of the AI Involvement Claim Is Confirmed?

Here, facts and speculation need to be separated.

- **Security vendor analyses (multiple):** Genians, Oasis Security, and S2W reported traces of ARTEX, a Chinese-language autonomous penetration testing tool, on servers believed to have been used in the attack. S2W said it also found a relay program connecting ARTEX to AI models. S2W added, however, that the authorities need to determine which parts of the data theft AI performed.[^5]
- **CrowdStrike (moderate confidence):** According to Reuters, CrowdStrike claimed the attackers used ARTEX and Anthropic's Claude Code. CrowdStrike itself stated that this assessment was made with "moderate confidence" and that it had not attributed the attack to a specific group.[^9]
- **Government:** The Financial Services Commission's October 2 press release described the incident only as a "cyberattack" and "intrusion attempts." As of October 14, the authorities were still investigating whether AI hacking was involved.[^2]

In short, "traces of an LLM-based attack automation tool were found on the attack infrastructure" is what several vendors reported. "AI carried out this attack" has not yet been confirmed.

Outside Korea, there is a clearer record. In November 2025, Anthropic reported that a group it assessed as Chinese state-sponsored had set up Claude Code as an autonomous intrusion agent, targeted about 30 organizations, and had AI perform 80–90% of the tactical work. These figures come from Anthropic's own analysis.[^10]

## 2. What Changed Is Not the Kind of Attack but Its Speed

Park Moon-beom, CPO of 78ResearchLab and a security expert, wrote this about the incident (quotes translated from Korean): the attack "bolted a 'turbo engine' called AI onto existing attack techniques to maximize efficiency and scale," and the real source of the alarm that practitioners feel is that the defensive paradigm did not erode over time but "collapsed in an instant."[^1]

The example he gives is striking. In the past, cyberattacks from China dropped noticeably during the Chinese Spring Festival and the Mid-Autumn Festival. Human attackers had days off, and in the meantime defenders gained time to analyze and respond. AI has no such days.

Put the table in Section 1 together with this observation, and a single picture emerges. The causes that government investigations confirmed or multiple outlets reported were all old problems: secret keys placed in source code (TVING, Coupang), a key left unchanged after an employee left (Coupang), an auxiliary lookup service with a reported authentication bypass (Shinhan Bank), and unapplied patches (regulatory inspection). When the financial regulators inspected 555 financial companies in October, 130 of them had weak basic controls, such as unapplied security patches, no 24-hour monitoring, and no multi-factor authentication.[^11] Indeed, some analyses argue that the core cause of this incident was not AI but flawed authorization checks in an externally exposed API.[^12]

I do not think these two interpretations conflict. **Rather than creating new holes, AI can find existing holes far faster than people can.** As in the case Anthropic reported, when AI agents take on most of the reconnaissance and intrusion work, the number of targets and attempts a single attacker can pursue at once goes up.[^10]

That attacks are getting faster also shows up in vulnerability statistics, independently of AI. In M-Trends 2026, Google Mandiant estimated the average time-to-exploit (the time from a vulnerability's disclosure to its actual exploitation) at about -7 days. A negative average means the data includes cases exploited before disclosure.[^13] VulnCheck counted 28.96% of vulnerabilities exploited in 2025 as exploited on or before the day of disclosure, up from 23.6% in 2024.[^14] Neither statistic shows that AI is the cause, and I could not verify Mandiant's methodology. But both sources point in the same direction: defenders have less and less room to start responding after a vulnerability is disclosed.

When the time attackers need to find a gap shrinks from days to hours, the metric that matters to defenders changes too. It becomes **the time from finding a gap to closing it**. TVING found a vulnerability in a 2024 penetration test but did not fix it, and that vulnerability led to the 2026 incident.[^4] The discovery happened, but the fix did not keep up.

## 3. Response Tied to Human Sequencing Struggles to Keep Up with This Speed

Traditional security response generally follows a human sequence. A vulnerability report comes in, the person in charge confirms it, a task goes to the development team, a developer schedules and makes the fix, and after review it ships with the regular release schedule. Each step is reasonable. The problem is the waiting time between steps. If the person in charge is on vacation, the development team is tied up with other work, or the release is scheduled for next month, the gap stays open the whole time.

Individual diligence does not solve this. As Park Moon-beom points out, attacks do not stop even on holidays, but each step of the defense is tied to people's working hours. His conclusion was to invest more people and equipment.[^1] I agree that this is necessary. But adding people alone does not remove the structural problem of waiting time, because even with more people, each step is still tied to people's working hours and the order of approvals.

One could object that existing CI/CD and emergency change procedures are enough. CI/CD automates building and deploying code that people write. Emergency change procedures cut approval steps. But in organizations where remediation is mostly manual, people still triage the problem, find the cause, write the fix, and produce evidence that the fix is correct. In such organizations, I think the waiting time in these upstream steps is the largest gap. Conversely, in organizations that already have mature patch automation and emergency response systems, the factory has correspondingly less to add.

## 4. The Pressure Is Already Moving

It is not only the speed of attacks. In 2026, pressure pushing toward the factory can be observed from three directions at once. Below, I separate facts, vendor claims, and forecasts.

### 4.1 Those Who Automated Discovery Now Name Remediation as the Bottleneck

In its May 2026 interim report on Project Glasswing, Anthropic said it had used AI to find vulnerabilities in open-source projects and reported about 530 of them to maintainers, but only 75 had been patched. It diagnosed the situation this way: "the bottleneck in fixing bugs like these is the human capacity to triage, report, and design and deploy patches for them."[^15] In October, it described triage and patching as "still mostly manual" and set automating them as its next goal.[^16] This is the vendor's own announcement. But Forrester forecast the same direction: "Discovery is now cheap. Remediation is where the value lives."[^17]

This is one vendor's observation, and the figure of 75 out of 530 alone does not show that the bottleneck has shifted across the whole industry. But if AI speeds up vulnerability discovery equally for attackers and defenders, I think the place where defenders can get ahead is in fixing what they find faster. And I think this is where the software factory fits in.

### 4.2 Regulators Are Shortening Remediation Deadlines and Lowering Barriers to Fast Patching

- **US (fact):** In June 2026, CISA issued BOD 26-04, requiring federal civilian agencies to remediate the most dangerous vulnerabilities in as little as three days. Its prioritization criteria include "whether large-scale automated attacks are possible."[^18]
- **EU (fact):** From September 11, 2026, under the Cyber Resilience Act (CRA), manufacturers must submit an early warning within 24 hours for actively exploited vulnerabilities. This is a reporting deadline, not a patching deadline.[^19] The European Central Bank (ECB) asked the roughly 110 banks it directly supervises to submit action plans for responding to AI-driven cyber threats by October 31, and patch management is among the focus areas.[^20]
- **Korea (fact):** In May 2026, the Financial Services Commission proposed temporarily relaxing network separation rules for one year at 49 large financial companies, limited to AI used for security purposes.[^21] In June, it decided to exempt from sanctions minor IT outages caused by AI security testing or by emergency security patches for vulnerabilities that the authorities had circulated.[^22] This reduces the sanction risk of outages caused by patching quickly. The scope of the exemption is narrow, however.
- **Korea (fact):** On October 14, after the financial-sector incident, Shin Jin-chang, Secretary General of the Financial Services Commission, said (translated from Korean) that the commission would "push ahead more carefully and with greater speed on institutional improvements, including relaxing network separation rules, to establish a security system in which 'AI attacks are defended with AI.'"[^23] The same article also carried experts' counterargument that it is inappropriate to link this incident directly to a network separation overhaul.
- **Korea (plan):** In its May draft plan for private-sector information security, the Ministry of Science and ICT said it would pilot high-performance AI models for automated vulnerability analysis and patch generation. I could not confirm the timeline or budget.[^24]

None of these measures requires "have agents fix the code and deploy it." But remediation deadlines are getting shorter, and the institutional barriers that blocked fast patching and security-purpose AI are coming down. I think this is a direction that remediation procedures tied to people's working hours will struggle to meet.

### 4.3 Tools Already Produce Fixes

- **DARPA AI Cyber Challenge (fact):** In the August 2025 finals, the teams' autonomous systems found 54 synthetic vulnerabilities and patched 43. The average patch took about 45 minutes and cost about $152 per task.[^25]
- **GitHub Copilot Autofix (vendor claim):** In public beta data, the median time to fix security alerts at PR time dropped from 1.5 hours manually to 28 minutes.[^26]
- **Google DeepMind CodeMender (vendor claim):** Over six months, it landed 72 security fixes in open-source projects. People reviewed every patch before submission.[^27]

### 4.4 Adoption Is Still Early

Adoption is still early. In an Ivanti survey of about 1,200 security practitioners in February 2026, 87% named agentic AI integration as a priority, but only 42% used AI for vulnerability remediation.[^28] The cases confirmed in Korea, such as KB Financial Group's AI penetration testing agent, also focus on inspection and detection,[^29] and in this research I found no Korean company that has said it "adopted a coding-agent-based development system because of security." Forrester forecast that regulators and insurers will require human verification and approval steps between AI's discovery and actual remediation.[^17]

These surveys do not explain why adoption is slow. But in Kai's CISO survey (secondary coverage), 52% of respondents named lack of trust in automated decisions as the biggest barrier.[^30] I think this trust problem actually pinpoints the design challenge of the software factory: a structure that fixes automatically, leaves evidence that the fix is correct, and has people approve risky changes. The following sections cover that structure.

## 5. What the Software Factory Reduces

A software factory is a development system in which AI agents repeatedly run the loop from task intake through implementation, verification, reporting, and improvement. This blog introduced the concept in a [September post](/en/posts/beyond-vibe-coding-software-factory/),[^31] and in a recent [four-part series](/en/posts/software-factory-best-practices-from-open-source/) I reverse-engineered 12 public repositories and confirmed 8 where a factory is actually running.[^32]

Translated into the language of security, the mechanisms observed in the series look like this.

- **Intake:** Issues, failed CI runs, and user reports automatically become tasks. Applied to security, vulnerability scanner results, penetration test reports, and security advisories become tasks without waiting for someone's schedule. But scanner results include false positives, so there must first be a step that classifies the scope of impact and severity and sets priorities.
- **Gates and evidence:** As seen in [Part 3](/en/posts/software-factory-evidence-before-fix/), mature factories require as evidence "a test that fails on the code before the fix and passes after it."[^33] Applied to a security fix, this means leaving a test showing that an authentication bypass succeeds before the fix and is blocked after it. That test then keeps checking, on every later change, that the same hole does not reopen.
- **Self-improvement:** The "failures into rules" loop from [Part 4](/en/posts/software-factory-failures-into-rules/) turns a failure that has happened once into an instruction or a check.[^34] Applied to security, after one incident of a key ending up in source code, you add a check that blocks commits containing keys at the gate. But as Part 4 showed, public records confirming that new rules actually worked were rare. For security rules, the loop is complete only with a step that periodically tests whether the check actually blocks what it should.

Automated fixes carry risks too. [Part 3](/en/posts/software-factory-evidence-before-fix/) included a case where a fix that a maintainer had checked and merged turned out to change intended behavior and was reverted before release (Astro).[^33] Security fixes can break business functionality, so you need to define in advance a verification step separate from the agent that made the fix, and the conditions for rolling back when something goes wrong.

What matters here is scope. What the factory reduces is **the time from finding a defect in software to fixing and deploying it**. The factory does not solve accounts stolen through phishing, a shortage of monitoring staff, or problems in network design. Revoking and reissuing exposed keys is also an operational task separate from code fixes, and fixing the code does not remove the risk of keys that are already exposed. But many of the causes in Section 1, namely the habit of putting secret keys in code, flawed authentication checks, and unfixed vulnerabilities, are problems whose recurrence can only be prevented by fixing the code, and they fall within this scope.

The effect must also be measured. OpenClaw's automated implementation worker, discussed in [Part 4](/en/posts/software-factory-failures-into-rules/), succeeded 52 times and failed 256 times in one week, and the project added a mechanism that stops automated implementation when the failure rate is high.[^34] You need to measure whether the time to fix actually went down, including the extra verification and review burden that automation added.

## 6. People Set the Rules, Machines Execute

The phrase "respond without human intervention" invites misunderstanding. What the series found was closer to the opposite. Of the 8 factories, OpenClaw was the only one where a bot merged into the main branch at volume. In the rest, final merges by people were mainly observed.[^32] Even OpenClaw, which entrusted merging to a bot, defined risk tiers by type of change and had people approve security policies and releases.[^35]

So I define what is needed this way: **a system in which people are not the bottleneck.** People define, as rules, what may be handled automatically. Machines execute within those rules, at night and on holidays. Work outside the rules, such as security policy changes or deployments that are hard to roll back, goes to people.

Keeping human approval does not mean the waiting time stays as it is. If, when a person presses the approve button, the triage, the fix, and evidence showing failure before the fix and success after it are already prepared, the person's work can shrink from the whole remediation task to a judgment that reviews the prepared evidence. How much it shrinks has to be measured in each organization. For urgent security fixes, deciding in advance who is on call for this judgment and how to reach them is part of the factory's design.

This structure also connects to Park Moon-beom's emphasized conclusion that "the experience of practitioners must be reflected in the system."[^1] Practitioners are the first to notice the evasion patterns and signs of compromise that AI produces. If their judgment stays only in reports or meeting minutes, the next attack will again be handled at human speed. If instead that judgment becomes the factory's rules and checks, it executes even while the experts sleep. The factory does not replace practitioners. It turns their judgment into a form that executes without rest.

## 7. Without Securing the Factory Itself, Threats Increase

To argue for the factory on security grounds, I also have to address the risk on the other side. An agent with write permissions is itself a target. Typical examples are prompt injection, in which an attacker hides instructions in an issue or PR body to manipulate the agent, and theft of the tokens the agent uses. If CrowdStrike's assessment is correct, the attackers in this financial-sector incident used the same kind of coding agent that developers use.[^9] The tool is neutral. The mechanisms around it determine the outcome.

The projects observed in the series had concrete mechanisms against this risk.[^35]

- **Define risk tiers in a file.** Separate documentation changes, ordinary code, sensitive paths, security policies, and releases, and enforce human approval for high-risk tiers through CODEOWNERS and security guards. (OpenClaw)
- **Do not give agents write tokens.** Run agents that analyze and review in read-only mode, and perform writes only in workflow code in narrow, dedicated steps. Read review rules from the target branch, not the PR's branch, so a PR cannot change its own review rules. (Astro)
- **Let people stop it at any time.** Start auto-merge as opt-in, and provide a stop command that anyone with write permissions can use. (OpenClaw)

For organizations such as financial institutions that are required to enforce strict change approval and separation of duties, these mechanisms are actually a starting point. Risk tiers let you explicitly distinguish changes that truly require human approval from those that do not. The goal is to keep human approval where it is really needed and cut the waiting time in the remaining steps. Each organization must separately review compliance with specific rules against its supervisory regulations.

## Conclusion

As Park Moon-beom observed, attackers used to have days off too, and defenders used that window to buy time to analyze and fix. I believe the limits of a system that depends on human response speed are growing. Whether AI was used in the Korean incidents is still under investigation, but outside Korea there are already reports of AI agents performing most of an attack's work, and by VulnCheck's count, the share of vulnerabilities exploited on or before the day of disclosure rose from 2024 to 2025.

In this environment, "we haven't had an incident" is no basis for safety, because there is no basis for assuming the existing approach will keep guaranteeing safety. We are living in an era that demands adaptation.

I believe this is the direction of that adaptation. The time from the moment a gap is found to the moment it is closed must be decoupled from people's working hours. People set the rules, machines execute within those rules without rest, and failures become rules again. And people design and supervise the mechanisms around those machines. That is the software factory. Remediation deadlines are getting shorter, and attacks never rest. I believe security will become a major reason that accelerates the adoption of the software factory.

---

[^1]: Park Moon-beom, Facebook post (2026-10, in Korean): https://www.facebook.com/moonbeom.park/posts/pfbid025RJ5FP92jpcRq51PZvxoY9pzMNoamgatBgeqJMr8K5qvENzh37J8DaE6zK2mvtHgl
[^2]: Financial Services Commission press release (2026-10-02): https://fsc.go.kr/no010101/87869 , Money Today (2026-10-14): https://mt.co.kr/finance/2026/10/14/2026101415210579063
[^3]: Herald Economy (2026-10-06): https://www.heraldk.com/article/2026100615510457182 , SBS Biz: https://biz.sbs.co.kr/amp/article/20000338817
[^4]: Money Today (2026-09-03), announcement by the Ministry of Science and ICT public-private joint investigation team: https://www.mt.co.kr/article/2026090313590280077 , iNews24: https://www.inews24.com/view/2001755
[^5]: Newsis (2026-10-03): https://www.newsis.com/view/NISX20261002_0003813064 , ZDNet Korea (2026-10-04): https://zdnet.co.kr/view/?no=20261004170058 , The Financial News English edition (2026-10-08): https://en.fnnews.com/news/202610081452408589
[^6]: Herald Economy (2026-10-01): https://www.heraldk.com/article/2026100104545469433 , SBS Biz (2026-10-01): https://biz.sbs.co.kr/amp/article/20000337764
[^7]: Byline Network (2026-02-10): https://byline.network/2026/02/10-611/ , Money Today (2026-06-11): https://www.mt.co.kr/article/2026061109363411664
[^8]: DailySecu: https://www.dailysecu.com/news/articleView.html?idxno=207881
[^9]: iTnews/Reuters (2026-10-08): https://www.itnews.com.au/news/crowdstrike-says-china-based-suspect-used-ai-tools-in-south-korean-bank-hacks-629513
[^10]: Anthropic, "Disrupting the first reported AI-orchestrated cyber espionage campaign" (2025-11): https://assets.anthropic.com/m/ec212e6566a0d47/original/Disrupting-the-first-reported-AI-orchestrated-cyber-espionage-campaign.pdf
[^11]: Money Today (2026-10-14), results of the financial regulators' inspection: https://mt.co.kr/finance/2026/10/14/2026101415210579063 , Newspim (2026-10-14): https://www.newspim.com/news/view/20261014001149
[^12]: AI Insight Journal (2026-10-03): https://aiinsightjournal.com/2026/10/03/7372/
[^13]: Google Cloud, M-Trends 2026: https://cloud.google.com/blog/topics/threat-intelligence/m-trends-2026
[^14]: Infosecurity Magazine, coverage of VulnCheck "State of Exploitation 2026": https://www.infosecurity-magazine.com/news/zeroday-exploits-surge-vulncheck
[^15]: Anthropic, "Project Glasswing: An initial update" (2026-05-22): https://www.anthropic.com/research/glasswing-initial-update
[^16]: Anthropic, "Introducing the Anthropic Cyber Mission" (2026-10-08): https://www.anthropic.com/news/anthropic-cyber-mission
[^17]: Forrester, "Project Glasswing: The 10 Consequences Nobody's Writing About Yet" (2026-04-10): https://www.forrester.com/blogs/project-glasswing-the-10-consequences-nobodys-writing-about-yet/
[^18]: BleepingComputer, coverage of CISA BOD 26-04 (2026-06-11): https://bleepingcomputer.com/news/security/cisa-tells-govt-agencies-to-patch-critical-exploited-flaws-in-3-days
[^19]: Jones Day (2026-07): https://www.jonesday.com/en/insights/2026/07/eu-cyber-resilience-act-24hour-reporting-duties-start-september-11-2026 , European Commission: https://digital-strategy.ec.europa.eu/en/policies/cra-reporting
[^20]: Euronews (2026-07-07): https://www.euronews.com/2026/07/07/ecb-tells-europes-biggest-banks-to-prepare-for-ai-powered-cyber-threats
[^21]: Nocut News (2026-05-24): https://www.nocutnews.co.kr/news/6521713 , Aju Business Daily: https://www.ajunews.com/view/20260524102548536
[^22]: Financial Services Commission press release: https://www.fsc.go.kr/po010107/87240 , Herald Economy: https://www.heraldk.com/article/2026070118162383330
[^23]: Kuki News (2026-10-15): https://www.kukinews.com/article/view/kuk202610140218
[^24]: Newsis (2026-05-29): https://mobile.newsis.com/view/NISX20260529_0003648705
[^25]: DARPA, AIxCC results announcement: https://darpa.mil/news/2025/aixcc-results
[^26]: GitHub Blog, "Secure code more than three times faster with Copilot Autofix": https://github.blog/news-insights/product-news/secure-code-more-than-three-times-faster-with-copilot-autofix/
[^27]: BetaNews (2025-10-06): https://betanews.com/2025/10/06/google-builds-new-ai-agent-to-improve-code-security
[^28]: Ivanti press release (2026-02): https://www.ivanti.com/company/press-releases/2026/adopting-agentic-ai-is-a-priority-for-87-of-security-teams-according-to-ivanti-s-research
[^29]: Herald Economy (2026-05-25): https://www.heraldk.com/article/2026052516484966702
[^30]: Webull (coverage of Kai's CISO survey, secondary source): https://www.webull.com/news/15310721290675201
[^31]: Beyond Vibe Coding, Toward the Software Factory: https://roboco.io/en/posts/beyond-vibe-coding-software-factory/
[^32]: Software Factory Best Practices from Open-Source Projects (1/4): https://roboco.io/en/posts/software-factory-best-practices-from-open-source/
[^33]: Software Factory Best Practices from Open-Source Projects (3/4): https://roboco.io/en/posts/software-factory-evidence-before-fix/
[^34]: Software Factory Best Practices from Open-Source Projects (4/4): https://roboco.io/en/posts/software-factory-failures-into-rules/
[^35]: Software Factory Best Practices from Open-Source Projects (2/4): https://roboco.io/en/posts/software-factory-who-merges/
