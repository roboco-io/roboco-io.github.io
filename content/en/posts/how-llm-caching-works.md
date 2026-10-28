---
title: "How Does LLM Caching Work? Reading AI Infrastructure Efficiency Through Anthropic’s S-1"
date: 2026-10-28T10:00:00+09:00
draft: false
toc: false
description: "Starting with Anthropic’s S-1, seven diagrams explain how KV caching, shared prefixes, cache-aware routing, and storage tiers improve large-scale LLM infrastructure, and how that efficiency can coexist with user context isolation."
images:
tags:
  - llm
  - prompt-caching
  - ai-infrastructure
  - cost-optimization
---

> Anthropic’s S-1 describes reductions in the inference compute needed to deliver a given level of model performance, alongside improvements in how efficiently that compute is used in production. – Summary of “Compute Efficiency”[^1]

{{< figure src="/posts/images/Dohyun.png" title="Dohyun Jung - Principal Consultant, ROBOCO" style=".author-image">}}

---

## TL;DR

- LLM infrastructure is evolving to require less compute for a task at a given performance level and to make better use of available resources. Anthropic’s discussion of inference efficiency in its S-1 is one piece of evidence for that trend.
- Prompt caching reuses the KV cache produced while processing an identical input prefix. It reduces repeated computation over long documents, while new questions still need processing and answers still need generating.
- At scale, systems share common computations in memory blocks and route requests with both cache location and load in mind. Some also store caches outside GPU memory.
- Improving cache efficiency starts with deciding whose computations may be shared with whom. User isolation can reduce reuse, and the same authorization boundaries must follow caches outside the GPU.
- The benefits depend on reuse frequency, available memory, and transfer costs. The reduction in reprocessed input tokens must not be treated as the reduction in total cost.

---

Imagine visiting a support specialist with the same product manual. On the first day, the specialist has to read it from the beginning. You return the next day with a different question, but the specialist starts reading the entire manual again. Repeated reading could take longer than answering the question.

Something similar happens in LLM services. A request can include product documents, tool instructions, and conversation history. The screen shows only one new question, but the input sent to the server contains a long trail of material sent before.

**Improving LLM infrastructure efficiency also means finding and reducing this repeated work.** Alongside installing more GPUs, systems are getting better at reusing computations they have already performed. Caching is central to that effort.

Anthropic’s registration statement for its proposed IPO, the S-1 made public on October 26, 2026, is one source of evidence for this change. Starting with its discussion, this post uses seven diagrams to explain how caching works in large-scale infrastructure.

That raises an important operational question: **can we improve cache efficiency while keeping different users’ contexts isolated?** Alongside deciding how to expand storage, we need to decide who may reuse what.

The diagrams use public vLLM, SGLang, and LMCache technologies to explain general principles. They do not depict Anthropic’s actual internal architecture.

## 1. What the S-1 shows: doing more with the same resources

The S-1 describes both research that reduces inference computation and operational improvements that make better use of available compute. In a separate discussion of platform features, it states that caching long prompts can reduce costs by up to approximately 97% and latency by approximately 60%, compared with processing the same requests without caching.[^1]

The trend to recognize is that **the way models are served keeps improving too**. Those figures describe a conditional benefit for long prompts. They do not mean Anthropic’s total infrastructure operating costs fell by that amount, or that caching accounts for all its improvements.

How does caching contribute? It helps to split the process of producing an answer into two stages.

## 2. Before answering, the model has to process the input

Inference in a typical generative LLM has two broad stages.

- **Prefill**: process the input and compute internal states that will be referenced when generating an answer.
- **Decoding**: use those states to generate the answer token by token. A token is a small unit the model uses to handle text.

Think of the first stage as reading the materials and preparing to work, and the second as writing an answer while referring to those materials.

During this process, the model produces numerical arrays called keys and values for attention. The **KV cache** stores them. Within a single request, it helps avoid recomputing the keys and values of earlier tokens each time the next answer token is generated.[^2]

This reuse can extend across requests. With the same model and compatible execution conditions, a new request that begins with the same input as an earlier request can retrieve the KV cache for that prefix and continue processing. This is called prompt caching or prefix caching.[^3]

![The first request processes the document and creates its KV cache. Later requests reuse that cache, while still processing new questions and generating answers.](/posts/images/llm-cache/en/01-read-and-reuse.svg)

*Figure 1. Caching reduces repeated computation over a long shared document. Processing the new question and generating an answer remain necessary.*

Returning to the support specialist analogy, the KV cache is like prepared working material that the next computation can immediately reference. It is not a human-readable summary. It consists of numerical arrays used in model computation, and it does not retrain the model itself.

Its operation therefore differs from retrieving an answer similar to the last one. Even when the document is reused, an answer to the current question is generated anew.

## 3. What comes before the same document matters

