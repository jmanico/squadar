# [REQ-AUTH-020] Passkey registration and authentication with server-side assertion verification

## Metadata

- **ID**: REQ-AUTH-020
- **Title**: Passkey registration and authentication with server-side assertion verification
- **Version**: 1.0.0
- **Status**: Draft
- **Owner**: Squadar engineering — unassigned
- **Author**: Jim Manico
- **Last Updated**: 2026-09-14
- **Priority**: Critical
- **Requirement Type**: Security
- **Source / Parent**: REQ-AUTH-000; `REQUIREMENTS.md` FR-1.1; `SECURITY.md` SEC-AUTHN-2, SEC-AUTHN-3, SEC-AUTHN-6

## Requirement

- **Statement**: Identity & Access MUST support passkey registration and authentication, verifying the WebAuthn challenge, relying-party identifier and origin server-side against values the server itself issued, and MUST reject an assertion that fails any of them.
- **Rationale**: `ARCHITECTURE.md` names passkey as a first-class authentication path. SEC-AUTHN-3 fixes the three checks that make a WebAuthn assertion meaningful; verifying them against server-issued values is what prevents replay and origin confusion.
- **Assumptions**: None. Attestation policy, authenticator requirements and credential lifecycle are `TO BE DECIDED` in SEC-AUTHN-3; this issue implements the three mandatory verifications and leaves the policy knobs recorded.
- **Out of Scope**: Session issuance (REQ-AUTH-040, blocked on `PQ-2`). Recovery when a passkey is lost — `PQ-12`, unresolved and not drafted. Platform passkey integration on mobile, which is part of the blocked REQ-MOBILE-000.
- **Design Traceability**: `DESIGN.md` — Components (Buttons: a slow action shows a busy state and stays disabled until it resolves, which the authenticator ceremony is), Form feedback and errors, Accessibility (Keyboard: the ceremony must be reachable and operable by keyboard).
- **Architecture Traceability**: `ARCHITECTURE.md` Identity & Access — owns users, credentials and sessions; Primary Flow 1; DR-3.
- **Security Traceability**: SEC-AUTHN-1, SEC-AUTHN-2, SEC-AUTHN-3, SEC-AUTHN-6, SEC-HTTP-1, SEC-LOG-2, SEC-LOG-3, SEC-ERR-1.

## Scope

- **Applies To**: Multiple
- **Components**: Identity & Access; REST API; Web Client
- **Interfaces / Operations**: Passkey registration ceremony; passkey authentication ceremony; challenge issue and consumption
- **Actors**: Administrator, Assessor, Team Member, Viewer
- **Preconditions**: An account exists; for authentication, a registered credential exists for it
- **Data Classification**: Restricted
- **Personal or Regulated Data**: Personal Data
- **Jurisdiction / Regulatory Scope**: TO BE DECIDED — `PQ-13`

## Security Context

- **Security Objectives**: Authenticity, Confidentiality
- **Control Layers**: Authentication
- **Threat References**: STRIDE — Spoofing; OWASP Top 10:2025 Identification and Authentication Failures; CWE-294 Authentication Bypass by Capture-replay; CWE-346 Origin Validation Error
- **Abuse / Misuse Case**: Replaying a captured assertion; presenting an assertion produced for a different origin or relying party; registering a credential against another user's account; enumerating which accounts have a passkey by observing the ceremony's response.
- **Trust Boundary**: Clients → REST API → Identity & Access; the authenticator is outside the trust boundary
- **Untrusted Inputs or Assertions**: The entire WebAuthn response — client data, authenticator data, signature, credential identifier — and any challenge value echoed by the client
- **Authoritative Enforcement Point**: Identity & Access, comparing against the challenge, relying-party identifier and origin the server issued, never against values taken from the client's payload (SEC-AUTHN-3)
- **Independent Verification**: The challenge is server-generated and single-use; the origin and relying-party identifier come from server configuration, not from the request
- **Zero Trust Relevance**: NIST SP 800-207 §2.1 tenet 6 — the assertion is validated per authentication event against server-held state

## Standards Alignment

- **OWASP ASVS 5.0.0**: TO BE DECIDED — `PQ-17`; the applicable chapter is Authentication
- **OWASP AISVS 1.0**: N/A
- **NIST SP 800-53 Rev. 5**: N/A — no control mapping verified against a specific catalog release
- **NIST SP 800-207**: §2.1 tenet 6
- **Regulatory**: TO BE DECIDED — `PQ-13`
- **Other**: W3C Web Authentication (WebAuthn) and the FIDO passkey guidance, cited by `SECURITY.md` as `REF-WEBAUTHN` and `REF-PASSKEY`; NIST SP 800-63B (`REF-NIST-63B`)
- **Mapping Basis**: WebAuthn defines the registration and authentication ceremonies and the verification steps SEC-AUTHN-3 requires; `SECURITY.md` cites it directly on this rule.

