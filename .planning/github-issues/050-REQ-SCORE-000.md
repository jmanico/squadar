# [REQ-SCORE-000] Skill scores, history and audit

## Metadata

- **ID**: REQ-SCORE-000
- **Title**: Skill scores, history and audit
- **Version**: 1.0.0
- **Status**: Draft
- **Owner**: Squadar engineering — unassigned
- **Author**: Jim Manico
- **Last Updated**: 2026-09-14
- **Priority**: Critical
- **Requirement Type**: Functional
- **Source / Parent**: REQ-EPIC-001; `REQUIREMENTS.md` FR-4.1–FR-4.6, FR-5.2, FR-5.3, FR-5.11, FR-6.1, NFR-9.6; `ARCHITECTURE.md` Assessment

## Requirement

- **Statement**: The Assessment component MUST hold at most one current score per member per skill on the integer 1–10 scale, retain every superseded score as history, distinguish an unassessed skill from a score of 1, stamp each score with its method and source, and write an audit entry for every create, change and delete; delivery is the sum of its children.
- **Rationale**: These rules are the business core — every chart, table, ranked list and export reads from them, and FR-4.4 and FR-4.6 are the ones most easily lost to a naive data model.
- **Assumptions**: FR-4.2 (integers only) and FR-4.6 (full history) are marked **(assumed)** and stand. Scores do not expire — `OQ-4` is open and no decay behavior is specified.
- **Out of Scope**: Exam-derived scoring, which REQ-EXAM-000 owns. Whether a self-assessed score becomes the current score — `PQ-5`, which blocks REQ-SCORE-070.
- **Design Traceability**: `DESIGN.md` — Typography (monospace numerics so 1–10 scores align in columns); Components (Inputs: score entry accepts only integers 1–10 and states the range in helper text); Form feedback and errors.
- **Architecture Traceability**: `ARCHITECTURE.md` Assessment; Relational Data Store (integrity); Primary Flow 4; DR-3, DR-7.
- **Security Traceability**: SEC-INPUT-2, SEC-INPUT-3, SEC-BIZ-2, SEC-BIZ-3, SEC-BIZ-4, SEC-AUTHZ-3, SEC-AUTHZ-4, SEC-LOG-1, SEC-LOG-3, SEC-LOG-4, SEC-ERR-2, SEC-DATA-4.

## Scope

- **Applies To**: Multiple
- **Components**: Assessment; Relational Data Store; REST API; Web Client
- **Interfaces / Operations**: Score read and write; score history read; score detail; audit trail read
- **Actors**: Administrator, Assessor, Team Member, Viewer
- **Preconditions**: The member exists and is active (FR-2.3) and the skill is active (FR-3.4)
- **Data Classification**: Restricted
- **Personal or Regulated Data**: Personal Data — skill scores are personal performance data about identifiable individuals
- **Jurisdiction / Regulatory Scope**: TO BE DECIDED — `PQ-13`

## Security Context

- **Security Objectives**: Multiple
- **Control Layers**: Authorization, Input Validation, Business-Rule Validation, Data Protection, Logging and Monitoring
- **Threat References**: STRIDE — Tampering, Repudiation, Information Disclosure; OWASP Top 10:2025 Broken Access Control
- **Abuse / Misuse Case**: A caller supplying the scoring method, source or recorded date; an out-of-range score coerced rather than rejected; an Assessor scoring a member outside their teams; a score changed without an audit entry; an audit entry deleted through a product interface.
- **Trust Boundary**: Clients → REST API
- **Untrusted Inputs or Assertions**: Score values, member and skill identifiers, and every server-derived field a client might try to set
- **Authoritative Enforcement Point**: Assessment, behind the REST API
- **Independent Verification**: The one-current-score-per-member-per-skill constraint is enforced in the data store as well as in application logic (SEC-BIZ-2)
- **Zero Trust Relevance**: NIST SP 800-207 §2.1 tenet 4 — each score read is authorized against the requester's role, team assignment and member linkage

## Standards Alignment

- **OWASP ASVS 5.0.0**: TO BE DECIDED — `PQ-17`
- **OWASP AISVS 1.0**: N/A
- **NIST SP 800-53 Rev. 5**: N/A — no mapping verified against the catalog release
- **NIST SP 800-207**: §2.1 tenet 4
- **Regulatory**: TO BE DECIDED — `PQ-13`
- **Other**: N/A
- **Mapping Basis**: Tenet 4 applies because score access depends on the requester's relationship to the scored member, not on having a session.

## Acceptance Criteria