Suppose two customers ask questions about the same product manual. One asks about features, the other about integration with external systems. Even though their questions differ, there is an opportunity to reuse computation if their inputs are identical up to the end of the manual.

![Identical instructions and a product document form a shared prefix before requests branch into questions A and B. Placing a changing timestamp first changes the computation for the document that follows.](/posts/images/llm-cache/en/02-shared-prefix.svg)

*Figure 2. A prefix is the beginning of an input. Requests follow a common path, then compute independently from the point where their questions differ.*

Why is identical document content alone insufficient? In a typical autoregressive transformer, a token’s internal state depends on preceding tokens. Different instructions before a document cause that document to be processed in a different context. That makes the extent of the matching prefix important.[^3]

For example, placing a different timestamp or session ID at the start of every request can make it difficult to reuse earlier computation for the same manual that follows. Putting common instructions and documents first, followed by the new question, lengthens the shared path.

Agents work the same way. When tool definitions, task instructions, and earlier conversation remain stable and new execution results are appended, more computation can be reused. Replacing history with a summary or changing common instructions can require new computation from the changed point onward.

This differs from simply shortening sentences. Even a long input can offer substantial reuse if most of it repeats consistently.

## 4. Splitting the cache into blocks for many requests

As user numbers grow, reusing one copy of a manual is not enough. Many conversations run simultaneously, and their lengths differ. Managing the memory occupied by KV caches becomes important.

One approach divides the cache into small **blocks**. Think of sharing groups of common pages rather than copying an entire book for every person. PagedAttention introduced an approach that manages KV caches in blocks to reduce memory waste.[^2]

![Requests A and B reference the same two KV blocks. After use, blocks can remain as reuse candidates and be replaced when space is needed.](/posts/images/llm-cache/en/03-block-sharing.svg)

*Figure 3. Requests share one copy of common computation while managing their differing parts separately. This diagram simplifies vLLM’s block management principles.*

Finding shared blocks also requires identifiers. vLLM identifies a block using its tokens, the preceding block’s hash, and other information. A hash can be understood as an identifier used to find content. Linking the prefix into the identifier prevents computations from different contexts being mixed merely because they contain the same words.[^4]

Memory is finite, so caches cannot all be retained forever. Systems need to distinguish blocks still used by active requests from blocks that have finished being used and are waiting for potential reuse. When space runs short, they choose replacement candidates from the latter group.[^4]

Keeping frequently used shared material reduces recomputation for the next request. Holding rarely reused material for too long reduces the space available for new requests. Cache management is ultimately **a balance between future reuse opportunities and current memory demand**.

## 5. With many servers, request placement matters too

Now imagine several inference servers. Server A has the product manual’s cache; server B does not. Where the same question is sent changes how much computation must be repeated.

Distributing request counts evenly can miss opportunities to use caches already present. That motivates **cache-aware routing**. Routing means sending an incoming request to a server that will process it.

![A router considers both caches and load. Server A has the document cache and server B does not, so the benefit of reuse must be weighed against waiting time.](/posts/images/llm-cache/en/04-cache-aware-routing.svg)

*Figure 4. A cache existing somewhere in a cluster is not enough. The request must be able to use the stored computation.*

It is like sending the next question to the specialist who has already read the book. But if that specialist has a long queue, another specialist might finish sooner even after reading it afresh.

A router therefore needs to consider both who can reuse the prefix and how long the request will wait. SGLang’s model gateway, an open serving project, provides policies that account for caches and load.[^5]

A server in this diagram may represent an inference unit spanning several GPUs. Cache location matters more than the physical equipment count. Systems with cache transfer or sharing layers may retrieve the state, but without such a configuration the receiving server must recompute it.

At this point, caching becomes **a cluster-wide request placement problem**, extending beyond memory management on a single server.

## 6. Keep the materials needed now on the expensive workbench

GPU memory is a fast workbench with limited space. Stacking every previously read document on it leaves no room to start the next job.

Some systems therefore move KV caches outside the GPU for storage. Immediately needed material can stay on the GPU, while less urgent material goes into CPU memory or storage. LMCache provides a KV cache hierarchy using CPU memory, local storage, and remote storage.[^6]

![A hierarchy stores and reloads KV caches across GPU memory, CPU memory, and SSD or remote storage. Transfer costs must be compared with recomputation costs.](/posts/images/llm-cache/en/05-cache-hierarchy.svg)

*Figure 5. A fast workbench and larger storage areas serve different roles. Not every system has these tiers, and actual configurations vary.*

This also has a cost. Retrieving materials takes time. Remote storage uses the network too. Even after a stored KV cache is loaded, the state must continue to be referenced during generation of a new answer.

Having a cache does not therefore guarantee faster processing. Retrieval is beneficial when it costs less than recomputation. Recomputing a short input may be preferable, while retrieving a long shared document may be more efficient.

