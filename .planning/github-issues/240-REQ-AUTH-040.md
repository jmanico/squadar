# [REQ-AUTH-040] JWT session issuance, transport and rotation

> **BLOCKED — do not implement.** Blocked on `PQ-2`. See **Open Decisions**.

## Metadata

- **ID**: REQ-AUTH-040
- **Title**: JWT session issuance, transport and rotation
- **Version**: 0.1.0
- **Status**: Draft
- **Owner**: Squadar engineering — unassigned
- **Author**: Jim Manico
- **Last Updated**: 2026-09-14
- **Priority**: Critical
- **Requirement Type**: Security
- **Source / Parent**: REQ-AUTH-000; `SECURITY.md` SEC-SESSION-1, SEC-SESSION-4, SEC-SESSION-5, SEC-HTTP-3, `SQ-5`

## Requirement

- **Statement**: Session state MUST be carried in a JWT issued by Identity & Access; the API MUST verify its signature, issuer, audience and expiry on every request and reject a token failing any check or presenting an unexpected algorithm; a new session identifier MUST be issued on authentication and on any privilege change, with the prior one ceasing to be valid.
- **Rationale**: SEC-SESSION-1 is CONFIRMED and fixes the session mechanism. What is not fixed is how the token is carried on web — and that choice decides whether SEC-HTTP-3's CSRF defense applies at all, which is a security control on every state-changing endpoint.
- **Assumptions**: None — the transport question is recorded rather than assumed.
- **Out of Scope**: Session revocation and authorization-context resolution (REQ-AUTH-050), which are independent of the transport choice.
- **Design Traceability**: N/A — session transport has no surface in `DESIGN.md`.
- **Architecture Traceability**: `ARCHITECTURE.md` Identity & Access — session transport and lifetime are `TO BE DECIDED`; Primary Flow 1; DR-1, DR-2.
- **Security Traceability**: SEC-SESSION-1, SEC-SESSION-2, SEC-SESSION-4, SEC-SESSION-5, SEC-HTTP-3, SEC-HTTP-4, SEC-SECRET-2, SEC-LOG-3.

## Scope

- **Applies To**: Multiple
- **Components**: Identity & Access; REST API; Web Client; Mobile Client
- **Interfaces / Operations**: Token issuance, verification on every authenticated request, reissue on privilege change
- **Actors**: All four roles
- **Preconditions**: The caller has authenticated through REQ-AUTH-010, REQ-AUTH-020 or REQ-AUTH-030
- **Data Classification**: Restricted
- **Personal or Regulated Data**: Personal Data — the token identifies a user
- **Jurisdiction / Regulatory Scope**: TO BE DECIDED — `PQ-13`

## Security Context

- **Security Objectives**: Authenticity, Confidentiality, Authorization
- **Control Layers**: Session Management, Authentication
- **Threat References**: STRIDE — Spoofing, Tampering, Elevation of Privilege; OWASP Top 10:2025 Identification and Authentication Failures; CWE-347 Improper Verification of Cryptographic Signature; CWE-352 Cross-Site Request Forgery; CWE-384 Session Fixation
- **Abuse / Misuse Case**: A token accepted with the `none` algorithm or a mismatched issuer or audience; a token read from `localStorage` by injected script; a cross-origin state-changing request riding an ambient cookie; a pre-authentication token still valid after sign-in; a token issued before a role change still authorizing the elevated operation.
- **Trust Boundary**: Clients → REST API
- **Untrusted Inputs or Assertions**: The presented token in full, including every claim and its algorithm header
- **Authoritative Enforcement Point**: The REST API, verifying on every request (SEC-SESSION-1)
- **Independent Verification**: The signing key is held only by Identity & Access and the verifying side, and is rotatable without redeploying application code (SEC-SECRET-2)
- **Zero Trust Relevance**: NIST SP 800-207 §2.1 tenet 6 — the session is re-verified per request rather than established once and trusted

## Standards Alignment

- **OWASP ASVS 5.0.0**: TO BE DECIDED — `PQ-17`; the applicable chapter is Session Management
- **OWASP AISVS 1.0**: N/A
- **NIST SP 800-53 Rev. 5**: N/A
- **NIST SP 800-207**: §2.1 tenet 6
- **Regulatory**: TO BE DECIDED — `PQ-13`
- **Other**: RFC 7519 (JSON Web Token) and RFC 8725 (JSON Web Token Best Current Practices)
- **Mapping Basis**: RFC 7519 defines the token format SEC-SESSION-1 mandates; RFC 8725 §3.1 is the basis for rejecting an unexpected algorithm, which SEC-SESSION-1 states explicitly.

## Acceptance Criteria

Acceptance criteria for transport and for CSRF cannot be written without the transport decision:
SEC-HTTP-3 applies in full if the session is carried by a cookie or any other ambient credential, and
not at all if it is an explicitly attached bearer token. Writing them now would resolve `PQ-2` by
implication. The verification criterion is independent of transport and is stated.

