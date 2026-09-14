# [REQ-AUTH-000] Identity, session and authorization

## Metadata

- **ID**: REQ-AUTH-000
- **Title**: Identity, session and authorization
- **Version**: 1.0.0
- **Status**: Draft
- **Owner**: Squadar engineering — unassigned
- **Author**: Jim Manico
- **Last Updated**: 2026-09-14
- **Priority**: Critical
- **Requirement Type**: Security
- **Source / Parent**: REQ-EPIC-001; `REQUIREMENTS.md` FR-1.1–FR-1.7; `ARCHITECTURE.md` Identity & Access, REST API

## Requirement

- **Statement**: The system MUST authenticate every caller before any product data is returned, resolve exactly one role and the caller's authorization context server-side, and refuse every impermissible request without disclosing withheld data; delivery is the sum of its children.
- **Rationale**: FR-1.1 gates all data behind authentication and FR-1.7 defines the refusal contract. `ARCHITECTURE.md` makes the REST API the sole enforcement point and Identity & Access the only credential verifier.
- **Assumptions**: The four roles in `REQUIREMENTS.md` are correct (`OQ-1` open). Exactly one role per user per FR-1.2, notwithstanding the ABAC language in the security notes (`PQ-1`).
- **Out of Scope**: Account recovery when a passkey is lost (`PQ-12`); the retention period for authentication logs (`PQ-13`).
- **Design Traceability**: `DESIGN.md` — Form feedback and errors (sign-in error presentation); Focus states; Accessibility.
- **Architecture Traceability**: `ARCHITECTURE.md` Identity & Access; REST API; Primary Flow 1; DR-1, DR-2, DR-3, DR-5, DR-6, DR-8.
- **Security Traceability**: SEC-AUTHN-1…8, SEC-SESSION-1…5, SEC-AUTHZ-1…8, SEC-BOUND-1, SEC-BOUND-2, SEC-HTTP-1, SEC-HTTP-2, SEC-HTTP-3, SEC-ERR-1, SEC-LOG-2, SEC-SECRET-2, SEC-EXT-1, SEC-EXT-2.

## Scope

- **Applies To**: Multiple
- **Components**: Identity & Access; REST API; Roster (member linkage); Outbound Notification (account access)
- **Interfaces / Operations**: Sign-in, sign-out, session verification, account and role administration, authorization decision point
- **Actors**: Administrator, Assessor, Team Member, Viewer, unauthenticated caller, OIDC provider
- **Preconditions**: None
- **Data Classification**: Restricted
- **Personal or Regulated Data**: Personal Data
- **Jurisdiction / Regulatory Scope**: TO BE DECIDED — `PQ-13`

## Security Context

- **Security Objectives**: Multiple
- **Control Layers**: Authentication, Session Management, Authorization, Logging and Monitoring
- **Threat References**: STRIDE — Spoofing, Elevation of Privilege, Information Disclosure; OWASP Top 10:2025 Broken Access Control
- **Abuse / Misuse Case**: Credential guessing, account enumeration through differing failure responses, a forged or stale JWT claiming an elevated role, a non-Administrator changing their own role, a denial response that confirms a hidden record exists.
- **Trust Boundary**: Clients → REST API; API → OIDC provider
- **Untrusted Inputs or Assertions**: Credentials, WebAuthn assertions, OIDC identity tokens, JWT claims, every role/team/member identifier in a request
- **Authoritative Enforcement Point**: REST API for authorization; Identity & Access for credential verification
- **Independent Verification**: Role, assessor team assignments and member linkage are resolved from Identity & Access and Roster, never taken as final from a token payload (SEC-SESSION-2)
- **Zero Trust Relevance**: NIST SP 800-207 §2.1 tenet 6 — authentication and authorization are dynamic and enforced before access is allowed

## Standards Alignment

- **OWASP ASVS 5.0.0**: TO BE DECIDED — `PQ-17` sets the verification level; individual children cite chapters once it is fixed
- **OWASP AISVS 1.0**: N/A
- **NIST SP 800-53 Rev. 5**: N/A — no mapping verified against the catalog release yet
- **NIST SP 800-207**: §2.1 tenet 6
- **Regulatory**: TO BE DECIDED — `PQ-13`
- **Other**: W3C WebAuthn and OpenID Connect Core, as cited by `SECURITY.md` references `REF-WEBAUTHN`, `REF-PASSKEY`, `REF-AUTH`
- **Mapping Basis**: SP 800-207 tenet 6 is cited because `SECURITY.md` requires a per-request authorization decision rather than a session-establishment-time one.

## Acceptance Criteria

1. **AC-01 — Expected behavior**: Given an authenticated caller with a resolved role, when they request an operation their role permits on a target they are entitled to, then the operation proceeds.
2. **AC-02 — Boundary or failure behavior**: Given an unauthenticated caller, when any product endpoint is called, then the request is refused and no team member, score, exam, chart or account data appears in the response body (FR-1.1, SEC-AUTHN-1).
3. **AC-03 — Prohibited behavior**: Given a denial, when the response is compared for an existing and a non-existing target identifier, then the two MUST NOT be distinguishable (FR-1.7, SEC-AUTHZ-7).

