---
title: "In the Age of Vibe Coding, the Break-Even Point for Multi-Cloud DR Has Dropped"
date: 2026-10-19T09:00:00+09:00
draft: false
toc: false
images:
tags:
  - vibe-coding
  - multi-cloud
  - disaster-recovery
  - chaos-engineering
  - cloud-architecture
---

> The conventional wisdom that multi-cloud is too complex still holds for active-active operations. But for the DR tier, where you keep only backups and the means to recover in another cloud, the cost structure has changed. Vibe coding reduces the cost of building DR in the first place, and the software factory reduces the cost of keeping that DR working and verified over time. Together, these two costs have made up most of what DR costs.

{{< figure src="/posts/images/Dohyun.png" title="Dohyun Jung - Principal Consultant, ROBOCO" style=".author-image">}}

---

## Games Are Already Going Multi-Platform

Over the past one to two years, it has become common in the games industry for exclusives to ship on other platforms. Microsoft released Forza Horizon 5, formerly an Xbox exclusive, on PS5 in April 2025, and the game ranked second in US sales that month.[^1] The same year, Gears of War: Reloaded became the first game in the series to come to PS5, and Indiana Jones and the Great Circle launched on Switch 2 in May 2026.[^2] It also goes the other way. Sony's Helldivers 2 launched on Xbox in August 2025, and according to estimates from analytics firm Alinea, its first-six-day sales on Xbox (about 926,000 units) exceeded the PS5 version's sales over the same period in 2024 (about 633,000 units).[^3]

The main motivation behind this trend is revenue diversification. As development costs keep rising, it is hard to recoup the investment from a single platform's user base. The maturity of general-purpose engines such as Unreal and Unity, which absorb much of the difference between platforms, is a long-standing factor as well.

I believe another factor is now being added: vibe coding, the practice of delegating implementation to AI coding agents, is lowering porting costs. This, however, is an interpretation, not an established fact. As of October 2026, I could not find quantitative data showing how much AI has reduced the cost of porting games. In the GDC 2026 survey, 36% of respondents said they use generative AI at work, and code assistance accounted for 47% of those uses, but the share of respondents who said generative AI is harmful to the industry also rose to 52%.[^4]

The quantitative evidence lies not in games but in code migration for general software. Amazon said it saved 4,500 developer-years with AI tools while upgrading about 30,000 applications to Java 17. This figure is Amazon's own estimate.[^5] In a migration of 32-bit IDs to 64-bit in Google's Ads system, AI authored 80% of the code changes that landed, and engineers estimated the total time spent dropped by about 50%. The authors also noted, however, that in most cases humans had to revert some of the model's changes.[^6] Porting to another platform is essentially "reimplementing the same behavior against a different environment's APIs and constraints," so these studies can be read as a signal that the same kind of change could happen in game porting. I covered concrete ways to migrate legacy code with vibe coding in the [legacy modernization series](/en/posts/legacy-cpp-vibe-coding-modernization/).[^7]

## Will the Same Thing Happen in the Cloud?

If porting cost was what held games back from supporting multiple platforms, the complexity of multi-cloud has played the same role in the cloud. And the risk of depending on a single cloud is not theoretical.

Exactly one year ago, from the night of October 19 to the afternoon of October 20, 2025 (US Pacific Time), a large-scale outage hit the AWS us-east-1 region. According to AWS's post-event summary, a latent race condition in DynamoDB's DNS management automation left the regional endpoint's DNS record empty. The outage cascaded into EC2 instance launches, Network Load Balancer, Lambda, STS, and IAM console sign-in.[^8] On June 12, 2025, code deployed to Google Cloud's Service Control without error handling or a feature flag hit globally replicated policy data and went into a crash loop, and the outage lasted about seven hours.[^9]

The two incidents have something in common. The failures did not stay within a single service or availability zone; they spread along shared dependencies inside the provider, such as authentication, endpoints, and policy. Splitting workloads across regions within the same cloud does not separate these shared dependencies.

Meanwhile, in Flexera's 2026 survey, 88% of organizations said they use multi-cloud.[^10] But this figure mostly means "using different clouds for different workloads." That is not the same as being designed to recover a service in another cloud when one cloud goes down.

## Breaking Down Why Multi-Cloud Was Hard, Cost by Cost

The conventional wisdom that "multi-cloud greatly increases development and operational complexity" bundles several costs into one phrase. To assess the effect of AI accurately, we need to break these costs down by item, and we also need to split the effect of AI in two.

