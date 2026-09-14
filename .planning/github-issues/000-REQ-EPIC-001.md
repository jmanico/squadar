# [REQ-EPIC-001] Squadar — implement the specified system

## Metadata

- **ID**: REQ-EPIC-001
- **Title**: Squadar — implement the specified system
- **Version**: 1.0.0
- **Status**: Draft
- **Owner**: Squadar product and engineering — unassigned
- **Author**: Jim Manico
- **Last Updated**: 2026-09-14
- **Priority**: Critical
- **Requirement Type**: Functional
- **Source / Parent**: `REQUIREMENTS.md` (FR-1.1–FR-8.4, NFR-9.1–NFR-9.7, UT-10.1); `ARCHITECTURE.md`; `SECURITY.md`; `DESIGN.md`

## Requirement

- **Statement**: Squadar MUST be delivered as the web, mobile and API system described in `REQUIREMENTS.md`, built to the components and dependency rules in `ARCHITECTURE.md`, the `SEC-*` and `DEP-*` rules in `SECURITY.md`, and the design language in `DESIGN.md`; this requirement is satisfied only when every child requirement is Verified.
- **Rationale**: The specification set is complete enough to build against but decomposes into work no single issue can hold. This epic is the decomposition root and the place where overall coverage is tracked.
- **Assumptions**: The requirements marked **(assumed)** in `REQUIREMENTS.md` stand until the corresponding `OQ-*` is answered. The `PROVISIONAL` rules in `SECURITY.md` stand until reviewed.
- **Out of Scope**: Any behavior not stated in `REQUIREMENTS.md`. Resolution of `OQ-1`…`OQ-6` and `SQ-1`…`SQ-12` — those are product and security decisions, recorded in `ISSUE_PLAN.md` as `PQ-*` and answered outside this epic.
- **Design Traceability**: `DESIGN.md` in full; `style-guide.html` as its rendered reference implementation.
- **Architecture Traceability**: `ARCHITECTURE.md` — all components, Primary Flows 1–5, and dependency rules DR-1…DR-10.
- **Security Traceability**: `SECURITY.md` — SEC-BOUND-1…4, SEC-AUTHN-1…8, SEC-SESSION-1…5, SEC-AUTHZ-1…8, SEC-HTTP-1…7, SEC-INPUT-1…6, SEC-BIZ-1…4, SEC-RENDER-1…4, SEC-DATA-1…6, SEC-SECRET-1…3, SEC-LOG-1…4, SEC-ERR-1…2, SEC-EXT-1…4, SEC-CICD-1…6, DEP-1…DEP-8.

## Scope

- **Applies To**: Multiple
- **Components**: Web Client, Mobile Client, REST API, Identity & Access, Roster, Skill Catalog, Assessment, Chart Data Service, Bulk Import / Export, Relational Data Store, Protected Asset Store, Outbound Notification
- **Interfaces / Operations**: The whole documented REST surface and every screen for the four roles
- **Actors**: Administrator, Assessor, Team Member, Viewer
- **Preconditions**: None
- **Data Classification**: Multiple
- **Personal or Regulated Data**: Personal Data
- **Jurisdiction / Regulatory Scope**: TO BE DECIDED — `SQ-1` conflicts with the stated "no special-category or regulated data" position in `REQUIREMENTS.md`

## Security Context

- **Security Objectives**: Multiple
- **Control Layers**: Architecture
- **Threat References**: STRIDE (full model in `threat-model/10-threat-model-report.md`)
- **Abuse / Misuse Case**: The epic's own abuse case is incompleteness — a requirement or security rule left with no issue, so it is never built and never tested. The coverage table in `ISSUE_PLAN.md` is the control.
- **Trust Boundary**: All three named in `ARCHITECTURE.md` — clients → REST API, API → OIDC provider, API → Protected Asset Store
- **Untrusted Inputs or Assertions**: Everything crossing those boundaries; see each child requirement
- **Authoritative Enforcement Point**: REST API and the owning domain components (DR-1, DR-3)
- **Independent Verification**: Each child carries its own server-side verification; this epic verifies only that every child is Verified
- **Zero Trust Relevance**: NIST SP 800-207 §2.1 tenets 4 and 6 — per-request access decisions on dynamic policy; realized by the children, not here

## Standards Alignment

- **OWASP ASVS 5.0.0**: TO BE DECIDED — target verification level unresolved (`SQ-3`, recorded as `PQ-17`)
- **OWASP AISVS 1.0**: N/A — no AI-enabled component is specified
- **NIST SP 800-53 Rev. 5**: N/A at epic level; children map individually where a mapping is verified
- **NIST SP 800-207**: §2.1 tenets 4 and 6
- **Regulatory**: TO BE DECIDED — `SQ-1`
- **Other**: RFC 2119 / RFC 8174 for normative terms throughout
- **Mapping Basis**: Only mappings that hold for the system as a whole are listed; per-behavior control mappings belong to the child that implements the behavior.

## Acceptance Criteria

