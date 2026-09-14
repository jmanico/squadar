# [REQ-AUTH-010] Password authentication with memory-hard hashing and non-disclosing failure

## Metadata

- **ID**: REQ-AUTH-010
- **Title**: Password authentication with memory-hard hashing and non-disclosing failure
- **Version**: 1.0.0
- **Status**: Draft
- **Owner**: Squadar engineering — unassigned
- **Author**: Jim Manico
- **Last Updated**: 2026-09-14
- **Priority**: Critical
- **Requirement Type**: Security
- **Source / Parent**: REQ-AUTH-000; `REQUIREMENTS.md` FR-1.1; `SECURITY.md` SEC-AUTHN-2, SEC-AUTHN-4, SEC-AUTHN-6, SEC-AUTHN-7

## Requirement

- **Statement**: Identity & Access MUST authenticate a password credential, storing it only as a salted hash from a memory-hard password-hashing function, MUST return a response that does not reveal whether the account or email address exists, and MUST apply credential-guessing resistance keyed on at least the account identifier.
- **Rationale**: `ARCHITECTURE.md` names passkey/password plus OIDC as the authentication model and SEC-AUTHN-2 confines credential verification to Identity & Access. SEC-AUTHN-4, SEC-AUTHN-6 and SEC-AUTHN-7 state how the password path must behave.
- **Assumptions**: None. Algorithm, parameters and password composition policy are `TO BE DECIDED` in SEC-AUTHN-4 — the requirement is the property (memory-hard, salted, never reversible), and the concrete parameters are chosen and recorded during implementation.
- **Out of Scope**: Session issuance, which REQ-AUTH-040 owns (blocked on `PQ-2`). Account recovery when a credential is lost — `PQ-12`, unresolved and not drafted. The passkey path (REQ-AUTH-020) and the OIDC path (REQ-AUTH-030).
- **Design Traceability**: `DESIGN.md` — Components (Inputs: persistent visible label; Buttons: busy state on a slow action), Form feedback and errors (the sign-in failure is rendered through the standard error contract, which must not distinguish causes).
- **Architecture Traceability**: `ARCHITECTURE.md` Identity & Access — authentication via passkey/password and OIDC; owns users, credentials, role assignments and sessions; Primary Flow 1; DR-3.
- **Security Traceability**: SEC-AUTHN-1, SEC-AUTHN-2, SEC-AUTHN-4, SEC-AUTHN-6, SEC-AUTHN-7, SEC-LOG-2, SEC-LOG-3, SEC-ERR-1, SEC-HTTP-1, SEC-HTTP-5.

## Scope

- **Applies To**: Server-Side Application
- **Components**: Identity & Access; REST API; Web Client (sign-in surface)
- **Interfaces / Operations**: Sign-in with a password; credential storage and verification
- **Actors**: Administrator, Assessor, Team Member, Viewer, and any unauthenticated caller
- **Preconditions**: An account exists with a password credential
- **Data Classification**: Restricted
- **Personal or Regulated Data**: Personal Data — the account identifier is typically an email address
- **Jurisdiction / Regulatory Scope**: TO BE DECIDED — `PQ-13`

## Security Context

- **Security Objectives**: Authenticity, Confidentiality, Accountability
- **Control Layers**: Authentication, Data Protection, Logging and Monitoring
- **Threat References**: STRIDE — Spoofing, Information Disclosure; OWASP Top 10:2025 Identification and Authentication Failures; CWE-307 Improper Restriction of Excessive Authentication Attempts; CWE-916 Use of Password Hash With Insufficient Computational Effort; CWE-204 Observable Response Discrepancy
- **Abuse / Misuse Case**: An attacker enumerating valid accounts by comparing responses, status codes or timing between an existing and a non-existing identifier; brute-forcing a password; recovering plaintext passwords from a stolen credential store; distinguishing a throttled attempt from a rejected one and using that to map accounts.
- **Trust Boundary**: Clients → REST API → Identity & Access
- **Untrusted Inputs or Assertions**: The submitted identifier and password; the client's claim about which account it is attempting
- **Authoritative Enforcement Point**: Identity & Access — no component outside it verifies a credential (SEC-AUTHN-2)
- **Independent Verification**: Response, status code and timing are compared across existing and non-existing identifiers by test, not asserted by the implementer (SEC-AUTHN-6)
- **Zero Trust Relevance**: NIST SP 800-207 §2.1 tenet 6 — authentication is required before access and is not inherited from network position

## Standards Alignment

- **OWASP ASVS 5.0.0**: TO BE DECIDED — `PQ-17` sets the verification level; the applicable chapter is Authentication
- **OWASP AISVS 1.0**: N/A
- **NIST SP 800-53 Rev. 5**: N/A — no control mapping verified against a specific catalog release
- **NIST SP 800-207**: §2.1 tenet 6
- **Regulatory**: TO BE DECIDED — `PQ-13`
- **Other**: NIST SP 800-63B, cited by `SECURITY.md` as `REF-NIST-63B` for memorized-secret verifier requirements
- **Mapping Basis**: SP 800-63B is named because `SECURITY.md` cites it directly on SEC-AUTHN-4 and SEC-AUTHN-7; the specific assurance level is `SQ-3` and therefore TO BE DECIDED.

