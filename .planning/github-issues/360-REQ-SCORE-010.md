# [REQ-SCORE-010] One current score per member per skill, enforced in the data store

## Metadata

- **ID**: REQ-SCORE-010
- **Title**: One current score per member per skill, enforced in the data store
- **Version**: 1.0.0
- **Status**: Draft
- **Owner**: Squadar engineering — unassigned
- **Author**: Jim Manico
- **Last Updated**: 2026-09-14
- **Priority**: Critical
- **Requirement Type**: Functional
- **Source / Parent**: REQ-SCORE-000; `REQUIREMENTS.md` FR-4.1; `SECURITY.md` SEC-BIZ-2

## Requirement

- **Statement**: The system MUST associate each team member with at most one current score per skill, and that constraint MUST be enforced in the data store as well as in application logic.
- **Rationale**: FR-4.1 is the invariant every chart series, score table cell and ranked list depends on. SEC-BIZ-2 requires it at the storage layer because a concurrent write defeats an application-only check.
- **Assumptions**: None.
- **Out of Scope**: Score history and supersession (REQ-SCORE-050); range validation (REQ-SCORE-020); the absence representation (REQ-SCORE-030).
- **Design Traceability**: `DESIGN.md` — Typography (numeric and code family used for 1–10 scores in tables so digits align in columns), Layout and Spacing (score tables are compact because comparison across rows is the point).
- **Architecture Traceability**: `ARCHITECTURE.md` Assessment — keeps at most one current score per member per skill; Relational Data Store — enforces relational integrity for the constraints the domain depends on, naming one current score per member per skill explicitly; DR-3.
- **Security Traceability**: SEC-BIZ-2, SEC-INPUT-3, SEC-ERR-2, SEC-DATA-1.

## Scope

- **Applies To**: Server-Side Application
- **Components**: Assessment; Relational Data Store
- **Interfaces / Operations**: Current-score read and write; the storage constraint
- **Actors**: Administrator, Assessor, Team Member (self-assessment), and the exam scoring path
- **Preconditions**: REQ-ROSTER-010 and REQ-SKILL-010 are Verified
- **Data Classification**: Restricted
- **Personal or Regulated Data**: Personal Data — a score is personal performance data about an identifiable individual
- **Jurisdiction / Regulatory Scope**: TO BE DECIDED — `PQ-13`

## Security Context

- **Security Objectives**: Integrity
- **Control Layers**: Business-Rule Validation, Data Protection
- **Threat References**: STRIDE — Tampering; CWE-362 Concurrent Execution using Shared Resource with Improper Synchronization; CWE-667 Improper Locking
- **Abuse / Misuse Case**: Two simultaneous writes for the same member and skill each passing an application-level "is there a current score?" check and both being written, leaving two current scores — after which the chart, the table and the ranked list may each pick a different one.
- **Trust Boundary**: Clients → REST API → Assessment → Relational Data Store
- **Untrusted Inputs or Assertions**: Member and skill identifiers on a score write
- **Authoritative Enforcement Point**: The Relational Data Store's constraint, backed by Assessment's application logic (SEC-BIZ-2)
- **Independent Verification**: A concurrent-write test asserting no duplicate current score and no lost history (SEC-BIZ-2)
- **Zero Trust Relevance**: N/A — a data-integrity constraint, not a resource-access decision

## Standards Alignment

- **OWASP ASVS 5.0.0**: TO BE DECIDED — `PQ-17`
- **OWASP AISVS 1.0**: N/A
- **NIST SP 800-53 Rev. 5**: N/A
- **NIST SP 800-207**: N/A
- **Regulatory**: TO BE DECIDED — `PQ-13`
- **Other**: N/A
- **Mapping Basis**: No standard mapping is verified; the governing rules are FR-4.1 and SEC-BIZ-2.

## Acceptance Criteria