## Acceptance Criteria

1. **AC-01 — Expected behavior**: Given a registered passkey, when the user completes the authentication ceremony with an assertion carrying the challenge the server issued, the configured relying-party identifier and the configured origin, then authentication succeeds and Identity & Access produces a verified identity.
2. **AC-02 — Boundary or failure behavior**: Given an assertion with a mismatched origin, a replayed challenge, or an unknown credential identifier, when it is submitted, then it is rejected, and the refusal is indistinguishable from the other authentication failure cases (SEC-AUTHN-3, SEC-AUTHN-6).
3. **AC-03 — Prohibited behavior**: Given a challenge that has already been consumed, when it is presented a second time, then authentication MUST NOT succeed; and the relying-party identifier and origin used for comparison MUST NOT be taken from the request payload.

## Failure Behavior

- **On Invalid Input**: Reject a malformed ceremony payload at the boundary; consume no challenge (SEC-INPUT-1)
- **On Authentication Failure**: Uniform refusal shared with the password path, revealing nothing about whether the account or credential exists (SEC-AUTHN-6)
- **On Authorization Failure**: N/A — evaluated after authentication by REQ-AUTH-060
- **On Security-Decision Failure**: Deny — a verification step that cannot complete fails closed
- **On External Dependency Failure**: N/A — the authenticator is client-side; an absent or failing authenticator is an authentication failure, not a dependency failure
- **On System Error**: No internal detail in the response; diagnostics under an opaque reference (SEC-ERR-1)
- **Logging / Audit**: Registration and authentication success and failure logged with actor, action, target and timestamp (SEC-LOG-2); credential material and challenges MUST NOT be logged (SEC-LOG-3)
- **Alerting**: TO BE DECIDED — depends on `PQ-10`

## Test Strategy

- **Unit Tests**: Challenge generation, single-use consumption and expiry; signature verification; relying-party identifier and origin comparison against configured values
- **Integration Tests**: Registration then authentication round trip through the REST API; interaction with REQ-AUTH-050's context resolution
- **Security Tests**: Negative tests with a mismatched origin, a replayed challenge and an unknown credential (SEC-AUTHN-3); a comparison test that the passkey failure response matches the password failure response (SEC-AUTHN-6); a test asserting a request-supplied relying-party identifier or origin is ignored; a plaintext-HTTP connection test (SEC-HTTP-1)
- **Compliance Tests / Evidence**: TO BE DECIDED — `PQ-13`
- **Acceptance-Criteria Traceability**: AC-01 by the ceremony round trip; AC-02 and AC-03 by the negative test set
- **Coverage Target**: Positive and negative coverage on each of the three mandatory verifications
- **Required Test Environment**: A WebAuthn authenticator simulator capable of producing assertions with controlled origin, challenge and credential values; the `UT-10.1` fixture

## Dependencies

- **Upstream Requirements**: REQ-FOUND-010, REQ-FOUND-020, REQ-AUTH-010 (shares the uniform failure response)
- **Downstream Requirements**: REQ-AUTH-040, REQ-AUTH-050
- **External Dependencies**: A WebAuthn server library, if added — justified in the pull request against DEP-1…DEP-8, with DEP-1 weighing against hand-rolling protocol parsing and signature verification
- **Dependency Assumptions**: The library performs the three mandatory verifications itself, or exposes them so this issue can; either way the tests assert the behavior, not the library's claims.
- **Failure Impact**: A library that silently skips origin or challenge verification would void this requirement without any visible error, which is why the negative tests are non-optional.

## Implementation Notes

- **Constraints**: Credential verification lives only in Identity & Access (SEC-AUTHN-2). Origin and relying-party identifier come from server configuration.
- **Prohibited Approaches**: Hand-rolled protocol parsing or signature verification (DEP-1); trusting any origin or relying-party value from the request; reusable challenges
- **Implementation Guidance**: Attestation policy, authenticator requirements and credential lifecycle are `TO BE DECIDED` in SEC-AUTHN-3 — implement the mandatory verifications now, and record whichever policy is chosen in `SECURITY.md` in the same change rather than leaving it only in code.
- **AI Development Guidance**: `CLAUDE.md`; `.claude/agents/security-reviewer.md` before the pull request
- **Required Human Review**: Human security review before merge — authentication (`CLAUDE.md`)
- **Open Decisions**: Attestation policy, authenticator requirements and credential lifecycle (`TO BE DECIDED`, SEC-AUTHN-3) — non-blocking. Account recovery is `PQ-12` and is out of scope here.
- **Estimated effort**: 1.5–2 engineer-days; 500–800 changed human-authored lines
- **Recommended model**: Claude Opus 5 (`claude-opus-5`) — protocol-level security code whose failure modes are silent: an assertion that verifies successfully while skipping the origin or challenge check looks identical to one that does not.