The first is the effect of vibe coding. Vibe coding is a way of working in which a person completes a single piece of work through conversation with an AI coding agent. What it reduces is **one-time build cost**. The second is the effect of the software factory. As I explained in an [earlier post](/en/posts/beyond-vibe-coding-software-factory/), a software factory is an operating model in which people set goals, constraints, and the scope of delegation, and multiple automated development streams then carry the work forward continuously, from organizing requirements through implementation, verification, and reporting.[^15] What it reduces is **recurring maintenance and verification cost**. The two effects also differ in timing. Vibe coding is something teams can use in the field today, while the software factory is a direction organizations can now begin to build toward.

The table below assesses each cost against both effects. These assessments are interpretations based on my consulting experience, not measured results.

| Cost item | Description | Vibe coding (build) | Software factory (maintain and verify) |
|---|---|---|---|
| Writing infrastructure code twice | Writing and maintaining separate IaC for each cloud's resource model | Initial writing cost greatly reduced | Cost of keeping up with primary cloud changes greatly reduced |
| Design and review | Building service mapping tables, designing data replication, designing failover procedures | Greatly reduced | Cost of re-reviewing when changes occur partially reduced |
| Runbooks and test code | Recovery procedures, restore scripts, verification tests | Drafting cost greatly reduced | Cost of updating them for infrastructure changes greatly reduced |
| Restore drills | Regularly restoring from backups and measuring and reporting actual RTO/RPO | Cost of building the drill pipeline reduced | Cost of repeated runs and reporting greatly reduced |
| Maintaining an abstraction layer | Maintaining a common interface that hides the differences between two clouds | Partially reduced | Partially reduced |
| Data transfer costs | Egress fees from cross-cloud replication | Not reduced | Not reduced |
| Security and IAM model differences | Operating permission models, key management, and audit logging separately for each cloud | Cost of writing configuration partially reduced | Cost of detecting configuration drift partially reduced; operational responsibility remains |
| Operations staff and on-call | Hiring people who understand both clouds, incident response structure | Not reduced | Detection and first-line reporting partially reduced; failover decision authority stays with people |
| Diluted usage discounts | Splitting usage across two clouds makes it harder to meet the conditions for commitment and volume discounts | Not reduced | Not reduced |

As the table shows, the two effects target different costs. Vibe coding reduces the cost of creating code and documents in the first place, while the software factory reduces the cost of keeping that code and those documents correct and confirming that they actually work. Neither reduces data transfer fees or discount conditions.

The last item deserves particular attention. Cloud provider discounts are designed to favor concentrating usage in one place. There are products that grant discounts in exchange for committing to a certain level of usage, such as AWS Savings Plans and Reserved Instances or Google Cloud's Committed Use Discounts, and large customers sometimes sign separate discount agreements with a provider in exchange for an annual spend commitment. If you split day-to-day workloads across two clouds, usage in each cloud shrinks, making such commitments harder to sign or leaving you in a lower discount tier. No amount of well-written code reduces this cost.

A conclusion follows from this breakdown. Active-active configurations, which run a service in two clouds at once, remain hard because the remaining costs, namely data transfer, ongoing operations, and diluted discounts, make up most of their cost. By contrast, for DR configurations that keep only backups and the means to recover in another cloud, most of the cost has been design and implementation work plus recurring verification work. Those are exactly the costs that vibe coding and the software factory each reduce. On top of that, in a DR configuration your day-to-day compute usage stays concentrated in the primary cloud, so you keep the primary cloud's discounts as well. The ongoing costs in the secondary cloud are mainly backup storage and transfer fees. This is why I see the break-even point dropping first in the DR tier, not in multi-cloud as a whole.

## A Multi-Cloud DR Strategy Matrix

AWS divides DR strategies into four tiers: backup and restore, pilot light, warm standby, and multi-site active-active. It explains that the lower you push RTO (the maximum acceptable delay between the interruption of service and restoration of service) and RPO (the maximum acceptable amount of time since the last data recovery point), the more you spend on resources and operational complexity.[^11] The original article covers multi-region configurations within AWS, but the same framework can be applied to a "primary cloud and secondary cloud." The table below does exactly that. The AWS article does not give RTO/RPO figures for each tier, so the table shows only relative levels.

| Strategy | What you keep in the secondary cloud | RTO / RPO | Ongoing cost | Build work vibe coding reduces |
|---|---|---|---|---|
| Backup and restore | Data backups (object storage replication, DB snapshots and dumps) and IaC code for the secondary cloud | Longest / as long as the backup interval | Lowest (storage and transfer fees) | Writing IaC for the secondary cloud, restore scripts, restore verification tests |
| Pilot light | A continuously replicated database plus minimal networking and core infrastructure; compute stays off | Long / short | Low | Setting up cross-cloud DB replication, automating compute startup |
| Warm standby | The full service running continuously at reduced capacity | Short / short | High | Keeping deployment pipelines in sync across both clouds, automating capacity scale-out |
| Multi-site active-active | A production environment at the same scale as the primary cloud | Shortest / near zero | Highest | Only partially reduced; data consistency and ongoing operational costs remain |

