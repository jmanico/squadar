# [REQ-ROSTER-040] Ad-hoc member selection sets for display

## Metadata

- **ID**: REQ-ROSTER-040
- **Title**: Ad-hoc member selection sets for display
- **Version**: 1.0.0
- **Status**: Draft
- **Owner**: Squadar engineering — unassigned
- **Author**: Jim Manico
- **Last Updated**: 2026-09-14
- **Priority**: High
- **Requirement Type**: Functional
- **Source / Parent**: REQ-ROSTER-000; `REQUIREMENTS.md` FR-2.6; `ARCHITECTURE.md` Roster

## Requirement

- **Statement**: Team members MUST be selectable individually and in groups for the purpose of skill display, whether or not they belong to a saved team, and such a selection MUST be authorized per member rather than assumed permissible because the caller assembled it.
- **Rationale**: FR-2.6 makes display selection independent of saved teams. The authorization clause follows from SEC-AUTHZ-3: a Team Member may see the aggregated chart series only for a team they belong to, so an arbitrary selection cannot be a way around that.
- **Assumptions**: None.
- **Out of Scope**: The chart dataset assembled from a selection (REQ-CHART-010) and the limits applied to it (REQ-CHART-020). Saved teams (REQ-ROSTER-030).
- **Design Traceability**: `DESIGN.md` — Components (Inputs: selection of team members and skills for a chart uses checkable list items with a visible count of the current selection against its limit), Accessibility (Keyboard: selecting team members is keyboard-operable).
- **Architecture Traceability**: `ARCHITECTURE.md` Roster — ad-hoc selection sets for display (FR-2.6); Web Client holds the current selection as transient view state; DR-3.
- **Security Traceability**: SEC-AUTHZ-1, SEC-AUTHZ-2, SEC-AUTHZ-3, SEC-AUTHZ-5, SEC-INPUT-1, SEC-HTTP-6.

## Scope

- **Applies To**: Multiple
- **Components**: Roster; Chart Data Service; REST API; Web Client
- **Interfaces / Operations**: Member selection for display; per-member entitlement check on a selection
- **Actors**: Administrator, Assessor, Team Member, Viewer
- **Preconditions**: REQ-ROSTER-010 and REQ-AUTH-060 are Verified
- **Data Classification**: Confidential
- **Personal or Regulated Data**: Personal Data
- **Jurisdiction / Regulatory Scope**: TO BE DECIDED — `PQ-13`

## Security Context

- **Security Objectives**: Authorization, Confidentiality
- **Control Layers**: Authorization, Input Validation
- **Threat References**: STRIDE — Information Disclosure, Elevation of Privilege; OWASP Top 10:2025 Broken Access Control; CWE-639 Authorization Bypass Through User-Controlled Key
- **Abuse / Misuse Case**: A Team Member assembling an ad-hoc selection containing a member they share no team with, and reading that member's scores through the chart or table route rather than the score-detail route.
- **Trust Boundary**: Clients → REST API
- **Untrusted Inputs or Assertions**: The member identifier list in a selection, and its length
- **Authoritative Enforcement Point**: The REST API, checking each member in the selection against the caller's authorization context before any data is assembled (SEC-AUTHZ-1, SEC-AUTHZ-3)
- **Independent Verification**: Tests per endpoint with a Team Member actor and another member's identifier, including the chart, table, export and ranked-list routes (SEC-AUTHZ-3)
- **Zero Trust Relevance**: NIST SP 800-207 §2.1 tenet 4 — every member in the selection is a distinct resource with its own access decision

## Standards Alignment

- **OWASP ASVS 5.0.0**: TO BE DECIDED — `PQ-17`
- **OWASP AISVS 1.0**: N/A
- **NIST SP 800-53 Rev. 5**: N/A
- **NIST SP 800-207**: §2.1 tenet 4
- **Regulatory**: TO BE DECIDED — `PQ-13`
- **Other**: N/A
- **Mapping Basis**: Tenet 4 is cited because a selection is a set of resources, and SEC-AUTHZ-3 requires the decision to be made per member rather than per request.

