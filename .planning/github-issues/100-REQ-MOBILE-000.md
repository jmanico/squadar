# [REQ-MOBILE-000] React Native mobile client

> **BLOCKED — do not implement.** Blocked on `PQ-14`. See **Open Decisions**.

## Metadata

- **ID**: REQ-MOBILE-000
- **Title**: React Native mobile client
- **Version**: 0.1.0
- **Status**: Draft
- **Owner**: Squadar product and engineering — unassigned
- **Author**: Jim Manico
- **Last Updated**: 2026-09-14
- **Priority**: Medium
- **Requirement Type**: Functional
- **Source / Parent**: REQ-EPIC-001; `ARCHITECTURE.md` Mobile Client

## Requirement

- **Statement**: The Mobile Client MUST present the same product surface as the Web Client, carrying the same design and accessibility obligations, and MUST consume the identical REST API with no mobile-only endpoint; delivery is the sum of its children.
- **Rationale**: `ARCHITECTURE.md` names React Native for mobile against the same API, and DR-2 forbids an endpoint that serves only one client.
- **Assumptions**: None — the launch scope is `UNKNOWN` rather than assumed.
- **Out of Scope**: Cannot be stated until `PQ-14` is answered.
- **Design Traceability**: `DESIGN.md` in full — the same conformance target applies on both platform targets.
- **Architecture Traceability**: `ARCHITECTURE.md` Mobile Client; DR-1, DR-2; SEC-BOUND-2 (the Mobile Client is not more trusted than the Web Client).
- **Security Traceability**: SEC-BOUND-2, SEC-SESSION-4 (mobile tokens in the platform's protected credential storage), SEC-SECRET-3, SEC-RENDER-2, SEC-RENDER-3.

## Scope

- **Applies To**: Multiple
- **Components**: Mobile Client; REST API
- **Interfaces / Operations**: TO BE DECIDED — which screens are in the mobile scope at launch is `UNKNOWN` in `ARCHITECTURE.md`
- **Actors**: Administrator, Assessor, Team Member, Viewer
- **Preconditions**: The REST API surface is delivered by the other workstreams
- **Data Classification**: Restricted
- **Personal or Regulated Data**: Personal Data
- **Jurisdiction / Regulatory Scope**: TO BE DECIDED — `PQ-13`

## Security Context

- **Security Objectives**: Multiple
- **Control Layers**: Session Management, Output Encoding, Data Protection
- **Threat References**: STRIDE — Information Disclosure (token or secret in a distributable binary)
- **Abuse / Misuse Case**: A session token in unprotected device storage; a secret embedded in the app binary; a mobile-only endpoint treated as more trusted than the web surface.
- **Trust Boundary**: Mobile Client → REST API
- **Untrusted Inputs or Assertions**: Every API response, deep link and asset reference reaching the app
- **Authoritative Enforcement Point**: The REST API — unchanged by the client's platform (DR-1, SEC-BOUND-2)
- **Independent Verification**: The same server-side rules serve both clients; no mobile client check substitutes for one
- **Zero Trust Relevance**: NIST SP 800-207 §2.1 tenet 2 — the device is not trusted by virtue of being an installed app

## Standards Alignment

- **OWASP ASVS 5.0.0**: TO BE DECIDED — `PQ-17`
- **OWASP AISVS 1.0**: N/A
- **NIST SP 800-53 Rev. 5**: N/A
- **NIST SP 800-207**: §2.1 tenet 2
- **Regulatory**: TO BE DECIDED — `PQ-13`
- **Other**: W3C WCAG 2.2 Level AA, as `DESIGN.md` applies it to both platform targets
- **Mapping Basis**: Tenet 2 is cited because SEC-BOUND-2 explicitly refuses to treat the mobile client as more trusted.

## Acceptance Criteria

Acceptance criteria cannot be written without the launch scope. Writing them now would invent product
behavior, which this decomposition MUST NOT do. They are deferred until `PQ-14` is answered, at which
point this workstream is re-decomposed into leaf requirements.

1. **AC-01 — Expected behavior**: TO BE DECIDED — blocked on `PQ-14`.
2. **AC-02 — Boundary or failure behavior**: TO BE DECIDED — blocked on `PQ-14`.
3. **AC-03 — Prohibited behavior**: Given any mobile build, when the REST surface it calls is compared against the Web Client's, then it MUST NOT use an endpoint, parameter or response field the Web Client does not (DR-2, SEC-BOUND-2). This criterion holds regardless of how `PQ-14` is answered.

## Failure Behavior

- **On Invalid Input**: TO BE DECIDED — blocked on `PQ-14`
- **On Authentication Failure**: As the Web Client — uniform, non-disclosing (SEC-AUTHN-6)
- **On Authorization Failure**: As the Web Client — the server denies; the client displays the refusal (SEC-AUTHZ-7)
- **On Security-Decision Failure**: Deny by default at the server; the client never decides (DR-1)
- **On External Dependency Failure**: TO BE DECIDED — offline behavior is `TO BE DECIDED` in `ARCHITECTURE.md`
- **On System Error**: Present the server's product-term message only (SEC-ERR-1)
- **Logging / Audit**: N/A — the client logs no security event
- **Alerting**: N/A

## Test Strategy

- **Unit Tests**: TO BE DECIDED — blocked on `PQ-14`
- **Integration Tests**: Contract test asserting one documented endpoint set, exercised identically with each client's user agent and build identifiers (SEC-BOUND-2)
- **Security Tests**: Inspection of platform keystore usage for session tokens (SEC-SESSION-4); automated scan of the built binary for secret-shaped values (SEC-SECRET-3); deep-link scheme allow-list tests (SEC-RENDER-3)
- **Compliance Tests / Evidence**: TO BE DECIDED — `PQ-13`
- **Acceptance-Criteria Traceability**: AC-03 by the contract test above; AC-01 and AC-02 deferred with the criteria themselves
- **Coverage Target**: Same as the Web Client, once the scope is set
- **Required Test Environment**: The `UT-10.1` fixture; iOS and Android simulators

## Dependencies

- **Upstream Requirements**: REQ-FOUND-010, REQ-AUTH-000, and every API workstream whose screens mobile carries
- **Downstream Requirements**: None
- **Child Requirements**: TO BE DECIDED — none can be enumerated until `PQ-14` is answered
- **External Dependencies**: Platform passkey integration — details `TO BE DECIDED` in `ARCHITECTURE.md`
- **Dependency Assumptions**: Platform credential storage protects tokens at rest (SEC-SESSION-4)
- **Failure Impact**: Unavailable platform passkey support would force the password or OIDC path on mobile.

## Implementation Notes

- **Constraints**: No mobile-only endpoint (DR-2). The same design and accessibility obligations as web (`ARCHITECTURE.md` Mobile Client).
- **Prohibited Approaches**: Tokens in unprotected storage; secrets in the binary; treating the app as a trusted client
- **Implementation Guidance**: None until the scope is set — guidance written now would presuppose the answer to `PQ-14`.
- **AI Development Guidance**: `CLAUDE.md`; do not implement this workstream while it is BLOCKED
- **Required Human Review**: Product owner to set the launch scope; security review for credential storage
- **Open Decisions**: **`PQ-14` (blocking)** — which screens are in the mobile scope at launch (`UNKNOWN`), offline behavior (`TO BE DECIDED`) and platform passkey integration details (`TO BE DECIDED`), all from `ARCHITECTURE.md` Mobile Client. Until answered, this workstream has no leaves and MUST NOT be implemented.
