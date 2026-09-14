# [REQ-EXAM-070] Serve exam media from the protected asset store under a live authorization decision

> **BLOCKED — do not implement.** Blocked on `PQ-16`. See **Open Decisions**.

## Metadata

- **ID**: REQ-EXAM-070
- **Title**: Serve exam media from the protected asset store under a live authorization decision
- **Version**: 0.1.0
- **Status**: Draft
- **Owner**: Squadar product and engineering — unassigned
- **Author**: Jim Manico
- **Last Updated**: 2026-09-14
- **Priority**: Low
- **Requirement Type**: Security
- **Source / Parent**: REQ-EXAM-000; `ARCHITECTURE.md` Protected Asset Store, DR-9; `SECURITY.md` SEC-BOUND-4

## Requirement

- **Statement**: Large binary assets such as exam media MUST be held in the Protected Asset Store outside the relational database, referenced from it; the store MUST NOT serve an asset on possession of a reference alone; each read MUST require a live authorization decision from the API; and any grant issued MUST be scoped to one asset and time-bounded.
- **Rationale**: `ARCHITECTURE.md`'s data-model note places large assets in protected folders rather than the database, and DR-9 makes possession of a reference explicitly not an entitlement. SEC-BOUND-4 states the access rule. What is unresolved is the storage technology, the grant mechanism, and — more fundamentally — whether exams carry media at all.
- **Assumptions**: None. `ARCHITECTURE.md` records an explicit `ASSUMPTION` that the "movie files" example implies media-bearing exam content, and marks whether exams carry media at all as `UNKNOWN`. That assumption is not adopted here.
- **Out of Scope**: The exam definition itself (REQ-EXAM-010) and its delivery payload (REQ-EXAM-030), both of which stand without media.
- **Design Traceability**: `DESIGN.md` — Accessibility (media in an exam would carry its own alternative-content obligations under WCAG 2.2 AA), Layout and Spacing (images cap at their container).
- **Architecture Traceability**: `ARCHITECTURE.md` Protected Asset Store — holds large binary assets outside the relational database; the database holds references, never the bytes; access is granted only per an authorization decision made by the API; storage technology and access-grant mechanism are `TO BE DECIDED`; whether exams carry media at all is `UNKNOWN`; DR-9, DR-6.
- **Security Traceability**: SEC-BOUND-4, SEC-INPUT-5, SEC-DATA-1, SEC-EXT-1, SEC-EXT-2, SEC-EXT-4, SEC-AUTHZ-1, SEC-RENDER-3.

## Scope

- **Applies To**: External Integration
- **Components**: Protected Asset Store; Assessment; REST API; Web Client
- **Interfaces / Operations**: Asset write from Assessment; authorized asset read; grant issuance and expiry
- **Actors**: Administrator (upload); Team Member (read during an attempt); the asset store
- **Preconditions**: A storage technology and grant mechanism have been chosen
- **Data Classification**: Restricted
- **Personal or Regulated Data**: None expected — exam media is content, not personal data; this would need revisiting if media ever depicted individuals
- **Jurisdiction / Regulatory Scope**: TO BE DECIDED — `PQ-13`

## Security Context

- **Security Objectives**: Confidentiality, Authorization, Integrity
- **Control Layers**: Authorization, Data Protection, Input Validation, Architecture
- **Threat References**: STRIDE — Information Disclosure, Elevation of Privilege; OWASP Top 10:2025 Broken Access Control; CWE-425 Direct Request (Forced Browsing); CWE-434 Unrestricted Upload of File with Dangerous Type; CWE-22 Improper Limitation of a Pathname to a Restricted Directory
- **Abuse / Misuse Case**: An asset URL shared or guessed and used by an unentitled actor; a grant that never expires or that covers more than one asset; an uploaded file stored under a caller-controlled path or name; an uploaded file parsed in a way that evaluates embedded content; a server-side fetch of a URL derived from an asset reference.
- **Trust Boundary**: API → Protected Asset Store
- **Untrusted Inputs or Assertions**: Asset references, uploaded files and their declared types and sizes, and every response from the store
- **Authoritative Enforcement Point**: The REST API, which must make a live authorization decision per read (SEC-BOUND-4, DR-9)
- **Independent Verification**: A test that an asset reference obtained by an entitled actor fails for an unentitled actor and after grant expiry (SEC-BOUND-4)
- **Zero Trust Relevance**: NIST SP 800-207 §2.1 tenet 4 — possession of a resource identifier confers nothing; each access is decided per request

## Standards Alignment

- **OWASP ASVS 5.0.0**: TO BE DECIDED — `PQ-17`
- **OWASP AISVS 1.0**: N/A
- **NIST SP 800-53 Rev. 5**: N/A
- **NIST SP 800-207**: §2.1 tenet 4
- **Regulatory**: TO BE DECIDED — `PQ-13`
- **Other**: W3C WCAG 2.2 Level AA — any media in an exam would need a text alternative and, for time-based media, captions
- **Mapping Basis**: Tenet 4 is cited because DR-9 states in terms that possession of a reference is not entitlement, which is that tenet applied to assets.

## Acceptance Criteria

