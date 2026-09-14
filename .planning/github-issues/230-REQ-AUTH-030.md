# [REQ-AUTH-030] OIDC authentication path with full identity-token validation

> **BLOCKED — do not implement.** Blocked on `PQ-11`. See **Open Decisions**.

## Metadata

- **ID**: REQ-AUTH-030
- **Title**: OIDC authentication path with full identity-token validation
- **Version**: 0.1.0
- **Status**: Draft
- **Owner**: Squadar engineering — unassigned
- **Author**: Jim Manico
- **Last Updated**: 2026-09-14
- **Priority**: High
- **Requirement Type**: Security
- **Source / Parent**: REQ-AUTH-000; `REQUIREMENTS.md` FR-1.1, FR-1.2; `SECURITY.md` SEC-AUTHN-5, `SQ-10`

## Requirement

- **Statement**: Identity & Access MUST authenticate through an OIDC flow, validating the issuer, audience, signature, nonce and expiry of every identity token against provider metadata and rejecting a token that fails any check.
- **Rationale**: `ARCHITECTURE.md` names OIDC as one of the two authentication models. SEC-AUTHN-5 fixes the five validations. The requirement statement is determinate; what is not determinate is whether the provider may assert role or group membership, which changes how FR-1.2's single role is established.
- **Assumptions**: None — the blocking question is recorded rather than assumed away.
- **Out of Scope**: The password path (REQ-AUTH-010) and the passkey path (REQ-AUTH-020).
- **Design Traceability**: `DESIGN.md` — Components (Buttons, Links), Form feedback and errors, for the provider-redirect surface.
- **Architecture Traceability**: `ARCHITECTURE.md` Identity & Access — the OIDC provider(s) and whether Squadar is also its own issuer are `UNKNOWN`; DR-6 (reached only through an adapter, no vendor type crossing out of it); Primary Flow 1.
- **Security Traceability**: SEC-AUTHN-5, SEC-AUTHN-2, SEC-AUTHN-6, SEC-EXT-1, SEC-EXT-2, SEC-SESSION-2, SEC-HTTP-1.

## Scope

- **Applies To**: External Integration
- **Components**: Identity & Access; REST API; the OIDC provider adapter
- **Interfaces / Operations**: The OIDC authorization and token exchange; identity-token validation; provider metadata retrieval
- **Actors**: All four roles; the OIDC provider
- **Preconditions**: A provider has been selected and its metadata is reachable
- **Data Classification**: Restricted
- **Personal or Regulated Data**: Personal Data
- **Jurisdiction / Regulatory Scope**: TO BE DECIDED — `PQ-13`

## Security Context

- **Security Objectives**: Authenticity, Authorization, Confidentiality
- **Control Layers**: Authentication, Authorization, Supply Chain
- **Threat References**: STRIDE — Spoofing, Elevation of Privilege; OWASP Top 10:2025 Identification and Authentication Failures; CWE-347 Improper Verification of Cryptographic Signature; CWE-290 Authentication Bypass by Spoofing
- **Abuse / Misuse Case**: A token from a different issuer or for a different audience accepted; an unverified or `none`-algorithm signature; a replayed nonce; an expired token accepted; and — the reason this issue is blocked — a provider-asserted role or group claim silently granting Administrator.
- **Trust Boundary**: API → OIDC provider
- **Untrusted Inputs or Assertions**: The identity token in full, provider metadata, and every claim in either
- **Authoritative Enforcement Point**: Identity & Access, behind the provider adapter (SEC-AUTHN-2, SEC-EXT-1)
- **Independent Verification**: Validation is performed against provider metadata the server fetched, not against values in the token itself
- **Zero Trust Relevance**: NIST SP 800-207 §2.1 tenet 6 — the external assertion is verified per authentication event rather than trusted by federation

## Standards Alignment

- **OWASP ASVS 5.0.0**: TO BE DECIDED — `PQ-17`
- **OWASP AISVS 1.0**: N/A
- **NIST SP 800-53 Rev. 5**: N/A
- **NIST SP 800-207**: §2.1 tenet 6
- **Regulatory**: TO BE DECIDED — `PQ-13`
- **Other**: OpenID Connect Core, cited by `SECURITY.md` as part of `REF-AUTH`
- **Mapping Basis**: OIDC Core defines the issuer, audience, signature, nonce and expiry validations SEC-AUTHN-5 enumerates.

## Acceptance Criteria

