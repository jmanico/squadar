# Squadar — Issue Plan

Decomposition of the Squadar specification into one root epic, eleven workstreams and fifty leaf
issues.

- **Scope**: ALL
- **Execution mode**: DRAFT_ONLY — no GitHub call was made and no specification file was modified.
- **Sources**: `REQUIREMENTS.md`, `ARCHITECTURE.md`, `SECURITY.md`, `DESIGN.md`, `REQUIREMENT_TEMPLATE.md`, with `style-guide.html` cited by every UI-facing issue. `CLAUDE.md` was followed as repository instruction, not as product specification.
- **Drafted**: 2026-09-14
- **Counts**: 62 issue bodies — 1 epic, 11 workstreams (2 BLOCKED), 50 leaves (10 BLOCKED, 40 ready).

Each document is authoritative for its own domain. Where two conflicted, or where a required decision
was absent, the conflict is recorded below as a `PQ-*` question and no interpretation was chosen.

---

## Open Questions

Sixteen of these are BLOCKING under the run's definition — they affect observable behavior, roles or
permissions, auth, API contracts, data semantics, trust boundaries, security controls, failure
behavior, or acceptance testing. Because the mode is `DRAFT_ONLY`, the blocked scope is marked and the
rest is decomposed; a `CREATE` run must not proceed on a blocked issue until its question is answered.