## Acceptance Criteria

1. **AC-01 — Expected behavior**: Given an active account with a correct password, when it is submitted, then authentication succeeds and Identity & Access produces a verified identity for the caller.
2. **AC-02 — Boundary or failure behavior**: Given a non-existent identifier and given an existing identifier with a wrong password, when each is submitted, then the response body, status code and observable timing are indistinguishable between the two cases (SEC-AUTHN-6).
3. **AC-03 — Prohibited behavior**: Given the credential store, logs and any response, when they are inspected, then a password MUST NOT appear in reversible form anywhere in them (SEC-AUTHN-4, SEC-LOG-3); and repeated failures against one identifier MUST NOT continue to succeed in reaching verification beyond the configured policy, with a throttled attempt indistinguishable from a rejected one (SEC-AUTHN-7).

## Failure Behavior

- **On Invalid Input**: Reject a malformed request at the boundary; no credential verification is attempted (SEC-INPUT-1)
- **On Authentication Failure**: A uniform refusal across unknown account, unknown passkey, wrong password and throttled attempt; no indication of which (SEC-AUTHN-6, SEC-AUTHN-7)
- **On Authorization Failure**: N/A — authorization is evaluated after authentication, by REQ-AUTH-060
- **On Security-Decision Failure**: Deny — a verification step that cannot complete fails closed
- **On External Dependency Failure**: N/A — the password path reaches no external system
- **On System Error**: No stack trace, query text or internal identifier in the response; diagnostics retained server-side under an opaque reference (SEC-ERR-1)
- **Logging / Audit**: Authentication success and failure logged with actor identifier, action, target and timestamp (SEC-LOG-2); the password, its hash and any session token MUST NOT be logged (SEC-LOG-3)
- **Alerting**: TO BE DECIDED — thresholds depend on `PQ-10`

## Test Strategy

- **Unit Tests**: Hash and verify round trip; salt uniqueness across two accounts with the same password; rejection of a reversible or unsalted stored form; the throttling counter's keying and window
- **Integration Tests**: Sign-in through the REST API producing a verified identity; interaction with REQ-AUTH-050's context resolution
- **Security Tests**: Comparison of responses, status codes and timing for existing vs. non-existing identifiers (SEC-AUTHN-6); repeated-failure test asserting attempts stop succeeding within the configured policy and that throttled and rejected are indistinguishable (SEC-AUTHN-7); inspection of stored credential records and of logs for plaintext (SEC-AUTHN-4, SEC-LOG-3); a plaintext-HTTP connection test asserting refusal (SEC-HTTP-1)
- **Compliance Tests / Evidence**: TO BE DECIDED — `PQ-13`
- **Acceptance-Criteria Traceability**: AC-01 by the sign-in integration test; AC-02 by the comparison test; AC-03 by the storage and log inspection tests and the repeated-failure test
- **Coverage Target**: Positive and negative coverage on every verification and throttling path
- **Required Test Environment**: The `UT-10.1` fixture with a password credential per role; a timing-stable test runner for the comparison test

## Dependencies

- **Upstream Requirements**: REQ-FOUND-010, REQ-FOUND-020
- **Downstream Requirements**: REQ-AUTH-040, REQ-AUTH-050
- **External Dependencies**: A password-hashing library — memory-hard, and justified in the pull request against DEP-1…DEP-8 before it is added
- **Dependency Assumptions**: DEP-1 forbids replacing vetted cryptography with custom code, so a library is the required approach here rather than an optional one.
- **Failure Impact**: A weak or misconfigured hashing library would compromise every stored credential at once; its parameters are part of the security review.

## Implementation Notes

- **Constraints**: Credential verification exists in exactly one component (SEC-AUTHN-2). The chosen algorithm and parameters must be recorded, since SEC-AUTHN-4 leaves them `TO BE DECIDED` and `CLAUDE.md` requires the owning document to be updated rather than the decision living only in code.
- **Prohibited Approaches**: A hand-rolled hash; an unsalted or fast hash; distinguishing failure causes in the response; logging credentials or tokens
- **Implementation Guidance**: Keep the uniform-failure behavior in one place so the passkey path (REQ-AUTH-020) and any later recovery path share it rather than each re-deriving it.
- **AI Development Guidance**: `CLAUDE.md`; `.claude/agents/security-reviewer.md` before the pull request
- **Required Human Review**: Human security review before merge — authentication (`CLAUDE.md`)
- **Open Decisions**: The hashing algorithm, its parameters and the password composition policy are `TO BE DECIDED` in SEC-AUTHN-4; they are non-blocking because the requirement states the property to satisfy. Record the choice in `SECURITY.md` in the same change.
- **Estimated effort**: 1–2 engineer-days; 400–700 changed human-authored lines
- **Recommended model**: Claude Opus 5 (`claude-opus-5`) — security-sensitive code where the failure modes are subtle: response and timing uniformity, correct use of a memory-hard KDF, and throttling that does not itself become an enumeration oracle.
