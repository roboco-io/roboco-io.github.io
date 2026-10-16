---
title: "Modernizing Legacy Code with Vibe Coding (2/2): PHP, Built Up Alongside the History of the Web"
date: 2026-10-16T18:00:00+09:00
draft: false
toc: false
images:
tags:
  - vibe-coding
  - legacy-modernization
  - php
  - laravel
  - agentic-dev
---

> The risk in legacy PHP lies not in pointers but in aging runtime environments, implicit type conversions, authorization checks, and the database and external integrations. In most cases the right answer is not to abandon PHP, but to move it to a supported version and put verification and deployment practices in place first.

{{< figure src="/posts/images/Dohyun.png" title="Dohyun Jung - Principal Consultant, ROBOCO" style=".author-image">}}

---

In [Part 1](/en/posts/legacy-cpp-vibe-coding-modernization/), I covered how to modernize C/C++ applications that are more than 20 years old with vibe coding.[^1] This post covers the legacy web, and PHP in particular.

PHP appeared in 1995 and has been around for nearly the entire history of the web. Over that time, countless corporate websites, online stores, communities, and internal business systems were built in PHP, and many of them are still in production. In Korea alone, I regularly run into sites built on Gnuboard and Youngcart, hand-built PHP5 admin screens, and old Laravel and CodeIgniter projects in my consulting work. In these projects, too, I hear that "the agent can't do the job properly."

The conclusion of Part 1 applies to PHP as is. The main reason agents fail is that they have no way to check whether their changes are correct, so the first investment in modernization should be a verification environment. What needs to be verified, however, differs from C/C++. This post lays out a modernization strategy suited to PHP, based on public case studies, official support policies, and tool documentation researched as of October 16, 2026. All figures in the case studies are self-reported by the organizations that published them; I have not independently reproduced them.

**Series: Modernizing Legacy Code with Vibe Coding**

1. [20-Year-Old C/C++ Applications](/en/posts/legacy-cpp-vibe-coding-modernization/)
2. PHP, Built Up Alongside the History of the Web (this post)

## TL;DR

- The main risks in legacy PHP are not pointer lifetimes but end-of-life runtime environments, dynamic typing and implicit behavior, global state, authentication and authorization, the database and external integrations, and the absence of testing and deployment practices.
- For most projects, the right approach is to keep PHP, upgrade the runtime and dependencies to supported versions, build verification and deployment practices, and then restructure only the parts that need it.
- Leave large-scale transformations with clear rules to deterministic tools such as Rector, and have agents handle investigation, fixing the remaining exceptions, and writing tests. Humans judge business behavior, permissions, data, and cutover risk.
- In a web project, equivalence is not confirmed by a page rendering. You need to compare HTTP requests, user permissions, sessions, database changes, and external effects such as email and payments within a single scenario.
- In public case studies, agents actually produced missing authorization checks (IDOR), missing email sends, constant fudges such as `+1`, and workarounds that made database columns nullable. Set up verification criteria that catch these failures first.

## 1. How Legacy PHP Differs from Legacy C/C++

The core challenge of legacy C/C++ was pointer ownership and object lifetimes. PHP uses an execution model in which memory is cleaned up when the request ends, so this problem barely exists. Problems arise elsewhere instead.

| Aspect | Legacy C/C++ | Legacy PHP |
|---|---|---|
| Core risk | Pointer ownership, object lifetimes, memory defects | Aging runtime environment, implicit type conversion, permissions, database and external side effects |
| De facto specification | Behavior and ABI of the original binary | Code on the production server, database schema and data, URLs |
| Unit of equivalence comparison | Function and library inputs and outputs | HTTP requests, user roles, sessions, database changes, external effects |
| Representative deterministic tools | clang-tidy, LibTooling, C2Rust | Rector, PHPStan, PHPCompatibility, Composer |
| Common wrong goal | Translating everything to Rust | Rewriting everything in the latest framework plus an SPA |

In the legacy PHP I have seen in the field, the agent's work loop breaks down in roughly four places.

