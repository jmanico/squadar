# [REQ-ROSTER-020] Add, edit and deactivate a team member with history retained

## Metadata

- **ID**: REQ-ROSTER-020
- **Title**: Add, edit and deactivate a team member with history retained
- **Version**: 1.0.0
- **Status**: Draft
- **Owner**: Squadar engineering — unassigned
- **Author**: Jim Manico
- **Last Updated**: 2026-09-14
- **Priority**: High
- **Requirement Type**: Functional
- **Source / Parent**: REQ-ROSTER-000; `REQUIREMENTS.md` FR-2.2, FR-2.3; `SECURITY.md` SEC-BIZ-3

## Requirement

- **Statement**: An Administrator MUST be able to add, edit and deactivate a team member; a deactivated member's historical scores MUST be retained and MUST remain retrievable; and a deactivated member MUST be excluded from new assessments, enforced at the API regardless of what the client offers.
- **Rationale**: FR-2.2 and FR-2.3 together mean deactivation is a business state, not a delete. SEC-BIZ-3 makes the exclusion a server-side rule so it cannot be bypassed by calling the API directly.
- **Assumptions**: None.
- **Out of Scope**: Deletion of personal data (FR-8.4, REQ-ROSTER-050, blocked on `PQ-3`) — deactivation and deletion are different operations with different outcomes.
- **Design Traceability**: `DESIGN.md` — Components (Buttons: the destructive variant, filled `error`, is reserved for deletion and deactivation; disabled is never the only signal that an action is unavailable), Form feedback and errors.
- **Architecture Traceability**: `ARCHITECTURE.md` Roster — team member records and lifecycle, including retaining a deactivated member's history while excluding them from new assessments; DR-3, DR-5 (deactivation published as an event Assessment consumes).
- **Security Traceability**: SEC-BIZ-3, SEC-AUTHZ-1, SEC-AUTHZ-5, SEC-AUTHZ-6, SEC-INPUT-1, SEC-LOG-2, SEC-ERR-2.

## Scope

- **Applies To**: Multiple
- **Components**: Roster; Assessment (consumer of the deactivation event); REST API; Web Client
- **Interfaces / Operations**: Member add, edit, deactivate; the assessment write path's active-member check
- **Actors**: Administrator (write); all roles (read)
- **Preconditions**: REQ-ROSTER-010 and REQ-AUTH-060 are Verified
- **Data Classification**: Confidential
- **Personal or Regulated Data**: Personal Data
- **Jurisdiction / Regulatory Scope**: TO BE DECIDED — `PQ-13`

## Security Context

- **Security Objectives**: Integrity, Authorization
- **Control Layers**: Authorization, Business-Rule Validation, Input Validation
- **Threat References**: STRIDE — Tampering, Elevation of Privilege; OWASP Top 10:2025 Broken Access Control; CWE-863 Incorrect Authorization
- **Abuse / Misuse Case**: A score recorded against a deactivated member by calling the API directly, bypassing a client that hides them; a non-Administrator deactivating a member; deactivation implemented as a delete, losing the history FR-2.3 requires.
- **Trust Boundary**: Clients → REST API
- **Untrusted Inputs or Assertions**: Member identifiers and lifecycle-state values in a request
- **Authoritative Enforcement Point**: Roster for the lifecycle state; Assessment for refusing a write against an inactive member (SEC-BIZ-3)
- **Independent Verification**: Direct API write attempts naming a deactivated member, run without a client (SEC-BIZ-3)
- **Zero Trust Relevance**: N/A — this is a business-rule check, not a resource-access policy decision

## Standards Alignment

- **OWASP ASVS 5.0.0**: TO BE DECIDED — `PQ-17`
- **OWASP AISVS 1.0**: N/A
- **NIST SP 800-53 Rev. 5**: N/A
- **NIST SP 800-207**: N/A
- **Regulatory**: TO BE DECIDED — `PQ-13`
- **Other**: N/A
- **Mapping Basis**: No standard mapping is verified for member lifecycle; the governing rules are FR-2.2, FR-2.3 and SEC-BIZ-3.