What I find most notable in this matrix is the first row. Keeping only backups in another cloud has a low ongoing cost, yet it protects against risks that multi-region configurations within the same cloud cannot. One is the kind of outage we saw earlier, which spreads along shared dependencies inside the provider. Another is an account being suspended or compromised, with even the backups in that same account deleted. No matter how many copies of your backups you replicate within the same cloud, you cannot prevent incidents like these.

In the past, what made people hesitate over this configuration was not the backups themselves but the next step. Even with backup data in another cloud, actually recovering requires building networking, compute, databases, and permissions in the secondary cloud from scratch, and that procedure has to be prepared as code in advance. This preparation is where vibe coding cuts the most effort. Writing IaC for the secondary cloud based on the primary cloud's IaC, mapping services between clouds, and writing restore scripts are all the same kind of work as code migration.

The criterion for choosing a strategy is each service's RTO/RPO target. Not every service needs the same tier. It is realistic to start most services with backup and restore and raise only the few services directly tied to revenue or regulation to pilot light or warm standby. Vibe coding also lowers the cost of implementing different tiers for different services.

## The Real Cost Comes After the Build: Continuous Verification with a Software Factory

The most common failure of a DR plan is not failing to build it but failing to confirm that it actually works. In the field, I often see backups that have never been restored, or runbooks that no longer match the procedure because the infrastructure changed in the meantime. This problem gets bigger with multi-cloud DR, because changes in the primary cloud are not automatically reflected in the recovery code for the secondary cloud.

Chaos engineering is the answer to this problem. AWS lays out its principles as forming hypotheses based on real-world conditions, limiting the blast radius, preparing rollback mechanisms, and continuously injecting faults within CI/CD, and it recommends a root-cause analysis whenever unexpected behavior is found. AWS Fault Injection Service (FIS) is a managed service that injects faults such as instance termination, forced failover, latency, and packet loss into resources like EC2, ECS, EKS, and RDS.[^12] As that article puts it, "The ultimate goal of Chaos Engineering is not about breaking production systems."

Applied to multi-cloud DR, the verification system splits into two parts. First, on the primary cloud side, use a tool like FIS to simulate a situation where "the primary environment is unavailable," and confirm that detection and the failover decision happen as expected. Second, on the secondary cloud side, regularly restore the service from backups for real, and measure how long the restore took and the point in time of the last recovered data. Those measurements are your actual RTO and RPO. Because FIS targets AWS resources, the second part has to be built separately as a restore drill pipeline.

Building this system in the first place is well within reach of vibe coding. Experiment scenarios, restore pipelines, and checks that compare results against targets are all code you write once. Keeping the system valid over time is a different kind of work, however. The primary cloud's infrastructure changes every week, and each time, the secondary cloud's recovery code, runbooks, and drill scenarios have to be brought back in line. If a person has to instruct an agent to do this every time, updates slip during busy periods and DR reverts to a plan that exists only on paper.

This recurring work is where the software factory comes in. For example, you could run a flow like this continuously. When an IaC change is merged in the primary cloud, an automated development stream identifies the changes needed in the secondary cloud's recovery code and drafts a fix. The fix is applied only after it passes predefined verification. Restore drills run on a set schedule, and the measured RTO/RPO is compared against targets. If results miss the targets or unexpected behavior is found, the stream summarizes the cause, the impact, and the remaining risks and reports them to a person.

There is one thing people must keep fixed. Each service's RTO/RPO target is a success criterion set by people, and the factory must not be able to change it on its own. If it could change the success criteria too, you could no longer trust the judgment that a drill passed. This is the same reason I wrote in the earlier post that a software factory needs a good reporting system.

That is why I think the bigger change in multi-cloud DR lies less in lower build costs than in lower costs for continuous verification. Vibe coding has already brought build costs down. Once a software factory brings verification costs down as well, you can shorten the drill cycle from quarterly to weekly and catch gaps between the plan and reality sooner.

## Limitations: What Vibe Coding and the Software Factory Do Not Solve

This argument has clear limitations.

First, data transfer costs remain. In 2024, Google, AWS, and Azure each announced egress fee waivers, but these waivers apply only when you leave that cloud entirely. For example, AWS requires you to move all your data within 60 days, and Azure requires you to cancel your subscription.[^13] Ongoing DR replication therefore keeps incurring transfer fees. You need to calculate this cost first when deciding what to back up and how often.

Second, regulation does not require multi-cloud. The EU's DORA, in effect since January 2025, requires financial institutions to have exit strategies for critical ICT services and to manage concentration risk, but it does not mandate multi-cloud.[^14] Regulation can prompt a review, but the basis for any configuration should be each organization's RTO/RPO targets.