Acceptance criteria are not written here. Whether the provider may assert role or group membership
determines what a successful authentication establishes — a verified identity only, or an identity
plus a role — and therefore what the expected, unauthorized and failure criteria must say. Writing
them now would resolve `PQ-11` by implication, which this decomposition MUST NOT do.

1. **AC-01 — Expected behavior**: BLOCKED on `PQ-11`.
2. **AC-02 — Boundary or failure behavior**: BLOCKED on `PQ-11`.
3. **AC-03 — Prohibited behavior**: Given any identity token, when it is validated, then a token failing the issuer, audience, signature, nonce or expiry check MUST NOT authenticate the caller (SEC-AUTHN-5). This criterion holds regardless of how `PQ-11` is answered.

## Failure Behavior

- **On Invalid Input**: Reject a malformed callback or token at the boundary; establish no identity (SEC-INPUT-1)
- **On Authentication Failure**: Uniform refusal shared with the other authentication paths (SEC-AUTHN-6)
- **On Authorization Failure**: BLOCKED on `PQ-11` — whether a provider claim can contribute to the authorization decision is the unresolved question
- **On Security-Decision Failure**: Deny by default; an external failure or malformed response MUST NOT cause the system to authorize an operation it would otherwise deny (SEC-EXT-2)
- **On External Dependency Failure**: Fail closed; the password and passkey paths remain available (DR-6)
- **On System Error**: No internal or vendor detail in the response (SEC-ERR-1, SEC-EXT-1)
- **Logging / Audit**: Authentication success and failure logged with actor, action, target and timestamp (SEC-LOG-2); tokens MUST NOT be logged (SEC-LOG-3)
- **Alerting**: TO BE DECIDED — depends on `PQ-10`

## Test Strategy

- **Unit Tests**: Each of the five validations in isolation, positive and negative
- **Integration Tests**: BLOCKED on `PQ-11` for the role-establishment path; the identity-only flow is testable once a provider is selected
- **Security Tests**: Negative tests for wrong issuer, wrong audience, bad signature, replayed nonce and expired token (SEC-AUTHN-5); malformed, oversized and error responses from the adapter asserting fail-closed behavior (SEC-EXT-2); a test that no vendor type, error or payload shape appears outside the adapter (SEC-EXT-1)
- **Compliance Tests / Evidence**: TO BE DECIDED — `PQ-13`
- **Acceptance-Criteria Traceability**: AC-03 by the five negative validation tests; AC-01 and AC-02 deferred with the criteria themselves
- **Coverage Target**: Positive and negative coverage on all five validations
- **Required Test Environment**: An OIDC provider simulator able to issue tokens with controlled issuer, audience, signature, nonce and expiry

## Dependencies

- **Upstream Requirements**: REQ-FOUND-020, REQ-AUTH-050
- **Downstream Requirements**: REQ-AUTH-040
- **External Dependencies**: An OIDC provider — `UNKNOWN` in `ARCHITECTURE.md`; an OIDC client library, if added, justified against DEP-1…DEP-8
- **Dependency Assumptions**: The provider is reached only through an adapter owned by Identity & Access, and no vendor type, error, identifier or payload shape crosses out of it (DR-6, SEC-EXT-1). The provider is not assumed honest about any claim beyond what the five validations establish.
- **Failure Impact**: An unavailable provider blocks this sign-in path only; password and passkey continue.

## Implementation Notes

- **Constraints**: DR-6 — no vendor type crosses out of the adapter, so a provider can be replaced without touching a domain component.
- **Prohibited Approaches**: Hand-rolled token parsing or signature verification (DEP-1); accepting the `none` algorithm; trusting an unverified claim
- **Implementation Guidance**: None beyond the above while blocked — guidance on role handling would presuppose the answer to `PQ-11`.
- **AI Development Guidance**: `CLAUDE.md`; do not implement while BLOCKED
- **Required Human Review**: Human security review before merge; product owner to answer `PQ-11`
- **Open Decisions**: **`PQ-11` (blocking)** — `SQ-10` in `SECURITY.md`: is the OIDC provider trusted to assert role or group membership, or is role always assigned locally? FR-1.2 requires exactly one role per user; SEC-SESSION-2 requires authorization-relevant claims to be resolved against the authoritative source. Also unresolved and recorded: which provider(s), and whether Squadar is its own issuer (`UNKNOWN`, `ARCHITECTURE.md` Identity & Access).
- **Estimated effort**: Not estimated while blocked — the scope depends on the answer.
- **Recommended model**: Claude Opus 5 (`claude-opus-5`) — federated identity validation is security-critical and its failure modes are silent; to be confirmed once `PQ-11` fixes the scope.