Large-scale infrastructure efficiency emerges from these decisions: what to retain, where to put it, and which requests should use it.

## 7. Small opportunities for reuse add up at scale

Consider a numerical example. The following is **hypothetical**, not a measurement from a real service.

Each of 100 requests includes the same 10,000-token document and a different 500-token question. Without caching, every request processes the document as part of its input. With complete cache reuse, the document is computed once, and subsequent requests process their new questions.

![Processing all 1.05 million input tokens across 100 requests is compared with computing the common document once and prefilling only 60,000 new tokens.](/posts/images/llm-cache/en/06-repeated-work.svg)

*Figure 6. This token comparison assumes the same model and document, with no expiry, eviction, or routing misses after the first computation. The bars do not represent time or cost.*

Without caching, the new input processing totals `10,500 × 100 = 1,050,000 tokens`. Reusing the common document reduces it to `10,000 + 500 × 100 = 60,000 tokens`. Newly prefilled input tokens fall by approximately 94.3%.

That does not mean total cost or compute time falls by 94.3%. Cache reads, storage memory, necessary transfers, and generation of every answer remain. Nor can computation be assumed to scale linearly with input token count.

Still, the example shows the direction of efficiency gains. Instead of spending resources repeatedly on the same computation, systems gain an opportunity to devote more to new questions and tasks. Actual benefits depend on shared input length, reuse frequency, available memory, and routing.

## 8. Can efficiency improve while user contexts stay isolated?

Yes. But tighter isolation also reduces the set of requests that can reuse a cache. The goal is **to maximize repeated-computation reuse within authorized boundaries**, rather than putting every request into one cache.

The GPU, CPU, and storage tiers above divide **where data is kept**. Public, organization, user, and session boundaries divide **who may reuse it**. These are separate distinctions. Even if users share remote storage, their access must be separable. Being on a GPU does not automatically guarantee isolation either.

### Finding identical content is different from permission to use it

People can share public library books, while private consultation records should be available only to the relevant user. Likewise, a cache identifier indicating matching content and the authority to use that content are different things. A hash is neither encryption nor proof of access rights.

| Type of context | Reuse scope to consider | Efficiency and isolation trade-off |
|---|---|---|
| Public instructions and manuals | A sharing group authorized by the service | Opportunities for broad reuse |
| Internal company documents | Users in the organization with the same permissions | Document-level permissions still matter within one company |
| Private conversations and personalization | The relevant user or session | Narrower sharing, but repeated work within the boundary can still be reused |

This table is a basis for policy decisions. Not every engine automatically separates these boundaries within a request. For example, vLLM injects `cache_salt` into the first block’s hash, and that boundary propagates to subsequent block identifiers. Different salts per user may therefore require even the same public document to be computed and stored separately.[^4]

To share a public prefix across everyone while isolating only the private suffix, you must separately verify an engine’s support for segment-level sharing and its security properties. Placing user data last or inserting a cache option midway through a request is insufficient. Where such support is absent, dividing the entire cache by user or permission group and reusing it within each boundary is a practical option.

### Share common input and isolate private context

![Requests from users A and B share one KV cache for an identical public manual, then branch into separate authorization scopes for personal questions and conversations.](/posts/images/llm-cache/en/07-context-isolation.svg)

*Figure 7. Cross-user cache hits occur where requests converge on the common prefix cache. Private contexts are separated afterward. This is a design concept for engines supporting segment-level sharing and access control, rather than vLLM’s default isolation with a salt applied to the entire request.*

The public prefix must not contain states influenced by private information. Public material must precede private context, and the engine must enforce sharing boundaries independently of input ordering. Separating private segments does not eliminate every kind of side channel.

Even when users A and B have different cache domains, A’s second request can reuse the document blocks created by A’s first request. B can do the same within its own domain. **Preventing cross-user sharing is different from recomputing every repeated request from the same user.** Reuse can also span sessions when the authorization boundary and compatible input remain the same. Conversely, a different isolation value for every request removes those opportunities too.

Even without support for this design, an entire cache partitioned by user can still provide reuse within each user’s domain. For comparison, assume 10 users each make 10 requests containing the same 10,000-token document and a different 500-token question. All cache domains start empty, with no subsequent expiry, eviction, routing misses, or block-boundary losses.

Total input is again 1,050,000 tokens. Each user’s first request computes the document, while the remaining nine read it from cache. Cached document reads total `10 users × 9 requests × 10,000 = 900,000 tokens`. **The token hit rate is `900,000 / 1,050,000`, approximately 85.7%.** Under these conditions, repetition within each user’s domain produces a high hit rate without cross-user cache sharing.

Under a separate assumption of a single trust group authorized to share all inputs, the document is computed once and reused 99 times, giving approximately 94.3%. This comparison illustrates the reuse opportunities lost through user isolation. It does not imply that placing mutually untrusted users in one group is safe. If every user makes only one request and leaves, per-user caching cannot deliver the same benefit. **Consider both the isolation unit and repetition frequency within it.**

