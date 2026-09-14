# [REQ-ROSTER-000] Team members and teams

## Metadata

- **ID**: REQ-ROSTER-000
- **Title**: Team members and teams
- **Version**: 1.0.0
- **Status**: Draft
- **Owner**: Squadar engineering — unassigned
- **Author**: Jim Manico
- **Last Updated**: 2026-09-14
- **Priority**: High
- **Requirement Type**: Functional
- **Source / Parent**: REQ-EPIC-001; `REQUIREMENTS.md` FR-2.1–FR-2.6, FR-8.4; `ARCHITECTURE.md` Roster

## Requirement

- **Statement**: The Roster component MUST own team member records, named teams with many-to-many membership, ad-hoc selection sets and personal-data deletion on request; delivery is the sum of its children.
- **Rationale**: FR-2.1–FR-2.6 define the records every score, chart and authorization decision refers to. `ARCHITECTURE.md` assigns sole ownership of members and teams to Roster (DR-3).
- **Assumptions**: FR-2.4 and FR-2.5 are marked **(assumed)** in `REQUIREMENTS.md` and stand until `OQ-6` is answered. "Assembling a team" means saving a manually chosen set, not recommending one.
- **Out of Scope**: Recommending members against a target skill profile (`OQ-6`). Scores themselves, which Assessment owns.
- **Design Traceability**: `DESIGN.md` — Components (Inputs, Buttons including the destructive variant reserved for deletion and deactivation); Layout and Spacing; Accessibility.
- **Architecture Traceability**: `ARCHITECTURE.md` Roster; DR-3, DR-4, DR-5 (deletion published as an event Assessment consumes).
- **Security Traceability**: SEC-AUTHZ-1, SEC-AUTHZ-2, SEC-AUTHZ-5, SEC-AUTHZ-6, SEC-BIZ-3, SEC-DATA-3, SEC-DATA-4, SEC-INPUT-1, SEC-LOG-2.

## Scope

- **Applies To**: Multiple
- **Components**: Roster; REST API; Web Client; Assessment (consumer of deactivation and deletion events)
- **Interfaces / Operations**: Member create/edit/deactivate/delete; team create/save/reopen; selection sets for display
- **Actors**: Administrator, Assessor, Team Member, Viewer
- **Preconditions**: The caller is authenticated and their authorization context is resolved (REQ-AUTH-050)
- **Data Classification**: Confidential
- **Personal or Regulated Data**: Personal Data
- **Jurisdiction / Regulatory Scope**: TO BE DECIDED — `PQ-13`

## Security Context

- **Security Objectives**: Multiple
- **Control Layers**: Authorization, Input Validation, Business-Rule Validation, Data Protection
- **Threat References**: STRIDE — Tampering, Information Disclosure, Elevation of Privilege; OWASP Top 10:2025 Broken Access Control
- **Abuse / Misuse Case**: A non-Administrator creating or deactivating members; a score recorded against a deactivated member; a deleted member still appearing in a chart, ranked list or export.
- **Trust Boundary**: Clients → REST API
- **Untrusted Inputs or Assertions**: Member and team names, member and team identifiers supplied in a request
- **Authoritative Enforcement Point**: REST API for authorization; Roster for lifecycle rules
- **Independent Verification**: Team membership used in authorization decisions is read from Roster, never from the request (SEC-AUTHZ-2)
- **Zero Trust Relevance**: NIST SP 800-207 §2.1 tenet 4 — access to a member record is determined by policy including the requester's team assignment

## Standards Alignment

- **OWASP ASVS 5.0.0**: TO BE DECIDED — `PQ-17`
- **OWASP AISVS 1.0**: N/A
- **NIST SP 800-53 Rev. 5**: N/A — no verified mapping at workstream level
- **NIST SP 800-207**: §2.1 tenet 4
- **Regulatory**: TO BE DECIDED — `PQ-13`
- **Other**: N/A
- **Mapping Basis**: Tenet 4 is cited because assessor-to-team assignment is an attribute of the access decision, not of the session.

## Acceptance Criteria

