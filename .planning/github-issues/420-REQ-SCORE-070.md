# [REQ-SCORE-070] Record a score by assessor rating and by self-assessment

> **BLOCKED — do not implement.** Blocked on `PQ-5`. See **Open Decisions**.

## Metadata

- **ID**: REQ-SCORE-070
- **Title**: Record a score by assessor rating and by self-assessment
- **Version**: 0.1.0
- **Status**: Draft
- **Owner**: Squadar product and engineering — unassigned
- **Author**: Jim Manico
- **Last Updated**: 2026-09-14
- **Priority**: High
- **Requirement Type**: Functional
- **Source / Parent**: REQ-SCORE-000; `REQUIREMENTS.md` FR-5.2, FR-1.5, `OQ-3`; `SECURITY.md` SEC-AUTHZ-4

## Requirement

- **Statement**: The system MUST support recording a skill score by assessor rating and by team-member self-assessment, and an Assessor MUST NOT be able to record, modify or delete a score for a team member outside the teams they are assigned to, on any code path including bulk operations.
- **Rationale**: FR-5.2 adds the two non-exam methods and FR-1.5 scopes the Assessor. What is unresolved is whether a self-assessed score participates in the current score a chart shows, which changes what recording a self-assessment actually does to the system's observable state.
- **Assumptions**: None — `OQ-3` is recorded rather than assumed away.
- **Out of Scope**: Exam-derived scores (REQ-EXAM-050); provenance stamping (REQ-SCORE-040, which already distinguishes the methods in the detail view per FR-5.11).
- **Design Traceability**: `DESIGN.md` — Components (Inputs: score entry accepts only integers 1–10 and states that range in helper text), Form feedback and errors, Brand direction (Squadar measures people and shows the result to those people; nothing gamifies a low score).
- **Architecture Traceability**: `ARCHITECTURE.md` Assessment — supports exam, assessor-rating and self-assessment methods; whether self-assessed scores count as the current score on a chart is `UNKNOWN` (`OQ-3`); Primary Flow 4; DR-3.
- **Security Traceability**: SEC-AUTHZ-4, SEC-AUTHZ-1, SEC-AUTHZ-2, SEC-INPUT-2, SEC-INPUT-3, SEC-BIZ-2, SEC-LOG-1.

## Scope

- **Applies To**: Multiple
- **Components**: Assessment; REST API; Web Client
- **Interfaces / Operations**: Assessor rating write; self-assessment write
- **Actors**: Assessor, Team Member, Administrator
- **Preconditions**: REQ-SCORE-020, REQ-SCORE-040 and REQ-SCORE-050 are Verified
- **Data Classification**: Restricted
- **Personal or Regulated Data**: Personal Data
- **Jurisdiction / Regulatory Scope**: TO BE DECIDED — `PQ-13`

## Security Context

- **Security Objectives**: Authorization, Integrity, Accountability
- **Control Layers**: Authorization, Input Validation, Business-Rule Validation
- **Threat References**: STRIDE — Elevation of Privilege, Tampering; OWASP Top 10:2025 Broken Access Control; CWE-639 Authorization Bypass Through User-Controlled Key
- **Abuse / Misuse Case**: An Assessor scoring a member on a team they are not assigned to, directly or through a bulk operation; a Team Member self-assessing on behalf of someone else; a self-assessed 10 silently becoming the score a shared chart displays to that member's colleagues.
- **Trust Boundary**: Clients → REST API
- **Untrusted Inputs or Assertions**: The target member identifier, the score value, and the caller's implied relationship to the target
- **Authoritative Enforcement Point**: The REST API and Assessment, evaluating the Assessor's team assignments resolved from Roster (SEC-AUTHZ-2, SEC-AUTHZ-4)
- **Independent Verification**: Tests with an Assessor actor and out-of-team member identifiers, run single and bulk (SEC-AUTHZ-4)
- **Zero Trust Relevance**: NIST SP 800-207 §2.1 tenet 4 — the write decision depends on the actor's current team assignment, resolved per request

## Standards Alignment

- **OWASP ASVS 5.0.0**: TO BE DECIDED — `PQ-17`
- **OWASP AISVS 1.0**: N/A
- **NIST SP 800-53 Rev. 5**: N/A
- **NIST SP 800-207**: §2.1 tenet 4
- **Regulatory**: TO BE DECIDED — `PQ-13`
- **Other**: N/A
- **Mapping Basis**: Tenet 4 is cited because SEC-AUTHZ-4's scope depends on an attribute — team assignment — that is resolved at request time rather than carried in the session.

## Acceptance Criteria

