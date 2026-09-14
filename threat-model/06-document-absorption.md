# 06 — Document and Architecture Absorption

**Target:** `squadar` @ `6441881`
**Date:** 2026-09-14
**Companion data:** `06-document-absorption.cdx.json`

This repository is **documentation-first**: the specifications are the system. Stage 06 is therefore
the primary evidence source for this engagement, and stage 05 is the corroborating one — the reverse
of the usual arrangement.

---

## Documents processed

| Document | Type | Lines | Extracted |
| --- | --- | --- | --- |
| `REQUIREMENTS.md` | Requirements specification | 103 | 4 actors, 8 business objects, 5 core workflows, 55 FR, 7 NFR, 1 UT, 6 open questions (`OQ-1`…`OQ-6`) |
| `ARCHITECTURE.md` | Architecture specification | 270 | 12 components with ownership, 5 primary flows, 6 trust boundaries, 10 dependency rules (`DR-1`…`DR-10`), a requirement traceability matrix, ~20 open decisions |
| `SECURITY.md` | Threat model and security rules | 748 | 48 `SEC-*` rules with applies-to and verification method, 8 `DEP-*` rules, 19 external references, a rule-to-requirement traceability matrix, 12 open security questions (`SQ-1`…`SQ-12`) |
| `DESIGN.md` | Design language | 228 | Rendering surfaces, color/contrast rules, WCAG 2.2 AA conformance target, chart conventions including non-color series encoding |
| `style-guide.html` | Rendered design reference | 22 KB | The client rendering surface; the DOM shapes on which `SEC-RENDER-1`…`3` will be enforced |
| `REQUIREMENT_TEMPLATE.md` | Process artifact | 133 | Required issue structure, acceptance criteria and traceability obligations including negative and authorization test cases |
| `CLAUDE.md` / `AGENTS.md` | Contributor and agent instructions | 93 / 5 | Workflow, branch and merge rules, security-review gate, dependency justification requirement, enforcement inventory |
| `.claude/*` | Enforcement layer | — | Hooks, agents, commands, permission and sandbox settings (see stage 05) |

**No API specification, no OpenAPI or GraphQL schema, no architecture diagram, no prior threat model,
no penetration test report, no compliance audit and no data protection impact assessment exists.**
`SECURITY.md` records its own threat model status as `TO BE COMPLETED` — this engagement is the first
structured per-flow threat enumeration performed against Squadar.

**Staleness:** no document carries a date. All eight were last modified on 2026-09-14 and the last
five commits are same-day, so the corpus is internally current and none is flagged stale.

---

## What the documents establish

**Actors.** Administrator, Assessor, Team Member, Viewer — all four marked **(assumed)** at source.
Non-human: OIDC provider, mail provider.

**Trust boundaries.** Six, enumerated identically in `ARCHITECTURE.md` and `SECURITY.md` with no
contradiction between them. The clients are declared public, untrusted code and the REST API is
declared the sole enforcement point.

**Data.** Personal performance data about identifiable individuals (scores, history, attempts, audit
entries), confidential system data (exam questions and answer keys, exam media), and secrets
(credentials, passkey material, JWT signing key, session tokens).

**Controls claimed.** 48 security rules, each with an applies-to scope and a stated verification
method. `SECURITY.md` self-labels each CONFIRMED (traceable to a requirement, architecture rule or
security note) or PROVISIONAL (a safe default chosen in that document). **That label describes
provenance, not implementation.** Per stage 05, every one of the 48 is recorded here as
**Claimed — Not Verified**, and more precisely as *Specified — Not Implemented*, since no code exists
to verify against.

**Requirements with security weight extracted as obligations:** FR-1.1…FR-1.7 (authentication and
authorization), FR-4.2/FR-4.3 (score range), FR-5.6/FR-5.7 (exam assignment and server-side scoring),
FR-7.6/FR-7.7 (chart limits), FR-8.2 (import validation), FR-8.3 (self-scoped export), FR-8.4
(deletion), NFR-9.6 (audit trail), NFR-9.7 (answer-key confidentiality).

---

## Conflicts and contradictions found

These are the highest-value output of document absorption. Each is carried into the consolidated
model as a finding, not silently resolved.

### C-1 — Regulatory scope is self-contradictory *(already logged as `SQ-1`)*

`REQUIREMENTS.md` states *"No special-category or regulated data is stored."* The security notes
behind `SECURITY.md` state the education context is protected by **GDPR and CCPA**. `SECURITY.md`
records the conflict but cannot resolve it: jurisdiction, establishment, data-subject residency, and
whether Squadar is controller or processor are all UNKNOWN.

**Why it matters beyond the paperwork:** lawful basis, the data-subject rights the system must serve
beyond FR-8.3/FR-8.4, breach-notification duties, and every retention period in `SEC-DATA-6` are
blocked behind this. It also changes the severity of the deletion and retention findings below. This
is the single most consequential unresolved item in the corpus.

### C-2 — The radar chart contradicts the Team Member confidentiality rule

`FR-1.4`: a Team Member *"MUST NOT be able to view another individual's scores except as part of a
radar chart for a team they belong to."*
`FR-7.3`: the chart *"MUST visually distinguish each team member's series ... and MUST identify which
series belongs to which team member."*
`FR-6.2`: the same data *"MUST be visible in a tabular or list form as well as within the radar
chart"*, and `DR-7` requires both to render from **one** dataset.