1. **AC-01 — Expected behavior**: Given a member with a current score of 6 for a skill, when a permitted actor records 8, then 8 becomes the current score, 6 is retained in history, and an audit entry names the acting user, the member, the skill, the method and the timestamp (FR-4.6, NFR-9.6, SEC-LOG-1).
2. **AC-02 — Boundary or failure behavior**: Given a member with a current score of 6, when a score of 0, 11, 5.5, "5", null or NaN is submitted, then the request is rejected and the current score is still 6 (FR-4.3, SEC-INPUT-2).
3. **AC-03 — Prohibited behavior**: Given a skill never assessed for a member, when that member's scores are read through any surface, then the skill MUST NOT carry a numeric value — it is reported as absent (FR-4.4, SEC-BIZ-4).

## Failure Behavior

- **On Invalid Input**: Reject rather than coerce; no record, no partial record, no supersession of the existing current score (SEC-INPUT-2)
- **On Authentication Failure**: Refuse; return no score data (SEC-AUTHN-1)
- **On Authorization Failure**: Deny without confirming the target member or score exists (SEC-AUTHZ-7)
- **On Security-Decision Failure**: Deny by default (SEC-AUTHZ-1)
- **On External Dependency Failure**: N/A
- **On System Error**: Roll back; never a score recorded without its history entry or its audit entry (SEC-ERR-2)
- **Logging / Audit**: One audit entry per score create, change and delete, naming acting user, member, skill, method and timestamp, readable only by an Administrator, append-only (SEC-LOG-1, SEC-LOG-4); score values MUST NOT appear in general application logs (SEC-LOG-3)
- **Alerting**: N/A

## Test Strategy

- **Unit Tests**: Range validation; absence vs. zero; supersession ordering; provenance stamping; audit-entry construction
- **Integration Tests**: Concurrent writes asserting no duplicate current score and no lost history (SEC-BIZ-2); failure injection mid-transaction (SEC-ERR-2)
- **Security Tests**: Mass-assignment tests for every server-derived field (SEC-INPUT-3); Assessor out-of-team write attempts (SEC-AUTHZ-4); Team Member reads of another individual's score detail (SEC-AUTHZ-3); audit mutation attempts from every role (SEC-LOG-4); log scrubbing for score values (SEC-LOG-3)
- **Compliance Tests / Evidence**: TO BE DECIDED — `PQ-13`
- **Acceptance-Criteria Traceability**: AC-01 by REQ-SCORE-050 and REQ-SCORE-060; AC-02 by REQ-SCORE-020; AC-03 by REQ-SCORE-030
- **Coverage Target**: Positive and negative coverage on every validation rule, authorization decision and error path
- **Required Test Environment**: The `UT-10.1` fixture — ten members across ten skill levels, including members with unassessed skills

## Dependencies

- **Upstream Requirements**: REQ-FOUND-020, REQ-AUTH-060, REQ-ROSTER-010, REQ-SKILL-010
- **Downstream Requirements**: REQ-EXAM-000, REQ-CHART-000, REQ-PORT-000
- **Child Requirements**:
  - [ ] {{ISSUE_URL:REQ-SCORE-010}} — One current score per member per skill, enforced in the data store
  - [ ] {{ISSUE_URL:REQ-SCORE-020}} — Reject any score that is not an integer from 1 to 10
  - [ ] {{ISSUE_URL:REQ-SCORE-030}} — Represent an unassessed skill as absent, never as a value
  - [ ] {{ISSUE_URL:REQ-SCORE-040}} — Stamp every score with its method, source and recorded date
  - [ ] {{ISSUE_URL:REQ-SCORE-050}} — Retain superseded scores as history and present the most recent as current
  - [ ] {{ISSUE_URL:REQ-SCORE-060}} — Append-only score audit trail readable only by an Administrator
  - [ ] {{ISSUE_URL:REQ-SCORE-070}} — Record a score by assessor rating and by self-assessment
- **External Dependencies**: None
- **Dependency Assumptions**: N/A
- **Failure Impact**: N/A

## Implementation Notes

- **Constraints**: Assessment references members and skills by identity and never mutates them (DR-3). The 1–10 scale and its direction (higher is greater skill, FR-6.1) are fixed.
- **Prohibited Approaches**: Defaulting an unassessed skill to 0 or 1 anywhere in storage, the chart dataset or the table (SEC-BIZ-4); accepting a client-supplied method, source, date or audit field (SEC-INPUT-3); a soft-delete on audit entries (SEC-LOG-4)
- **Implementation Guidance**: Model history as the primary table with a current-score constraint over it, so FR-4.6 and FR-4.1 are one mechanism rather than two.
- **AI Development Guidance**: `CLAUDE.md`; `.claude/agents/security-reviewer.md` on every child here
- **Required Human Review**: Human security review — this workstream is data protection and authorization throughout
- **Open Decisions**: `PQ-5` — whether a self-assessed score counts as the current score; blocks REQ-SCORE-070 only.
