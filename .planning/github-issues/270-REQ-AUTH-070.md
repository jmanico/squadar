# [REQ-AUTH-070] Administrator account and role administration

## Metadata

- **ID**: REQ-AUTH-070
- **Title**: Administrator account and role administration
- **Version**: 1.0.0
- **Status**: Draft
- **Owner**: Squadar engineering — unassigned
- **Author**: Jim Manico
- **Last Updated**: 2026-09-14
- **Priority**: High
- **Requirement Type**: Security
- **Source / Parent**: REQ-AUTH-000; `REQUIREMENTS.md` FR-1.2, FR-1.3; `SECURITY.md` SEC-AUTHZ-6

## Requirement

- **Statement**: Only an Administrator MUST be able to create, modify or deactivate user accounts and assign roles; every user MUST have exactly one role from Administrator, Assessor, Team Member and Viewer; and no actor MUST be able to change their own role.
- **Rationale**: FR-1.3 restricts account administration to Administrators and FR-1.2 fixes the single-role model. SEC-AUTHZ-6 adds the self-role prohibition, which is the escalation path a role field on a profile update would otherwise open.
- **Assumptions**: The four roles in `REQUIREMENTS.md` are correct; `OQ-1` questions their boundaries but not their existence.
- **Out of Scope**: Team member records, which Roster owns (REQ-ROSTER-020) — a user account and a team member are distinct objects linked by Identity & Access. Credential setup, which REQ-AUTH-010 and REQ-AUTH-020 own.
- **Design Traceability**: `DESIGN.md` — Components (Inputs: persistent visible labels, required fields marked in the label; Buttons: the destructive variant is reserved for deletion and deactivation), Form feedback and errors.
- **Architecture Traceability**: `ARCHITECTURE.md` Identity & Access — owns users, credentials, role assignments and sessions; role assignment per FR-1.2 and FR-1.3; DR-3.
- **Security Traceability**: SEC-AUTHZ-6, SEC-AUTHZ-1, SEC-AUTHZ-7, SEC-SESSION-3, SEC-INPUT-3, SEC-LOG-2, SEC-ERR-1.

## Scope

- **Applies To**: Multiple
- **Components**: Identity & Access; REST API; Web Client
- **Interfaces / Operations**: Account create, modify, deactivate; role assignment; account list
- **Actors**: Administrator (write); all roles are possible targets
- **Preconditions**: The caller is authenticated and their context is resolved (REQ-AUTH-050)
- **Data Classification**: Restricted
- **Personal or Regulated Data**: Personal Data
- **Jurisdiction / Regulatory Scope**: TO BE DECIDED — `PQ-13`

## Security Context

- **Security Objectives**: Authorization, Integrity, Accountability
- **Control Layers**: Authorization, Input Validation, Logging and Monitoring
- **Threat References**: STRIDE — Elevation of Privilege; OWASP Top 10:2025 Broken Access Control; CWE-269 Improper Privilege Management; CWE-915 Improperly Controlled Modification of Dynamically-Determined Object Attributes
- **Abuse / Misuse Case**: A Team Member submitting a profile update carrying a `role` field and having it applied (mass assignment); an Assessor creating an Administrator account; an actor promoting themselves; a deactivated account continuing to act on an already-issued token.
- **Trust Boundary**: Clients → REST API → Identity & Access
- **Untrusted Inputs or Assertions**: Every field in an account payload, including any role field on a self-service update
- **Authoritative Enforcement Point**: Identity & Access behind the REST API (SEC-AUTHZ-6)
- **Independent Verification**: Privilege-escalation tests run from each non-Administrator role, including self-role modification and mass assignment of a role field on a profile update (SEC-AUTHZ-6)
- **Zero Trust Relevance**: NIST SP 800-207 §2.1 tenet 4 — the decision uses the requester's own role as an attribute, evaluated server-side

## Standards Alignment

- **OWASP ASVS 5.0.0**: TO BE DECIDED — `PQ-17`
- **OWASP AISVS 1.0**: N/A
- **NIST SP 800-53 Rev. 5**: N/A — no control mapping verified against a specific catalog release
- **NIST SP 800-207**: §2.1 tenet 4
- **Regulatory**: TO BE DECIDED — `PQ-13`
- **Other**: N/A
- **Mapping Basis**: Tenet 4 is cited because the requester's role is an attribute of the access decision resolved per request, not a property of the session.

