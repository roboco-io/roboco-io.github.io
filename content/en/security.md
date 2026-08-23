---
title: "Security Policy"
summary: "The security principles ROBOCO follows to protect our clients' data and code"
draft: false
---

In the course of consulting, training, and software development, ROBOCO works with client data, source code, and business information. To earn and keep the trust of security-conscious clients, we adhere to the following principles.

## Principles for Handling Client Data

- **Minimal collection**: We request only the minimum data and access rights necessary to carry out the project.
- **Purpose limitation**: Data provided to us is never used for anything beyond the agreed project purpose.
- **Time limitation**: At the end of a project, we return or destroy client data and access credentials, and we provide confirmation of destruction on request.
- **Confidentiality**: Every project can be carried out under a non-disclosure agreement (NDA), and regardless of whether such an agreement is in place, we never disclose client information to third parties.

## AI Tool Usage Policy

Because ROBOCO specializes in AI-assisted development (vibe coding), we maintain clear standards for how AI tools are used.

- When client data or code must be entered into an AI tool, we use **an enterprise plan or API that is not used for model training**.
- Where a client has its own AI tool usage policy (an approved tool list, on-premises or specific-region requirements, and so on), that policy takes precedence.
- Sensitive client information (personal data, credentials, trade secrets) is removed or pseudonymized before being entered into any AI tool.
- We disclose the AI tools we use and the corresponding data flows transparently at the client's request.

## Access Control and Working Environment

- Accounts with access to client systems are limited to project members and protected with multi-factor authentication (MFA).
- Credentials (API keys, passwords, and the like) are never stored in plaintext in code or documents; they are managed through a secrets management tool.
- Work devices are protected with disk encryption and screen locking.

## Contractual Documents

For guidance on security-related agreements such as a data processing agreement (DPA) or a non-disclosure agreement (NDA), please see our [DPA guide](/en/dpa/).

## Security Inquiries and Vulnerability Reports

If you discover a security vulnerability in this website or in software developed by ROBOCO, please report it to contact@roboco.io. We will verify the report, act on it promptly, and get back to you with the outcome.