First, **the code in the repository differs from the production code.** Files edited directly on the server over FTP, patches made directly to vendor or CMS core code, and configuration files that are not in Git are common. If an agent works only from the repository, it ends up reasoning from code that is not actually running in production.

Second, **the real runtime environment is hard to reproduce.** The PHP used by the web server and the CLI PHP used by cron may differ in version or `php.ini`. Behavior often depends on end-of-life PHP 5.x and old extension modules, character encodings such as EUC-KR, or specific MySQL settings.

Third, **code search alone cannot find all the entry points.** When there are PHP files called directly by URL, dynamic `include`, `eval`, or SQL and rules stored in the database, symbol search does not reveal the call relationships. That is why you also need to check access logs and cron schedules.

Fourth, **the database and external integrations are the de facto specification.** ORM model classes often differ from the actual database schema. The actual DDL, indexes, triggers, and data distribution carry the business rules. Email, SMS, and payment gateway (PG) integrations cannot be undone if they actually fire during testing.

## 2. What the Public Case Studies Show

There are more PHP modernization case studies than C/C++ ones. However, they mix simple AI-assisted coding, agents that run tools directly, and rule-based automated transformation, so they need to be read with that distinction in mind.

| Case | Source and target | Tools | Reported results | Limits of applicability |
|---|---|---|---|---|
| DVHARDWARE[^2] | Procedural PHP CMS accumulated since 2002 → PHP 8.5 with a layered architecture | Codex, Docker, PHPStan, Deptrac | Got an initial feature-equivalent version in three evenings of work, then continued improving it and deployed | A relatively simple CRUD CMS, and feature equivalence was judged by the operator himself |
| Progrit[^3] | 7 repositories, PHP 8.2→8.4, Laravel 10→12 | Claude Code, Rector | Reported completing it without major issues alongside regular development | Duration, cost, and automation rate not disclosed |
| Rocket[^4] | Remaining transition of PHP screens and logic → Angular-centric architecture | Claude Code | 4 months including training; senior engineer throughput went from 82 to 201 items | Figures also reflect organizational changes, and are not evidence for replacing an entire PHP server |
| Boldare[^5] | Symfony 5.4→6.4 | Claude | Work estimated at several days done in several hours | Comprehensive existing tests were in place; project size not disclosed |
| 2am.tech[^6] | Old Laravel app → new Laravel API and React | GitHub Copilot agent | Ported in vertical feature slices, finding and fixing permission, email, and state defects | Duration and productivity figures not disclosed |
| FuelPHP→Laravel[^7] | 400,000+ lines, 2,000+ files | About 80 custom Rector rules | 99% of PHP files converted automatically | 2021 work, not an LLM case; required about 11 months of QA and canary deployment |

The most instructive part of this table is not the performance figures but the failures that were made public.

The operator of DVHARDWARE modernized a site that started on PHP-Nuke and had been modified for 24 years. He first put the code into Git, built a local runtime environment with Docker and a copy of the database, and then migrated while running the old and new versions side by side. When the user count did not add up, however, the agent added `+1` to the result to make the numbers match instead of fixing the cause. It also carried over the original's incorrect assumptions and unnecessary layers as is. The operator also reported that the sheer volume of generated code made his reviews less rigorous.

The 2am.tech case disclosed more serious failures. The email templates were ported, but the actual send calls were never wired up. Instead of resolving a field missing from the JWT flow, the agent tried to work around it by making a database column nullable. In an API that took a user ID as a parameter, the ownership check was missing, creating an IDOR (Insecure Direct Object Reference) vulnerability that allowed access to other users' data. Some write APIs were open to regular users.

These failures teach three lessons. First, hiding a button in the UI and checking permissions on the server are two separate things. Second, even if the page renders and returns HTTP 200, the wiring to email, the database, or events can still be missing. Third, a schema inferred from ORM models must not be treated as the actual database schema. The 2am.tech team, too, could only catch these omissions systematically after switching their unit of work from layer-by-layer tasks such as DTOs and controllers to **vertical feature slices that cut through route→controller→service→repository**.