## Acceptance Criteria

1. **AC-01 — Expected behavior**: Given an Administrator, when they create an account and assign it the Assessor role, then the account exists with exactly one role and the assignment is recorded with actor, action, target and timestamp (FR-1.2, FR-1.3, SEC-LOG-2).
2. **AC-02 — Boundary or failure behavior**: Given an Administrator who deactivates an account, when that account's already-issued token is next presented on a protected request, then the operation is refused without waiting for token expiry (SEC-SESSION-3).
3. **AC-03 — Prohibited behavior**: Given any non-Administrator, when they submit an account create, modify, deactivate or role-assignment request — including a profile update carrying a role field — then it MUST NOT take effect; and given any actor including an Administrator, a request to change their own role MUST NOT take effect (SEC-AUTHZ-6, SEC-INPUT-3).

## Failure Behavior

- **On Invalid Input**: Reject with the field and reason named; no account is created or modified; a role field on a self-service update is ignored or rejected rather than applied (SEC-INPUT-1, SEC-INPUT-3)
- **On Authentication Failure**: Refuse; return no account data (SEC-AUTHN-1)
- **On Authorization Failure**: Deny without confirming whether the named account exists (SEC-AUTHZ-7)
- **On Security-Decision Failure**: Deny by default (SEC-AUTHZ-1)
- **On External Dependency Failure**: An account-access email that fails to send does not roll back the account change; the failure is reported and retried (DR-6)
- **On System Error**: Roll back; no half-created account and no role assigned without its account (SEC-ERR-2)
- **Logging / Audit**: Account creation, modification, deactivation and role change logged with actor, action, target and timestamp (SEC-LOG-2); credentials MUST NOT be logged (SEC-LOG-3)
- **Alerting**: N/A

## Test Strategy

- **Unit Tests**: Single-role invariant; the self-role prohibition; role-field stripping on a self-service update; deactivation state transition
- **Integration Tests**: Account creation followed by sign-in as the new role; deactivation followed by a protected request on the pre-existing token (SEC-SESSION-3)
- **Security Tests**: Privilege-escalation tests from each non-Administrator role, including self-role modification and mass assignment of a role field on a profile update (SEC-AUTHZ-6); denial-response comparison for existing vs. non-existing account identifiers (SEC-AUTHZ-7)
- **Compliance Tests / Evidence**: TO BE DECIDED — `PQ-13`
- **Acceptance-Criteria Traceability**: AC-01 by the creation and logging tests; AC-02 by the deactivation integration test; AC-03 by the privilege-escalation suite
- **Coverage Target**: Every account operation × every role, positive and negative
- **Required Test Environment**: The `UT-10.1` fixture with one account per role

## Dependencies

- **Upstream Requirements**: REQ-AUTH-050, REQ-AUTH-060, REQ-UIKIT-050
- **Downstream Requirements**: None
- **External Dependencies**: The mail provider, for account-access messages — reached only through the Outbound Notification adapter (DR-6, SEC-EXT-1)
- **Dependency Assumptions**: An account-access link is single-use, time-bounded, unguessable, bound to the intended recipient, and confers no session beyond the action it authorizes (SEC-AUTHN-8).
- **Failure Impact**: A mail-provider outage delays account access but does not block account administration itself.

## Implementation Notes

- **Constraints**: Identity & Access owns users, roles and sessions (DR-3). Exactly one role per user (FR-1.2) — the data model should make a second role unrepresentable rather than merely rejected.
- **Prohibited Approaches**: A role field accepted from a general profile-update payload; a self-service role change behind any condition; a deactivation that only hides the account from lists
- **Implementation Guidance**: Deactivation must interact with REQ-AUTH-050's revocation path, not merely flag the record — SEC-SESSION-3 requires the next protected request to be refused.
- **AI Development Guidance**: `CLAUDE.md`; `.claude/agents/security-reviewer.md` before the pull request
- **Required Human Review**: Human security review before merge — authorization (`CLAUDE.md`)
- **Open Decisions**: None blocking. `OQ-1` may adjust what each role may see, but not who administers accounts.
- **Estimated effort**: 1–1.5 engineer-days; 350–600 changed human-authored lines
- **Recommended model**: Claude Sonnet 5 (`claude-sonnet-5`) — a well-specified administrative CRUD surface whose one sharp edge, the self-role and mass-assignment prohibition, is stated explicitly and covered by a named test suite.