## Failure Behavior

- **On Invalid Input**: Reject at the boundary without coercion (SEC-INPUT-1); no session is established
- **On Authentication Failure**: Uniform response across unknown account, wrong password and unknown passkey; no indication of which (SEC-AUTHN-6)
- **On Authorization Failure**: Deny; do not disclose the withheld data or confirm the record exists (SEC-AUTHZ-7)
- **On Security-Decision Failure**: Deny by default when no rule explicitly permits the combination (SEC-AUTHZ-1)
- **On External Dependency Failure**: An OIDC provider failure or malformed response fails closed — it MUST NOT authorize an operation that would otherwise be denied (SEC-EXT-2)
- **On System Error**: No stack trace, query text or internal identifier in the response; diagnostics retained server-side under an opaque reference (SEC-ERR-1)
- **Logging / Audit**: Authentication success and failure, session revocation, authorization denial, role and account changes, with actor, action, target and timestamp; no credentials or tokens (SEC-LOG-2, SEC-LOG-3)
- **Alerting**: TO BE DECIDED — thresholds depend on `PQ-10`

## Test Strategy

- **Unit Tests**: Role resolution, the authorization decision function, token claim verification, failure-response uniformity
- **Integration Tests**: Primary Flow 1 end to end for each credential path; session revocation on role change and deactivation
- **Security Tests**: The automated authorization matrix over every actor/object/operation combination (SEC-AUTHZ-1); privilege-escalation and self-role-change tests (SEC-AUTHZ-6); enumeration-timing comparison (SEC-AUTHN-6); `none`/mismatched-algorithm and tampered-token tests (SEC-SESSION-1)
- **Compliance Tests / Evidence**: TO BE DECIDED — `PQ-13`
- **Acceptance-Criteria Traceability**: AC-01 and AC-02 by the endpoint sweep in REQ-AUTH-060; AC-03 by the denial-comparison test in REQ-AUTH-060
- **Coverage Target**: Every authorization decision and error path carries positive and negative coverage
- **Required Test Environment**: The `UT-10.1` fixture with one account per role; an OIDC provider simulator; a WebAuthn authenticator simulator

## Dependencies

- **Upstream Requirements**: REQ-FOUND-010, REQ-FOUND-020
- **Downstream Requirements**: REQ-ROSTER-000, REQ-SKILL-000, REQ-SCORE-000, REQ-EXAM-000, REQ-CHART-000, REQ-PORT-000
- **Child Requirements**:
  - [ ] {{ISSUE_URL:REQ-AUTH-010}} — Password authentication with memory-hard hashing and non-disclosing failure
  - [ ] {{ISSUE_URL:REQ-AUTH-020}} — Passkey registration and authentication with server-side assertion verification
  - [ ] {{ISSUE_URL:REQ-AUTH-030}} — OIDC authentication path with full identity-token validation
  - [ ] {{ISSUE_URL:REQ-AUTH-040}} — JWT session issuance, transport and rotation
  - [ ] {{ISSUE_URL:REQ-AUTH-050}} — Server-resolved authorization context and session revocation
  - [ ] {{ISSUE_URL:REQ-AUTH-060}} — Role-based authorization enforcement at the API boundary
  - [ ] {{ISSUE_URL:REQ-AUTH-070}} — Administrator account and role administration
- **External Dependencies**: OIDC provider (UNKNOWN); mail provider for account-access links (TO BE DECIDED)
- **Dependency Assumptions**: Both are reached only through an adapter owned by Identity & Access or Outbound Notification (DR-6, SEC-EXT-1) and neither is trusted beyond its validated response (SEC-EXT-2).
- **Failure Impact**: An unavailable OIDC provider blocks that sign-in path only; password and passkey paths continue.

## Implementation Notes

- **Constraints**: No component outside Identity & Access verifies a credential (SEC-AUTHN-2). The JWT signing key is held only by Identity & Access and the verifying side (SEC-SECRET-2).
- **Prohibited Approaches**: Client-side authorization as the only check (DR-1); trusting a role claim from a token payload as final (SEC-SESSION-2); tokens in URLs or web storage (SEC-SESSION-4); logging credentials or tokens (SEC-LOG-3)
- **Implementation Guidance**: Build REQ-AUTH-050 and REQ-AUTH-060 before any domain workstream so no endpoint ships without an enforcement point.
- **AI Development Guidance**: `CLAUDE.md`; `.claude/agents/security-reviewer.md` is mandatory on every child here
- **Required Human Review**: Human security review before merge for every child (`CLAUDE.md`)
- **Open Decisions**: `PQ-1` (ABAC vs single role), `PQ-2` (session transport), `PQ-11` (OIDC role assertion), `PQ-12` (recovery) — the children they block are marked BLOCKED.