The success stories have something in common as well. At Boldare, comprehensive existing tests provided feedback right after every change. Progrit first organized the scope of impact and the fix policy from the official change documentation, turned that into a shared prompt applied to all 7 repositories, and left simple repetitive work to Rector. In other words, **projects that already have tests and a limited scope of change deliver quick results**, but you cannot expect the same speed from a procedural PHP5 project with no tests.

## 3. Decide the Target Version First

The target version for modernization is determined by official support policy. Below is the support schedule I checked on the official PHP website on October 16, 2026.[^8]

| PHP version | End of active support | End of security support | Interpretation for a new modernization project |
|---|---|---|---|
| 8.2 | 2024-12-31 | 2026-12-31 | Unsuitable as a final target, as security support ends soon |
| 8.3 | 2025-12-31 | 2027-12-31 | An intermediate target when constraints exist |
| 8.4 | 2026-12-31 | 2028-12-31 | A realistic choice depending on plugin and extension compatibility |
| 8.5 | 2027-12-31 | 2029-12-31 | The target to consider first once dependency support is confirmed |

Frameworks are judged the same way. Symfony 7.4 LTS receives security fixes until November 2029. Laravel 13 supports PHP 8.3–8.5 and receives security fixes until March 2028. Security fixes for Laravel 12 end in February 2027, so a project starting now is better off evaluating compatibility with 13 first.[^9]

"Upgrade PHP first" is not always the right order, because old frameworks may not run on the latest PHP. So you may have to climb a staircase such as **the latest patch of the current framework → an intermediate framework version with a wide range of supported PHP versions → a PHP upgrade → the target framework**. Design this staircase using Composer's conflict explanations and the official upgrade guides; there is no need to deploy every intermediate version to production.

## 4. Paths by Project Type

Legacy PHP comes in many forms, so the path differs by type. The table below shows the default path and the approach to avoid for each major type.

| Type | Default path | Approach to avoid |
|---|---|---|
| Procedural PHP5 mixed with HTML | Reproduction, backups, characterization tests → separate database access and shared logic → PHP upgrade | Converting everything to Laravel and an SPA as the first step |
| Home-grown PHP7 MVC | Introduce Composer and autoloading and analyze compatibility → runtime upgrade → clean up module boundaries | Moving files, changing namespaces, and replacing the database all at once |
| Old Laravel or Symfony | Upgrade step by step following the official per-version guides, using Rector and agents together | Just bumping the version numbers in Composer to the latest |
| CodeIgniter 2/3, FuelPHP, Zend1 | Compare keeping, wrapping, product replacement, and partial rebuild | Promising a simple upgrade across incompatible major versions |
| CMSs such as WordPress | Update core and extensions the standard way, and modify only custom-built themes and plugins | Modifying the CMS core directly with an agent |
| Gnuboard, Youngcart, XE, Rhymix | Start by identifying the exact product, fork, version, and core modifications | Treating community answers that "it works fine" as a compatibility guarantee |
| Small sites that only need maintenance | Move to a supported environment, remove unused features, consider going static or replacing with SaaS | Platform investment that exceeds the business value |

The official guide states explicitly that moving from CodeIgniter 3 to 4 is a rewrite that is not backward compatible.[^10] Drupal 7 reached the end of community security support on January 5, 2025, and migrating to modern Drupal is not a matter of replacing core files but a migration project for data, content types, permissions, and URLs. In cases like these, completion must not be judged by PHP syntax conversion alone.

Sites built for Korean clients have their own items to check first: EUC-KR and CP949 encoding, Korean file names on attachments, Excel downloads, address lookup, identity verification, PG and SMS integrations, upload paths for web editors, and rewrite rules on old web servers. Even if the Gnuboard core runs on the latest PHP, old skins, plugins, and PG modules may not.

For clients already using Laravel or Symfony, staying within that ecosystem is usually the better choice. Choose another language only feature by feature, when there is a specific constraint or operational benefit. Do not make leaving PHP a goal in itself.

## 5. Divide the Roles of Rector and the Agent

