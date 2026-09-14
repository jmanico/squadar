# [REQ-SCORE-050] Retain superseded scores as history and present the most recent as current

## Metadata

- **ID**: REQ-SCORE-050
- **Title**: Retain superseded scores as history and present the most recent as current
- **Version**: 1.0.0
- **Status**: Draft
- **Owner**: Squadar engineering — unassigned
- **Author**: Jim Manico
- **Last Updated**: 2026-09-14
- **Priority**: Critical
- **Requirement Type**: Functional
- **Source / Parent**: REQ-SCORE-000; `REQUIREMENTS.md` FR-4.6; `SECURITY.md` SEC-BIZ-2, SEC-ERR-2

## Requirement

- **Statement**: The system MUST retain every previous score for a team member and skill as history, MUST present the most recent score as the current one, and recording a new score MUST preserve the superseded score in history atomically with the supersession.
- **Rationale**: FR-4.6 makes history permanent and the newest score authoritative. SEC-BIZ-2 pairs history preservation with the one-current-score constraint, and SEC-ERR-2 names "a score recorded without history" as a prohibited partial state.
- **Assumptions**: FR-4.6 is marked **(assumed)** in `REQUIREMENTS.md` and stands. Scores do not expire or decay — `OQ-4` is open and no decay behavior is specified, so "most recent" is by recorded date alone.
- **Out of Scope**: The audit trail, which is a separate record of who changed what (REQ-SCORE-060); the storage constraint (REQ-SCORE-010).
- **Design Traceability**: `DESIGN.md` — Layout and Spacing (Density: score tables are compact because comparison across rows is the point), Typography (monospace numerics so 1–10 scores align in columns).
- **Architecture Traceability**: `ARCHITECTURE.md` Assessment — keeps at most one current score per member per skill while retaining full history; Primary Flow 4 (supersedes the prior current score into history); DR-3.
- **Security Traceability**: SEC-BIZ-2, SEC-ERR-2, SEC-AUTHZ-3, SEC-DATA-4, SEC-DATA-6.

## Scope

- **Applies To**: Server-Side Application
- **Components**: Assessment; Relational Data Store; REST API
- **Interfaces / Operations**: Score write with supersession; current-score read; score history read
- **Actors**: Administrator, Assessor, Team Member, Viewer
- **Preconditions**: REQ-SCORE-010, REQ-SCORE-020 and REQ-SCORE-040 are Verified
- **Data Classification**: Restricted
- **Personal or Regulated Data**: Personal Data
- **Jurisdiction / Regulatory Scope**: TO BE DECIDED — `PQ-13`; retention for score history is `TO BE DECIDED` in SEC-DATA-6

## Security Context

- **Security Objectives**: Integrity, Accountability
- **Control Layers**: Business-Rule Validation, Data Protection
- **Threat References**: STRIDE — Tampering, Repudiation; CWE-362 Concurrent Execution using Shared Resource with Improper Synchronization; CWE-460 Improper Cleanup on Thrown Exception
- **Abuse / Misuse Case**: A score overwritten in place so the previous value disappears, erasing evidence of a change; a failure between writing the new score and archiving the old one, leaving a current score with no history behind it; a concurrent pair of writes losing one history entry.
- **Trust Boundary**: Clients → REST API → Assessment
- **Untrusted Inputs or Assertions**: The score value and the member and skill identifiers; the ordering of concurrent writes
- **Authoritative Enforcement Point**: Assessment, performing supersession and archival in one transaction (SEC-BIZ-2, SEC-ERR-2)
- **Independent Verification**: A concurrent-write test asserting no duplicate current score and no lost history, and a failure-injection test mid-transaction asserting no partial state
- **Zero Trust Relevance**: N/A — a data-integrity guarantee, not a resource-access decision

## Standards Alignment

- **OWASP ASVS 5.0.0**: TO BE DECIDED — `PQ-17`
- **OWASP AISVS 1.0**: N/A
- **NIST SP 800-53 Rev. 5**: N/A
- **NIST SP 800-207**: N/A
- **Regulatory**: TO BE DECIDED — `PQ-13`
- **Other**: N/A
- **Mapping Basis**: No standard mapping is verified; the governing rules are FR-4.6, SEC-BIZ-2 and SEC-ERR-2.

## Acceptance Criteria

