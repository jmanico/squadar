# [REQ-AUTH-050] Server-resolved authorization context and session revocation

## Metadata

- **ID**: REQ-AUTH-050
- **Title**: Server-resolved authorization context and session revocation
- **Version**: 1.0.0
- **Status**: Draft
- **Owner**: Squadar engineering — unassigned
- **Author**: Jim Manico
- **Last Updated**: 2026-09-14
- **Priority**: Critical
- **Requirement Type**: Security
- **Source / Parent**: REQ-AUTH-000; `REQUIREMENTS.md` FR-1.2, FR-1.4, FR-1.5; `SECURITY.md` SEC-SESSION-2, SEC-SESSION-3

## Requirement

- **Statement**: For every authenticated request the API MUST resolve the caller's authorization context — their single role, the teams an Assessor is assigned to, and the team member the user corresponds to — from Identity & Access and Roster rather than accepting it as final from a client-supplied token payload; and a revoked or role-changed session MUST stop authorizing protected operations without waiting for token expiry.
- **Rationale**: FR-1.2 assigns exactly one role per user, FR-1.4 scopes a Team Member to their own record, and FR-1.5 scopes an Assessor to their assigned teams. SEC-SESSION-2 makes those attributes resolvable only from their owning components, and SEC-SESSION-3 makes a role change take effect immediately rather than at expiry.
- **Assumptions**: FR-1.2's exactly-one-role model governs, notwithstanding the ABAC language in the security notes (`PQ-1` records the conflict). The context assembled here carries the documented attributes, so either reading is served by the same resolution.
- **Out of Scope**: The decision function that consumes the context (REQ-AUTH-060); session issuance and transport (REQ-AUTH-040).
- **Design Traceability**: N/A — the authorization context has no visual surface.
- **Architecture Traceability**: `ARCHITECTURE.md` Identity & Access — produces the authorization context the API and domain components evaluate against, and reads Roster to link a user to a team member; DR-3, DR-5.
- **Security Traceability**: SEC-SESSION-2, SEC-SESSION-3, SEC-AUTHZ-1, SEC-AUTHZ-2, SEC-LOG-2, SEC-LOG-3.

## Scope

- **Applies To**: Server-Side Application
- **Components**: Identity & Access; Roster; REST API
- **Interfaces / Operations**: Authorization-context assembly on every authenticated request; session revocation
- **Actors**: Administrator, Assessor, Team Member, Viewer
- **Preconditions**: The request carries a verified session
- **Data Classification**: Restricted
- **Personal or Regulated Data**: Personal Data — the member linkage identifies an individual
- **Jurisdiction / Regulatory Scope**: TO BE DECIDED — `PQ-13`

## Security Context

- **Security Objectives**: Authorization, Integrity, Accountability
- **Control Layers**: Session Management, Authorization, Logging and Monitoring
- **Threat References**: STRIDE — Elevation of Privilege, Spoofing; OWASP Top 10:2025 Broken Access Control; CWE-863 Incorrect Authorization; CWE-613 Insufficient Session Expiration
- **Abuse / Misuse Case**: A validly signed token carrying a stale or elevated role still granting the elevated operation; a request supplying its own team identifier or member identifier and having it accepted as the caller's; a deactivated account continuing to act until its token expires.
- **Trust Boundary**: Clients → REST API
- **Untrusted Inputs or Assertions**: Every role, team and member value present in the token payload, request body, header or path
- **Authoritative Enforcement Point**: Identity & Access for role and session validity; Roster for team assignment and member linkage
- **Independent Verification**: The context is rebuilt from the owning components per request; the token is treated as an identity assertion, not as an authorization statement (SEC-SESSION-2)
- **Zero Trust Relevance**: NIST SP 800-207 §2.1 tenet 4 — access is determined by dynamic policy including the requester's observable attributes, resolved at request time

## Standards Alignment

- **OWASP ASVS 5.0.0**: TO BE DECIDED — `PQ-17`
- **OWASP AISVS 1.0**: N/A
- **NIST SP 800-53 Rev. 5**: N/A — no control mapping verified against a specific catalog release
- **NIST SP 800-207**: §2.1 tenet 4
- **Regulatory**: TO BE DECIDED — `PQ-13`
- **Other**: N/A
- **Mapping Basis**: Tenet 4 is cited because SEC-SESSION-2 requires the authorization attributes to be resolved from authoritative sources per request rather than carried in the session.

## Acceptance Criteria

