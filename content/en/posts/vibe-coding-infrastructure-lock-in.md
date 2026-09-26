---
title: "Who Dared Cry Lock-In? - Infrastructure Dependence in the Vibe Coding Era"
date: 2026-09-26T10:00:00+09:00
draft: false
toc: false
images:
tags:
  - vibe-coding
  - cloud
  - infrastructure
  - vendor-lock-in
---

> “Who dared cry lock-in?”

{{< figure src="/posts/images/Dohyun.png" title="Dohyun Jung - Principal Consultant, ROBOCO" style=".author-image">}}

---

Plenty of people still prefer on-premises infrastructure in 2026. I understand the appeal of handling the machines and controlling every layer yourself. Latency, connections to existing equipment, and regulatory requirements can also make a self-managed environment necessary. But I find “we cannot use the cloud because it creates lock-in” hard to accept. **Vibe coding has greatly reduced the cost of moving between clouds or back on-premises. The cost of remaining tied to facilities, equipment, and specialist operators has not gone away.** Which choice creates the deeper dependency?

## TL;DR

- Vibe coding has already greatly reduced the labor of cloud migration. I expect better models and agents to reduce it further.
- On-premises infrastructure can create a much heavier dependency: property for a data center, facilities, equipment, and the people needed to operate it.
- Running Kubernetes in the cloud removes the need for your own data center, but still requires specialist operators. Hiring them creates another kind of dependency.
- As GPU computing and LLM services change quickly, the cloud lets teams try new technology without first buying hardware, lowering the barrier to advanced tools.
- I expect serverless and other cloud-native architectures once avoided for their implementation and testing complexity to be chosen more often as vibe coding becomes the new normal.
- ROBOCO proposes updating documentation and tests, migrating smaller services first, checking success against those tests and documents, then turning the proven process into agent rules and skills.

## 1. Redefining lock-in

Vendor lock-in usually means becoming deeply dependent on one cloud provider's managed services and APIs. Replacing that provider requires changes to your application and data. NIST describes portability in terms of moving applications and data to another environment at an **acceptable cost**.[^1]

“Cost” is the key word. The question is not simply whether a service is proprietary. It is what you would have to redo, and at what cost, if you chose to leave. Alongside changes to cloud APIs, the ledger should include hardware depreciation, equipment replacement, network contracts, operating procedures, and staff.

## 2. Migration costs have fallen and will keep falling

Entering the cloud used to be expensive in itself. Teams had to learn new services, rewrite infrastructure configuration, change SDK calls, and rebuild tests and deployment procedures. It was reasonable to worry that optimizing for one cloud would make a later exit costly.

Today, AI agents can locate service integrations, adapt infrastructure code to another environment, and change application calls and tests together. AWS also documents agent-based tools for transforming infrastructure, applications, and code.[^2] Work that once required people to find and edit files for days can be completed much faster with an agent. **The labor cost of migration has already fallen sharply.**

The change will not stop here. As models understand longer codebases and service relationships, and agents carry changes through testing and recovery more reliably, the human time needed for migration should keep shrinking. In my view, organizations that have made vibe coding part of their workflow will see migration work become hard to compare with the old approach. The size of the reduction differs by system, but the direction is clear. If a cloud-native managed service makes today's product simpler and faster, a vague fear of a future migration is becoming a weaker reason to avoid it.

## 3. The migration costs that remain

Even when an agent changes the code, the data still has to move. Database features and schemas may behave differently on another engine. AWS's schema conversion tooling explicitly identifies objects that cannot be converted automatically.[^3] Teams must plan downtime, parallel operation, and rollback, then recheck security, access, and regulatory requirements. Google Cloud's migration guidance treats validation and cost estimation as separate tasks.[^4]

Vibe coding can help here too. An agent can help draft schema conversions, data comparison scripts, validation scenarios, and cutover and recovery procedures. **The human labor involved in moving, validating, and switching data can be far smaller than before, and should continue to fall.** What remains includes actual transfer time and charges, the risk of downtime, and responsibility for checking the outcome. A small service and a large transactional database that must move without downtime are different problems, so no single cost estimate fits every system. But the work that remains should not obscure the reduction that has already happened.

## 4. Does owning servers remove lock-in?

On-premises infrastructure may reduce your dependence on a cloud provider's contract. In its place come long-term commitments to buildings, power and cooling, servers and network equipment, replacement cycles, and maintenance agreements. If you run your own production Kubernetes cluster, you **must secure specialist operators** to keep availability, certificates, nodes, security, incident response, and upgrades working. Kubernetes' production documentation sets out those responsibilities.[^5]

If you hire them directly, you must handle recruiting, on-call coverage, training, knowledge transfer, and vacancies. When critical operational knowledge sits with a few people, the organization depends on them. Outsourcing or managed Kubernetes can change the scope of that responsibility, but it does not remove the need for operational expertise. **Portable containers do not automatically make an organization portable. The continuing need to retain specialist staff is a form of employment lock-in.**