The authorization criteria are determinate and are stated. The expected-behavior criteria are not:
whether recording a self-assessment supersedes the current score, sits alongside it, or is visible
only in the detail view decides what "then" clause each criterion carries, and `REQUIREMENTS.md`
poses that as `OQ-3` without answering it. Writing them now would resolve `PQ-5` by implication.

1. **AC-01 — Expected behavior**: BLOCKED on `PQ-5`.
2. **AC-02 — Boundary or failure behavior**: BLOCKED on `PQ-5` for the self-assessment path. For the assessor path: given an Assessor and a member on a team they are not assigned to, when a score is submitted for that member, then it is refused and nothing is recorded (FR-1.5, SEC-AUTHZ-4).
3. **AC-03 — Prohibited behavior**: Given an Assessor, when they attempt to record, modify or delete a score for an out-of-team member on any code path including bulk import, then it MUST NOT succeed (SEC-AUTHZ-4). Given a Team Member, a self-assessment MUST NOT be recordable against another individual. Both criteria hold regardless of how `PQ-5` is answered.

## Failure Behavior

- **On Invalid Input**: Reject; the existing current score is unchanged (SEC-INPUT-2)
- **On Authentication Failure**: Refuse (SEC-AUTHN-1)
- **On Authorization Failure**: Deny without confirming whether the target member exists or which team they belong to (SEC-AUTHZ-7)
- **On Security-Decision Failure**: Deny by default (SEC-AUTHZ-1)
- **On External Dependency Failure**: If team assignments cannot be resolved from Roster, fail closed rather than permitting the write
- **On System Error**: Roll back; no score without its history entry and audit entry (SEC-ERR-2)
- **Logging / Audit**: One audit entry per score mutation (SEC-LOG-1); denials logged with actor, action and target (SEC-LOG-2)
- **Alerting**: N/A

## Test Strategy

- **Unit Tests**: The Assessor team-scope predicate; the self-assessment target predicate; BLOCKED on `PQ-5` for the supersession behavior
- **Integration Tests**: BLOCKED on `PQ-5` — what to assert about the resulting current score depends on the answer
- **Security Tests**: Tests with an Assessor actor and out-of-team member identifiers, single and bulk (SEC-AUTHZ-4); a Team Member self-assessing against another member's identifier; mass-assignment tests on the method and source fields (SEC-INPUT-3)
- **Compliance Tests / Evidence**: TO BE DECIDED — `PQ-13`
- **Acceptance-Criteria Traceability**: AC-02's assessor clause and AC-03 by the SEC-AUTHZ-4 suite; AC-01 and AC-02's self-assessment clause deferred with the criteria themselves
- **Coverage Target**: Every write path × every role, positive and negative, on the authorization dimension
- **Required Test Environment**: The `UT-10.1` fixture with an Assessor assigned to a strict subset of teams

## Dependencies

- **Upstream Requirements**: REQ-SCORE-020, REQ-SCORE-040, REQ-SCORE-050, REQ-SCORE-060, REQ-AUTH-050, REQ-AUTH-060, REQ-ROSTER-030
- **Downstream Requirements**: REQ-CHART-010
- **External Dependencies**: None
- **Dependency Assumptions**: N/A
- **Failure Impact**: N/A

## Implementation Notes

- **Constraints**: The method vocabulary is fixed by FR-5.1 and FR-5.2 — exam, assessor rating, self-assessment. Provenance is derived, not supplied (SEC-INPUT-3, REQ-SCORE-040).
- **Prohibited Approaches**: Deriving the Assessor's team scope from the request; a bulk path with weaker authorization than the interactive one (SEC-AUTHZ-4 says "on any code path including bulk operations"); resolving `OQ-3` in code rather than in `REQUIREMENTS.md`
- **Implementation Guidance**: None on the self-assessment semantics while blocked. The Assessor scope rule is independent of `PQ-5` and could be built first if the team chooses to split this issue once the question is answered.
- **AI Development Guidance**: `CLAUDE.md`; do not implement the self-assessment semantics while BLOCKED
- **Required Human Review**: Product owner to answer `PQ-5`; human security review before merge — authorization (`CLAUDE.md`)
- **Open Decisions**: **`PQ-5` (blocking)** — `OQ-3` in `REQUIREMENTS.md` and the matching `UNKNOWN` in `ARCHITECTURE.md` Assessment: should self-assessed scores count toward the current score shown on a radar chart, or only be shown alongside an assessor- or exam-derived score? FR-5.11 already requires the two to be distinguishable in the detail view; what is undecided is their effect on the current score.
- **Estimated effort**: Not estimated while blocked — the two branches differ materially in scope.
- **Recommended model**: Claude Opus 5 (`claude-opus-5`) — an authorization-sensitive write path with a bulk variant that must not diverge; to be confirmed once `PQ-5` fixes the scope.