## Acceptance Criteria

1. **AC-01 — Expected behavior**: Given an Assessor assigned to two teams, when they select members individually across both teams without saving a team, then the selection is accepted and can back a display without any saved team existing (FR-2.6).
2. **AC-02 — Boundary or failure behavior**: Given a Team Member, when they submit a selection containing one member from a team they belong to and one member they share no team with, then the request is denied without revealing which of the two was the problem (SEC-AUTHZ-3, SEC-AUTHZ-7).
3. **AC-03 — Prohibited behavior**: Given any selection, when it is processed, then entitlement MUST NOT be inferred from the caller having assembled the selection — each member is checked against the caller's context independently (SEC-AUTHZ-1, SEC-AUTHZ-2).

## Failure Behavior

- **On Invalid Input**: Reject a malformed or empty selection with the reason named; assemble no data (SEC-INPUT-1)
- **On Authentication Failure**: Refuse; return no member data (SEC-AUTHN-1)
- **On Authorization Failure**: Deny the whole request; do not silently drop the members the caller may not see, which would disclose their absence (SEC-AUTHZ-7)
- **On Security-Decision Failure**: Deny by default (SEC-AUTHZ-1)
- **On External Dependency Failure**: N/A
- **On System Error**: No partial selection result (SEC-ERR-2)
- **Logging / Audit**: Authorization denials logged with actor, action and target (SEC-LOG-2)
- **Alerting**: N/A

## Test Strategy

- **Unit Tests**: Selection construction; the per-member entitlement predicate; deny-whole-request behavior on a mixed selection
- **Integration Tests**: An ad-hoc selection backing a chart dataset request with no saved team involved
- **Security Tests**: Tests per route with a Team Member actor and another member's identifier, covering chart, table, export and ranked list (SEC-AUTHZ-3); a mixed-entitlement selection asserting whole-request denial rather than silent filtering; selection-length bounds asserted server-side (SEC-HTTP-6)
- **Compliance Tests / Evidence**: TO BE DECIDED — `PQ-13`
- **Acceptance-Criteria Traceability**: AC-01 by the cross-team selection test; AC-02 by the mixed-entitlement test; AC-03 by the per-member entitlement tests
- **Coverage Target**: Positive and negative coverage per role on selections that are fully entitled, partly entitled and not entitled
- **Required Test Environment**: The `UT-10.1` fixture with members spanning teams the test actors do and do not belong to

## Dependencies

- **Upstream Requirements**: REQ-ROSTER-010, REQ-ROSTER-030, REQ-AUTH-050, REQ-AUTH-060
- **Downstream Requirements**: REQ-CHART-010, REQ-CHART-020, REQ-CHART-040
- **External Dependencies**: None
- **Dependency Assumptions**: N/A
- **Failure Impact**: N/A

## Implementation Notes

- **Constraints**: The Web Client holds the current selection as transient view state and owns no durable data (`ARCHITECTURE.md` Web Client) — the selection is not a saved object.
- **Prohibited Approaches**: Silently filtering out members the caller may not see, which discloses their existence by omission; treating a selection as entitled because it came from an authenticated caller; enforcing selection size only in the client (SEC-HTTP-6)
- **Implementation Guidance**: Keep the entitlement check here, before REQ-CHART-010 assembles anything, so no score is read for a member the caller may not see.
- **AI Development Guidance**: `CLAUDE.md`; `.claude/agents/security-reviewer.md` before the pull request
- **Required Human Review**: Human security review before merge — authorization (`CLAUDE.md`)
- **Open Decisions**: None
- **Estimated effort**: 0.5–1 engineer-day; 250–450 changed human-authored lines
- **Recommended model**: Claude Opus 5 (`claude-opus-5`) — small in size but it is the route by which an unentitled read is most likely to slip through, and the correct failure behavior (deny the request rather than filter the set) is counterintuitive.