1. **AC-01 — Expected behavior**: Given every child requirement listed below, when each has reached `Verified`, then this epic MAY reach `Verified` and every `FR-`, `NFR-` and `UT-` identifier in `REQUIREMENTS.md` traces to at least one Verified child.
2. **AC-02 — Boundary or failure behavior**: Given a child that is `BLOCKED` on a `PQ-*` question, when the coverage table is evaluated, then that requirement is reported as `BLOCKED` with its `PQ-*` named, and this epic MUST NOT reach `Verified`.
3. **AC-03 — Prohibited behavior**: Given the specification files, when any child is implemented, then no child MUST have modified `REQUIREMENTS.md`, `ARCHITECTURE.md`, `SECURITY.md`, `DESIGN.md` or `REQUIREMENT_TEMPLATE.md` to encode a decision rather than raising the `PQ-*`.

## Failure Behavior

- **On Invalid Input**: N/A — this requirement accepts no runtime input
- **On Authentication Failure**: N/A
- **On Authorization Failure**: N/A
- **On Security-Decision Failure**: Deny by default; a child whose security rule cannot be satisfied is blocked, not shipped with the rule waived
- **On External Dependency Failure**: N/A
- **On System Error**: N/A
- **Logging / Audit**: N/A at epic level; SEC-LOG-1…4 are carried by the children that produce the events
- **Alerting**: N/A

## Test Strategy

- **Unit Tests**: N/A — behavior is delivered by the children
- **Integration Tests**: An end-to-end pass over Primary Flows 1–5 in `ARCHITECTURE.md` once the children on those paths are Verified
- **Security Tests**: The aggregate of every child's security tests, run as one suite in CI (SEC-CICD-6)
- **Compliance Tests / Evidence**: TO BE DECIDED pending `SQ-1`
- **Acceptance-Criteria Traceability**: AC-01 and AC-02 are verified by the coverage table in `ISSUE_PLAN.md`; AC-03 by `git log` over the specification files
- **Coverage Target**: Every child's security-critical decision and error path carries positive and negative coverage; the numeric target is set with the first workspace (`REQ-FOUND-010`)
- **Required Test Environment**: The `UT-10.1` fixture from `REQ-FOUND-030`, synthetic only (SEC-DATA-5)

## Dependencies

- **Upstream Requirements**: None
- **Downstream Requirements**: None
- **Child Requirements**:
  - [ ] {{ISSUE_URL:REQ-FOUND-000}} — Foundation: workspaces, shared validation and test fixture
  - [ ] {{ISSUE_URL:REQ-UIKIT-000}} — Design language implementation
  - [ ] {{ISSUE_URL:REQ-AUTH-000}} — Identity, session and authorization
  - [ ] {{ISSUE_URL:REQ-ROSTER-000}} — Team members and teams
  - [ ] {{ISSUE_URL:REQ-SKILL-000}} — Skill catalog
  - [ ] {{ISSUE_URL:REQ-SCORE-000}} — Skill scores, history and audit
  - [ ] {{ISSUE_URL:REQ-EXAM-000}} — Exams, assignment, attempts and scoring
  - [ ] {{ISSUE_URL:REQ-CHART-000}} — Chart dataset, radar chart, score table and ranking
  - [ ] {{ISSUE_URL:REQ-PORT-000}} — Data entry, import, export and deletion
  - [ ] {{ISSUE_URL:REQ-MOBILE-000}} — React Native mobile client
  - [ ] {{ISSUE_URL:REQ-INFRA-000}} — Terraform infrastructure and delivery pipeline
- **External Dependencies**: OIDC provider (UNKNOWN), mail provider (TO BE DECIDED), object/asset storage (TO BE DECIDED), relational database product (TO BE DECIDED)
- **Dependency Assumptions**: Each is reached only through an adapter owned by the component that needs it (DR-6, SEC-EXT-1), so none is assumed trustworthy beyond its contract.
- **Failure Impact**: An unavailable OIDC provider blocks the OIDC sign-in path only; an unavailable mail provider delays exam invitations and account access; an unavailable asset store affects media-bearing exams only.

## Implementation Notes

- **Constraints**: TypeScript strict mode throughout; npm workspaces monorepo (`api/`, `web/`, `mobile/`, `shared/`, `infra/`) per `CLAUDE.md`; one requirement per pull request.
- **Prohibited Approaches**: No business rule may live only in a client (DR-1). No "add security" or "write tests" child — security and tests land with the behavior. No accessibility pass deferred to later (`CLAUDE.md`).
- **Implementation Guidance**: Work the waves in `ISSUE_PLAN.md`; leaves within a wave share no files and can run in parallel.
- **AI Development Guidance**: `CLAUDE.md` and `AGENTS.md`; `.claude/agents/spec-auditor.md` and `.claude/agents/security-reviewer.md` before every pull request; `.claude/commands/next-issue.md` drives the loop.
- **Required Human Review**: Product owner for the `OQ-*` answers; a human security reviewer for every child touching auth, sessions, authorization, input handling, data protection or a trust boundary (`CLAUDE.md`).
- **Open Decisions**: `PQ-1`…`PQ-16` in `ISSUE_PLAN.md` are blocking and gate the children that name them.