1. **AC-01 — Expected behavior**: Given an Administrator, when they add a team member and save a named team containing that member, then reopening the team later returns the same membership (FR-2.1, FR-2.4).
2. **AC-02 — Boundary or failure behavior**: Given a deactivated team member, when any actor attempts to record a new assessment against them through the API, then the request is refused and the member's historical scores remain retrievable (FR-2.3, SEC-BIZ-3).
3. **AC-03 — Prohibited behavior**: Given a Viewer, when they attempt any member or team create, update or delete, then the operation MUST NOT succeed on any code path (FR-1.6, SEC-AUTHZ-5).

## Failure Behavior

- **On Invalid Input**: Reject with a per-field reason; no member or team record is created or modified (SEC-INPUT-1)
- **On Authentication Failure**: Refuse; return no member or team data (SEC-AUTHN-1)
- **On Authorization Failure**: Deny without confirming whether the named member or team exists (SEC-AUTHZ-7)
- **On Security-Decision Failure**: Deny by default (SEC-AUTHZ-1)
- **On External Dependency Failure**: N/A — Roster reaches no external system
- **On System Error**: Roll back; no partially created member or half-saved team (SEC-ERR-2)
- **Logging / Audit**: Account-adjacent and deletion events logged with actor, action, target and timestamp (SEC-LOG-2); no personal content in the log line (SEC-LOG-3)
- **Alerting**: N/A

## Test Strategy

- **Unit Tests**: Member lifecycle transitions; many-to-many membership; selection-set construction
- **Integration Tests**: Team save and reopen round trip; deactivation propagated to Assessment's write path; deletion event consumed by Assessment
- **Security Tests**: Authorization matrix per endpoint and role; a Viewer sweep over every state-changing route (SEC-AUTHZ-5); an Assessor naming an out-of-team member (SEC-AUTHZ-4)
- **Compliance Tests / Evidence**: TO BE DECIDED — `PQ-13`
- **Acceptance-Criteria Traceability**: AC-01 by REQ-ROSTER-030's round-trip test; AC-02 by REQ-ROSTER-020's deactivation test; AC-03 by the role sweep in REQ-AUTH-060 extended to Roster routes
- **Coverage Target**: Positive and negative coverage on every lifecycle rule and authorization decision
- **Required Test Environment**: The `UT-10.1` fixture — ten synthetic members across multiple teams

## Dependencies

- **Upstream Requirements**: REQ-FOUND-020, REQ-AUTH-050, REQ-AUTH-060
- **Downstream Requirements**: REQ-SCORE-000, REQ-CHART-000, REQ-PORT-000
- **Child Requirements**:
  - [ ] {{ISSUE_URL:REQ-ROSTER-010}} — Team member record with distinct identity
  - [ ] {{ISSUE_URL:REQ-ROSTER-020}} — Add, edit and deactivate a team member with history retained
  - [ ] {{ISSUE_URL:REQ-ROSTER-030}} — Named teams with persistent many-to-many membership
  - [ ] {{ISSUE_URL:REQ-ROSTER-040}} — Ad-hoc member selection sets for display
  - [ ] {{ISSUE_URL:REQ-ROSTER-050}} — Personal-data deletion on request
- **External Dependencies**: None
- **Dependency Assumptions**: N/A
- **Failure Impact**: N/A — no external dependency

## Implementation Notes

- **Constraints**: Only Roster mutates members and teams; Assessment references them by identity and never mutates them (DR-3).
- **Prohibited Approaches**: Assessment reading Roster tables directly (DR-4); a deletion implemented as a client-side filter rather than removal at the source (SEC-DATA-3)
- **Implementation Guidance**: Publish deactivation and deletion as events Assessment consumes rather than calling into Assessment (DR-5).
- **AI Development Guidance**: `CLAUDE.md`; `.claude/agents/spec-auditor.md` before each pull request
- **Required Human Review**: Security review for REQ-ROSTER-050 (data protection); product review for the deletion semantics
- **Open Decisions**: `PQ-3` — erasure vs. anonymization and its effect on audit entries; blocks REQ-ROSTER-050 only.