1. **AC-01 — Expected behavior**: BLOCKED on `PQ-2`.
2. **AC-02 — Boundary or failure behavior**: BLOCKED on `PQ-2`.
3. **AC-03 — Prohibited behavior**: Given a token with the `none` algorithm, a mismatched algorithm, a wrong issuer or audience, an expired claim, or a tampered payload, when any authenticated request presents it, then the request MUST NOT be authorized (SEC-SESSION-1). Given the Web Client, a session token MUST NOT be written to `localStorage`, `sessionStorage`, any client-side store readable by injected script, or a URL (SEC-SESSION-4). Both criteria hold regardless of how `PQ-2` is answered.

## Failure Behavior

- **On Invalid Input**: Reject a malformed token without further processing
- **On Authentication Failure**: Refuse the request; return no product data (SEC-AUTHN-1)
- **On Authorization Failure**: Deny without disclosing the withheld data (SEC-AUTHZ-7)
- **On Security-Decision Failure**: Deny by default — an unverifiable token is not a valid session
- **On External Dependency Failure**: N/A
- **On System Error**: No internal detail in the response (SEC-ERR-1)
- **Logging / Audit**: Session issuance and rejection logged with actor, action and timestamp (SEC-LOG-2); token values MUST NOT be logged (SEC-LOG-3)
- **Alerting**: TO BE DECIDED — depends on `PQ-10`

## Test Strategy

- **Unit Tests**: Signature, issuer, audience and expiry verification; algorithm allow-listing; reissue on authentication and on privilege change
- **Integration Tests**: BLOCKED on `PQ-2` for the transport path; verification behavior is testable independently
- **Security Tests**: Negative tests for `none` and mismatched algorithm, wrong issuer or audience, expired token and tampered payload (SEC-SESSION-1); an automated check that no token value reaches web storage or a URL (SEC-SESSION-4); a test asserting the pre-authentication token is rejected after sign-in (SEC-SESSION-5); a key-rotation test asserting tokens issued before and after rotation behave as specified (SEC-SECRET-2); a cross-origin state-changing request test — applicable only if the transport is ambient (SEC-HTTP-3)
- **Compliance Tests / Evidence**: TO BE DECIDED — `PQ-13`
- **Acceptance-Criteria Traceability**: AC-03 by the negative verification tests and the storage check; AC-01 and AC-02 deferred with the criteria themselves
- **Coverage Target**: Positive and negative coverage on every verification check
- **Required Test Environment**: A token forge able to produce tokens with controlled algorithm, issuer, audience, expiry and payload; a browser context for the storage check

## Dependencies

- **Upstream Requirements**: REQ-AUTH-010, REQ-AUTH-020
- **Downstream Requirements**: REQ-AUTH-050, REQ-AUTH-060, and every authenticated endpoint
- **External Dependencies**: A JWT library, if added — justified against DEP-1…DEP-8, with DEP-1 weighing against hand-rolled signature verification
- **Dependency Assumptions**: The library rejects an unexpected algorithm rather than inferring it from the token header; the tests assert this rather than trusting it.
- **Failure Impact**: A library that honours the token's own algorithm header would void SEC-SESSION-1 silently.

## Implementation Notes

- **Constraints**: The signing key is held only by Identity & Access and the verifying side, rotatable without redeploying code, and rotation must not invalidate verification of tokens issued moments before (SEC-SECRET-2).
- **Prohibited Approaches**: Tokens in URLs, query strings, `localStorage` or `sessionStorage`; inferring the verification algorithm from the token; a mobile token outside the platform's protected credential storage
- **Implementation Guidance**: None on transport while blocked. Note that `SECURITY.md` already states the consequence of each branch: if the transport carries ambient authority, SEC-HTTP-3 requires a per-request CSRF defense on every state-changing request; if it is an explicitly attached bearer token, that rule does not apply.
- **AI Development Guidance**: `CLAUDE.md`; do not implement while BLOCKED
- **Required Human Review**: Human security review before merge — sessions (`CLAUDE.md`); architecture and security owners to answer `PQ-2`
- **Open Decisions**: **`PQ-2` (blocking)** — `SQ-5` in `SECURITY.md`: how is the JWT session carried on web, cookie (ambient authority, so SEC-HTTP-3's CSRF defense applies) or in-memory bearer token? Also `TO BE DECIDED` and recorded: access-token lifetime, refresh model, and idle and absolute timeouts (SEC-SESSION-3).
- **Estimated effort**: Not estimated while blocked — the transport branch changes the scope materially.
- **Recommended model**: Claude Opus 5 (`claude-opus-5`) — session management is security-critical and this issue determines whether an entire class of CSRF defense is required; to be confirmed once `PQ-2` fixes the scope.