1. **AC-01 — Expected behavior**: Given a member and a skill, when their scores are read, then exactly zero or one current score is returned — never two (FR-4.1).
2. **AC-02 — Boundary or failure behavior**: Given two simultaneous score writes for the same member and skill, when both are committed, then exactly one current score exists afterwards, no history entry is lost, and the losing write either fails cleanly or is applied as a supersession — never as a second current score (SEC-BIZ-2).
3. **AC-03 — Prohibited behavior**: Given the data store, when its schema is inspected, then the one-current-score-per-member-per-skill rule MUST NOT exist only in application code (SEC-BIZ-2).

## Failure Behavior

- **On Invalid Input**: Reject a write naming an unknown member or skill; record nothing (SEC-INPUT-1)
- **On Authentication Failure**: Refuse; return no score data (SEC-AUTHN-1)
- **On Authorization Failure**: Deny without confirming the score exists (SEC-AUTHZ-7)
- **On Security-Decision Failure**: Deny by default (SEC-AUTHZ-1)
- **On External Dependency Failure**: N/A
- **On System Error**: Roll back; a constraint violation MUST NOT leave a score recorded without its history entry (SEC-ERR-2)
- **Logging / Audit**: The score mutation's audit entry is written by REQ-SCORE-060; a constraint violation is logged with identifiers only, never score values (SEC-LOG-3)
- **Alerting**: N/A

## Test Strategy

- **Unit Tests**: The current-score read returning zero or one; the supersession path's interaction with the constraint
- **Integration Tests**: Concurrent-write test at the data store asserting exactly one current score and no lost history (SEC-BIZ-2); failure injection mid-transaction asserting no partial state (SEC-ERR-2)
- **Security Tests**: A direct data-store write attempt that would create a second current score, asserting the constraint refuses it independently of application logic
- **Compliance Tests / Evidence**: TO BE DECIDED — `PQ-13`
- **Acceptance-Criteria Traceability**: AC-01 by the read test; AC-02 by the concurrency test; AC-03 by the schema inspection and the direct-write test
- **Coverage Target**: Positive and negative coverage on the constraint, including the concurrent path
- **Required Test Environment**: A data store able to run genuinely concurrent transactions; the `UT-10.1` fixture

## Dependencies

- **Upstream Requirements**: REQ-ROSTER-010, REQ-SKILL-010, REQ-FOUND-020
- **Downstream Requirements**: REQ-SCORE-020, REQ-SCORE-030, REQ-SCORE-040, REQ-SCORE-050, REQ-SCORE-060, REQ-EXAM-050, REQ-CHART-010
- **External Dependencies**: The relational database product — `TO BE DECIDED` in `ARCHITECTURE.md` (`PQ-8`)
- **Dependency Assumptions**: The eventual product supports a uniqueness constraint over a partial or filtered index, or an equivalent mechanism; if it does not, the model must change rather than the rule being relaxed.
- **Failure Impact**: A product without the necessary constraint capability would push FR-4.1 into application logic alone, which SEC-BIZ-2 prohibits — a reason to raise `PQ-8` before committing to a product.

## Implementation Notes

- **Constraints**: Third normal form (`ARCHITECTURE.md` data model expectations). `PQ-8` leaves the product and the history-table shape undecided; this issue defines the constraint the eventual schema must carry.
- **Prohibited Approaches**: An application-only check; a "latest by timestamp" convention with no constraint, which permits two rows to be written and then disagreed about; a client-side guard
- **Implementation Guidance**: Modelling history as the primary table with a constraint identifying the current row makes FR-4.1 and FR-4.6 one mechanism rather than two that can drift — see REQ-SCORE-050, which owns the history behavior itself.
- **AI Development Guidance**: `CLAUDE.md`; `.claude/agents/security-reviewer.md` before the pull request
- **Required Human Review**: Architecture reviewer for the schema; human security review — data integrity at the storage layer
- **Open Decisions**: `PQ-8` (blocking for the concrete schema, not for the constraint's definition) — the database product, schema and history-table shape are `TO BE DECIDED` in `ARCHITECTURE.md`. Implement against the chosen product and record the choice in `ARCHITECTURE.md` in the same change.
- **Estimated effort**: 1–1.5 engineer-days; 300–550 changed human-authored lines
- **Recommended model**: Claude Opus 5 (`claude-opus-5`) — the invariant every downstream surface depends on, and the failure mode is a race that only appears under genuine concurrency.