| PQ | Source | Exact IDs and sections affected | Blocking | Issues blocked |
| --- | --- | --- | --- | --- |
| **PQ-1** | `SECURITY.md` `SQ-2` vs `REQUIREMENTS.md` FR-1.2 | The security notes specify ABAC; FR-1.2 specifies exactly one role per user. Affects SEC-AUTHZ-1, SEC-AUTHZ-2, SEC-SESSION-2. `SECURITY.md` records it as an unresolved model question. | **Yes** — two authoritative documents disagree on the authorization model | None directly; recorded on REQ-AUTH-050 and REQ-AUTH-060, both of which resolve the documented attributes under either reading |
| **PQ-2** | `SECURITY.md` `SQ-5`, SEC-SESSION-4, SEC-HTTP-3 | How the JWT session is carried on web — cookie (ambient authority, so SEC-HTTP-3's per-request CSRF defense applies to every state-changing endpoint) or in-memory bearer (SEC-HTTP-3 does not apply). Also `ARCHITECTURE.md` Identity & Access "session transport and lifetime — TO BE DECIDED". | **Yes** — decides whether a whole class of security control exists | REQ-AUTH-040 |
| **PQ-3** | `SECURITY.md` `SQ-6`, SEC-DATA-3; `ARCHITECTURE.md` Roster | Is FR-8.4 deletion an irreversible erasure or an anonymization, and what happens to the audit entries NFR-9.6 requires and SEC-LOG-4 makes append-only? | **Yes** — data semantics, and a direct conflict between FR-8.4 and NFR-9.6 | REQ-ROSTER-050 |
| **PQ-4** | `SECURITY.md` `SQ-11`, SEC-AUTHZ-8; `REQUIREMENTS.md` `OQ-2`; `ARCHITECTURE.md` Assessment | Are exam attempts subject to proctoring, timing or retake constraints? `SECURITY.md` states that without a policy SEC-AUTHZ-8 cannot fully specify what a valid attempt is. `OQ-2` adds per-question weights, pass thresholds and manual review. | **Yes** — acceptance testing and a security control | REQ-EXAM-040 |
| **PQ-5** | `REQUIREMENTS.md` `OQ-3`; `ARCHITECTURE.md` Assessment | Should self-assessed scores count toward the current score shown on a radar chart, or only be shown alongside an assessor- or exam-derived score? Affects FR-5.2, FR-5.11, FR-7.x, SEC-BIZ-4. | **Yes** — observable behavior of every score surface | REQ-SCORE-070 |
| **PQ-6** | `SECURITY.md` `SQ-4`; `ARCHITECTURE.md` REST API | API versioning scheme, error response format and pagination convention are `TO BE DECIDED`; and is the API a first-party contract for the two clients only, or a consumable public API? Every issue's Failure Behavior and every list endpoint depends on it. | **Yes** — API contract | None blocked; recorded on REQ-AUTH-060, REQ-SKILL-030, REQ-CHART-070, REQ-CHART-080 |
| **PQ-7** | `ARCHITECTURE.md` Web Client; `SECURITY.md` SEC-RENDER-2 | Radar chart rendering approach and library are `TO BE DECIDED`, and whether series geometry is computed client-side or returned by the API is `TO BE DECIDED`. `ARCHITECTURE.md` marks FR-7.1–FR-7.11 `PARTIALLY DEFINED` for this reason. | **Yes** — trust boundary placement and observable behavior | REQ-CHART-030 |
| **PQ-8** | `ARCHITECTURE.md` Relational Data Store, Chart Data Service | Database product, schema, indexing and history-table shape are `TO BE DECIDED`; whether any read model or caching is needed to hold NFR-9.1 at NFR-9.3 scale is `TO BE DECIDED`. | **Yes** — data semantics and the enforceability of SEC-BIZ-2 | REQ-CHART-090; recorded on REQ-SCORE-010, REQ-SCORE-050, REQ-ROSTER-010 |
| **PQ-9** | `SECURITY.md` `SQ-8`; `CLAUDE.md` "Release process: TO BE DECIDED" | Which cloud provider, CI system and runtime topology will Terraform provision, and where do environments live? Affects SEC-CICD-1…6. | **Yes** — security controls and the delivery path | REQ-INFRA-000 (whole workstream) |
| **PQ-10** | `SECURITY.md` `SQ-9`, SEC-HTTP-5 | Abuse and resource limits for exam submission, chart dataset requests and bulk import are `TO BE DECIDED`. | **Yes** — a security control and failure behavior | REQ-CHART-090; recorded on REQ-EXAM-040, REQ-EXAM-050, REQ-PORT-020 |
| **PQ-11** | `SECURITY.md` `SQ-10`, SEC-AUTHN-5; `REQUIREMENTS.md` FR-1.2 | Is the OIDC provider trusted to assert role or group membership, or is role always assigned locally? SEC-SESSION-2 requires authorization-relevant claims to be resolved against the authoritative source. | **Yes** — roles and permissions | REQ-AUTH-030 |
| **PQ-12** | `SECURITY.md` `SQ-7`, SEC-AUTHN-3, SEC-AUTHN-8 | What is the account-recovery path when a user loses their passkey, and how is it prevented from becoming the weakest authenticator? | **Yes** — auth | No issue drafted; recovery is recorded as out of scope on REQ-AUTH-010 and REQ-AUTH-020 rather than invented |
| **PQ-13** | `SECURITY.md` `SQ-1`, SEC-DATA-6, SEC-DATA-1 | The security notes name GDPR and CCPA while `REQUIREMENTS.md` states no special-category or regulated data. Controller/processor roles are `UNKNOWN`, and retention periods and data-subject rights are `TO BE DECIDED`. | **Yes** — privacy and data semantics | None blocked; recorded as `TO BE DECIDED` in the Jurisdiction and Regulatory fields of every personal-data issue |
| **PQ-14** | `ARCHITECTURE.md` Mobile Client | Which screens are in the mobile scope at launch is `UNKNOWN`; offline behavior and platform passkey integration are `TO BE DECIDED`. | **Yes** — observable behavior | REQ-MOBILE-000 (whole workstream) |
| **PQ-15** | `ARCHITECTURE.md` Bulk Import / Export; `SECURITY.md` SEC-INPUT-5 | File format specifics, size limits, and whether large imports run synchronously or as background work are `TO BE DECIDED`. | **Yes** — API contract and failure behavior | REQ-PORT-020 |
| **PQ-16** | `ARCHITECTURE.md` Protected Asset Store; `SECURITY.md` SEC-BOUND-4 | Storage technology and access-grant mechanism are `TO BE DECIDED`; grant lifetime is `TO BE DECIDED`; and whether exams carry media at all is `UNKNOWN` (`ARCHITECTURE.md` records an `ASSUMPTION` that the "movie files" note implies media-bearing exams; that assumption is not adopted here). | **Yes** — trust boundary and a security control | REQ-EXAM-070 |
| PQ-17 | `SECURITY.md` `SQ-3` | Target OWASP ASVS 5.0.0 verification level and authenticator assurance level. | No — `REQUIREMENT_TEMPLATE.md` permits `TO BE DECIDED` in the Standards Alignment field, which is where it is recorded | None |
| PQ-18 | `REQUIREMENTS.md` `OQ-1`, `OQ-4`, `OQ-5`, `OQ-6` | Peer score visibility (FR-1.4 states a testable position), score decay (no behavior is specified, so none is built), chart limits (FR-7.6 and FR-7.7 state numbers), team recommendation vs. manual selection (FR-2.4 states manual). | No — each has a stated, testable position; answering one would move a number or add a feature, not unblock existing work | None |
| PQ-19 | `SECURITY.md` `SQ-12` | The incident-response path — who is notified on a suspected exposure of personal data. | No — no issue's acceptance criteria depend on it | None |
| PQ-20 | `DESIGN.md` Typography | Whether Squadar adopts a distinct open-licensed brand face; the system stack is the stated provisional default. | No — `DESIGN.md` names the provisional default and `style-guide.html` renders it | None |

### What a CREATE run needs

`PQ-2`, `PQ-3`, `PQ-4`, `PQ-5`, `PQ-7`, `PQ-8`, `PQ-9`, `PQ-10`, `PQ-11`, `PQ-14`, `PQ-15` and
`PQ-16` each block at least one drafted issue. `PQ-1`, `PQ-6`, `PQ-12` and `PQ-13` are blocking in
kind but block no drafted issue: their effect is recorded inside the issues they touch. The forty
unblocked leaves can be created and worked without any of them being answered.

---

## Coverage

Every `FR-`, `NFR-` and `UT-` identifier in `REQUIREMENTS.md` appears exactly once below.

| Requirement | Issue IDs | Boundary | Security rules | Design sections | Status |
| --- | --- | --- | --- | --- | --- |
| FR-1.1 | REQ-AUTH-010, REQ-AUTH-020, REQ-AUTH-060 | Clients → REST API | SEC-AUTHN-1, SEC-AUTHN-2 | Form feedback and errors | COVERED |
| FR-1.2 | REQ-AUTH-050, REQ-AUTH-070 | Identity & Access | SEC-SESSION-2, SEC-AUTHZ-2, SEC-AUTHZ-6 | N/A | COVERED |
| FR-1.3 | REQ-AUTH-070 | Identity & Access | SEC-AUTHZ-6, SEC-SESSION-3 | Components; Form feedback | COVERED |
| FR-1.4 | REQ-AUTH-050, REQ-CHART-010, REQ-PORT-010 | REST API; Assessment; Chart Data Service | SEC-AUTHZ-3, SEC-DATA-4 | N/A | COVERED |
| FR-1.5 | REQ-AUTH-050, REQ-SCORE-070, REQ-EXAM-020 | REST API; Assessment | SEC-AUTHZ-4, SEC-AUTHZ-2 | N/A | PARTIALLY COVERED — the write-scope clause sits in REQ-SCORE-070, BLOCKED on `PQ-5` |
| FR-1.6 | REQ-AUTH-060 | REST API | SEC-AUTHZ-5 | N/A | COVERED |
| FR-1.7 | REQ-AUTH-060 | REST API | SEC-AUTHZ-7, SEC-ERR-1 | Form feedback and errors | COVERED |
| FR-2.1 | REQ-ROSTER-010 | Roster | SEC-AUTHZ-1, SEC-DATA-4 | Components (Inputs) | COVERED |
| FR-2.2 | REQ-ROSTER-020, REQ-PORT-030 | Roster; Web Client | SEC-AUTHZ-6, SEC-INPUT-1 | Components; Form feedback | COVERED |
| FR-2.3 | REQ-ROSTER-020 | Roster; Assessment | SEC-BIZ-3 | Components (Buttons, destructive) | COVERED |
| FR-2.4 | REQ-ROSTER-030 | Roster | SEC-AUTHZ-1, SEC-AUTHZ-2 | Components (Inputs) | COVERED |
| FR-2.5 | REQ-ROSTER-030 | Roster | SEC-AUTHZ-2 | N/A | COVERED |
| FR-2.6 | REQ-ROSTER-040 | Roster; Chart Data Service | SEC-AUTHZ-3, SEC-HTTP-6 | Components (Inputs) | COVERED |
| FR-3.1 | REQ-SKILL-010 | Skill Catalog | SEC-INPUT-1 | Components (Inputs) | COVERED |
| FR-3.2 | REQ-SKILL-010, REQ-SKILL-020, REQ-PORT-030 | Skill Catalog; Web Client | SEC-AUTHZ-6 | Components; Form feedback | COVERED |
| FR-3.3 | REQ-SKILL-010 | Skill Catalog; Relational Data Store | SEC-INPUT-1, SEC-INPUT-6 | Form feedback and errors | COVERED |
| FR-3.4 | REQ-SKILL-020, REQ-SKILL-030 | Skill Catalog; Assessment | SEC-BIZ-3 | Components (Buttons) | COVERED |
| FR-4.1 | REQ-SCORE-010 | Assessment; Relational Data Store | SEC-BIZ-2 | Layout (Density); Typography | COVERED |
| FR-4.2 | REQ-FOUND-020, REQ-SCORE-020 | REST API; Assessment | SEC-INPUT-2, SEC-BOUND-1 | Components (Inputs) | COVERED |
| FR-4.3 | REQ-SCORE-020 | Assessment | SEC-INPUT-2 | Form feedback and errors | COVERED |
| FR-4.4 | REQ-SCORE-030 | Assessment; Chart Data Service | SEC-BIZ-4 | Charts; Accessibility | COVERED |
| FR-4.5 | REQ-SCORE-040 | Assessment | SEC-INPUT-3 | Layout (Density); Typography | COVERED |
| FR-4.6 | REQ-SCORE-050 | Assessment; Relational Data Store | SEC-BIZ-2, SEC-ERR-2 | Layout (Density) | COVERED |
| FR-5.1 | REQ-EXAM-010, REQ-EXAM-050 | Assessment | SEC-BIZ-1 | Layout (long-form text) | COVERED |
| FR-5.2 | REQ-SCORE-070 | Assessment | SEC-AUTHZ-4, SEC-INPUT-3 | Components (Inputs) | **BLOCKED** — `PQ-5` |
| FR-5.3 | REQ-SCORE-040 | Assessment; Web Client | SEC-INPUT-3 | Layout (Density); Accessibility | COVERED |
| FR-5.4 | REQ-EXAM-010 | Assessment | SEC-AUTHZ-6, SEC-BOUND-3 | Layout (long-form text) | COVERED |
| FR-5.5 | REQ-EXAM-020 | Assessment; Outbound Notification | SEC-AUTHN-8, SEC-EXT-1, SEC-EXT-3 | Components (Inputs, Buttons) | COVERED |
| FR-5.6 | REQ-EXAM-040 | Assessment | SEC-AUTHZ-8 | Components (Buttons); Accessibility | **BLOCKED** — `PQ-4` |
| FR-5.7 | REQ-EXAM-050 | Assessment | SEC-BIZ-1, SEC-INPUT-3 | Components (Buttons) | COVERED |
| FR-5.8 | REQ-EXAM-050 | Assessment | SEC-BIZ-1 | Form feedback and errors | COVERED |
| FR-5.9 | REQ-EXAM-050 | Assessment; Web Client | SEC-DATA-4 | Form feedback; Brand direction | COVERED |
| FR-5.10 | REQ-EXAM-060 | Assessment; Chart Data Service | SEC-BIZ-2, SEC-DATA-3 | Charts; Accessibility (Reduced motion) | COVERED |
| FR-5.11 | REQ-SCORE-040 | Assessment; Web Client | SEC-INPUT-3 | Layout (Density); Accessibility | COVERED |
| FR-6.1 | REQ-CHART-070, REQ-CHART-080 | Assessment; Web Client | SEC-DATA-4 | Layout (Density); Typography | COVERED |
| FR-6.2 | REQ-CHART-010, REQ-CHART-070 | Chart Data Service; Web Client | SEC-BIZ-4, SEC-AUTHZ-3 | Layout; Accessibility (Names and structure) | COVERED |
| FR-6.3 | REQ-CHART-080 | Assessment; REST API | SEC-INPUT-6, SEC-HTTP-6 | Layout (Density); Brand direction | COVERED |
| FR-7.1 | REQ-CHART-030 | Web Client | SEC-RENDER-2 | Charts; Layout; Brand and Logo | **BLOCKED** — `PQ-7` |
| FR-7.2 | REQ-CHART-030 | Web Client | SEC-RENDER-2 | Charts | **BLOCKED** — `PQ-7` |
| FR-7.3 | REQ-CHART-030, REQ-CHART-050 | Web Client | SEC-RENDER-1, SEC-RENDER-2 | Charts; Accessibility (Not colour alone) | PARTIALLY COVERED — the legend's identification is in REQ-CHART-050; the series drawing is BLOCKED on `PQ-7` |
| FR-7.4 | REQ-CHART-010 | Chart Data Service | SEC-BIZ-4 | Charts | COVERED |
| FR-7.5 | REQ-SKILL-030, REQ-CHART-040 | Skill Catalog; Web Client | SEC-INPUT-6, SEC-HTTP-6 | Components (Inputs); Charts | COVERED |
| FR-7.6 | REQ-CHART-020, REQ-CHART-040 | Chart Data Service; REST API | SEC-HTTP-6, SEC-BOUND-1 | Components (Inputs) | COVERED |
| FR-7.7 | REQ-CHART-020, REQ-CHART-040 | Chart Data Service; REST API | SEC-HTTP-6 | Components (Inputs) | COVERED |
| FR-7.8 | REQ-CHART-040, REQ-CHART-060 | Web Client | SEC-HTTP-6 | Charts; Layout | COVERED |
| FR-7.9 | REQ-SCORE-030, REQ-CHART-010, REQ-CHART-050, REQ-CHART-070 | Assessment; Chart Data Service; Web Client | SEC-BIZ-4 | Charts; Accessibility | COVERED |
| FR-7.10 | REQ-CHART-060 | Chart Data Service; Web Client | SEC-DATA-4, SEC-ERR-1 | Charts (empty state) | COVERED |
| FR-7.11 | REQ-CHART-050 | Web Client | SEC-RENDER-1 | Charts (legend) | COVERED |
| FR-8.1 | REQ-PORT-030, REQ-PORT-020 | Web Client; Roster; Skill Catalog | SEC-INPUT-1, SEC-INPUT-4 | Components; Form feedback | COVERED — the interactive path is REQ-PORT-030; REQ-PORT-020's import clause is blocked |
| FR-8.2 | REQ-PORT-020 | Bulk Import / Export | SEC-INPUT-4, SEC-INPUT-5, SEC-EXT-4 | Form feedback and errors | **BLOCKED** — `PQ-15` |
| FR-8.3 | REQ-PORT-010 | Bulk Import / Export; Assessment | SEC-DATA-2, SEC-AUTHZ-3, SEC-BOUND-3 | Components (Buttons) | COVERED |
| FR-8.4 | REQ-ROSTER-050 | Roster; Assessment; Chart Data Service | SEC-DATA-3, SEC-LOG-4 | Components (Buttons, destructive) | **BLOCKED** — `PQ-3` |
| NFR-9.1 | REQ-CHART-090 | Chart Data Service; Relational Data Store | SEC-HTTP-5, SEC-DATA-1 | Components (Buttons, busy state) | **BLOCKED** — `PQ-8`, `PQ-10` |
| NFR-9.2 | REQ-EXAM-050 | Assessment | SEC-HTTP-5 | Components (Buttons, busy state) | COVERED |
| NFR-9.3 | REQ-CHART-090 | Chart Data Service; Relational Data Store | SEC-HTTP-5, SEC-HTTP-6 | N/A | **BLOCKED** — `PQ-8`, `PQ-10` |
| NFR-9.4 | REQ-UIKIT-060, REQ-CHART-030, REQ-CHART-050 | Web Client | N/A | Accessibility (Not colour alone); Charts; Color Palette | PARTIALLY COVERED — the vocabulary and legend are covered; its use in the drawn series is BLOCKED on `PQ-7` |
| NFR-9.5 | REQ-UIKIT-040 | Web Client | N/A | Accessibility (Keyboard, Visible focus); Components (Focus states) | COVERED |
| NFR-9.6 | REQ-SCORE-060 | Assessment | SEC-LOG-1, SEC-LOG-3, SEC-LOG-4 | Layout (Density); Typography | COVERED |
| NFR-9.7 | REQ-EXAM-010, REQ-EXAM-030 | Assessment; REST API; Web Client | SEC-BOUND-3, SEC-RENDER-4 | Layout (long-form text) | COVERED |
| UT-10.1 | REQ-FOUND-030 | Test fixtures; all components | SEC-DATA-5 | N/A | COVERED |

Cross-cutting `SEC-*` rules are carried by a host leaf rather than by an issue of their own, because
`CLAUDE.md` and the run inputs both forbid an "add security" issue: SEC-HTTP-1 and SEC-HTTP-2 in
REQ-AUTH-060; SEC-HTTP-7, SEC-RENDER-1 and SEC-RENDER-3 in REQ-UIKIT-010 and REQ-UIKIT-030;
SEC-SECRET-1 and SEC-SECRET-3 in REQ-FOUND-010; SEC-SECRET-2 in REQ-AUTH-040; SEC-LOG-2 in
REQ-AUTH-050; SEC-EXT-2 and SEC-EXT-4 in REQ-AUTH-030, REQ-EXAM-020 and REQ-PORT-020; SEC-DATA-1 and
SEC-CICD-1…6 in REQ-INFRA-000; DEP-1…DEP-8 in REQ-FOUND-010 and in every issue that adds a
dependency. `SEC-BOUND-4` is carried by REQ-EXAM-070 and `SEC-DATA-6` by REQ-SCORE-050 and
REQ-SCORE-060, both pending their questions.

---

## Hierarchy

```
REQ-EPIC-001  Squadar — implement the specified system
├── REQ-FOUND-000   Foundation: workspaces, shared validation and test fixture
│   ├── REQ-FOUND-010 · REQ-FOUND-020 · REQ-FOUND-030
├── REQ-UIKIT-000   Design language implementation
│   ├── REQ-UIKIT-010 · REQ-UIKIT-020 · REQ-UIKIT-030 · REQ-UIKIT-040 · REQ-UIKIT-050 · REQ-UIKIT-060
├── REQ-AUTH-000    Identity, session and authorization
│   ├── REQ-AUTH-010 · REQ-AUTH-020 · REQ-AUTH-030 ⛔ · REQ-AUTH-040 ⛔ · REQ-AUTH-050 · REQ-AUTH-060 · REQ-AUTH-070
├── REQ-ROSTER-000  Team members and teams
│   ├── REQ-ROSTER-010 · REQ-ROSTER-020 · REQ-ROSTER-030 · REQ-ROSTER-040 · REQ-ROSTER-050 ⛔
├── REQ-SKILL-000   Skill catalog
│   ├── REQ-SKILL-010 · REQ-SKILL-020 · REQ-SKILL-030
├── REQ-SCORE-000   Skill scores, history and audit
│   ├── REQ-SCORE-010 · REQ-SCORE-020 · REQ-SCORE-030 · REQ-SCORE-040 · REQ-SCORE-050 · REQ-SCORE-060 · REQ-SCORE-070 ⛔
├── REQ-EXAM-000    Exams, assignment, attempts and scoring
│   ├── REQ-EXAM-010 · REQ-EXAM-020 · REQ-EXAM-030 · REQ-EXAM-040 ⛔ · REQ-EXAM-050 · REQ-EXAM-060 · REQ-EXAM-070 ⛔
├── REQ-CHART-000   Chart dataset, radar chart, score table and ranking
│   ├── REQ-CHART-010 · REQ-CHART-020 · REQ-CHART-030 ⛔ · REQ-CHART-040 · REQ-CHART-050 · REQ-CHART-060 · REQ-CHART-070 · REQ-CHART-080 · REQ-CHART-090 ⛔
├── REQ-PORT-000    Data entry, import, export and deletion
│   ├── REQ-PORT-010 · REQ-PORT-020 ⛔ · REQ-PORT-030
├── REQ-MOBILE-000  React Native mobile client — ⛔ BLOCKED (PQ-14), no leaves
└── REQ-INFRA-000   Terraform infrastructure and delivery pipeline — ⛔ BLOCKED (PQ-9), no leaves
```

⛔ = BLOCKED. Do not implement until the named `PQ-*` is answered.

---

## Manifest

Effort and changed-line figures are ranges for human-authored code, excluding generated files and
lockfiles. Model identifiers matter when an issue is driven from CI or the SDK; in Claude Code the
model is chosen with `/model`.

| # | ID | Title | Parent | Effort | LOC | Model | Status |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 000 | REQ-EPIC-001 | Squadar — implement the specified system | — | — | — | — | Root |
| 010 | REQ-FOUND-000 | Foundation: workspaces, shared validation and test fixture | EPIC-001 | — | — | — | Workstream |
| 020 | REQ-AUTH-000 | Identity, session and authorization | EPIC-001 | — | — | — | Workstream |
| 030 | REQ-ROSTER-000 | Team members and teams | EPIC-001 | — | — | — | Workstream |
| 040 | REQ-SKILL-000 | Skill catalog | EPIC-001 | — | — | — | Workstream |
| 050 | REQ-SCORE-000 | Skill scores, history and audit | EPIC-001 | — | — | — | Workstream |
| 060 | REQ-EXAM-000 | Exams, assignment, attempts and scoring | EPIC-001 | — | — | — | Workstream |
| 070 | REQ-CHART-000 | Chart dataset, radar chart, score table and ranking | EPIC-001 | — | — | — | Workstream |
| 080 | REQ-PORT-000 | Data entry, import, export and deletion | EPIC-001 | — | — | — | Workstream |
| 090 | REQ-UIKIT-000 | Design language implementation | EPIC-001 | — | — | — | Workstream |
| 100 | REQ-MOBILE-000 | React Native mobile client | EPIC-001 | — | — | — | ⛔ PQ-14 |
| 110 | REQ-INFRA-000 | Terraform infrastructure and delivery pipeline | EPIC-001 | — | — | — | ⛔ PQ-9 |
| 120 | REQ-FOUND-010 | Establish the npm workspaces monorepo with strict TypeScript and the quality gate | FOUND-000 | 0.5–1 d | 200–400 | `claude-sonnet-5` | Ready |
| 130 | REQ-FOUND-020 | Shared validation schemas applied server-side at the API boundary | FOUND-000 | 1–2 d | 400–700 | `claude-opus-5` | Ready |
| 140 | REQ-FOUND-030 | Synthetic ten-member, ten-skill test fixture | FOUND-000 | 0.5–1 d | 150–350 | `claude-sonnet-5` | Ready |
| 150 | REQ-UIKIT-010 | Design tokens for colour, type and spacing in light and dark mode | UIKIT-000 | 0.5–1 d | 250–450 | `claude-sonnet-5` | Ready |
| 160 | REQ-UIKIT-020 | Responsive grid, breakpoints and zoom resilience | UIKIT-000 | 0.5–1 d | 200–400 | `claude-sonnet-5` | Ready |
| 170 | REQ-UIKIT-030 | Button, input and link primitives | UIKIT-000 | 1–2 d | 500–800 | `claude-sonnet-5` | Ready |
| 180 | REQ-UIKIT-040 | Focus states and full keyboard operability | UIKIT-000 | 1–1.5 d | 300–500 | `claude-sonnet-5` | Ready |
| 190 | REQ-UIKIT-050 | Form feedback, error messaging and error summary | UIKIT-000 | 1–1.5 d | 350–600 | `claude-sonnet-5` | Ready |
| 200 | REQ-UIKIT-060 | Non-colour encoding and reduced-motion conformance | UIKIT-000 | 0.5–1 d | 200–350 | `claude-sonnet-5` | Ready |
| 210 | REQ-AUTH-010 | Password authentication with memory-hard hashing and non-disclosing failure | AUTH-000 | 1–2 d | 400–700 | `claude-opus-5` | Ready |
| 220 | REQ-AUTH-020 | Passkey registration and authentication with server-side assertion verification | AUTH-000 | 1.5–2 d | 500–800 | `claude-opus-5` | Ready |
| 230 | REQ-AUTH-030 | OIDC authentication path with full identity-token validation | AUTH-000 | — | — | `claude-opus-5` (provisional) | ⛔ PQ-11 |
| 240 | REQ-AUTH-040 | JWT session issuance, transport and rotation | AUTH-000 | — | — | `claude-opus-5` (provisional) | ⛔ PQ-2 |
| 250 | REQ-AUTH-050 | Server-resolved authorization context and session revocation | AUTH-000 | 1.5–2 d | 450–750 | `claude-opus-5` | Ready |
| 260 | REQ-AUTH-060 | Role-based authorization enforcement at the API boundary | AUTH-000 | 1.5–2 d | 500–900 | `claude-opus-5` | Ready |
| 270 | REQ-AUTH-070 | Administrator account and role administration | AUTH-000 | 1–1.5 d | 350–600 | `claude-sonnet-5` | Ready |
| 280 | REQ-ROSTER-010 | Team member record with distinct identity | ROSTER-000 | 0.5–1 d | 250–450 | `claude-sonnet-5` | Ready |
| 290 | REQ-ROSTER-020 | Add, edit and deactivate a team member with history retained | ROSTER-000 | 1–1.5 d | 350–600 | `claude-sonnet-5` | Ready |
| 300 | REQ-ROSTER-030 | Named teams with persistent many-to-many membership | ROSTER-000 | 1–1.5 d | 350–600 | `claude-sonnet-5` | Ready |
| 310 | REQ-ROSTER-040 | Ad-hoc member selection sets for display | ROSTER-000 | 0.5–1 d | 250–450 | `claude-opus-5` | Ready |
| 320 | REQ-ROSTER-050 | Personal-data deletion on request | ROSTER-000 | — | — | `claude-opus-5` (provisional) | ⛔ PQ-3 |
| 330 | REQ-SKILL-010 | Skill catalog administration with duplicate active-name rejection | SKILL-000 | 0.5–1 d | 250–450 | `claude-sonnet-5` | Ready |
| 340 | REQ-SKILL-020 | Retire a skill, retaining history and excluding it from new assessments | SKILL-000 | 0.5 d | 150–300 | `claude-sonnet-5` | Ready |
| 350 | REQ-SKILL-030 | Axis candidate list for chart configuration | SKILL-000 | 0.5 d | 150–300 | `claude-sonnet-5` | Ready |
| 360 | REQ-SCORE-010 | One current score per member per skill, enforced in the data store | SCORE-000 | 1–1.5 d | 300–550 | `claude-opus-5` | Ready |
| 370 | REQ-SCORE-020 | Reject any score that is not an integer from 1 to 10 | SCORE-000 | 0.5–1 d | 250–450 | `claude-opus-5` | Ready |
| 380 | REQ-SCORE-030 | Represent an unassessed skill as absent, never as a value | SCORE-000 | 0.5–1 d | 200–400 | `claude-sonnet-5` | Ready |
| 390 | REQ-SCORE-040 | Stamp every score with its method, source and recorded date | SCORE-000 | 0.5–1 d | 250–450 | `claude-sonnet-5` | Ready |
| 400 | REQ-SCORE-050 | Retain superseded scores as history and present the most recent as current | SCORE-000 | 1.5–2 d | 450–750 | `claude-opus-5` | Ready |
| 410 | REQ-SCORE-060 | Append-only score audit trail readable only by an Administrator | SCORE-000 | 1–1.5 d | 350–600 | `claude-opus-5` | Ready |
| 420 | REQ-SCORE-070 | Record a score by assessor rating and by self-assessment | SCORE-000 | — | — | `claude-opus-5` (provisional) | ⛔ PQ-5 |
| 430 | REQ-EXAM-010 | Define an exam for a single skill with its questions and answer key | EXAM-000 | 1–1.5 d | 400–650 | `claude-opus-5` | Ready |
| 440 | REQ-EXAM-020 | Assign an exam and send its invitation through the notification adapter | EXAM-000 | 1.5–2 d | 500–800 | `claude-opus-5` | Ready |
| 450 | REQ-EXAM-030 | Deliver an exam to an assignee with no answer-key data in the payload | EXAM-000 | 1–1.5 d | 350–600 | `claude-opus-5` | Ready |
| 460 | REQ-EXAM-040 | Authorize an exam attempt against its assignment | EXAM-000 | — | — | `claude-opus-5` (provisional) | ⛔ PQ-4 |
| 470 | REQ-EXAM-050 | Score a submission server-side and convert the percentage to a 1–10 band | EXAM-000 | 1–1.5 d | 350–600 | `claude-opus-5` | Ready |
| 480 | REQ-EXAM-060 | Use the updated score everywhere after reassessment | EXAM-000 | 0.5–1 d | 200–400 | `claude-sonnet-5` | Ready |
| 490 | REQ-EXAM-070 | Serve exam media from the protected asset store under a live authorization decision | EXAM-000 | — | — | `claude-opus-5` (provisional) | ⛔ PQ-16 |
| 500 | REQ-CHART-010 | Assemble one chart dataset with a shared axis set and explicit absence markers | CHART-000 | 1.5–2 d | 500–800 | `claude-opus-5` | Ready |
| 510 | REQ-CHART-020 | Enforce the axis and member selection limits server-side with a stated reason | CHART-000 | 0.5 d | 150–300 | `claude-sonnet-5` | Ready |
| 520 | REQ-CHART-030 | Render the shared radar chart with distinguishable series | CHART-000 | — | — | `claude-opus-5` (provisional) | ⛔ PQ-7 |
| 530 | REQ-CHART-040 | Member and skill selection controls with a visible count against the limit | CHART-000 | 1–1.5 d | 350–600 | `claude-sonnet-5` | Ready |
| 540 | REQ-CHART-050 | Legend that names every series and toggles its visibility | CHART-000 | 0.5–1 d | 250–450 | `claude-sonnet-5` | Ready |
| 550 | REQ-CHART-060 | Chart empty state when no team member is selected | CHART-000 | 0.5 d | 120–250 | `claude-sonnet-5` | Ready |
| 560 | REQ-CHART-070 | Equivalent score table rendered from the chart dataset | CHART-000 | 1–1.5 d | 350–600 | `claude-sonnet-5` | Ready |
| 570 | REQ-CHART-080 | Rank team members by their score for a chosen skill | CHART-000 | 0.5–1 d | 250–450 | `claude-sonnet-5` | Ready |
| 580 | REQ-CHART-090 | Meet the chart render budget at the supported member and skill scale | CHART-000 | — | — | `claude-fable-5-1` (provisional) | ⛔ PQ-8, PQ-10 |
| 590 | REQ-PORT-010 | Team member self-export of their own skill and exam record | PORT-000 | 1–1.5 d | 350–600 | `claude-opus-5` | Ready |
| 600 | REQ-PORT-020 | Bulk delimited import of team members and skills with per-row rejection reasons | PORT-000 | — | — | `claude-opus-5` (provisional) | ⛔ PQ-15 |
| 610 | REQ-PORT-030 | Administrator interface for creating team members and skills | PORT-000 | 1–1.5 d | 350–600 | `claude-sonnet-5` | Ready |

**Unblocked total**: 40 leaves, roughly 33–48 engineer-days, 11,700–19,900 changed human-authored
lines. Sixteen leaves are assigned `claude-opus-5` — each is security-sensitive or carries an
invariant that every later surface depends on; the remaining twenty-four are `claude-sonnet-5`.
`claude-fable-5-1` appears once, provisionally, on REQ-CHART-090, which becomes long-horizon
cross-boundary work if a read model turns out to be needed. No issue is assigned
`claude-haiku-4-5` — nothing in this decomposition is a rename, a generated-boilerplate pass, or a
mass edit against a fixed pattern.

---

## Waves

Leaves within a wave share no dependency and no files, so a team can pick up a whole wave in
parallel. Blocked leaves appear in no wave.

| Wave | Issues | Parallelism |
| --- | --- | --- |
| 1 | REQ-FOUND-010 | 1 |
| 2 | REQ-FOUND-020 · REQ-FOUND-030 · REQ-UIKIT-010 | 3 |
| 3 | REQ-AUTH-010 · REQ-AUTH-020 · REQ-ROSTER-010 · REQ-SKILL-010 · REQ-UIKIT-020 · REQ-UIKIT-030 | 6 |
| 4 | REQ-AUTH-050 · REQ-ROSTER-020 · REQ-SKILL-020 · REQ-SKILL-030 · REQ-SCORE-010 · REQ-UIKIT-040 · REQ-UIKIT-060 | 7 |
| 5 | REQ-AUTH-060 · REQ-ROSTER-030 · REQ-SCORE-020 · REQ-SCORE-030 · REQ-SCORE-040 · REQ-UIKIT-050 | 6 |
| 6 | REQ-AUTH-070 · REQ-ROSTER-040 · REQ-SCORE-050 · REQ-PORT-030 | 4 |
| 7 | REQ-SCORE-060 · REQ-EXAM-010 · REQ-CHART-020 | 3 |
| 8 | REQ-EXAM-020 · REQ-EXAM-030 · REQ-CHART-010 · REQ-CHART-080 | 4 |
| 9 | REQ-EXAM-050 · REQ-CHART-040 · REQ-CHART-050 · REQ-CHART-060 · REQ-CHART-070 | 5 |
| 10 | REQ-EXAM-060 · REQ-PORT-010 | 2 |

Ten waves against forty leaves: with enough hands the critical path is ten iterations, not forty.
The chart's accessible surfaces — the dataset, the score table, the ranked list, the legend, the
empty state and the selection controls — all land before `PQ-7` is answered, so the product is
usable through the score table while the radar chart itself is still blocked.

---

## Topological creation order

The order below is safe for `--parent`: every parent exists before its children, and every issue's
upstream dependencies precede it. Blocked issues are created too — they carry their `PQ-*` and a
"do not implement" banner — but they are excluded from the waves above.

```
REQ-EPIC-001
REQ-FOUND-000  REQ-AUTH-000  REQ-ROSTER-000  REQ-SKILL-000  REQ-SCORE-000
REQ-EXAM-000   REQ-CHART-000 REQ-PORT-000    REQ-UIKIT-000  REQ-MOBILE-000  REQ-INFRA-000
REQ-FOUND-010  REQ-FOUND-020 REQ-FOUND-030
REQ-UIKIT-010  REQ-UIKIT-020 REQ-UIKIT-030   REQ-UIKIT-040  REQ-UIKIT-050  REQ-UIKIT-060
REQ-AUTH-010   REQ-AUTH-020  REQ-AUTH-030    REQ-AUTH-040   REQ-AUTH-050   REQ-AUTH-060  REQ-AUTH-070
REQ-ROSTER-010 REQ-ROSTER-020 REQ-ROSTER-030 REQ-ROSTER-040 REQ-ROSTER-050
REQ-SKILL-010  REQ-SKILL-020 REQ-SKILL-030
REQ-SCORE-010  REQ-SCORE-020 REQ-SCORE-030   REQ-SCORE-040  REQ-SCORE-050  REQ-SCORE-060 REQ-SCORE-070
REQ-EXAM-010   REQ-EXAM-020  REQ-EXAM-030    REQ-EXAM-040   REQ-EXAM-050   REQ-EXAM-060  REQ-EXAM-070
REQ-CHART-010  REQ-CHART-020 REQ-CHART-030   REQ-CHART-040  REQ-CHART-050  REQ-CHART-060
REQ-CHART-070  REQ-CHART-080 REQ-CHART-090
REQ-PORT-010   REQ-PORT-020  REQ-PORT-030
```

---

## Proposed commands

Not run — this is a `DRAFT_ONLY` plan. A `CREATE` run performs pre-flight first (`gh auth status`;
confirm the target repository; confirm the CLI supports `--body-file` and `--parent`; confirm no
existing issue reuses a planning ID for different scope), then runs these in order, capturing every
URL and replacing the `{{ISSUE_URL:<ID>}}` placeholders in each parent's Child Requirements list
before that parent is created — or immediately after, by editing it.

```sh
gh issue create --title "[REQ-EPIC-001] Squadar — implement the specified system" --body-file ".planning/github-issues/000-REQ-EPIC-001.md"
gh issue create --title "[REQ-FOUND-000] Foundation: workspaces, shared validation and test fixture" --body-file ".planning/github-issues/010-REQ-FOUND-000.md" --parent <REQ-EPIC-001>
gh issue create --title "[REQ-AUTH-000] Identity, session and authorization" --body-file ".planning/github-issues/020-REQ-AUTH-000.md" --parent <REQ-EPIC-001>
gh issue create --title "[REQ-ROSTER-000] Team members and teams" --body-file ".planning/github-issues/030-REQ-ROSTER-000.md" --parent <REQ-EPIC-001>
gh issue create --title "[REQ-SKILL-000] Skill catalog" --body-file ".planning/github-issues/040-REQ-SKILL-000.md" --parent <REQ-EPIC-001>
gh issue create --title "[REQ-SCORE-000] Skill scores, history and audit" --body-file ".planning/github-issues/050-REQ-SCORE-000.md" --parent <REQ-EPIC-001>
gh issue create --title "[REQ-EXAM-000] Exams, assignment, attempts and scoring" --body-file ".planning/github-issues/060-REQ-EXAM-000.md" --parent <REQ-EPIC-001>
gh issue create --title "[REQ-CHART-000] Chart dataset, radar chart, score table and ranking" --body-file ".planning/github-issues/070-REQ-CHART-000.md" --parent <REQ-EPIC-001>
gh issue create --title "[REQ-PORT-000] Data entry, import, export and deletion" --body-file ".planning/github-issues/080-REQ-PORT-000.md" --parent <REQ-EPIC-001>
gh issue create --title "[REQ-UIKIT-000] Design language implementation" --body-file ".planning/github-issues/090-REQ-UIKIT-000.md" --parent <REQ-EPIC-001>
gh issue create --title "[REQ-MOBILE-000] React Native mobile client" --body-file ".planning/github-issues/100-REQ-MOBILE-000.md" --parent <REQ-EPIC-001>
gh issue create --title "[REQ-INFRA-000] Terraform infrastructure and delivery pipeline" --body-file ".planning/github-issues/110-REQ-INFRA-000.md" --parent <REQ-EPIC-001>
gh issue create --title "[REQ-FOUND-010] Establish the npm workspaces monorepo with strict TypeScript and the quality gate" --body-file ".planning/github-issues/120-REQ-FOUND-010.md" --parent <REQ-FOUND-000>
gh issue create --title "[REQ-FOUND-020] Shared validation schemas applied server-side at the API boundary" --body-file ".planning/github-issues/130-REQ-FOUND-020.md" --parent <REQ-FOUND-000>
gh issue create --title "[REQ-FOUND-030] Synthetic ten-member, ten-skill test fixture" --body-file ".planning/github-issues/140-REQ-FOUND-030.md" --parent <REQ-FOUND-000>
gh issue create --title "[REQ-UIKIT-010] Design tokens for colour, type and spacing in light and dark mode" --body-file ".planning/github-issues/150-REQ-UIKIT-010.md" --parent <REQ-UIKIT-000>
gh issue create --title "[REQ-UIKIT-020] Responsive grid, breakpoints and zoom resilience" --body-file ".planning/github-issues/160-REQ-UIKIT-020.md" --parent <REQ-UIKIT-000>
gh issue create --title "[REQ-UIKIT-030] Button, input and link primitives" --body-file ".planning/github-issues/170-REQ-UIKIT-030.md" --parent <REQ-UIKIT-000>
gh issue create --title "[REQ-UIKIT-040] Focus states and full keyboard operability" --body-file ".planning/github-issues/180-REQ-UIKIT-040.md" --parent <REQ-UIKIT-000>
gh issue create --title "[REQ-UIKIT-050] Form feedback, error messaging and error summary" --body-file ".planning/github-issues/190-REQ-UIKIT-050.md" --parent <REQ-UIKIT-000>
gh issue create --title "[REQ-UIKIT-060] Non-colour encoding and reduced-motion conformance" --body-file ".planning/github-issues/200-REQ-UIKIT-060.md" --parent <REQ-UIKIT-000>
gh issue create --title "[REQ-AUTH-010] Password authentication with memory-hard hashing and non-disclosing failure" --body-file ".planning/github-issues/210-REQ-AUTH-010.md" --parent <REQ-AUTH-000>
gh issue create --title "[REQ-AUTH-020] Passkey registration and authentication with server-side assertion verification" --body-file ".planning/github-issues/220-REQ-AUTH-020.md" --parent <REQ-AUTH-000>
gh issue create --title "[REQ-AUTH-030] OIDC authentication path with full identity-token validation" --body-file ".planning/github-issues/230-REQ-AUTH-030.md" --parent <REQ-AUTH-000>
gh issue create --title "[REQ-AUTH-040] JWT session issuance, transport and rotation" --body-file ".planning/github-issues/240-REQ-AUTH-040.md" --parent <REQ-AUTH-000>
gh issue create --title "[REQ-AUTH-050] Server-resolved authorization context and session revocation" --body-file ".planning/github-issues/250-REQ-AUTH-050.md" --parent <REQ-AUTH-000>
gh issue create --title "[REQ-AUTH-060] Role-based authorization enforcement at the API boundary" --body-file ".planning/github-issues/260-REQ-AUTH-060.md" --parent <REQ-AUTH-000>
gh issue create --title "[REQ-AUTH-070] Administrator account and role administration" --body-file ".planning/github-issues/270-REQ-AUTH-070.md" --parent <REQ-AUTH-000>
gh issue create --title "[REQ-ROSTER-010] Team member record with distinct identity" --body-file ".planning/github-issues/280-REQ-ROSTER-010.md" --parent <REQ-ROSTER-000>
gh issue create --title "[REQ-ROSTER-020] Add, edit and deactivate a team member with history retained" --body-file ".planning/github-issues/290-REQ-ROSTER-020.md" --parent <REQ-ROSTER-000>
gh issue create --title "[REQ-ROSTER-030] Named teams with persistent many-to-many membership" --body-file ".planning/github-issues/300-REQ-ROSTER-030.md" --parent <REQ-ROSTER-000>
gh issue create --title "[REQ-ROSTER-040] Ad-hoc member selection sets for display" --body-file ".planning/github-issues/310-REQ-ROSTER-040.md" --parent <REQ-ROSTER-000>
gh issue create --title "[REQ-ROSTER-050] Personal-data deletion on request" --body-file ".planning/github-issues/320-REQ-ROSTER-050.md" --parent <REQ-ROSTER-000>
gh issue create --title "[REQ-SKILL-010] Skill catalog administration with duplicate active-name rejection" --body-file ".planning/github-issues/330-REQ-SKILL-010.md" --parent <REQ-SKILL-000>
gh issue create --title "[REQ-SKILL-020] Retire a skill, retaining history and excluding it from new assessments" --body-file ".planning/github-issues/340-REQ-SKILL-020.md" --parent <REQ-SKILL-000>
gh issue create --title "[REQ-SKILL-030] Axis candidate list for chart configuration" --body-file ".planning/github-issues/350-REQ-SKILL-030.md" --parent <REQ-SKILL-000>
gh issue create --title "[REQ-SCORE-010] One current score per member per skill, enforced in the data store" --body-file ".planning/github-issues/360-REQ-SCORE-010.md" --parent <REQ-SCORE-000>
gh issue create --title "[REQ-SCORE-020] Reject any score that is not an integer from 1 to 10" --body-file ".planning/github-issues/370-REQ-SCORE-020.md" --parent <REQ-SCORE-000>
gh issue create --title "[REQ-SCORE-030] Represent an unassessed skill as absent, never as a value" --body-file ".planning/github-issues/380-REQ-SCORE-030.md" --parent <REQ-SCORE-000>
gh issue create --title "[REQ-SCORE-040] Stamp every score with its method, source and recorded date" --body-file ".planning/github-issues/390-REQ-SCORE-040.md" --parent <REQ-SCORE-000>
gh issue create --title "[REQ-SCORE-050] Retain superseded scores as history and present the most recent as current" --body-file ".planning/github-issues/400-REQ-SCORE-050.md" --parent <REQ-SCORE-000>
gh issue create --title "[REQ-SCORE-060] Append-only score audit trail readable only by an Administrator" --body-file ".planning/github-issues/410-REQ-SCORE-060.md" --parent <REQ-SCORE-000>
gh issue create --title "[REQ-SCORE-070] Record a score by assessor rating and by self-assessment" --body-file ".planning/github-issues/420-REQ-SCORE-070.md" --parent <REQ-SCORE-000>
gh issue create --title "[REQ-EXAM-010] Define an exam for a single skill with its questions and answer key" --body-file ".planning/github-issues/430-REQ-EXAM-010.md" --parent <REQ-EXAM-000>
gh issue create --title "[REQ-EXAM-020] Assign an exam and send its invitation through the notification adapter" --body-file ".planning/github-issues/440-REQ-EXAM-020.md" --parent <REQ-EXAM-000>
gh issue create --title "[REQ-EXAM-030] Deliver an exam to an assignee with no answer-key data in the payload" --body-file ".planning/github-issues/450-REQ-EXAM-030.md" --parent <REQ-EXAM-000>
gh issue create --title "[REQ-EXAM-040] Authorize an exam attempt against its assignment" --body-file ".planning/github-issues/460-REQ-EXAM-040.md" --parent <REQ-EXAM-000>
gh issue create --title "[REQ-EXAM-050] Score a submission server-side and convert the percentage to a 1–10 band" --body-file ".planning/github-issues/470-REQ-EXAM-050.md" --parent <REQ-EXAM-000>
gh issue create --title "[REQ-EXAM-060] Use the updated score everywhere after reassessment" --body-file ".planning/github-issues/480-REQ-EXAM-060.md" --parent <REQ-EXAM-000>
gh issue create --title "[REQ-EXAM-070] Serve exam media from the protected asset store under a live authorization decision" --body-file ".planning/github-issues/490-REQ-EXAM-070.md" --parent <REQ-EXAM-000>
gh issue create --title "[REQ-CHART-010] Assemble one chart dataset with a shared axis set and explicit absence markers" --body-file ".planning/github-issues/500-REQ-CHART-010.md" --parent <REQ-CHART-000>
gh issue create --title "[REQ-CHART-020] Enforce the axis and member selection limits server-side with a stated reason" --body-file ".planning/github-issues/510-REQ-CHART-020.md" --parent <REQ-CHART-000>
gh issue create --title "[REQ-CHART-030] Render the shared radar chart with distinguishable series" --body-file ".planning/github-issues/520-REQ-CHART-030.md" --parent <REQ-CHART-000>
gh issue create --title "[REQ-CHART-040] Member and skill selection controls with a visible count against the limit" --body-file ".planning/github-issues/530-REQ-CHART-040.md" --parent <REQ-CHART-000>
gh issue create --title "[REQ-CHART-050] Legend that names every series and toggles its visibility" --body-file ".planning/github-issues/540-REQ-CHART-050.md" --parent <REQ-CHART-000>
gh issue create --title "[REQ-CHART-060] Chart empty state when no team member is selected" --body-file ".planning/github-issues/550-REQ-CHART-060.md" --parent <REQ-CHART-000>
gh issue create --title "[REQ-CHART-070] Equivalent score table rendered from the chart dataset" --body-file ".planning/github-issues/560-REQ-CHART-070.md" --parent <REQ-CHART-000>
gh issue create --title "[REQ-CHART-080] Rank team members by their score for a chosen skill" --body-file ".planning/github-issues/570-REQ-CHART-080.md" --parent <REQ-CHART-000>
gh issue create --title "[REQ-CHART-090] Meet the chart render budget at the supported member and skill scale" --body-file ".planning/github-issues/580-REQ-CHART-090.md" --parent <REQ-CHART-000>
gh issue create --title "[REQ-PORT-010] Team member self-export of their own skill and exam record" --body-file ".planning/github-issues/590-REQ-PORT-010.md" --parent <REQ-PORT-000>
gh issue create --title "[REQ-PORT-020] Bulk delimited import of team members and skills with per-row rejection reasons" --body-file ".planning/github-issues/600-REQ-PORT-020.md" --parent <REQ-PORT-000>
gh issue create --title "[REQ-PORT-030] Administrator interface for creating team members and skills" --body-file ".planning/github-issues/610-REQ-PORT-030.md" --parent <REQ-PORT-000>
```