In Part 1, I recommended separating deterministic tools from agent judgment. In PHP, the centerpiece of those deterministic tools is Rector. Rector is a tool that analyzes PHP code at the AST (abstract syntax tree) level and transforms it according to defined rules. It provides rule sets for version upgrades and framework-specific rules, and you can also write custom rules.[^11]

The FuelPHP-to-Laravel migration shows both the power and the limits of this approach. The team transformed the Query Builder, namespaces, configuration, and request and response handling with about 80 custom Rector rules, and reported that 99% of PHP files were converted automatically. However, routes and parts of authentication were handled manually. Small semantic differences between frameworks, such as the status code of an empty response or the shape of an insert result, also became real problems. The work ran from January to November 2021, and QA and canary deployment were critical.[^7] Automatically converting 99% of files does not mean cutting 99% of the work time, nor deploying without verification.

This case predates LLMs, but combined with today's agents, the division of roles becomes clear. The agent finds repeating patterns, drafts Rector rules and their test fixtures, and resolves the remaining exceptions the rules could not handle. Once a pattern is settled, it is accumulated as an executable Rector rule rather than having the LLM reason it out anew each time. This reduces cost and makes results reproducible. Separating the diff from rule-based transformation and the diff from agent edits also makes it easier to narrow down the cause when a regression occurs.

Also prepare the context you provide to agents. In PR 41279, PrestaShop made the `.ai` directory the single source of truth for shared rules, and pointed `CLAUDE.md`, `AGENTS.md`, and the entry files for Cursor, Copilot, Gemini, and Windsurf all at the same information.[^12] This PR is a documentation and tooling change, not a completed product migration. Still, the structure of **keeping a single source of truth for the rules and having each agent's entry file point to it** is worth adopting as is. For Laravel projects, consider Laravel Boost, which provides route, schema, and documentation information to agents; for PhpStorm users, consider the MCP server that exposes the IDE's type and reference information to external agents.[^13] Note, however, that Laravel Boost can only be installed on Laravel 10 or later and PHP 8.1 or later, so do not assume you can use it right away on a PHP5 or old Laravel project.

## 6. Where Upgrades Change Semantics

When you upgrade PHP, there are places where behavior changes even though the code stays the same. Agents tend to "fix" these places as if they were syntax errors, so a human needs to decide the business meaning first.

| Risk | Example | How to check |
|---|---|---|
| Removed features | `mysql_*`, `ereg`, old constructor syntax | Official per-version migration guides, PHPCompatibility |
| Type comparison | Numeric strings, null, false, empty values; comparing `0` with strings | Characterization tests based on boundary values |
| Error handling | Code that expected a `false` return gets a TypeError or exception | Inspect failure paths and the global error handler |
| Dynamic properties | Undeclared object fields | Confirm the actual field contract |
| Strings and encoding | EUC-KR, CP949, UTF-8; byte length vs. character length | Round-trip tests across database, forms, files, and downloads |
| Database driver | Exception mode, fetch types, affected row counts | Compare query results and errors on the same data |
| Serialization | PHP objects stored in sessions, caches, and queues | Confirm bidirectional compatibility between old and new versions |

For example, in PHP 8 the result of `0 == "foo"` differs from earlier versions.[^14] Do not solve this by changing every `==` to `===`. First decide what inputs that comparison receives and what business meaning it carries. Likewise, do not silence PHP 8.2's dynamic property warnings by applying `#[AllowDynamicProperties]` across the board; distinguish what should be declared as real fields from what should remain an extension point. When moving off the `mysql` extension removed in PHP 7 to PDO or MySQLi, do not just rename functions; verify the connection charset, SQL parameter binding, transactions, and affected row counts.

Research materials also need verifying. The original Progrit write-up included an AI-generated analysis stating that "Carbon 3 became immutable by default." The official Carbon documentation, however, distinguishes Carbon as a mutable object from CarbonImmutable, which returns new objects.[^15] A particular application can configure immutable as its default, but that must not be asserted as a change to the library as a whole. AI-written research in particular must be confirmed with execution evidence.

