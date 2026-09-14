```
THREAT MODEL REPORT
Squadar — Team Assembler
2026-09-14
Classification: Internal
Version: 1.0
```

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [Scope and Methodology](#2-scope-and-methodology)
3. [System Architecture](#3-system-architecture)
4. [Threat Inventory](#4-threat-inventory)
5. [Risk Matrix](#5-risk-matrix)
6. [Control Gap Analysis](#6-control-gap-analysis)
7. [Remediation Roadmap](#7-remediation-roadmap)
8. [Compliance Mapping](#8-compliance-mapping)
9. [Appendices](#9-appendices)

---

# 1. Executive Summary

**Overall risk assessment: Moderate — and unusually favourable, because nothing has been built yet.**

Squadar is a system for assessing, scoring and comparing the skills of named individuals. It is
specified in detail and **not implemented**: the repository contains 1,580 lines of specification and
zero lines of application code. Every one of the 48 security rules the project has written for itself
is therefore a statement of intent, not a control in place.

That makes this report a different kind of document from most threat models. **There is no running
system to be breached today.** What follows is a ranked account of the risk the current design carries
into implementation — the things that will go wrong if the code is written without deciding them
first. Acting on it now costs a fraction of what it will cost after the first release.

### Findings by severity

| Severity | Count | Meaning in this report |
| --- | --- | --- |
| Critical | 2 | Will cause a serious breach unless a specific control is deliberately built and tested |
| High | 11 | Serious impact, and the specification leaves the control undecided or unenforced |
| Medium | 16 | Real exposure, generally with a written rule that needs numbers or a decision |
| Low | 3 | Hygiene and development-boundary items |
| **Total** | **32** | |

### The five risks that matter most

1. **Anyone with an account may be able to read everyone's performance data.** The system's most
   valuable data is reachable by supplying someone else's identifier on a request. This is the single
   most common failure of APIs of this shape, and the project has described the rule in prose but has
   never written the authorization matrix that would enforce it. *(T-01)*

2. **The product's headline feature may already contradict its confidentiality promise.** The
   requirements say a Team Member must not see a colleague's scores — and then require the shared
   radar chart to label each colleague's series by name, with the same data available as a table. As
   written, the exception swallows the rule. Nobody has decided whether peers should see each other's
   scores, and if this reaches implementation undecided, a developer will decide it by accident.
   *(T-04)*

3. **Exam answer keys and exam results are one mistake away from worthless.** If answer keys travel in
   an exam payload the client merely hides, or if a submitted score is accepted from the client, every
   exam-derived score in the organization becomes meaningless — silently, with nothing in the data to
   show it. *(T-03, T-07)*

4. **The most privileged user is unchecked.** An Administrator can alter anyone's scores and is also
   the only person entitled to read the audit trail that would record them doing it. No separation of
   duties, independent log retention or review process exists. In a system whose output influences
   staffing decisions, that is a governance gap, not just a technical one. *(T-22)*

5. **Eight open questions are blocking thirteen findings.** Regulatory scope, session transport,
   account recovery, cloud provider, abuse limits, OIDC role trust, exam integrity policy, and the two
   product questions above. **Answering them is the cheapest risk reduction available on this list**,
   and none of them can be answered by an engineer at a keyboard.

### Key recommendations, in priority order

1. Hold two short decision sessions — one product (peer visibility, self-assessment), one
   privacy/legal (regulatory scope) — and record the answers in the owning specification documents.
2. Write the authorization matrix (4 roles × 22 entry points × operation) as an executable test
   fixture **before** the first endpoint exists. It is the control that most of this report depends on.
3. Add the CI security gate — tests, lint, typecheck, dependency and secret scanning, IaC scanning —
   in the same pull request as the first workspace. The project's own rules require it; the
   placeholder that stands in for it today enforces nothing.
4. Add `*.tfstate`, `*.tfstate.*`, `.terraform/` and `*.tfvars` to `.gitignore` now. One line, before
   any Terraform exists, permanently avoids a whole class of credential leak.
5. Treat the Critical and High findings here as acceptance criteria attached to the requirements they
   trace to, using the project's own `REQUIREMENT_TEMPLATE.md` — which already demands negative and
   authorization test cases per requirement.

### Compliance implications

**Undetermined, and that is itself the finding.** `REQUIREMENTS.md` states no regulated data is
stored; the security notes state GDPR and CCPA apply. The two have not been reconciled (`SQ-1`). Until
they are, retention periods, data-subject rights beyond self-export and deletion, and
breach-notification duties cannot be specified — and the system's default behaviour will be to retain
employment-relevant personal data about every individual indefinitely.

---

# 2. Scope and Methodology

## 2.1 System description

Squadar is a "Team Assembler UI": it assesses team members' skills — by exam, by assessor rating and
by self-assessment — ranks each skill from 1 to 10, and displays several members' skills together on a
shared radar chart. Four roles are defined: Administrator, Assessor, Team Member and Viewer. The
intended build is a React web client and a React Native mobile client over a shared Node.js REST API,
with a relational store, a protected store for large binary assets, passkey/password/OIDC
authentication, JWT sessions, and Terraform-managed infrastructure.

The business context matters to every severity rating in this report: **the data is a set of numeric
judgements about named individuals, in an employment setting.** Disclosure is a personal matter for
the people scored; manipulation affects who gets staffed on what.

## 2.2 Scope

**In scope:** all components, data stores, flows and trust boundaries described in `ARCHITECTURE.md`
and `SECURITY.md`; all requirements in `REQUIREMENTS.md`; the client rendering surfaces in
`DESIGN.md`; and the `.claude/` development enforcement layer as a development boundary.

**Excluded, with reasons:**

- **Deployment topology, cloud configuration and network architecture** — no provider, CI system or
  topology has been chosen (`SQ-8`), so infrastructure findings are necessarily provider-agnostic.
- **AI/ML threat modelling (MITRE ATLAS, OWASP ML Top 10)** — the product contains no AI/ML component.
  The only AI-adjacent surface is the development tooling, covered as T-32.
- **Third-party provider security (OIDC, mail)** — neither is selected. Both are modelled as external
  trust boundaries, not assessed as vendors.
- **Penetration testing and code review** — no code exists.

## 2.3 Methodology

| Methodology | Applied as | Why |
| --- | --- | --- |
| Automated Repository Analysis (prompt 05) | Full 8-phase scan | Establishes what exists versus what is intended — the decisive fact for this engagement |
| Document and Architecture Absorption (prompt 06) | Full extraction of 8 documents | The repository is documentation-first; this is the primary evidence source |
| STRIDE | Applied per component and per flow during consolidation | General-purpose coverage; the specifications are organized compatibly |
| LINDDUN | Applied to personal performance data flows | The data is personal data about identifiable individuals in an employment context |
| Consolidation (prompt 07) | Merge, deduplicate, rank, gap-analyse | Produced the unified model in `07-consolidated.cdx.json` |

**Not applied:** PASTA (no business-risk session was held), Attack Trees (recommended as follow-up for
exam integrity and insider score manipulation), FMEA (recommended as follow-up for availability at
scale), and the AI/ML interview (not applicable).

### Scoring convention — read this before section 4

No implementation exists, so conventional exploitability scoring would rate every finding zero.
Severity here rates **the risk the design carries into implementation**: impact if realized, weighted
by how likely the specifications are to be built wrong given what they leave undecided. CVSS vectors
for Critical and High findings are **design-stage estimates of the vulnerability as it would exist if
built as currently specified** — they are planning aids, not measurements of a live system. Every
control is recorded as **Specified — Not Implemented**. **No finding in this report asserts a running
vulnerability.**

## 2.4 Participants and perspectives

**No human participated.** This model was produced entirely by automated analysis. Under the
methodology's own cross-functional standard, all 32 findings are single-perspective.

| Domain | Represented | Consequence |
| --- | --- | --- |
| Security | Automated analysis only | Findings are unvalidated by a practitioner |
| Engineering | Not represented | No implementation feasibility or effort input |
| Privacy / Legal | Not represented | `SQ-1` cannot be resolved here; T-25 and T-26 stay open |
| Business / HR | Not represented | Impact ratings are inferred from context, not stated by the business |
| Operations / SRE | Not represented | Availability coverage is thin (one finding) |
| ML / Data Science | Not applicable | No AI/ML component |

Section 6.4 sets out the recommended follow-up sessions.

## 2.5 Data sources

- Repository `squadar` at commit `6441881` — complete file inventory, `.claude/` enforcement layer,
  `.gitignore`, git history.
- `REQUIREMENTS.md` (103 lines), `ARCHITECTURE.md` (270), `SECURITY.md` (748), `DESIGN.md` (228),
  `style-guide.html`, `REQUIREMENT_TEMPLATE.md` (133), `CLAUDE.md` (93), `AGENTS.md` (5).
- No API specification, schema, diagram, prior threat model, pentest report or audit exists.
- No interviews were conducted.

## 2.6 Limitations

1. **Nothing is verified against code.** Every finding must be revisited against the first
   implementation of the component it names.
2. **Single-perspective throughout** — see 2.4 and 6.4.
3. **Entry points are derived, not observed.** With no API specification, the 22 entry points in this
   report are inferred from requirements; the real surface will differ.
4. **Many inputs are self-declared assumptions.** The four roles, most privacy constraints and a
   large share of requirements are marked **(assumed)** in `REQUIREMENTS.md`. The authorization model
   rests on them and `OQ-1` may still change `FR-1.4`.
5. **Exam media may not exist.** Its existence is an assumption in `ARCHITECTURE.md`. If exams carry
   no media, T-09 and one trust boundary leave scope.
6. **Provider-specific threats are absent** pending `SQ-8`.
7. **The security notes behind `SECURITY.md` are not in the repository.** Their content is known only
   through that document's restatement, including the GDPR/CCPA claim at the centre of `SQ-1`.
8. **Availability and reliability are under-covered** — one finding, no FMEA pass.

---

# 3. System Architecture

Full diagram set in `08-diagrams.md` (ASCII, Mermaid and Graphviz for all five diagram types).

## 3.1 System context

Four human actors and three external systems surround one application. No unauthenticated product
surface exists: `FR-1.1` requires authentication before any team member, score, exam or chart data is
shown, and `SEC-AUTHN-1` restates it as a control.

- **Administrator** — accounts, roles, skill catalog, team members, exam definitions and answer keys,
  bulk import, personal-data deletion, audit trail. The highest-privilege actor, with no specified
  check on it.
- **Assessor** — records scores for members of assigned teams; assigns exams.
- **Team Member** — takes assigned exams, views and exports their own record, self-assesses.
- **Viewer** — read-only access to teams, scores and charts.
- **OIDC Identity Provider** (UNKNOWN), **Transactional Mail Provider** (TBD), **Protected Asset
  Store** (TBD).

## 3.2 Component architecture

Twelve components. The REST API is the sole enforcement point for authorization and business rules
(`DR-1`, `SEC-BOUND-1`), and both clients are declared public, untrusted code that may not be trusted
differently from one another (`DR-2`, `SEC-BOUND-2`). Each business object has exactly one owning
component (`DR-3`), and the dependency graph is acyclic (`DR-5`).

**Assessment** is the crown-jewel component: it owns scores, score history, assessment records, exams,
exam questions **and answer keys**, exam attempts, and the audit trail. Fourteen of the 32 threats
attach to it. **Identity & Access** owns users, credentials, roles and sessions. The **Chart Data
Service** produces the single dataset behind both the radar chart and its equivalent score table
(`DR-7`) — which is why the confidentiality question in T-04 cannot be solved in the client.

## 3.3 Data flow

Five primary flows: authenticate; render a shared radar chart; take and score an exam; record a
rating; administer catalog, accounts and roster. Two supporting flows carry the highest-risk data:
bulk import (Administrator-supplied files) and self export.

Data classes: **secret** (credentials, passkey material, JWT signing key, session tokens),
**personal performance data** (scores, history, exam attempts, audit entries), **personal data**
(member and team records), and **confidential system data** (exam questions, answer keys, exam media).

## 3.4 Trust boundaries

| ID | Boundary | Specified controls | Status |
| --- | --- | --- | --- |
| TB-1 | Client → REST API | 14 rules: authn, session, ABAC authz, input validation, HTTP hardening, response shaping, error handling | Specified — Not Implemented |
| TB-2 | Identity & Access ↔ OIDC provider | `SEC-AUTHN-5`, `SEC-EXT-1`, `SEC-EXT-2` | Specified — Not Implemented; role-claim trust undecided (`SQ-10`) |
| TB-3 | REST API → Protected Asset Store | `SEC-BOUND-4`, `SEC-DATA-1` | Specified — **mechanism undefined, so untestable** |
| TB-4 | Domain components → Relational Store | `SEC-INPUT-6`, `SEC-DATA-1`, `SEC-BIZ-2`, `SEC-ERR-2` | Specified — Not Implemented |
| TB-5 | Outbound Notification → mail provider | `SEC-EXT-1`, `SEC-EXT-3`, `SEC-AUTHN-8` | Specified — Not Implemented |
| TB-6 | Bulk Import ingest | `SEC-INPUT-4`, `SEC-INPUT-5`, `SEC-AUTHZ-4`, `SEC-EXT-4` | Specified — Not Implemented |
| TB-7 | Developer workstation → repository | `.claude/` hooks, deny-list, sandbox, `.gitignore` | **Implemented** — the only boundary with live controls |

`ARCHITECTURE.md` and `SECURITY.md` enumerate the six product boundaries identically, with no
contradiction between them. That consistency is worth noting: it is rare and it made this analysis
materially easier.

## 3.5 Attack surface

22 derived entry points; 15 carry a Critical or High threat; none is unauthenticated by design. The
three highest-value targets are **account and role CRUD** (leads to Administrator authority, and from
there to everything), **exam fetch and exam definition** (leads to answer keys, and from there to
silent destruction of assessment integrity), and **the chart dataset** (the whole organization's
personal performance data in one payload). Full map in `08-diagrams.md` §5.

---

# 4. Threat Inventory

Ordered by severity. Complete structured data for all 32 findings, including mitigations and residual
risk, is in `07-consolidated.cdx.json`.

---

### T-01: Broken object-level authorization on score, exam-result and export reads

**Severity:** Critical
**CVSS 3.1:** 8.1 — `AV:N/AC:L/PR:L/UI:N/S:U/C:H/I:N/A:N` *(design-stage estimate)*
**Category:** STRIDE — Information Disclosure, Elevation of Privilege · LINDDUN — Disclosure,
Identifiability · OWASP API1:2023 · CWE-639
**Affected assets:** Assessment, Chart Data Service, Bulk Import/Export; flows `flow-chart`,
`flow-export`
**Trust boundary:** TB-1

#### Description
Every read path that accepts a member identifier — score detail, exam result, self export, ranked
list, chart dataset — must re-derive entitlement from the caller's server-side authorization context
rather than honour the identifier in the request. `SEC-AUTHZ-1` and `SEC-AUTHZ-3` say so. What does
not exist, anywhere in the corpus, is the mechanism: no authorization matrix, no policy, no test
fixture. Stage 05 found this independently of stage 06, which makes it the highest-confidence finding
in the model.

#### Attack scenario
1. A Team Member signs in legitimately and observes the request their own dashboard makes.
2. They substitute a colleague's member identifier in that request.
3. The API returns the colleague's full per-skill score history and exam results.
4. Iterating over the identifier space yields the entire organization's assessment dataset.

#### Business impact
Mass exposure of employment-relevant performance data about every identifiable individual in the
organization, obtainable from any ordinary account with no special tooling. Loss of confidence in the
assessment programme; probable personal-data breach notification depending on `SQ-1`.

#### Existing controls
`SEC-AUTHZ-1`, `SEC-AUTHZ-3`, `SEC-DATA-2` — all **Specified — Not Implemented**. Effectiveness today:
none.

#### Recommended mitigations
1. Resolve object entitlement inside the owning component from the authorization context, never from a
   request-supplied identifier (`SEC-AUTHZ-2`).
2. **Build the authorization matrix as an executable test fixture before the first endpoint exists.**
   `REQUIREMENT_TEMPLATE.md` already demands authorization test cases per requirement; this is the
   fixture those tests run against.
3. Make deny-by-default structural: a new endpoint should be unreachable until a rule permits it.
4. Use unguessable identifiers as defence in depth only — never as the access control.

#### Residual risk
**Low**, given a matrix-driven test suite run in CI on every PR.

---

### T-02: Privilege escalation to Administrator

**Severity:** Critical
**CVSS 3.1:** 8.8 — `AV:N/AC:L/PR:L/UI:N/S:U/C:H/I:H/A:N` *(design-stage estimate)*
**Category:** STRIDE — Elevation of Privilege, Tampering · OWASP API3:2023, API5:2023 · CWE-269,
CWE-915
**Affected assets:** Identity & Access, REST API; flow `flow-admin`
**Trust boundary:** TB-1, TB-2

#### Description
Three routes converge on the same outcome. **(a)** Mass assignment: a profile update carrying a `role`
field bound wholesale to the user model. **(b)** Function-level: an account or role endpoint reachable
by a non-Administrator. **(c)** Federated: if `SQ-10` resolves toward trusting the OIDC provider for
role or group claims, provider compromise becomes a direct path to Administrator — and `SEC-AUTHZ-6`,
which restricts role assignment to an Administrator, is bypassed by a route no rule currently covers.

#### Attack scenario
1. A Team Member updates their own profile, appending `"role": "Administrator"`.
2. The handler binds the request body to the persistence model wholesale.
3. The next request carries Administrator authority.
4. The attacker now holds every score, every answer key, the audit trail, and the deletion capability
   — including the ability to remove the entries recording what they just did (see T-22).

#### Business impact
Total compromise of the assessment dataset and its integrity. Because the attacker also controls the
audit trail, the compromise may leave no reliable evidence.

#### Existing controls
`SEC-AUTHZ-6`, `SEC-INPUT-3`, `SEC-SESSION-2` — **Specified — Not Implemented**.

#### Recommended mitigations
1. Bind request bodies to explicit allow-listed field sets per endpoint. Never bind wholesale to a
   persistence model (`SEC-INPUT-3`).
2. Make `role` writable only by the account-administration endpoint, and forbid self-role modification
   outright — including for an Administrator.
3. **Answer `SQ-10` and record the decision:** role is assigned locally by an Administrator (`FR-1.3`)
   and any OIDC role or group claim is ignored. If the provider must be trusted, that is a separate,
   explicitly accepted risk with its own compensating controls.
4. Include self-role modification and mass-assignment cases in the standing authorization suite.

#### Residual risk
**Low**, given allow-listed binding plus the T-01 test suite.

---

### T-03: Exam answer-key disclosure through an over-returned exam payload

**Severity:** High
**CVSS 3.1:** 6.5 — `AV:N/AC:L/PR:L/UI:N/S:U/C:H/I:N/A:N` *(design-stage estimate; business impact
exceeds what the vector conveys)*
**Category:** STRIDE — Information Disclosure · OWASP API3:2023 · CWE-213
**Affected assets:** Assessment, REST API, both clients; flow `flow-exam-fetch`
**Trust boundary:** TB-1

#### Description
`NFR-9.7` forbids answer keys reaching a Team Member or Viewer at any point. The realistic failure is
not a deliberate leak but an exam object serialized whole: each question carries its correct answer,
the client hides it for display, and the network payload contains it. Error paths, cached responses,
debug output and source maps are the same hazard. `SEC-BOUND-3` and `DR-8` correctly require exclusion
*inside Assessment* rather than in a serializer or client — a distinction that is easy to state and
easy to lose.

#### Attack scenario
1. A Team Member opens an assigned exam and inspects the network response in their browser.
2. Each question carries its `correctAnswer`.
3. The answers are shared with colleagues.
4. Every exam-derived score in the organization becomes meaningless — and nothing in the data shows it.

#### Business impact
Silent, permanent loss of integrity across the entire assessment programme, which is the product's
core value. Undetectable from inside the system: the scores look normal. Recovery requires rewriting
every exam.

#### Existing controls
`SEC-BOUND-3`, `SEC-RENDER-4`, `DR-8` — **Specified — Not Implemented**.

#### Recommended mitigations
1. **Model the exam-attempt payload as a distinct type with no answer-key field to omit.** Structural
   exclusion beats filtering, and survives refactors that filtering does not.
2. Exclude inside Assessment before the response is assembled (`SEC-BOUND-3`).
3. Test against the recorded network payload, not the handler's return value, across error and debug
   paths.
4. Keep answer keys out of charts, exports, audit entries and logs (`SEC-LOG-3`).

#### Residual risk
**Low** with a payload type that cannot carry the field.

---

### T-04: Peer score exposure through the shared radar chart

**Severity:** High
**CVSS 3.1:** not applicable — this is a specification contradiction, not a vulnerability
**Category:** STRIDE — Information Disclosure · LINDDUN — Identifiability, Disclosure, Non-compliance
· CWE-200
**Affected assets:** Chart Data Service, Assessment; flow `flow-chart`
**Trust boundary:** TB-1

#### Description
`FR-1.4` forbids a Team Member viewing another individual's scores *except as part of a radar chart
for a team they belong to*. `FR-7.3` requires each series be attributed to its member by name.
`FR-6.2` requires the same data as a table. `DR-7` requires both to render from one dataset. Read
together, **the exception delivers exactly what the rule withholds, in machine-readable form.**
`SEC-AUTHZ-3` describes the chart series as "aggregated"; it is not. `OQ-1` asks the right question
and has not been answered.

This contradiction was **not** self-identified by the specification corpus. It is one of two such
findings this engagement adds.

#### Attack scenario
No attack is required. A Team Member opens a shared chart for a team they belong to and reads every
colleague's exact per-skill score from the accompanying table or the underlying payload. Where team
membership is broad, this is the whole organization.

#### Business impact
Peer-visible performance ranking with no deliberate policy behind it — in an employment context, a
morale and grievance exposure, and subject to `SQ-1`, a regulatory one. More fundamentally, **the
organization cannot state its own confidentiality posture, because the specification does not have
one.**

#### Existing controls
`SEC-AUTHZ-3` — Specified — Not Implemented, **and ambiguous as written**.

#### Recommended mitigations
1. **Answer `OQ-1` explicitly** and record it in `REQUIREMENTS.md`, which owns this fact. Three
   defensible answers: (a) peers see attributed scores — the current default, made deliberate;
   (b) peers see their own series plus an unattributed team envelope or median; (c) shared charts are
   visible only to Assessor, Administrator and Viewer roles.
2. Enforce the answer in the Chart Data Service. The dataset must not contain a value the caller may
   not see, because `DR-7` guarantees the table shows whatever the chart receives (`SEC-DATA-4`).
3. Amend `SEC-AUTHZ-3` to stop describing the series as aggregated — or make it actually aggregated.

#### Residual risk
**Low** once `OQ-1` is answered and enforced server-side.

---

### T-05: JWT verification bypass through algorithm or claim confusion

**Severity:** High
**CVSS 3.1:** 9.1 — `AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:N` *(design-stage estimate, if built naively)*
**Category:** STRIDE — Spoofing, Elevation of Privilege · OWASP API2:2023 · CWE-347
**Affected assets:** REST API, Identity & Access; flow `flow-auth`
**Trust boundary:** TB-1

#### Description
JWT is the chosen session mechanism, but algorithm, key handling and token-type split are all
TO BE DECIDED. The classic failures follow: accepting `alg: none`, accepting a caller-chosen
algorithm, confusing an asymmetric public key for an HMAC secret, or verifying the signature without
also verifying issuer, audience and expiry. `SEC-SESSION-1` names every one of these in its
verification method — the rule is right; nothing implements it.

#### Attack scenario
An attacker submits a token with `alg` set to `none`, or signs one using the published verification
key as an HMAC secret, and is granted whatever role the payload claims — with no account required.

#### Business impact
Complete authentication bypass, equivalent in outcome to T-02 but reachable without an account.

#### Existing controls
`SEC-SESSION-1`, `SEC-SECRET-2` — **Specified — Not Implemented**.

#### Recommended mitigations
1. Pin one signing algorithm server-side; reject any token whose header differs. **Never read the
   algorithm from the token to decide how to verify it.**
2. Verify signature, issuer, audience and expiry on every request.
3. Hold the signing key in the secret store, rotatable without redeploy, with an overlap window
   (`SEC-SECRET-2`).
4. Write the negative tests `SEC-SESSION-1` already specifies as part of the first authentication PR.

#### Residual risk
**Low** with a vetted library, pinned algorithm and the negative suite in CI.

---

### T-06: Stale authority — revoked or role-changed sessions keep working

**Severity:** High
**CVSS 3.1:** 6.5 — `AV:N/AC:L/PR:L/UI:N/S:U/C:H/I:L/A:N` *(design-stage estimate)*
**Category:** STRIDE — Elevation of Privilege · OWASP API2:2023 · CWE-613
**Affected assets:** Identity & Access, REST API; flows `flow-auth`, `flow-admin`
**Trust boundary:** TB-1

#### Description
Self-contained JWTs carry authority that outlives the decision granting it. `FR-1.3` lets an
Administrator deactivate an account or change a role; `SEC-SESSION-3` requires that to take effect
without waiting for token expiry — but the revocation mechanism, token lifetimes and refresh model are
all undecided (`SQ-5`). `SEC-SESSION-2` separately requires authorization-relevant claims be
re-resolved server-side rather than trusted from the token.

#### Attack scenario
An employee is deactivated during offboarding. Their existing access token remains valid for its
lifetime and every request it makes is authorized from claims baked in before the deactivation. A
demoted Assessor keeps writing scores.

#### Business impact
Offboarding and demotion do not take effect when the business believes they do. The gap between
intent and enforcement is exactly the window an aggrieved departing employee occupies.

#### Existing controls
`SEC-SESSION-2`, `SEC-SESSION-3`, `SEC-SESSION-5` — **Specified — Not Implemented**.

#### Recommended mitigations
1. Answer `SQ-5`: short-lived access token plus revocable refresh token, or server-side session state
   consulted per request.
2. Treat the token as identity only; re-resolve role, assessor team assignments and member
   correspondence from Identity & Access and Roster at authorization time (`SEC-SESSION-2`).
3. Issue a new session identifier on authentication and on any privilege change (`SEC-SESSION-5`).
4. Test that deactivation blocks the very next protected request on an already-issued token.

#### Residual risk
**Low** once `SQ-5` is answered.

---

### T-07: Exam result forgery through client-supplied score

**Severity:** High
**CVSS 3.1:** 6.5 — `AV:N/AC:L/PR:L/UI:N/S:U/C:N/I:H/A:N` *(design-stage estimate)*
**Category:** STRIDE — Tampering · OWASP API6:2023 · CWE-602
**Affected assets:** Assessment; flow `flow-exam-submit`
**Trust boundary:** TB-1

#### Description
`FR-5.7` derives a 1–10 band from the percentage of correct answers. If the submission handler accepts
a `score`, `percentage` or correct-count field from the client — or trusts a client-side computation —
the member sets their own result. `SEC-BIZ-1`, `SEC-INPUT-3` and `SEC-BOUND-1` all forbid it, which is
three independent statements of a rule with zero implementations.

#### Attack scenario
A Team Member submits an exam with an added `"score": 10`, or edits the client bundle to post a
precomputed percentage. The stored score, its method stamp of *exam-derived*, and its appearance on
every chart all attest to top marks.

#### Business impact
Worse than an answer-key leak: it requires no collusion, leaves the same trace as a legitimate result,
and directly corrupts the ranking the product exists to produce.

#### Existing controls
`SEC-BIZ-1`, `SEC-INPUT-3`, `SEC-BOUND-1` — **Specified — Not Implemented**.

#### Recommended mitigations
1. Accept only answer selections from the client; compute percentage and band server-side from the
   stored answer key.
2. Reject or ignore every server-derived field if present: score, method, source, recorded date, audit
   fields (`SEC-INPUT-3`).
3. Run the forged-score test `SEC-BIZ-1` already names.

#### Residual risk
**Low**.

---

### T-08: Assessor writes scores outside assigned teams, especially through bulk paths

**Severity:** High
**CVSS 3.1:** 6.5 — `AV:N/AC:L/PR:L/UI:N/S:U/C:N/I:H/A:N` *(design-stage estimate)*
**Category:** STRIDE — Tampering, Elevation of Privilege · OWASP API5:2023 · CWE-285
**Affected assets:** Assessment, Bulk Import/Export; flows `flow-rating`, `flow-import`
**Trust boundary:** TB-1, TB-6

#### Description
`FR-1.5` scopes an Assessor to assigned teams and `SEC-AUTHZ-4` extends that to *every* code path
including bulk operations — a clause that exists precisely because bulk paths are where per-object
authorization is habitually skipped. The check tends to sit on the request; the rows go unchecked.

#### Attack scenario
An Assessor uploads an import file, or posts a batch score payload, containing member identifiers from
teams they are not assigned to. The handler authorizes the operation once, then applies every row.

#### Business impact
Score manipulation across organizational boundaries, influencing staffing and promotion decisions
outside the actor's remit — with an audit trail that looks like routine bulk work.

#### Existing controls
`SEC-AUTHZ-4`, `SEC-INPUT-4` — **Specified — Not Implemented**.

#### Recommended mitigations
1. **Authorize per row and per target object, not per request.** The import path must call the same
   server-side rules as interactive entry (`SEC-INPUT-4`).
2. Reject the whole import rather than partially applying it (consistent with `SEC-ERR-2`).
3. Answer `SQ-9`: if bulk import runs as background work, give it its own authorization context and
   audit trail rather than an ambient one.
4. Test single and bulk paths with out-of-team identifiers, as `SEC-AUTHZ-4` specifies.

#### Residual risk
**Low**.

---

### T-09: Asset reference treated as entitlement for exam media

**Severity:** High
**CVSS 3.1:** 7.5 — `AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:N/A:N` *(design-stage estimate, if implemented as
long-lived URLs)*
**Category:** STRIDE — Information Disclosure · CWE-639, CWE-425
**Affected assets:** Protected Asset Store; flow `flow-media`
**Trust boundary:** TB-3

#### Description
`DR-9` and `SEC-BOUND-4` state that possession of a reference is not entitlement — but the
access-grant mechanism is TO BE DECIDED, so **the rule cannot currently be tested**. The common
shortcut (a long-lived signed URL, or a bucket with unguessable keys) silently converts a reference
into an entitlement and moves the access decision outside the API entirely.

#### Attack scenario
Exam media URLs are shared, cached by an intermediary, or enumerated. Anyone holding a URL retrieves
exam content indefinitely — including after the attempt window closes, and including unauthenticated
parties.

#### Business impact
Exam content leak with the same consequence as T-03: exam-derived scores stop meaning anything.

#### Existing controls
`SEC-BOUND-4` — **Specified, mechanism undefined**; `DR-9` — Specified — Not Implemented.

#### Recommended mitigations
1. Decide the grant mechanism as part of `SQ-8`: single-asset, short-lived, bound to the authorized
   actor.
2. Never make the asset store directly reachable from the internet (`SEC-CICD-3`).
3. Test that a legitimately obtained reference fails for an unentitled actor and after expiry.
4. **If exams carry no media, delete the Protected Asset Store from the architecture** and close this
   threat — its existence is currently only an assumption.

#### Residual risk
**Low**.

---

### T-10: Account recovery and emailed links become a parallel authentication route

**Severity:** High
**CVSS 3.1:** 8.1 — `AV:N/AC:H/PR:N/UI:N/S:U/C:H/I:H/A:N` *(design-stage estimate)*
**Category:** STRIDE — Spoofing · OWASP API2:2023 · CWE-640, CWE-330
**Affected assets:** Identity & Access, Outbound Notification; flows `flow-auth`, `flow-mail`
**Trust boundary:** TB-5

#### Description
Passkeys are strong; the recovery path around them usually is not, and `SQ-7` records that the path is
undefined. Separately, exam-invitation and account-access links are the only credential-bearing
artifacts leaving the system by email, and `SEC-AUTHN-8`'s requirements — single-use, time-bounded,
unguessable, recipient-bound, not session-conferring — have no chosen lifetime.

#### Attack scenario
A user loses their passkey. The recovery flow emails a link that establishes a full session. An
attacker with mailbox access, or with a predictable token, obtains a session without ever touching the
passkey. **The strong authenticator becomes decoration.**

#### Business impact
Account takeover at the strength of the weakest route rather than the advertised one. Against an
Administrator account, equivalent to T-02.

#### Existing controls
`SEC-AUTHN-8`, `SEC-AUTHN-3` — **Specified — Not Implemented**.

#### Recommended mitigations
1. Answer `SQ-7`: define the recovery path and hold it to the same assurance as the primary one. For
   privileged roles, re-enrolment verified by an Administrator rather than by an emailed link alone.
2. Generate link tokens from a cryptographic random source; store only their hash; bind to the
   recipient account; expire in minutes; invalidate on first use.
3. An exam-invitation link must authorize opening that exam — not establish a general session.
4. Decide whether password authentication is a permanent peer of passkeys or a migration path. **A
   permanent peer sets the system's true authentication strength.**

#### Residual risk
**Medium** until `SQ-7` is answered — recovery is intrinsically the weakest link in a passkey system.

---

### T-11: SQL injection through sort, filter and pagination parameters

**Severity:** High
**CVSS 3.1:** 8.8 — `AV:N/AC:L/PR:L/UI:N/S:U/C:H/I:H/A:H` *(design-stage estimate)*
**Category:** STRIDE — Tampering, Information Disclosure · CWE-89
**Affected assets:** Relational Data Store, Assessment; flow `flow-ranked`
**Trust boundary:** TB-4

#### Description
`FR-6.3` requires ordering team members by their score for a chosen skill. Sort and filter parameters
are the one place parameterization habitually fails, because a column name cannot be bound as a value
and gets concatenated instead. `SEC-INPUT-6` anticipates exactly this and requires a server-side
allow-list for sortable and filterable fields — a well-targeted rule with nothing enforcing it.

#### Attack scenario
An authenticated user supplies a crafted sort parameter concatenated into the `ORDER BY` clause,
extracting arbitrary rows — credential hashes, answer keys — through error or timing channels.

#### Business impact
Full database disclosure or modification from any authenticated account: the worst single outcome
available in this system.

#### Existing controls
`SEC-INPUT-6`, `SEC-INPUT-1` — **Specified — Not Implemented**.

#### Recommended mitigations
1. Parameterize every value; map sortable and filterable fields through a **server-side allow-list to
   fixed column expressions**, never interpolating the caller's string.
2. Give each domain component a database identity limited to the tables it owns (`DR-4`), so injection
   in one component cannot reach another's data.
3. Include injection payloads in sort and filter parameters in the standing test suite.

#### Residual risk
**Low**.

---

### T-12: Stored XSS through names and chart labels, chained to session theft

**Severity:** High
**CVSS 3.1:** 8.0 — `AV:N/AC:L/PR:L/UI:R/S:C/C:H/I:H/A:N` *(design-stage estimate)*
**Category:** STRIDE — Tampering, Elevation of Privilege · CWE-79
**Affected assets:** Web Client, Mobile Client; flow `flow-chart`
**Trust boundary:** TB-1

#### Description
Every displayed name here is user-supplied and crosses between users: member names, team names, skill
names, exam question text, import error messages, and chart axis and legend labels. React escapes by
default — **but the radar chart is the exception.** Chart labels are frequently rendered into SVG or
canvas by a library, outside React's escaping, and that library is TO BE DECIDED. Combined with a
session token reachable from script (`SEC-SESSION-4` forbids it, but transport is undecided under
`SQ-5`), any XSS becomes account takeover.

#### Attack scenario
1. An Assessor names a skill with a script payload.
2. Every user who loads a chart containing that axis executes it.
3. The attacker collects sessions — including an Administrator's, escalating to T-02.

#### Business impact
Account takeover chained from an ordinary data-entry field, with the privileged-user path as the
natural end state.

#### Existing controls
`SEC-RENDER-1`, `SEC-RENDER-2`, `SEC-SESSION-4` — Specified — Not Implemented. `SEC-HTTP-7` (CSP) —
Specified, directives TO BE DECIDED.

#### Recommended mitigations
1. **Choose the chart library under `DEP-1`…`DEP-8` with this threat as an explicit criterion**, and
   verify how it renders text before adopting it. This is the most security-relevant dependency
   decision the project will make.
2. Render chart labels as text nodes from structured values; never interpolate a server string into
   SVG, style or canvas markup.
3. Lint-ban raw-HTML injection props; test every displayed name field with markup payloads.
4. Keep the session token out of any script-readable store; decide the CSP directives `SEC-HTTP-7`
   defers.
5. Validate URL schemes against an allow-list wherever server data becomes a link (`SEC-RENDER-3`).

#### Residual risk
**Low**.

---

### T-13: Terraform provisions a publicly reachable data store or asset store

**Severity:** High
**CVSS 3.1:** 9.1 — `AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:N` *(design-stage estimate)*
**Category:** STRIDE — Information Disclosure · CWE-1188
**Affected assets:** Terraform infrastructure, both data stores; flow `flow-deploy`
**Trust boundary:** TB-7

#### Description
The single most common cause of mass data exposure in cloud systems is an unintentionally public
storage resource. `SEC-CICD-3` forbids it unless explicitly intended and documented, and requires IaC
scanning in CI — but no cloud provider, CI system or Terraform code exists (`SQ-8`), so neither the
rule nor the scanner has anything to act on. `hooks/run-tests.sh` is a documented placeholder.

#### Attack scenario
The first infrastructure PR creates an object store for exam media with default or over-broad access,
or a database reachable from the internet. Nothing in the repository detects it.

#### Business impact
Unauthenticated exposure of the entire personal performance dataset and exam content — **bypassing
every application control in this model**.

#### Existing controls
`SEC-CICD-3`, `SEC-DATA-1` — Specified; no CI exists to enforce either.

#### Recommended mitigations
1. **Configure an IaC scanner in CI in the same PR that introduces the first `.tf` file**, not after.
   `SEC-CICD-6` already requires security checks to block merge.
2. Default every data resource to private with explicit deny; require a documented exception for any
   publicly reachable resource.
3. Assert encryption at rest and in transit at the Terraform level, satisfying `SEC-DATA-1` by
   construction.
4. Answer `SQ-8` before the first infrastructure PR so provider-specific controls can be specified
   rather than improvised.

#### Residual risk
**Low** with scanning plus a documented exception process.

---

## Medium-severity findings

Full detail — description, attack scenario, controls, mitigations and residual risk — for each is in
`07-consolidated.cdx.json`.

| ID | Threat | Category | Affected | Key mitigation | Gated on |
| --- | --- | --- | --- | --- | --- |
| T-14 | Self-assessment inflates a member's own charted score | Tampering | Assessment, Chart | Answer `OQ-3`; carry method into the chart dataset | `OQ-3` |
| T-15 | Exam collusion, retake abuse, undefined attempt validity | Tampering, Repudiation | Assessment | Answer `SQ-11` with an exam integrity policy | `SQ-11` |
| T-16 | CSRF on state-changing endpoints | Tampering | API, Web Client | Answer `SQ-5`; resolve `SEC-HTTP-3` from conditional to required | `SQ-5` |
| T-17 | Credential stuffing and password brute force | Spoofing | Identity & Access | Per-account throttling; MFA or passkey-only for privileged roles | `SQ-3`, `SQ-7` |
| T-18 | Account enumeration | Information Disclosure | Identity & Access | Uniform response shape, status **and timing** | — |
| T-19 | Resource exhaustion via charts, ranked lists, import | Denial of Service | Chart, API, Import, DB | Answer `SQ-9`; enforce chart limits server-side | `SQ-9` |
| T-20 | Concurrent score writes break one-current-score | Tampering | Assessment, DB | Partial unique index plus one transaction | — |
| T-21 | Partial writes leave a score without its audit entry | Repudiation | Assessment, Import | Score, history and audit in one transaction | — |
| T-22 | Audit trail not tamper-evident; Administrator unchecked | Repudiation, Tampering | Assessment, DB | Independent append-only sink; separation of duties | — |
| T-23 | Personal data, tokens or answer keys in logs | Information Disclosure | API, IAM, Assessment | Redaction in the shared logging adapter | — |
| T-24 | Formula and content injection via import **and export** | Tampering | Bulk Import/Export | Neutralize formula characters on export; extend `SEC-INPUT-5` | — |
| T-25 | Deletion leaves residue; deletion versus audit unresolved | Info. Disclosure, Non-compliance | Roster, Assessment, Chart | Answer `SQ-6`; enumerate every surface deletion must sweep | `SQ-6` |
| T-26 | Retention undefined because regulatory scope is contradictory | Non-compliance, Linkability | Assessment, IAM | **Answer `SQ-1`**; set retention per data class regardless | `SQ-1`, `SQ-12` |
| T-27 | SSRF through dereferenced URLs | Info. Disclosure, EoP | API, Import | Do not dereference caller-supplied URLs at all | `SQ-8` |
| T-28 | Supply chain compromise in npm and Terraform trees | Tampering, EoP | All builds | Lockfile plus scanning from the first `package.json` | — |
| T-29 | Secrets in source, client bundles or Terraform state | Information Disclosure | IaC, clients, API | **Add `*.tfstate*`, `.terraform/`, `*.tfvars` to `.gitignore` now** | `SQ-8` |

**T-22 deserves a note beyond its severity.** It is the only finding in this report that no existing
`SEC-*` rule addresses, and it is a governance question rather than a technical one: the Administrator
can alter employment-relevant records and is also the sole party entitled to read the trail recording
it. Closing it requires a new requirement in `REQUIREMENTS.md`, not a code change.

**T-24 has an asymmetry worth flagging.** `SEC-INPUT-5` covers import thoroughly and does not cover
export at all — yet the export side is where a stored name becomes an executable formula on an
Administrator's workstation. The rule should be extended.

## Low-severity findings

| ID | Threat | Key mitigation |
| --- | --- | --- |
| T-30 | Personal or sensitive content in outbound email | Notify and link; never carry the value (`SEC-EXT-3`) |
| T-31 | Real personal data in the `UT-10.1` test fixture | Commit a generator, not data; CI check per `SEC-DATA-5` |
| T-32 | Development-boundary: unenforced test gate; specs as an agent instruction channel | Enable `run-tests.sh` with the first workspace; treat spec files as security-relevant paths |

---

# 5. Risk Matrix

## 5.1 Risk heat map

```
            IMPACT ->      Low          Moderate        Major         Severe
  LIKELIHOOD
  (as built            +------------+--------------+--------------+--------------+
   as specified)       |            |              |              |              |
  Very likely          |            | T-23  T-31   | T-14  T-24   | T-01  T-03   |
  (no mechanism        |            |              | T-18  T-30   | T-04  T-07   |
   exists at all)      |            |              |              | T-26         |
                       +------------+--------------+--------------+--------------+
  Likely               |   T-32     | T-21  T-20   | T-15  T-16   | T-02  T-11   |
  (rule written,       |            |              | T-19  T-25   | T-08  T-13   |
   decision missing)   |            |              | T-28         | T-12  T-22   |
                       +------------+--------------+--------------+--------------+
  Possible             |            |              | T-17  T-27   | T-05  T-06   |
  (rule written and    |            |              | T-29         | T-09  T-10   |
   specific)           |            |              |              |              |
                       +------------+--------------+--------------+--------------+

  Likelihood here means "likely to be built wrong", not "likely to be attacked".
```

## 5.2 Risk by category

| STRIDE | Count | | LINDDUN | Count |
| --- | --- | --- | --- | --- |
| Information Disclosure | 13 | | Identifiability | 4 |
| Tampering | 11 | | Disclosure of information | 4 |
| Elevation of Privilege | 7 | | Non-compliance | 3 |
| Repudiation | 4 | | Linkability | 1 |
| Spoofing | 3 | | Detectability | 1 |
| Denial of Service | 1 | | | |

**Information Disclosure and Tampering dominate** — the right shape for a system whose product is a
set of judgements about people. The thin Denial of Service coverage reflects a missing FMEA pass, not
an absence of availability risk (see 6.4).

## 5.3 Risk by component

| Rank | Component | Threats | Why |
| --- | --- | --- | --- |
| 1 | Assessment | 14 | Owns scores, history, exams, **answer keys**, attempts and audit |
| 2 | REST API | 11 | Sole enforcement point — every authorization failure lands here |
| 3 | Identity & Access | 8 | Authentication, sessions, roles |
| 4 | Bulk Import / Export | 6 | File ingest plus a bulk write path that bypasses interactive checks |
| 5= | Chart Data Service | 5 | The peer-visibility contradiction and the amplification primitive |
| 5= | Relational Data Store | 5 | Injection, retention, encryption |

## 5.4 Risk trend

Not applicable. `SECURITY.md` records its threat model status as `TO BE COMPLETED`; this is the first
structured threat model for Squadar and establishes the baseline. Re-run this pipeline after the first
implementation PR and diff against `07-consolidated.cdx.json`.

---

# 6. Control Gap Analysis

## 6.1 Controls inventory

| Control set | Count | Verified in code | Claimed in docs | Not found |
| --- | --- | --- | --- | --- |
| `SEC-*` security rules | 48 | **0** | 48 | 0 |
| `DEP-*` dependency rules | 8 | **0** | 8 | 0 |
| Development-boundary controls (`.claude/`, `.gitignore`) | 6 | **5** | 1 | 0 |

**Every product control is Claimed — Not Verified**, and more precisely *Specified — Not Implemented*.
`SECURITY.md`'s CONFIRMED / PROVISIONAL labels describe **provenance** (traceable to a requirement
versus chosen as a safe default), not implementation status. Reading CONFIRMED as "in place" is the
single most damaging misinterpretation available in this repository, and this report states the
distinction explicitly for that reason.

The five implemented controls are all development-time: `protect-files.sh`, `block-dangerous.sh`,
`audit.sh`, the `settings.json` permission deny-list and sandbox, and `.gitignore`. The sixth,
`run-tests.sh`, is a documented placeholder that enforces nothing.

## 6.2 Gap analysis

**Threats with a written rule but no mechanism:** 29 of 32. This is the expected state pre-build; the
work is to convert rules into tests as each requirement is implemented, which
`REQUIREMENT_TEMPLATE.md` already mandates.

**Threats with no covering rule at all:** three, and they are the ones to act on first because nobody
is currently responsible for them.

| Threat | Why no rule covers it | Where the fix belongs |
| --- | --- | --- |
| T-04 peer score exposure | A contradiction between requirements; `SEC-AUTHZ-3` inherits the ambiguity | `REQUIREMENTS.md` — answer `OQ-1` |
| T-14 self-assessment inflation | Follows from `FR-5.2` + `FR-4.6` + `FR-5.10`; not seen as a security matter | `REQUIREMENTS.md` — answer `OQ-3` |
| T-22 unchecked Administrator | `SEC-LOG-4` is application-level only; no separation of duties exists anywhere | `REQUIREMENTS.md` — new requirement |

**Rules that need extending rather than implementing:** `SEC-INPUT-5` (covers import, not export —
T-24); `SEC-AUTHZ-3` (describes chart series as aggregated when they are not — T-04); `SEC-BOUND-4`
(untestable until the grant mechanism is chosen — T-09).

**Boundaries with a specification-level gap, not just an implementation one:** TB-3 (grant mechanism
undefined) and TB-1 (session transport undecided, leaving `SEC-HTTP-3` conditional).

## 6.3 Defence in depth

Squadar's architecture has one deliberate single point of failure: **the REST API is the sole
enforcement point** (`DR-1`, `SEC-BOUND-1`). That is a sound decision — a single enforcement point is
far better than authorization scattered across clients — but it concentrates risk, and three
consequences follow:

1. **An authorization bug in the API has no backstop.** T-01 and T-02 are therefore rated at the top
   of this report: nothing else in the system would catch them. The mitigation is depth *within* the
   API — deny by default, per-object checks in the owning component, and the authorization matrix as a
   standing test suite.
2. **Database-layer constraints are the only independent integrity control specified.** `SEC-BIZ-2`
   requires the one-current-score invariant be enforced in the store as well as in application logic.
   This pattern should be extended: a database constraint is the one control that survives an
   application bug (T-20).
3. **Detection is weak relative to prevention.** `SEC-LOG-1` and `SEC-LOG-2` specify what to log;
   nothing specifies who reads it, what triggers an alert, or how an incident is handled (`SQ-12`).
   Combined with T-22, the system as specified would likely not notice a successful insider attack.

**Positive observations, which are genuinely unusual at this stage:** the client/server trust
relationship is stated unambiguously and the same for both clients; data exclusion is required in the
owning component rather than a view layer (`DR-8`); the chart and its table come from one dataset so
they cannot disagree (`DR-7`); and the specifications mark their own assumptions and open questions
rather than papering over them.

## 6.4 Cross-functional coverage analysis

**No human participated in this engagement.** All 32 findings are single-perspective.

| Component | Security | Engineering | Privacy | Business | Operations |
| --- | --- | --- | --- | --- | --- |
| REST API | Automated | Not assessed | Not assessed | Not assessed | Not assessed |
| Identity & Access | Automated | Not assessed | Not assessed | Not assessed | Not assessed |
| Assessment | Automated | Not assessed | Partial | **Needed** | Not assessed |
| Chart Data Service | Automated | Not assessed | **Needed** | **Needed** | Not assessed |
| Roster / Skill Catalog | Automated | Not assessed | **Needed** | Not assessed | Not assessed |
| Bulk Import / Export | Automated | Not assessed | Not assessed | Not assessed | Not assessed |
| Data stores | Automated | Not assessed | **Needed** | Not assessed | **Needed** |
| Terraform infrastructure | Automated | Not assessed | Not assessed | Not assessed | **Needed** |

**Highest-confidence findings** (corroborated by two independent analysis stages): **T-01** — derived
from requirements by stage 06 and independently confirmed by stage 05's discovery that no
authorization matrix exists in any form. **T-29** — the `.gitignore` gap is directly observable, not
inferred.

**Findings most likely to be incomplete** (single perspective, and the perspective that matters is
absent): T-04 and T-14 need a product and HR view; T-25 and T-26 need privacy and legal; T-13, T-27
and T-29 need platform engineering; T-19 needs SRE.

**Unresolved disagreements requiring facilitated resolution:**

| ID | Question | Tracked as | Who must decide |
| --- | --- | --- | --- |
| D-1 | Is regulated personal data in scope? | `SQ-1` | Privacy or legal counsel with the product owner |
| D-2 | May peers see each other's attributed scores? | `OQ-1` | Product owner with HR or people operations |
| D-3 | Should self-assessed scores drive the chart? | `OQ-3` | Product owner |

None should be resolved by an implementer at a keyboard — which is exactly what will happen if they
reach the first PR unanswered.

**Recommended follow-up sessions, in priority order:**

1. Product owner + HR — `OQ-1`, `OQ-3`. Two decisions, both blocking, neither answerable by engineering.
2. Privacy or legal + product owner — `SQ-1`. Gates retention, deletion semantics, rights and breach duties.
3. Security engineer + developer, STRIDE (prompt 00) — validate the 13 Critical and High findings
   against the first implementation design.
4. Platform engineer — `SQ-8`, making T-13, T-27 and T-29 provider-specific.
5. Red team, Attack Trees (prompt 03) — objectives *obtain the answer key* and *alter a colleague's
   score undetected*.
6. SRE, FMEA (prompt 04) — availability at `NFR-9.3` scale.

---

# 7. Remediation Roadmap

Effort is indicative and assumes the project's stated workflow (one requirement per PR, tests landing
with the change).

### Immediate — before the first implementation PR

| Priority | Threat | Remediation | Effort | Owner |
| --- | --- | --- | --- | --- |
| 1 | T-04, T-14 | Answer `OQ-1` and `OQ-3`; record in `REQUIREMENTS.md` | 1 meeting | Product owner + HR |
| 2 | T-25, T-26 | Answer `SQ-1`; record jurisdiction, controller/processor role, retention per data class | 1 meeting + write-up | Privacy/legal + product |
| 3 | T-01, T-02 | Write the authorization matrix (roles × entry points × operations) as an executable fixture | 2–3 days | Security + developer |
| 4 | T-29 | Add `*.tfstate`, `*.tfstate.*`, `.terraform/`, `*.tfvars` to `.gitignore` | 5 minutes | Any developer |
| 5 | T-06, T-12, T-16 | Answer `SQ-5`; resolve `SEC-HTTP-3` from conditional to required or not-applicable | 1 decision | Security + developer |
| 6 | T-02 | Answer `SQ-10`: role is assigned locally; OIDC role claims are ignored | 1 decision | Security + product |
| 7 | T-22 | Add a requirement for independent audit retention and separation of duties on deletion and role assignment | 0.5 day | Security + product |

### Short-term — first one to two sprints, landing with the first workspaces

| Priority | Threat | Remediation | Effort | Owner |
| --- | --- | --- | --- | --- |
| 8 | T-28, T-13, T-29 | CI gate in the first `package.json` PR: `npm ci`, lint, typecheck, test, dependency scan, secret scan; IaC scan in the first `.tf` PR | 2–3 days | DevOps + security |
| 9 | T-32 | Enable `run-tests.sh`; add the `PreToolUse` commit hook `CLAUDE.md` describes | 0.5 day | Developer |
| 10 | T-05, T-06 | JWT verification with a pinned algorithm; re-resolve authorization attributes server-side; revocable sessions | 3–5 days | Developer |
| 11 | T-01, T-08 | Deny-by-default authorization middleware; per-object and per-row checks in owning components | 3–5 days | Developer |
| 12 | T-03, T-07 | Exam-attempt payload type with no answer-key field; server-side scoring from the stored key | 2–3 days | Developer |
| 13 | T-11, T-19 | Allow-listed sort and filter fields; server-side chart and pagination limits | 2 days | Developer |
| 14 | T-31 | `UT-10.1` fixture as a committed generator, with a CI check that seeds are generated | 1 day | Developer |

### Medium-term — one to three months

| Priority | Threat | Remediation | Effort | Owner |
| --- | --- | --- | --- | --- |
| 15 | T-12 | Select the chart library under `DEP-1`…`DEP-8` with XSS behaviour as a criterion; CSP directives | 2–3 days | Developer + security |
| 16 | T-10, T-17 | Recovery path design; per-account throttling; MFA or passkey-only for privileged roles | 1 week | Security + developer |
| 17 | T-20, T-21 | Database constraint for one-current-score; score, history and audit in one transaction | 2–3 days | Developer |
| 18 | T-24, T-27 | Import and **export** hardening; stop dereferencing caller-supplied URLs | 2–3 days | Developer |
| 19 | T-15 | Exam integrity policy (`SQ-11`): attempt window, timing, retakes, question pools | 1 week | Product + developer |
| 20 | T-23, T-18 | Redaction in the shared logging adapter; uniform auth responses including timing | 2 days | Developer |
| 21 | T-09, T-13 | Asset grant mechanism; private-by-default infrastructure with documented exceptions | 1 week | Platform + security |

### Long-term — architectural

| Priority | Threat | Remediation | Effort | Owner |
| --- | --- | --- | --- | --- |
| 22 | T-22 | Independent, tamper-evident audit sink outside Administrator authority; defined review process | 2 weeks | Security + platform |
| 23 | T-25 | Deletion that sweeps every surface — caches, derived views, saved teams, backups, search | 1–2 weeks | Developer |
| 24 | T-26 | Enforced retention per data class, with automated expiry | 1–2 weeks | Developer + privacy |
| 25 | T-19 | Read model or index strategy for `NFR-9.1` at `NFR-9.3` scale | 2 weeks | Developer + SRE |
| 26 | — | Answer `SQ-12`: incident response path, named parties, timeframes | 1 week | Security + leadership |
| 27 | — | Re-run this pipeline against the first implementation and diff the model | 2 days | Security |

---

# 8. Compliance Mapping

| Framework | Status | Notes |
| --- | --- | --- |
| **GDPR** | **Undetermined** | `SQ-1` is unresolved: `REQUIREMENTS.md` says no regulated data is stored; the security notes invoke GDPR. Jurisdiction, establishment, data-subject residency and controller/processor role are all UNKNOWN. If GDPR applies, Art. 5(1)(e) storage limitation and Art. 17 erasure are **not met** (T-25, T-26); Art. 15 access is partially served by `FR-8.3`; Art. 32 security of processing is specified but unimplemented. |
| **CCPA/CPRA** | **Undetermined** | Same blocker. Deletion (`FR-8.4`) and portability (`FR-8.3`) exist as requirements; retention and opt-out are undefined. |
| **OWASP API Security Top 10 (2023)** | **Non-compliant — nothing implemented** | API1 BOLA → T-01. API2 Broken Authentication → T-05, T-06, T-10, T-17. API3 Object Property Level Authorization → T-02, T-03. API4 Unrestricted Resource Consumption → T-19. API5 Function Level Authorization → T-02, T-08. API6 Sensitive Business Flows → T-07, T-15. API7 SSRF → T-27. API8 Security Misconfiguration → T-13, T-16. API9 Inventory Management → no API specification exists. API10 Unsafe Consumption of APIs → `SEC-EXT-2`. **Every item is addressed by a written rule; none by a control.** |
| **OWASP Top 10 (2021)** | **Non-compliant — nothing implemented** | A01 Broken Access Control → T-01, T-02, T-08, T-09. A02 Cryptographic Failures → `SEC-DATA-1` undecided. A03 Injection → T-11, T-12, T-24. A04 Insecure Design → T-04, T-14, T-22. A05 Misconfiguration → T-13. A06 Vulnerable Components → T-28. A07 Auth Failures → T-05, T-06, T-10, T-17. A08 Integrity Failures → T-28, T-07. A09 Logging Failures → T-21, T-22, T-23. A10 SSRF → T-27. |
| **OWASP ASVS 5.0.0** | **Target level not set** | `SQ-3` is unresolved. `SECURITY.md` references ASVS generally and correctly declines to cite requirement identifiers it has not verified. **No verification bar is set, so "secure enough to ship" is currently undefined.** |
| **SOC 2 (Security, Confidentiality, Privacy)** | **Not assessed — no operating system to evidence** | CC6 logical access is specified but unimplemented; CC7 monitoring has no defined review or response (`SQ-12`); CC8 change management is partially addressed by the branch, review and merge rules in `CLAUDE.md`, but the merge gate itself is a placeholder (T-32). |
| **PCI DSS** | **Not applicable** | No payment data. |
| **HIPAA** | **Not applicable** | No health data. |
| **FERPA** | **Not applicable as specified** | `SECURITY.md` mentions an education context but assumes no FERPA obligation. Confirm during `SQ-1`, since an education context is precisely where it would apply. |

**The honest summary:** no compliance claim can be made about Squadar today, and the first blocker is
not a control — it is the unresolved question of which regime applies.

---

# 9. Appendices

### A. CycloneDX Threat Modeling Blueprint 2.0 data
- `07-consolidated.cdx.json` — the unified model: 16 assets, 10 actors and threat agents, 8 data sets,
  7 trust boundaries, 13 flows, 32 threats, 7 coverage gaps, 3 disagreements.
- `05-repository-recon.cdx.json`, `06-document-absorption.cdx.json` — upstream fragments.

### B. Diagram set
`08-diagrams.md` — system context, container/component, data flow, threat-annotated architecture and
attack surface map, each in ASCII, Mermaid and Graphviz DOT.

### C. Interview notes
None. No interviews were conducted — see §2.4 and §6.4.

### D. Repository analysis
`05-repository-recon.md` — eight-phase reconnaissance. Headline: no application code exists; the only
implemented controls are the `.claude/` development enforcement layer.

### E. Document sources
`06-document-absorption.md` — eight documents processed, eight conflicts identified (`C-1`…`C-8`), ten
documentation gaps, and recommendations for the five documents Squadar most needs and does not have.

### F. Glossary

| Term | Meaning |
| --- | --- |
| **ABAC** | Attribute-based access control — decisions from attributes (role, team membership) rather than role alone |
| **BOLA** | Broken Object Level Authorization — honouring an object identifier without checking entitlement to it |
| **Claimed — Not Verified** | A control documented as intended, with no evidence it exists |
| **Specified — Not Implemented** | Stronger: the control is written as a rule and no code exists at all. The status of every `SEC-*` rule in Squadar |
| **CONFIRMED / PROVISIONAL** | `SECURITY.md`'s own labels, describing a rule's **provenance**, not its implementation status |
| **LINDDUN** | Privacy threat methodology: Linkability, Identifiability, Non-repudiation, Detectability, Disclosure, Unawareness, Non-compliance |
| **Personal performance data** | This model's term for skill scores, history, exam attempts and audit entries — personal data about identifiable individuals in an employment context |
| **STRIDE** | Spoofing, Tampering, Repudiation, Information Disclosure, Denial of Service, Elevation of Privilege |
| **`OQ-n` / `SQ-n`** | Open product questions (`REQUIREMENTS.md`) and open security questions (`SECURITY.md`) — unresolved by design, not oversights |
| **Trust boundary** | A point where the trust level of data or a caller changes and a control must exist |

---

*Threat model produced 2026-09-14 against commit `6441881` using the CycloneDX Threat Modeling
Blueprint 2.0 pipeline (stages 05, 06, 07, 08, 10). No human participated; see §2.4 and §6.4 for what
that means for confidence in these findings.*
