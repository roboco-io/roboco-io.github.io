# Data Processing Agreement

> This form is a standard Data Processing Agreement draft provided by ROBOCO. Legal review by both parties is recommended before actual execution, and the clauses may be negotiated and amended according to the characteristics of the project.

**Client (Customer)**: [ Company Name ] (hereinafter the "Client")

**Processor**: ROBOCO (hereinafter the "Processor")

The Client and the Processor hereby enter into the following agreement (hereinafter this "Agreement") concerning the processing of data entrusted by the Client to the Processor in connection with the performance of [ Name of Project/Service Agreement ] (hereinafter the "Master Agreement").

## Article 1 (Purpose and Definitions)

1. The purpose of this Agreement is to set forth the rights and obligations of both parties with respect to the protection of data that the Processor receives from the Client and processes in the course of performing the Master Agreement.
2. "Data" means any and all information that the Client provides to the Processor or that the Processor accesses in the course of performing the Master Agreement, including personal information, source code, technical materials, and business information.
3. "Personal Information" means personal information as defined in Article 2 of the Personal Information Protection Act of Korea.

## Article 2 (Scope and Purpose of Processing)

1. The Processor shall process the Data only within the following scope.
   - Purpose of processing: [ e.g., performance of AI development consulting, software development ]
   - Data subject to processing: [ e.g., source code repositories, development documents, employee account information ]
   - Period of processing: the term of the Master Agreement
2. The Processor shall not use the Data for any purpose other than that set forth in Paragraph 1, nor provide it to any third party, without the prior written consent of the Client.

## Article 3 (Restrictions on Sub-processing)

1. The Processor shall not sub-entrust the processing of the Data to any third party without the prior written consent of the Client.
2. Where sub-processing has been approved, the Processor shall impose on the sub-processor obligations equivalent to those under this Agreement and shall be responsible to the Client for the sub-processor's performance thereof.
3. A list of the processing infrastructure used by the Processor, such as cloud and AI tools, shall be provided in an appendix or in writing upon the Client's request.

## Article 4 (Technical and Administrative Protection Measures)

The Processor shall implement the following measures for the protection of the Data.

1. The Processor shall minimize access rights to the Data to the personnel performing the Master Agreement and shall apply multi-factor authentication (MFA) to access accounts.
2. The Processor shall not store credentials (API keys, passwords, etc.) in plaintext and shall manage them with a secrets management tool.
3. The Processor shall apply disk encryption and screen lock to work devices.
4. Where the Data is entered into AI tools, the Processor shall use only enterprise plans or APIs that are not used for model training, and where the Client has designated an AI tool usage policy, such policy shall take precedence.
5. Sensitive information shall be removed or pseudonymized before being entered into AI tools.

## Article 5 (Notification of Security Incidents)

1. Where the Processor becomes aware of any loss, theft, leakage, forgery, alteration, or damage of the Data (hereinafter a "Security Incident"), the Processor shall notify the Client without delay and in any event no later than 72 hours after becoming aware thereof.
2. The notification shall include the circumstances of the Security Incident, the scope of its impact, and the status of and plans for remedial measures, and the Processor shall cooperate with the Client to minimize the damage and prevent recurrence.

## Article 6 (Cooperation with Audits)

1. In order to verify performance of this Agreement, the Client may request an inspection or audit up to once per year upon reasonable prior notice, and the Processor shall cooperate therewith.
2. Inspections and audits shall be conducted within a scope that does not infringe upon the information of the Processor's other clients or the Processor's trade secrets.

## Article 7 (Measures upon Termination of the Agreement)

1. Upon termination of the Master Agreement or upon the Client's request, the Processor shall without delay return the Data and access rights in its possession or destroy them by an irrecoverable method.
2. The Processor shall provide a certificate of destruction upon the Client's request.
3. Data subject to a statutory retention obligation shall be retained only within the scope of that purpose for the period prescribed by the relevant statute.

## Article 8 (Indemnification)

Where the Client suffers damage as a result of the Processor's breach of this Agreement, the Processor shall compensate for such damage. Provided, however, that the scope and limit of such compensation shall be governed by the limitation of liability provisions of the Master Agreement.

## Article 9 (Term and General Provisions)

1. This Agreement shall be effective from the date of execution until the termination date of the Master Agreement, and the obligations under Article 2, Paragraph 2 and Article 7 shall survive termination of this Agreement.
2. Matters not provided for in this Agreement shall be governed by the Master Agreement and relevant statutes.
3. This Agreement shall be construed in accordance with the laws of the Republic of Korea, and disputes shall be subject to the jurisdiction prescribed by the Master Agreement.

---

**Date of Execution**: [ Month Day, Year ]

| | Client | Processor |
|---|---|---|
| Company Name | [ ] | ROBOCO |
| By (Signature) | [ ] | [ ] |
| Name & Title | [ ] | [ ] |
| Address | [ ] | [ ] |
| Contact | [ ] | contact@roboco.io |