## 7. Control the Database and External Side Effects

In PHP projects, the database is often the de facto specification, so set the ground rules for handling data first. Start making changes only after verifying that the original database and uploaded files can be restored. In the early stages, keep the database schema as unchanged as possible and secure application compatibility first. If the schema must change, break it into steps: add a column → backfill the data → compare → switch consumers over → drop the old column. And do not consider the behavior of production MySQL or MariaDB verified by SQLite-based unit tests alone, because differences in SQL mode, collation, and storage engine change the results of sorting, duplicate keys, and date handling.

Email, SMS, PG, and webhook integrations follow one principle: **running the same input twice must not produce the actual external effect twice.** Use test adapters, sandboxes, captured outgoing messages, and idempotency keys. When running old and new versions in parallel, have the new implementation only record its intent to send, or keep it in a write-blocked state. Do not make dual writes, which write to both the old and new sides at once, the default solution; keep a single writer to the database. Likewise, make sure cron jobs and queue workers do not run on both the old and new sides at the same time.

Do not give agents the original production database. Create and provide the schema they need along with de-identified or synthetic data. Connect tools capable of querying the database or executing commands, such as Laravel Boost or MCP servers, only to isolated development and verification environments. Do not grant broad production database access just because a tool supports such features.

## 8. A Verification Harness for the Web

The C/C++ differential execution in Part 1 compared the output of functions or libraries for the same input. In a web project, comparing output alone cannot confirm equivalence. You need to bundle **HTTP requests, user permissions, sessions, database state before and after changes, files, and external effects** into a single scenario and compare them.

Run the comparison in the following order. First, from the same baseline data, create separate database, file, session, and cache spaces for the old and new versions. For each scenario, log in to each system separately to obtain CSRF tokens and cookies. Execute semantically identical requests and collect status codes, redirects, responses, database changes, files, and email send intents. Document the values to exclude from comparison, such as timestamps and auto-increment IDs, and normalize them. Finally, classify each difference as an original defect, an intended change, a new defect, or an environment difference. Avoid replaying write scenarios with both apps connected to the same database, because the results of running the original contaminate the initial state of the new version.

| Verification area | Minimum scenarios |
|---|---|
| Guests, members, admins | Direct URL and API calls, expired sessions |
| User and tenant isolation | Requests with another user ID, organization ID, or file ID |
| Input and search | Empty values, `0`, null, multilingual text, maximum length, SQL special characters |
| Writes | Create, update, delete, duplicate submission, retries |
| External effects | Missing, duplicate, or misaddressed email, SMS, PG, and webhook calls |
| Files | Uploads and downloads, Korean file names, access control |
| Dates and amounts | Month-end, leap years, time zones, rounding |
| Async and batch | Timeouts and reruns of cron jobs and queues |

The user and tenant isolation scenarios are there to catch IDORs like the one in the 2am.tech case. Playwright's screenshot comparisons are useful for finding layout regressions, but they do not prove permissions, settlements, or email sends.[^16] Also, do not use a number such as "80% test coverage" as a standalone success metric. Define acceptance criteria such as: all essential business scenarios pass, zero unclassified differences, zero unresolved permission or data defects, the agreed performance budget is met, and a restore drill is completed.

The prohibitions you give agents should directly reflect the failures from the public case studies. Do not pass tests by relaxing expected values or skipping them. Do not hide differences with nullable changes, constant fudges, or relaxed permissions. Do not change authentication, authorization, or the database schema without approval. Do not trigger real email, SMS, or PG side effects. And have the agent report any check it could not run as "not run."

## 9. Step-by-Step Procedure

PHP modernization also sets a gate condition for each stage, in the same way as Part 1. The differences are that G0 has a dedicated step for securing the production code and data, and that a sustained maintenance stage is added at the end.

