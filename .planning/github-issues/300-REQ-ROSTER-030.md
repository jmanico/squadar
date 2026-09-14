# [REQ-ROSTER-030] Named teams with persistent many-to-many membership

## Metadata

- **ID**: REQ-ROSTER-030
- **Title**: Named teams with persistent many-to-many membership
- **Version**: 1.0.0
- **Status**: Draft
- **Owner**: Squadar engineering — unassigned
- **Author**: Jim Manico
- **Last Updated**: 2026-09-14
- **Priority**: High
- **Requirement Type**: Functional
- **Source / Parent**: REQ-ROSTER-000; `REQUIREMENTS.md` FR-2.4, FR-2.5; `ARCHITECTURE.md` Roster

## Requirement

- **Statement**: A named team MUST be creatable from a selection of team members, saved, and reopened later with the same membership, and a team member MUST be able to belong to more than one team.
- **Rationale**: FR-2.4 and FR-2.5 define the persistent grouping. Team membership is also what FR-1.5 and SEC-AUTHZ-3 evaluate for authorization, so it is load-bearing beyond display.
- **Assumptions**: FR-2.4 and FR-2.5 are marked **(assumed)** in `REQUIREMENTS.md` and stand. "Assembling a team" means saving a manually chosen set; whether it ever means recommending members against a target profile is `OQ-6`, unresolved and out of scope.
- **Out of Scope**: Ad-hoc selection sets that are not saved teams (REQ-ROSTER-040). Team-based recommendation (`OQ-6`).
- **Design Traceability**: `DESIGN.md` — Components (Inputs: selection of team members uses checkable list items with a visible count of the current selection against its limit), Form feedback and errors, Accessibility (Keyboard: selecting team members must be keyboard-operable).
- **Architecture Traceability**: `ARCHITECTURE.md` Roster — named teams with persistent membership and many-to-many membership; membership answers used for authorization and charting; DR-3.
- **Security Traceability**: SEC-AUTHZ-1, SEC-AUTHZ-2, SEC-AUTHZ-5, SEC-INPUT-1, SEC-RENDER-1, SEC-LOG-2.

## Scope

- **Applies To**: Multiple
- **Components**: Roster; REST API; Web Client; Identity & Access and Chart Data Service as readers of membership
- **Interfaces / Operations**: Team create, save, reopen, list; membership add and remove
- **Actors**: Administrator, Assessor, Team Member, Viewer
- **Preconditions**: REQ-ROSTER-010 is Verified
- **Data Classification**: Confidential
- **Personal or Regulated Data**: Personal Data — membership associates named individuals
- **Jurisdiction / Regulatory Scope**: TO BE DECIDED — `PQ-13`

## Security Context

- **Security Objectives**: Integrity, Authorization, Confidentiality
- **Control Layers**: Authorization, Input Validation, Business-Rule Validation
- **Threat References**: STRIDE — Tampering, Elevation of Privilege; OWASP Top 10:2025 Broken Access Control; CWE-863 Incorrect Authorization
- **Abuse / Misuse Case**: A caller adding themselves to a team to gain visibility of its members' scores; a Viewer modifying membership; a team name containing markup reaching a legend or heading.
- **Trust Boundary**: Clients → REST API
- **Untrusted Inputs or Assertions**: Team names, team identifiers, and the member identifiers in a membership payload
- **Authoritative Enforcement Point**: Roster behind the REST API; membership used in an authorization decision is read from Roster, never from the request (SEC-AUTHZ-2)
- **Independent Verification**: The authorization matrix exercises team membership changes as a privilege-relevant operation, not merely a data edit
- **Zero Trust Relevance**: NIST SP 800-207 §2.1 tenet 4 — team membership is an attribute of the access decision for scores and charts

## Standards Alignment

- **OWASP ASVS 5.0.0**: TO BE DECIDED — `PQ-17`
- **OWASP AISVS 1.0**: N/A
- **NIST SP 800-53 Rev. 5**: N/A
- **NIST SP 800-207**: §2.1 tenet 4
- **Regulatory**: TO BE DECIDED — `PQ-13`
- **Other**: N/A
- **Mapping Basis**: Tenet 4 is cited because FR-1.4, FR-1.5 and SEC-AUTHZ-3 all make team membership an input to an access decision.