Read together, a Team Member on a shared chart receives every peer's per-skill score, attributed by
name, in machine-readable form — the chart is not an aggregate. The "except as part of a radar chart"
carve-out is therefore not a narrow exception; it is the general case, and `SEC-AUTHZ-3` inherits the
ambiguity ("plus the aggregated chart series for a team they belong to" — the series is not
aggregated). `OQ-1` asks the right question but has not been answered.

**Consequence:** the confidentiality boundary between peers is undefined, and any implementation will
resolve it by accident. Carried as `T-13`.

### C-3 — Authorization model: single role versus ABAC *(already logged as `SQ-2`)*

`FR-1.2` assigns *exactly one role* per user. The security notes specify ABAC. `SECURITY.md` takes
the reading that role is one attribute inside a broader ABAC policy, and flags that the policy
language, decision-point placement and attribute source of record are undecided. The reading is
reasonable; the gap is that no authorization matrix exists in any document.

### C-4 — Deletion versus the audit trail *(already logged as `SQ-6`)*

`FR-8.4` requires an Administrator to delete a team member's personal data such that the member and
their scores appear nowhere. `NFR-9.6` requires an immutable audit entry naming who changed which
member's score and when, and `SEC-LOG-4` makes those entries append-only. The two obligations pull
against each other and `ARCHITECTURE.md` independently records the same open decision (erasure versus
irreversible anonymization). Nothing decides it.

### C-5 — Role assertion by the OIDC provider *(already logged as `SQ-10`)*

`FR-1.3` makes role assignment an Administrator-only operation. The OIDC path is undefined on this
point. If the provider may assert role or group membership, provider compromise becomes a direct
privilege-escalation path into Administrator, and `SEC-AUTHZ-6` is bypassed by a route no rule
currently covers.

### C-6 — Session transport undecided, so CSRF posture is undecided *(already logged as `SQ-5`)*

`SEC-HTTP-3` is explicitly CONDITIONAL: CSRF defenses apply only if the web session is carried as an
ambient credential. `SEC-SESSION-4` forbids `localStorage`/`sessionStorage`, which pushes toward a
cookie — which activates `SEC-HTTP-3`. The corpus never closes the loop.

### C-7 — Self-assessment can raise a member's own current score *(already logged as `OQ-3`)*

`FR-5.2` permits self-assessment. `FR-4.6` makes the most recent score the current one. `FR-5.10`
propagates the updated score to radar charts. Read literally, a Team Member can set their own
displayed skill level to 10 at will. `FR-5.11` only requires the method be *distinguishable in the
score detail view* — not on the chart. `OQ-3` asks whether self-assessed scores should count toward
the chart; until it is answered, the specification says they do.

### C-8 — Answer-key confidentiality does not prevent exam collusion *(already logged as `SQ-11`)*

`SECURITY.md` states this plainly. No proctoring, timing, attempt-window or retake policy exists;
`SEC-AUTHZ-8` cannot fully define a valid attempt, and `ARCHITECTURE.md` lists exam attempt timing,
resumption and retake policy as UNKNOWN.

---

## Gaps in documentation coverage

| Gap | Impact on the threat model |
| --- | --- |
| No API specification of any kind | Entry points had to be derived from requirements; per-endpoint authorization and response-shape review is not possible |
| No data model or schema | Field-level sensitivity classification is inferred; `SEC-BIZ-2`'s store-level uniqueness constraint has no design to check |
| No authorization matrix | The central control of the system (4 roles × ~22 entry points) exists only as prose |
| No architecture diagram | Diagrams in stage 08 are synthesized from prose, not absorbed |
| No incident-response plan (`SQ-12`) | No notification path or timeline for an answer-key leak or a personal-data exposure |
| No threat model prior to this one | `SECURITY.md` records status `TO BE COMPLETED`; there is no baseline to diff against |
| No cloud provider, CI system or topology (`SQ-8`) | `SEC-CICD-*` and `SEC-DATA-1` cannot be specified concretely, let alone verified |
| No ASVS target level (`SQ-3`) | No verification bar is set, so "secure enough to ship" is undefined |
| No chart rendering library decision | `SEC-RENDER-2` and the `DEP-*` review of the single most XSS-relevant dependency are deferred |
| No abuse/resource limits (`SQ-9`) | `SEC-HTTP-5` and `SEC-HTTP-6` have no numbers; availability findings cannot be bounded |

## Recommended additional documentation

1. **An authorization matrix** — role × entry point × operation, with the deny case explicit. This is
   the highest-value document Squadar does not have, and it is also the test fixture for
   `SEC-AUTHZ-1`…`8`.
2. **An API contract** (OpenAPI), with per-role response field lists, to make `SEC-DATA-4` and
   `SEC-BOUND-3` checkable rather than aspirational.
3. **A data inventory** — field-level classification, retention period and deletion behavior per
   entity — which also discharges `SEC-DATA-6` once `SQ-1` is answered.
4. **A decision record resolving `SQ-1`, `SQ-5`, `SQ-6` and `SQ-10`.** These four gate the severity of
   nine findings in the consolidated model between them.
5. **An exam integrity policy** answering `SQ-11`, and an incident-response plan answering `SQ-12`.

---

## Absorption quality note

The corpus is unusually disciplined: every conflict listed above except **C-2** and **C-7** was
already self-identified by `SECURITY.md` or `REQUIREMENTS.md` and given an `SQ`/`OQ` identifier. The
documents do not overstate their own certainty, mark assumptions explicitly, and refuse to claim any
control is implemented. That materially raises confidence in this threat model's inputs — and it
means the value here is concentrated in the two contradictions the corpus had *not* caught (`C-2`,
`C-7`) and in the ranking and attack-path analysis the corpus does not attempt.