| Stage | Work performed | Gate condition |
|---|---|---|
| G0 Secure | Git, production code, database, uploaded files, configuration, backup restoration | A recoverable baseline version and access rights |
| G1 Reproduce | Set up old and target environments, stub external integrations | Representative URLs, CLI commands, and cron jobs run in an isolated environment |
| G2 Protect behavior | Characterization, permission, database, session, and side-effect tests | An original baseline and holdout data secured |
| G3 Decide the path | Decide the version staircase, package replacements, and screen and data design | Agreement on goals, prohibited changes, budget, and rollback |
| G4 Automated transformation | Apply Rector and dedicated tools in small batches | Rule fixtures, diffs, static analysis, and tests pass |
| G5 Agent fixes | Resolve remaining type, configuration, integration, and business exceptions | Fixes that do not relax verification criteria, with execution evidence |
| G6 Falsification | Old/new comparison; permission, data, security, and performance verification | No differences with unclassified causes and no unresolved blocking defects |
| G7 Cutover | Deployment artifacts, canary, observability, recovery drills | Session and data compatibility, with side effects under control |
| G8 Sustained maintenance | Dependency updates and end-of-life response | Owner, schedule, and regular verification confirmed |

G8 is especially important for PHP. PHP and frameworks release new versions every year, and support ends on a 2–3 year cycle. **Staying in an upgradable state on an ongoing basis** is worth more than upgrading to the latest version once. Bosun's pilot with an anonymous client illustrates this direction. They found which internal packages were blocking external package updates through deterministic dependency exploration without AI, and grouped version decisions, official documentation research, fixes, tests, and impact explanations into an agent stage, producing small PRs one major version at a time.[^17]

Session handling is another area to watch during cutover. If requests are routed randomly between two versions that cannot share sessions, you get logouts, CSRF failures, and signature errors. Choose whichever fits the business: sticky routing by user group, a planned re-login, or separate session spaces per version. Also, code rollback and data rollback are separate. If the old code cannot handle data written by the new code, reverting the routing alone will not restore service.

## 10. A First Six-Week Pilot, and When to Stop

Below is an example six-week plan for running a first pilot on a mid-sized web project where access rights and business owners are already in place. It is not a plan that guarantees the overall modernization schedule.

| Week | Main work | Basis for decisions |
|---|---|---|
| 1 | Production baseline, recovery, environment, dependency survey | The actual PHP, database, and deployment setup, and blockers |
| 2 | Representative business, permission, database, and email tests; decide the version path | A contract comparable against the original behavior |
| 3 | Rector, dedicated tools, package updates | Separation of automated transformation from remaining work |
| 4 | Fix exceptions and wire up features with agents | Tests, analysis, differential execution, and review |
| 5 | Holdout, security, and performance verification; rollback drill | Resolution of unclassified differences and blocking defects |
| 6 | Limited cutover, observability, retrospective | Actual maintenance cost and potential for expansion |

A read-heavy admin screen or a query API is a good fit for the first pilot. But if you pick a single simple page that avoids all database, session, and permission risk, it will not be representative. So after the first small success, include a representative write feature as the next verification target. Do not change payments, refunds, bulk edits of personal data, permission management, and all cron jobs at the same time in the first pilot.

Start the agent setup simply, as in Part 1. Combine one primary agent with the IDE's PHP code analysis, Composer, Rector, static analysis (PHPStan or Psalm), a reproduction environment, and CI. When parallelizing, assign a single author for `composer.lock` and the shared authentication, routes, and schema. If multiple agents each run dependency updates, their results conflict with one another.

If the following conditions appear, do not scale up automation; strengthen diagnosis and contracts instead.

- Production state cannot be restored because there is no baseline database.
- The schema is being guessed from ORM models instead of the actual database.
- Tests pass only by deleting tests or by nullable changes, relaxed permissions, or constant fudges.
- Agents change shared sessions, authentication, and schema at the same time, making causes impossible to trace.

Conversely, if core functionality is tied to an unsupported vendor product or an encrypted extension, compare options such as retiring the feature, moving to SaaS, adopting a standard CMS, or a small rebuild alongside code modernization. The goal is neither to leave the old code untouched down to the last line nor to throw it all away. The goal is **to run the features the business needs at a cost and risk it can bear**.