Owning hardware also carries a growing opportunity cost. GPU-based high-performance computing and LLM services are changing quickly. A purchased server ties you to its generation and replacement cycle. In the cloud, teams can try different GPU instances and newly available models through service catalogs.[^6][^7][^8] Even a small team can access advanced technology without a large upfront hardware purchase. Region availability, quotas, and usage charges still matter, but **lowering the barrier to new technology** is another advantage of the cloud.

## 5. Car sharing and car ownership

Switching between car-sharing services can be inconvenient. You need to check prices and coverage again. Yet that choice carries a different weight from having already bought a car. Ownership starts depreciation. A better car may appear, or the one you own may stop fitting your needs, but changing it takes time and money. Depending on the scale of use, you may also need parking, maintenance, or a driver.

Cloud services and private data centers have a similar distinction. The useful question is not whether you rent or own. It is **the total cost of changing course**. Better models and agents can keep reducing the cost of rebuilding software. Replacing equipment you already own and an operations team you have built is not as easy.

## 6. Rehearse an exit instead of guessing

If cloud lock-in concerns you, try a small migration instead of avoiding every cloud-native feature. Choose one important service and use an agent to run it in another cloud or in your own environment. Record the time spent changing code and infrastructure configuration, the time spent transferring and validating data, added charges, and work still done by hand. Test the path back as well.

This turns “we might be locked in” into a list of tasks and actual costs. Organizations whose regulatory or contractual requirements make cloud use difficult must respect those constraints first. But a team using vibe coding need not abandon a useful cloud service solely because of an untested fear that it may be unable to leave later.

## 7. ROBOCO's proposed vibe coding migration process

Rather than hand an entire migration to an agent in one step, first establish a shared understanding of the current system and a way to verify the result. ROBOCO proposes this sequence:

1. **Analyze the current system and update its documentation.** Read the source code and existing documents together to identify dependencies between services, data flows, deployment methods, and operating procedures. Correct descriptions that no longer match the code so people and agents work from the same picture.
2. **Repair or add tests.** Use UI, integration (IT), and end-to-end (E2E) tests to capture current behavior. Fill coverage gaps so the team can check that user journeys and service integrations still work after migration.
3. **Plan with an agent and start with smaller services.** Include each service's importance, size, dependencies, and rollback path in the plan. When there are several services, begin with one that is relatively small and less critical, and set an order for larger and more important services.
4. **Verify success against the tests and documentation.** Run the UI, integration, and E2E tests prepared before migration in the new environment. Compare actual behavior with the documented data flows, service integrations, deployment, and operating procedures, and fix any gaps. Passing tests and matching the documented expected behavior are the criteria for moving on to the next service.
5. **Turn a successful process into rules and skills.** Once the first service meets those criteria and remains stable after migration, record the repeatable steps in planning, code changes, testing, deployment, and verification. Package them as agent rules or skills to repeat mechanically for the next service, while a responsible person reviews exceptions and gives final approval.

The key is to make the first success a reusable process rather than a one-off experience. As the team stops relearning the same migration steps, later services become faster to move.

---

## Conclusion

The cost that vibe coding lowers extends beyond the initial implementation. By updating documentation and tests, moving a small service, verifying the result, and repeating the proven steps as rules and skills, a team can establish its ability to leave through experience. Data transfer and regulatory review remain, but better models and agents should keep reducing the time spent implementing and verifying a migration.

The lock-in calculation now needs to include cloud APIs, equipment investment, and the people required to operate Kubernetes. It should also count the opportunity to try rapidly changing GPUs and LLM services without buying hardware. It makes sense to choose the architecture that best serves the current product and keep testing the ability to move when needed. I expect serverless and other cloud-native architectures that teams once hesitated to choose because implementation and testing were difficult to be adopted more often as vibe coding becomes the new normal.

---

[^1]: NIST, *Cloud Computing Standards Roadmap*, on cloud portability and interoperability: https://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.500-291r2.pdf
[^2]: AWS, *AWS Transform Documentation*: https://docs.aws.amazon.com/transform/
[^3]: AWS Database Migration Service, schema conversion assessment reports: https://docs.aws.amazon.com/dms/latest/userguide/assessment-reports.html
[^4]: Google Cloud, best practices for validating a migration plan: https://docs.cloud.google.com/architecture/migration-to-google-cloud-best-practices
[^5]: Kubernetes, production environment considerations: https://kubernetes.io/docs/setup/production-environment/
[^6]: AWS, accelerated computing options among Amazon EC2 instance types: https://docs.aws.amazon.com/ec2/latest/instancetypes/instance-types.html
[^7]: AWS, Amazon Bedrock model catalog: https://docs.aws.amazon.com/bedrock/latest/userguide/model-cards.html
[^8]: Google Cloud, overview of Vertex AI Model Garden: https://cloud.google.com/vertex-ai/generative-ai/docs/model-garden/explore-models