Third, human judgment does not go away. Setting RTO/RPO targets for each service, the authority and criteria for deciding whether to switch to the secondary cloud during an incident, and how to handle gaps found in drills all still have to be decided by the organization. Whether recovery code was written through vibe coding or updated by a software factory, people must set the review criteria and the code must be validated through drills, just like any other code.

## Conclusion: Start by Recalculating the Economics of the DR Tier

The conclusion of this post is not "go multi-cloud." It is that we should stop accepting the conventional wisdom that multi-cloud is hard as a single lump, and recalculate it cost by cost. Broken down that way, the DR tier is where the costs AI reduces make up the largest share. Vibe coding lowers the cost of building DR, and the software factory lowers the cost of keeping that DR working. In particular, keeping only backups in another cloud lets you keep day-to-day usage concentrated in the primary cloud, preserving your discounts, while still protecting against the risk of being tied to a single provider.

Just as the games industry is moving to more platforms as porting costs fall, cloud architectures can now prepare for a wider range of failures as verification costs fall. The starting point is simple: set RTO/RPO targets for each service, keep backups of your single most important service in another cloud, and actually restore from those backups. How far the time measured in your first restore drill differs from the plan becomes the basis for your next investment decision.

---

[^1]: Push Square, "PS5 ports award Microsoft's Forza Horizon 5, Indiana Jones huge boosts" (2025-05): https://www.pushsquare.com/news/2025/05/apr-2025-usa-sales-ps5-ports-award-microsofts-forza-horizon-5-indiana-jones-huge-boosts
[^2]: Nintendo Life, "Xbox's latest multiplatform release has been announced" (2025-05): https://www.nintendolife.com/news/2025/05/xboxs-latest-multiplatform-release-has-been-announced / Gematsu, "Indiana Jones and the Great Circle for Switch 2 launches May 12" (2026-02): https://www.gematsu.com/2026/02/indiana-jones-and-the-great-circle-for-switch-2-launches-may-12
[^3]: Notebookcheck, report on estimated Helldivers 2 Xbox sales (2025-09): https://www.notebookcheck.net/Helldivers-2-has-reportedly-sold-nearly-1-million-units-on-Xbox-in-just-6-days-eclipsing-its-PlayStation-launch.1105598.0.html
[^4]: GDC 2026 State of the Game Industry press release (2026-01-29): https://www.businesswire.com/news/home/20260129438528/en/
[^5]: AWS DevOps Blog, "Amazon Q Developer just reached a $260 million dollar milestone" (2024-08): https://aws.amazon.com/blogs/devops/amazon-q-developer-just-reached-a-260-million-dollar-milestone
[^6]: Google Research, "Accelerating code migrations with AI" (2025-01): https://research.google/blog/accelerating-code-migrations-with-ai/
[^7]: Modernizing Legacy Code with Vibe Coding (1/2): https://roboco.io/en/posts/legacy-cpp-vibe-coding-modernization/
[^8]: AWS, "Summary of the Amazon DynamoDB Service Disruption in the Northern Virginia (US-EAST-1) Region": https://aws.amazon.com/message/101925/
[^9]: Google Cloud Service Health, 2025-06-12 incident report: https://status.cloud.google.com/incidents/ow5i3PPK96RduMcb1SsW
[^10]: Flexera 2026 State of the Cloud press release (2026-03-18, German): https://www.flexera.com/de/about-us/press-center/cloud-entwickelt-sich-vom-kostenfaktor-zum-werttreiber
[^11]: AWS Architecture Blog, "Disaster Recovery (DR) Architecture on AWS, Part I: Strategies for Recovery in the Cloud" (2021-04-05): https://aws.amazon.com/blogs/architecture/disaster-recovery-dr-architecture-on-aws-part-i-strategies-for-recovery-in-the-cloud/
[^12]: AWS Architecture Blog, "Chaos Engineering in the Cloud" (2022-10-12): https://aws.amazon.com/blogs/architecture/chaos-engineering-in-the-cloud/
[^13]: The Register, "Microsoft ends Azure egress fees" (2024-03-13): https://www.theregister.com/2024/03/13/microsoft_ends_azure_egress_fees/ / InfoQ, "AWS removes egress fees" (2024-03): https://www.infoq.com/news/2024/03/aws-egress-fees/
[^14]: FAST LTA, "DORA: ICT-Drittanbieter" (2026-02-24): https://www.fast-lta.de/en/blog/dora-ict-drittanbieter
[^15]: Beyond Vibe Coding, Toward the Software Factory: https://roboco.io/en/posts/beyond-vibe-coding-software-factory/