1. **AC-01 — Expected behavior**: Given a member whose current score for a skill is 6, when 8 is recorded, then 8 is the current score, 6 is retrievable in that member and skill's history with its own provenance and date, and the change is one atomic transition (FR-4.6, SEC-BIZ-2).
2. **AC-02 — Boundary or failure behavior**: Given a failure injected between writing the new score and archiving the superseded one, when the transaction completes, then neither change is visible — there is no current score without its history entry (SEC-ERR-2).
3. **AC-03 — Prohibited behavior**: Given any score write, when the previous current score existed, then that previous score MUST NOT be overwritten, deleted or altered in place (FR-4.6).

## Failure Behavior

- **On Invalid Input**: Reject before supersession; the existing current score is untouched (SEC-INPUT-2)
- **On Authentication Failure**: Refuse (SEC-AUTHN-1)
- **On Authorization Failure**: Deny without confirming the member or score exists (SEC-AUTHZ-7); a Team Member may read only their own history (SEC-AUTHZ-3)
- **On Security-Decision Failure**: Deny by default (SEC-AUTHZ-1)
- **On External Dependency Failure**: N/A
- **On System Error**: Roll back the whole supersession; never a score recorded without history (SEC-ERR-2)
- **Logging / Audit**: The change produces an audit entry through REQ-SCORE-060 in the same transaction (SEC-LOG-1); score values MUST NOT appear in general logs (SEC-LOG-3)
- **Alerting**: N/A

## Test Strategy

- **Unit Tests**: Supersession ordering; "most recent by recorded date" resolution, including two entries on the same date; history read ordering
- **Integration Tests**: A sequence of three scores for one member and skill asserting one current and two history entries, each with its own provenance; a concurrent-write test asserting no duplicate current score and no lost history (SEC-BIZ-2)
- **Security Tests**: Failure injection mid-transaction asserting no partial state (SEC-ERR-2); a Team Member reading another individual's history asserting denial (SEC-AUTHZ-3); a response-shape test per role over the history payload (SEC-DATA-4)
- **Compliance Tests / Evidence**: TO BE DECIDED — retention evidence depends on SEC-DATA-6, which is `TO BE DECIDED` pending `PQ-13`
- **Acceptance-Criteria Traceability**: AC-01 by the supersession sequence test; AC-02 by the failure-injection test; AC-03 by an assertion that prior history rows are byte-identical after a later write
- **Coverage Target**: Positive and negative coverage on supersession, concurrency and the failure path
- **Required Test Environment**: A data store able to run genuinely concurrent transactions and to have failures injected mid-transaction; the `UT-10.1` fixture

## Dependencies

- **Upstream Requirements**: REQ-SCORE-010, REQ-SCORE-020, REQ-SCORE-040
- **Downstream Requirements**: REQ-SCORE-060, REQ-EXAM-050, REQ-EXAM-060, REQ-CHART-010, REQ-PORT-010
- **External Dependencies**: The relational database product — `TO BE DECIDED` (`PQ-8`)
- **Dependency Assumptions**: The product supports transactions strong enough to make supersession and archival atomic; SEC-ERR-2 is not satisfiable without that.
- **Failure Impact**: A store without adequate transactional guarantees would make AC-02 unachievable, which is a reason to raise it when `PQ-8` is answered.

## Implementation Notes

- **Constraints**: History is permanent for as long as the retention policy allows; SEC-DATA-6 requires that policy to exist and it is `TO BE DECIDED`, so this issue must not build in an implicit deletion.
- **Prohibited Approaches**: Updating a score row in place; archiving asynchronously after the write, which opens exactly the window SEC-ERR-2 prohibits; resolving "most recent" by insertion order rather than by the recorded date FR-4.5 stamps
- **Implementation Guidance**: If history is the primary table with a constraint marking the current row (as suggested in REQ-SCORE-010), supersession becomes a single insert plus a constraint-guarded flag change, and atomicity follows from the transaction rather than from careful sequencing.
- **AI Development Guidance**: `CLAUDE.md`; `.claude/agents/security-reviewer.md` before the pull request
- **Required Human Review**: Architecture reviewer for the history model; human security review — data integrity
- **Open Decisions**: `PQ-8` (schema and history-table shape) and `PQ-13` (retention periods, SEC-DATA-6) are recorded. Neither blocks the behavior; both must be settled before retention can be enforced.
- **Estimated effort**: 1.5–2 engineer-days; 450–750 changed human-authored lines
- **Recommended model**: Claude Opus 5 (`claude-opus-5`) — atomicity under concurrency and under injected failure is the requirement, and both failure modes are invisible to a test suite that does not deliberately provoke them.