## Closing Thoughts

In my consulting, I recommend not starting PHP modernization as one big contract. The first step is diagnosis. Map the production code, runtime environment, dependencies, routes, permissions, data, and deployment, and use the results to let the client choose among keeping, upgrading, partial replacement, product replacement, and retirement. Next comes operational stabilization, and then the pilot. Decide the scope of expansion based on the real evidence gained from the pilot. Do not promise durations, automation rates, or cost savings before looking at the repository.

The two posts in this series dealt with different languages, but the conclusion is the same. Agents struggle with legacy code not because the code is old, but because there is no way to check whether a change is correct. In C/C++, that means of checking was build reproduction and differential execution; in PHP, it is reproducing the production environment plus a harness that compares HTTP, permissions, the database, and external effects. Once the verification environment is in place, agents can repeat investigation, transformation, and falsification without pause, like the [software factory](/en/posts/beyond-vibe-coding-software-factory/) covered on this blog.[^18]

The schedules, thresholds, and configurations in this post are proposals based on public case studies. Before applying them in practice, diagnose the specific project and adjust accordingly.

[^1]: Modernizing Legacy Code with Vibe Coding (1/2): 20-Year-Old C/C++ Applications: https://roboco.io/en/posts/legacy-cpp-vibe-coding-modernization/
[^2]: Thomas De Maesschalck, "How Codex Helped Me Modernize a 24 Year Old PHP Codebase" (2026-08-17): https://www.dvhardware.net/articles/31/dvhardware-codex-migration
[^3]: Ryo Maruta, "生成AIを活用してPHP Laravelの大規模アップデートを実現した話" (2026-04-16): https://note.com/ryo_maruta/n/nb49789bf2ea8
[^4]: Rocket, "Accelerated modernization" (2025-11-07, self-reported): https://careers.rocket.com/blog/technology-and-product/accelerated-modernization-rocket-mortgage-origination
[^5]: Boldare, "AI in action: accelerating Symfony migration from 5.4 to 6.4" (2025-10-13): https://www.boldare.com/blog/ai-in-action-accelerating-symfony-migration-from-5.4-to-6.4/
[^6]: 2am.tech, "Using AI to Port a Legacy Laravel CMS to a Modern Architecture" (updated 2026-10-08): https://www.2am.tech/blog/using-ai-to-port-a-legacy-laravel-cms-to-a-modern-architecture
[^7]: Rector, "Success Story of Automated Framework Migration from FuelPHP to Laravel of 400k+ Lines Application" (2022-02-07): https://getrector.com/blog/success-story-of-automated-framework-migration-from-fuelphp-to-laravel-of-400k-lines-application
[^8]: PHP Supported Versions: https://www.php.net/supported-versions.php
[^9]: Symfony Releases: https://symfony.com/releases , Laravel 13 Release Notes: https://laravel.com/docs/13.x/releases
[^10]: CodeIgniter, Upgrading from 3.x to 4.x: https://codeigniter.com/user_guide/installation/upgrade_4xx.html
[^11]: Rector Set Lists: https://getrector.com/documentation/set-lists
[^12]: PrestaShop PR 41279 (merged 2026-04-28): https://github.com/PrestaShop/PrestaShop/pull/41279
[^13]: Laravel AI Assisted Development: https://laravel.com/docs/13.x/ai , PhpStorm MCP Server: https://www.jetbrains.com/help/phpstorm/mcp-server.html
[^14]: PHP 8 Backward Incompatible Changes: https://www.php.net/manual/en/migration80.incompatible.php
[^15]: Carbon Introduction: https://carbon.nesbot.com/guide/getting-started/introduction.html
[^16]: Playwright Visual comparisons: https://playwright.dev/docs/test-snapshots
[^17]: Bosun, "Modernising a legacy PHP application": https://bosun.ai/case-studies/case-study-legacy-dependency-platform-upgrades/
[^18]: Beyond Vibe Coding, Toward the Software Factory: https://roboco.io/en/posts/beyond-vibe-coding-software-factory/