1. **AC-01 — Expected behavior**: Given an authenticated Assessor, when any request is handled, then the context resolved for it names exactly one role and the set of teams that Assessor is currently assigned to according to Roster (FR-1.2, FR-1.5).
2. **AC-02 — Boundary or failure behavior**: Given a validly signed token issued before a role change or an account deactivation, when the next protected request presents it, then the operation is refused — the context reflects the current state, not the state at issuance (SEC-SESSION-3).
3. **AC-03 — Prohibited behavior**: Given a request supplying a role, team identifier or member identifier of its own, when the context is assembled, then that supplied value MUST NOT change the resolved context or the resulting decision (SEC-SESSION-2, SEC-AUTHZ-2).

## Failure Behavior

- **On Invalid Input**: A request whose claimed subject cannot be resolved to an account yields no context and the request is refused
- **On Authentication Failure**: Refuse; return no product data (SEC-AUTHN-1)
- **On Authorization Failure**: Deny without confirming the existence of a record the caller may not see (SEC-AUTHZ-7)
- **On Security-Decision Failure**: Deny by default — an incomplete or unresolvable context is not treated as an empty-but-valid one (SEC-AUTHZ-1)
- **On External Dependency Failure**: If Roster cannot be reached, the context is incomplete and the request fails closed rather than proceeding without team assignments
- **On System Error**: No internal detail in the response (SEC-ERR-1)
- **Logging / Audit**: Session revocation and authorization denial logged with actor, action, target and timestamp (SEC-LOG-2); tokens and personal content MUST NOT be logged (SEC-LOG-3)
- **Alerting**: N/A

## Test Strategy

- **Unit Tests**: Context assembly from role, team assignments and member linkage; behavior when one source is missing; revocation predicate
- **Integration Tests**: A role change and an account deactivation each asserted to block the next protected request on an already-issued token (SEC-SESSION-3)
- **Security Tests**: A validly signed token carrying a stale or elevated role asserted not to grant the elevated operation (SEC-SESSION-2); requests supplying a role, team identifier or member identifier asserted not to change the decision (SEC-AUTHZ-2); a Roster-unavailable test asserting fail-closed
- **Compliance Tests / Evidence**: TO BE DECIDED — `PQ-13`
- **Acceptance-Criteria Traceability**: AC-01 by the context-assembly tests; AC-02 by the revocation integration tests; AC-03 by the attribute-override tests
- **Coverage Target**: Positive and negative coverage on each resolved attribute and on the revocation path
- **Required Test Environment**: The `UT-10.1` fixture with one account per role, an Assessor assigned to a subset of teams, and a Team Member linked to a member record

## Dependencies

- **Upstream Requirements**: REQ-FOUND-020, REQ-ROSTER-010, REQ-AUTH-010
- **Downstream Requirements**: REQ-AUTH-060, REQ-AUTH-070, and every authorization decision in the product
- **External Dependencies**: None
- **Dependency Assumptions**: N/A
- **Failure Impact**: N/A

## Implementation Notes

- **Constraints**: Identity & Access owns users, roles and sessions; Roster owns teams and membership; neither mutates the other's objects (DR-3). Identity & Access reads Roster to link a user to a team member, which `ARCHITECTURE.md` states explicitly.
- **Prohibited Approaches**: Caching the context across a role change without invalidation; treating the token payload's role claim as the final word; letting a missing team assignment default to "all teams"
- **Implementation Guidance**: Build this before REQ-AUTH-060 and before any domain workstream, so no endpoint can ship with an ad-hoc context of its own. SEC-LOG-2's security-event logging is implemented here, since this is where denials and revocations are observed.
- **AI Development Guidance**: `CLAUDE.md`; `.claude/agents/security-reviewer.md` before the pull request
- **Required Human Review**: Human security review before merge — sessions and authorization (`CLAUDE.md`)
- **Open Decisions**: `PQ-1` is recorded but does not block this issue: the context resolves the documented attributes either way. The revocation mechanism, access-token lifetime, refresh model and timeouts are `TO BE DECIDED` in SEC-SESSION-3; record the choice in `SECURITY.md` in the same change.
- **Estimated effort**: 1.5–2 engineer-days; 450–750 changed human-authored lines
- **Recommended model**: Claude Opus 5 (`claude-opus-5`) — every authorization decision in the product reads this context, and the dangerous failures are quiet ones: a stale cache, a defaulted team set, or a token claim trusted one layer too deep.