## Acceptance Criteria

1. **AC-01 — Expected behavior**: Given an Administrator who saves a named team containing four members, when the team is reopened later, then it contains exactly those four members (FR-2.4).
2. **AC-02 — Boundary or failure behavior**: Given a member already belonging to one team, when they are added to a second, then both memberships exist and neither replaces the other (FR-2.5).
3. **AC-03 — Prohibited behavior**: Given a Viewer, or any actor not permitted to administer the team, when they attempt to change its membership, then the change MUST NOT take effect (FR-1.6, SEC-AUTHZ-5); and a membership change MUST NOT be accepted on the basis of a team identifier supplied in the request without an authorization check on that specific team (SEC-AUTHZ-1).

## Failure Behavior

- **On Invalid Input**: Reject with the field and reason named; no team created and no membership changed (SEC-INPUT-1)
- **On Authentication Failure**: Refuse; return no team data (SEC-AUTHN-1)
- **On Authorization Failure**: Deny without confirming whether the named team or member exists (SEC-AUTHZ-7)
- **On Security-Decision Failure**: Deny by default (SEC-AUTHZ-1)
- **On External Dependency Failure**: N/A
- **On System Error**: Roll back; a team is saved with its full membership or not at all (SEC-ERR-2)
- **Logging / Audit**: Team creation and membership change logged with actor, action, target and timestamp (SEC-LOG-2)
- **Alerting**: N/A

## Test Strategy

- **Unit Tests**: Membership set construction; many-to-many invariants; team name validation
- **Integration Tests**: Save-and-reopen round trip asserting identical membership; a member in two teams read from both; membership consumed correctly by REQ-AUTH-050's context resolution
- **Security Tests**: The authorization matrix over membership operations, including a caller attempting to add themselves (SEC-AUTHZ-1); the Viewer sweep (SEC-AUTHZ-5); markup payloads in a team name asserted to render literally (SEC-RENDER-1)
- **Compliance Tests / Evidence**: TO BE DECIDED — `PQ-13`
- **Acceptance-Criteria Traceability**: AC-01 by the round-trip test; AC-02 by the multi-team membership test; AC-03 by the authorization matrix and the Viewer sweep
- **Coverage Target**: Positive and negative coverage on team operations and on membership as an authorization input
- **Required Test Environment**: The `UT-10.1` fixture with members spanning more than one team

## Dependencies

- **Upstream Requirements**: REQ-ROSTER-010, REQ-AUTH-060, REQ-UIKIT-030
- **Downstream Requirements**: REQ-AUTH-050, REQ-CHART-010, REQ-CHART-040
- **External Dependencies**: None
- **Dependency Assumptions**: N/A
- **Failure Impact**: N/A

## Implementation Notes

- **Constraints**: Third normal form (`ARCHITECTURE.md`) — membership is its own relation, which is also what makes FR-2.5 natural. Roster owns teams and membership (DR-3).
- **Prohibited Approaches**: A single team reference on the member record, which would make FR-2.5 unrepresentable; membership treated as a display concern rather than an authorization input
- **Implementation Guidance**: Expose membership through a Roster interface that Identity & Access and Chart Data Service can read, rather than letting either query the tables (DR-4).
- **AI Development Guidance**: `CLAUDE.md`; `.claude/agents/spec-auditor.md` before the pull request
- **Required Human Review**: Security review — membership feeds an authorization decision
- **Open Decisions**: `OQ-6` is recorded: whether assembling a team ever means recommending members. It does not block FR-2.4 as stated.
- **Estimated effort**: 1–1.5 engineer-days; 350–600 changed human-authored lines
- **Recommended model**: Claude Sonnet 5 (`claude-sonnet-5`) — a standard many-to-many relation with a stated round-trip guarantee; the authorization sensitivity is handled by the existing decision function.