The grant mechanism and its lifetime are `TO BE DECIDED`, and whether exams carry media at all is
`UNKNOWN`. Criteria describing how a grant is obtained, presented and expired would invent the
mechanism. The access rule itself does not depend on the mechanism and is stated.

1. **AC-01 — Expected behavior**: BLOCKED on `PQ-16`.
2. **AC-02 — Boundary or failure behavior**: BLOCKED on `PQ-16` for grant expiry specifics. Independent of it: given an asset reference obtained legitimately by an entitled actor, when an unentitled actor presents that same reference, then the asset MUST NOT be served (SEC-BOUND-4, DR-9).
3. **AC-03 — Prohibited behavior**: Given any uploaded asset, when it is stored, then it MUST NOT be stored under a caller-controlled filesystem path or name, and it MUST NOT be parsed in a way that evaluates embedded formulas, macros or references to external resources (SEC-INPUT-5). Given the relational store, asset bytes MUST NOT be embedded in it (DR-9). Both hold regardless of how `PQ-16` is answered.

## Failure Behavior

- **On Invalid Input**: Reject an upload whose declared size or type is not permitted, before parsing (SEC-INPUT-5)
- **On Authentication Failure**: Refuse; serve no asset (SEC-AUTHN-1)
- **On Authorization Failure**: Deny; do not confirm whether the referenced asset exists (SEC-AUTHZ-7)
- **On Security-Decision Failure**: Deny by default — an asset read with no live decision is refused (SEC-BOUND-4)
- **On External Dependency Failure**: An unavailable store fails the media read; it MUST NOT fall back to serving the asset without a decision, and no vendor error shape crosses out of the adapter (SEC-EXT-1, SEC-EXT-2)
- **On System Error**: No internal or vendor detail in the response (SEC-ERR-1)
- **Logging / Audit**: Asset access decisions logged with actor, action, target and timestamp (SEC-LOG-2); grant values MUST NOT be logged (SEC-LOG-3)
- **Alerting**: TO BE DECIDED

## Test Strategy

- **Unit Tests**: BLOCKED on `PQ-16` for grant construction; upload validation of declared size and type is testable independently
- **Integration Tests**: BLOCKED on `PQ-16` — the grant round trip depends on the mechanism
- **Security Tests**: A reference obtained by an entitled actor asserted to fail for an unentitled actor and after grant expiry (SEC-BOUND-4); oversized files, mismatched declared types, formula-bearing content and path-traversal file names (SEC-INPUT-5); internal and metadata-endpoint URLs in any dereferenceable field (SEC-EXT-4); `javascript:` and `data:` values in asset-reference fields on the client (SEC-RENDER-3)
- **Compliance Tests / Evidence**: WCAG 2.2 AA for any media presented in an exam
- **Acceptance-Criteria Traceability**: AC-02's reference clause and AC-03 by the SEC-BOUND-4 and SEC-INPUT-5 suites; AC-01 and the rest of AC-02 deferred with the criteria themselves
- **Coverage Target**: Positive and negative coverage on the access decision and on upload validation
- **Required Test Environment**: An asset store or simulator supporting the chosen grant mechanism; hostile upload fixtures

## Dependencies

- **Upstream Requirements**: REQ-EXAM-010, REQ-EXAM-030, REQ-AUTH-060
- **Downstream Requirements**: None
- **External Dependencies**: The asset store — technology `TO BE DECIDED` in `ARCHITECTURE.md`; reached only through an adapter owned by Assessment (DR-6, SEC-EXT-1)
- **Dependency Assumptions**: The store can be configured to refuse anonymous reads entirely, so that SEC-BOUND-4 does not rest on obscurity of the reference. Encryption at rest is required by SEC-DATA-1, whose mechanism is also `TO BE DECIDED`.
- **Failure Impact**: An unavailable store affects media-bearing exams only; text exams are unaffected.

## Implementation Notes

- **Constraints**: The database holds references, never bytes (DR-9). Access requires a live authorization decision from the API; an asset URL is not itself an entitlement.
- **Prohibited Approaches**: A long-lived or unscoped signed URL; a publicly readable bucket or folder with obscurity as the only control; storing bytes in the relational database; a caller-controlled storage path
- **Implementation Guidance**: None while blocked. Note that answering `PQ-16` should start with the prior question `ARCHITECTURE.md` raises — whether exams carry media at all. If they do not, this issue is closed as out of scope rather than implemented.
- **AI Development Guidance**: `CLAUDE.md`; do not implement while BLOCKED
- **Required Human Review**: Product owner on whether exams carry media; architecture and security review of the grant mechanism
- **Open Decisions**: **`PQ-16` (blocking)** — `ARCHITECTURE.md` Protected Asset Store: storage technology and access-grant mechanism are `TO BE DECIDED`, grant lifetime is `TO BE DECIDED` in SEC-BOUND-4, and whether exams carry media at all is `UNKNOWN` (the `ASSUMPTION` recorded there is not adopted). `PQ-9` is also relevant, since the store is provisioned by Terraform.
- **Estimated effort**: Not estimated while blocked — and possibly zero, if exams carry no media.
- **Recommended model**: Claude Opus 5 (`claude-opus-5`) — an authorization boundary at an external store where the common implementation shortcut, a signed URL, is close to the prohibited behavior; to be confirmed once `PQ-16` fixes the mechanism.