## Acceptance Criteria

1. **AC-01 — Expected behavior**: Given an Administrator and an active member with recorded scores, when the member is deactivated, then the member's historical scores remain retrievable and the member is reported as inactive (FR-2.3).
2. **AC-02 — Boundary or failure behavior**: Given a deactivated member, when a score is submitted against them directly to the API with no client involved, then the write is refused with the reason stated and no score is recorded (SEC-BIZ-3).
3. **AC-03 — Prohibited behavior**: Given any non-Administrator, when they attempt to add, edit or deactivate a member, then the operation MUST NOT succeed on any code path, including bulk import (FR-1.3, SEC-AUTHZ-5, SEC-AUTHZ-6).

## Failure Behavior

- **On Invalid Input**: Reject with the field and reason named; no lifecycle change (SEC-INPUT-1)
- **On Authentication Failure**: Refuse; return no member data (SEC-AUTHN-1)
- **On Authorization Failure**: Deny without confirming whether the named member exists (SEC-AUTHZ-7)
- **On Security-Decision Failure**: Deny by default (SEC-AUTHZ-1)
- **On External Dependency Failure**: N/A
- **On System Error**: Roll back; a deactivation either takes effect with its event published or not at all (SEC-ERR-2, DR-5)
- **Logging / Audit**: Member add, edit and deactivate logged with actor, action, target and timestamp (SEC-LOG-2); member names MUST NOT appear in the log line (SEC-LOG-3)
- **Alerting**: N/A

## Test Strategy

- **Unit Tests**: Lifecycle state transitions; the active-member predicate used by the assessment write path; edit field validation
- **Integration Tests**: Deactivation published as an event and consumed by Assessment (DR-5); historical scores retrievable after deactivation
- **Security Tests**: Direct API write attempts naming a deactivated member (SEC-BIZ-3); the role sweep over add, edit and deactivate (SEC-AUTHZ-5, SEC-AUTHZ-6); an Assessor attempting deactivation
- **Compliance Tests / Evidence**: TO BE DECIDED — `PQ-13`
- **Acceptance-Criteria Traceability**: AC-01 by the deactivation-and-history test; AC-02 by the direct API write test; AC-03 by the role sweep
- **Coverage Target**: Positive and negative coverage on each lifecycle operation and on the exclusion rule
- **Required Test Environment**: The `UT-10.1` fixture, which includes at least one deactivated member with prior scores

## Dependencies

- **Upstream Requirements**: REQ-ROSTER-010, REQ-AUTH-060, REQ-UIKIT-050
- **Downstream Requirements**: REQ-SCORE-010, REQ-CHART-010, REQ-PORT-020
- **External Dependencies**: None
- **Dependency Assumptions**: N/A
- **Failure Impact**: N/A

## Implementation Notes

- **Constraints**: Deactivation retains history (FR-2.3) — it is a state change, never a delete. Only Roster mutates members (DR-3).
- **Prohibited Approaches**: Implementing deactivation as a row delete or a cascade; enforcing the exclusion only by hiding inactive members in the client (DR-1); a hard delete that anticipates FR-8.4, which is a separate and currently blocked requirement
- **Implementation Guidance**: Publish deactivation as an event rather than calling into Assessment — `ARCHITECTURE.md` DR-5 names exactly this case as the reason the graph stays acyclic.
- **AI Development Guidance**: `CLAUDE.md`; `.claude/agents/spec-auditor.md` before the pull request
- **Required Human Review**: Architecture reviewer for the event contract
- **Open Decisions**: None
- **Estimated effort**: 1–1.5 engineer-days; 350–600 changed human-authored lines
- **Recommended model**: Claude Sonnet 5 (`claude-sonnet-5`) — a stated lifecycle with one server-side exclusion rule, against an authorization layer that already exists.