The hit rate here is cached input tokens divided by total input tokens. It differs from the proportion of requests with any cache hit and does not represent total cost savings.

### The existence of a cache can reveal information too

Isolation goes beyond preventing users from directly reading one another’s documents. Repeatedly observing faster responses on cache hits can provide clues that particular input was used before. This is a timing side channel. The PrefixWall research examines this inference risk in shared prefix caches.[^7]

A cache match does not automatically append another user’s conversation to the current request. However, **preventing content from being mixed into a request and preventing usage traces from leaking require separate defenses**. Verifying that cache keys match is not a substitute for security verification.

Managed API isolation scopes also need checking. The Claude API isolates caches by workspace, but that does not mean it separately isolates every user of a service sharing that workspace. If an application serves multiple customers through one workspace, customer document permissions and the required isolation configuration must be designed separately.[^8]

### The key must follow the material into storage

The following operational conditions matter in multi-tier caches. These are design checks, not a list of guarantees from a particular product.

- **Set the boundary**: the server determines reuse scope from authenticated users and document permissions. Do not let a client select another user’s domain merely by supplying a user ID or salt.
- **Preserve the boundary**: apply the same separation to GPU block lookups, CPU caches, remote storage, inter-server transfers, and cache location directories. Moving data must not broaden its authorization scope.
- **Separate access control from encryption**: apply transport and storage encryption as needed, while separately restricting which users’ material a service with decryption capability may retrieve.
- **Handle permission changes and deletion**: when permission is revoked, prevent subsequent use even if the cache remains. Retention and deletion policies must also cover off-GPU copies and storage.

LMCache’s storage encryption documentation illustrates the distinction. Even when encryption keys are separated by user or tenant salt, a server holding a shared master key can decrypt every tenant’s data. The documentation explicitly states that this configuration alone does not provide tenant access isolation.[^9]

The question is therefore not only how often the cache hits, but **who can find, retrieve, and reuse which cache**. Alongside efficiency metrics, verify that lookups and reuse across users with different permissions are rejected.

---

## Conclusion

LLM infrastructure is advancing both in the hardware that runs models and in how work is assigned to that hardware. Sharing computations for identical inputs, routing requests toward cached state, and dividing material between limited GPU memory and external storage are examples.

Anthropic’s S-1 discussion of inference efficiency is one indication that these changes matter in actual business operations. The diagrams in this post explain general principles through public vLLM, SGLang, and LMCache technologies; they do not reconstruct Anthropic’s internal deployment architecture.

The principle of caching is simple: **retain a computation already performed and let the next request continue from that point**. At scale, the challenge is finding it in time among many requests, placing it where needed, and reclaiming space appropriately. User authorization boundaries must hold throughout that process. Efficiency means expanding authorized sharing while preserving private context boundaries.

Even when efficiency per task improves, total infrastructure spending can rise if usage grows faster. Efficiency means reducing the resources needed for one task at the same performance level, or handling more tasks with the same resources. Caching offers a useful window into that change.

---

[^1]: Anthropic, Form S-1, October 26, 2026. “Compute Efficiency” and “The Claude Platform — Cost, Speed, and Scale”: https://www.sec.gov/Archives/edgar/data/2130357/000162828026067168/anthropicpbc-sx1.htm
[^2]: Kwon et al., Efficient Memory Management for Large Language Model Serving with PagedAttention: https://arxiv.org/abs/2309.06180
[^3]: vLLM, Automatic Prefix Caching. Cross-request KV cache reuse and the distinction between prefill and decoding: https://docs.vllm.ai/en/stable/features/automatic_prefix_caching/
[^4]: vLLM, Automatic Prefix Caching design. Block hashes, references, eviction, and cache isolation: https://docs.vllm.ai/en/stable/design/prefix_caching/
[^5]: SGLang, Model Gateway. Request distribution policies that consider cache state and load: https://docs.sglang.io/docs/advanced_features/sgl_model_gateway
[^6]: LMCache, Key features. Tiered KV cache storage and reuse outside the GPU: https://docs.lmcache.ai/
[^7]: Pennas et al., PrefixWall: Mitigating Prefix Caching Side Channels in Shared LLM Systems. Information inference through cache hit/miss latency differences: https://arxiv.org/abs/2603.10726
[^8]: Anthropic, Prompt caching — Cache storage and sharing. Workspace and organization isolation scopes; checked October 28, 2026: https://platform.claude.com/docs/en/build-with-claude/prompt-caching#cache-storage-and-sharing
[^9]: LMCache, KV Cache Compression — Encryption serde. Storage encryption versus tenant access isolation; checked October 28, 2026: https://docs.lmcache.ai/mp/serde.html
