# [REQ-EXAM-030] Deliver an exam to an assignee with no answer-key data in the payload

## Metadata

- **ID**: REQ-EXAM-030
- **Title**: Deliver an exam to an assignee with no answer-key data in the payload
- **Version**: 1.0.0
- **Status**: Draft
- **Owner**: Squadar engineering — unassigned
- **Author**: Jim Manico
- **Last Updated**: 2026-09-14
- **Priority**: Critical
- **Requirement Type**: Security
- **Source / Parent**: REQ-EXAM-000; `REQUIREMENTS.md` NFR-9.7; `SECURITY.md` SEC-BOUND-3, SEC-RENDER-4

## Requirement

- **Statement**: An exam presented to a Team Member MUST be rendered from a payload that contains no answer-key data in any field, comment, source map or cached response; the exclusion MUST happen inside Assessment before the response is assembled, and MUST NOT be performed in a serializer, view layer or client.
- **Rationale**: NFR-9.7 makes answer-key confidentiality absolute, including during and after an attempt. SEC-BOUND-3 and DR-8 place the filtering in the owning component, because any later layer can be bypassed by a debug path, an error shape or a cached response.
- **Assumptions**: NFR-9.7 is marked **(assumed)** in `REQUIREMENTS.md` and stands.
- **Out of Scope**: Whether this particular member may attempt this exam (REQ-EXAM-040, blocked on `PQ-4`); scoring (REQ-EXAM-050); exam media (REQ-EXAM-070, blocked).
- **Design Traceability**: `DESIGN.md` — Layout and Spacing (long-form text, including exam questions, caps at 72 characters per line; comfortable density for the exam surface), Accessibility (taking and submitting an exam is fully keyboard-operable), Components (Buttons: submission shows a busy state and stays disabled until it resolves).
- **Architecture Traceability**: `ARCHITECTURE.md` Assessment — returns questions without answer keys; Primary Flow 3; DR-8 (withheld data never crosses the API boundary toward a caller not entitled to it, filtered in the owning component).
- **Security Traceability**: SEC-BOUND-3, SEC-RENDER-4, SEC-DATA-4, SEC-AUTHZ-3, SEC-ERR-1, SEC-LOG-3, SEC-HTTP-7.

## Scope

- **Applies To**: Multiple
- **Components**: Assessment; REST API; Web Client
- **Interfaces / Operations**: Exam delivery to an assignee; the exam-taking surface
- **Actors**: Team Member (recipient); Viewer (no access); Administrator and Assessor (separate, key-bearing read path per REQ-EXAM-010)
- **Preconditions**: REQ-EXAM-010 and REQ-EXAM-020 are Verified
- **Data Classification**: Restricted
- **Personal or Regulated Data**: None — the exam payload describes content, not a person
- **Jurisdiction / Regulatory Scope**: N/A

## Security Context

- **Security Objectives**: Confidentiality, Integrity
- **Control Layers**: Architecture, Authorization, Data Protection, Output Encoding
- **Threat References**: STRIDE — Information Disclosure; OWASP Top 10:2025 Broken Access Control; CWE-200 Exposure of Sensitive Information to an Unauthorized Actor; CWE-540 Inclusion of Sensitive Information in Source Code; CWE-524 Use of Cache Containing Sensitive Information
- **Abuse / Misuse Case**: A Team Member reading the answer key from the network payload, from client state, from a source map, from a cached response, or from an error or debug response produced during the attempt — each of which a view-layer filter would miss.
- **Trust Boundary**: Assessment → REST API → clients
- **Untrusted Inputs or Assertions**: The exam and attempt identifiers in the delivery request
- **Authoritative Enforcement Point**: Assessment, excluding the key before the response is assembled (SEC-BOUND-3, DR-8)
- **Independent Verification**: Inspection of the network payload and client state during an attempt (SEC-RENDER-4), plus a test over every exam-facing response shape including error and debug paths (SEC-BOUND-3)
- **Zero Trust Relevance**: NIST SP 800-207 §2.1 tenet 4 — the delivery payload is shaped by the requester's entitlement, evaluated per request

## Standards Alignment

- **OWASP ASVS 5.0.0**: TO BE DECIDED — `PQ-17`
- **OWASP AISVS 1.0**: N/A
- **NIST SP 800-53 Rev. 5**: N/A — no control mapping verified against a specific catalog release
- **NIST SP 800-207**: §2.1 tenet 4
- **Regulatory**: N/A
- **Other**: N/A
- **Mapping Basis**: CWE-540 and CWE-524 are cited because SEC-RENDER-4 names source maps and cached responses explicitly as places the key must not appear.

## Acceptance Criteria

1. **AC-01 — Expected behavior**: Given a Team Member with an assigned exam, when the exam is delivered, then the payload contains every question and its presentation content and no correct-answer data of any kind (NFR-9.7).
2. **AC-02 — Boundary or failure behavior**: Given an error or a debug response produced on the exam-delivery or submission path, when it is inspected, then it MUST NOT carry answer-key data, and it MUST NOT carry a stack trace, query text or internal identifier either (SEC-BOUND-3, SEC-ERR-1).
3. **AC-03 — Prohibited behavior**: Given the network payload, the client's in-memory state, any cached response and any shipped source map during and after an attempt, when each is inspected, then none MUST contain answer-key data (SEC-RENDER-4).

## Failure Behavior

- **On Invalid Input**: Reject a malformed delivery request; return no exam content (SEC-INPUT-1)
- **On Authentication Failure**: Refuse; return no exam content (SEC-AUTHN-1)
- **On Authorization Failure**: Deny without confirming whether the exam exists (SEC-AUTHZ-7); a Viewer has no exam-taking path at all (SEC-AUTHZ-5)
- **On Security-Decision Failure**: Deny by default — if entitlement cannot be established, no content is returned (SEC-AUTHZ-1)
- **On External Dependency Failure**: N/A for this issue; media delivery is REQ-EXAM-070 and is blocked
- **On System Error**: Return an error with no internal detail and no key material; diagnostics retained server-side under an opaque reference (SEC-ERR-1)
- **Logging / Audit**: Exam delivery is not itself an audited score event; answer keys MUST NOT appear in any log (SEC-LOG-3)
- **Alerting**: N/A

## Test Strategy

- **Unit Tests**: The delivery projection asserting the key is structurally absent rather than filtered; error-shape construction on this path
- **Integration Tests**: Delivery to an assignee end to end, with the response body asserted key-free; the Administrator's key-bearing read path asserted unaffected
- **Security Tests**: The SEC-BOUND-3 sweep over every exam-facing response shape reaching a Team Member or Viewer, including error and debug paths; inspection of the network payload and client state during an attempt (SEC-RENDER-4); a check that shipped bundles carry no source map containing key material; a cache-header assertion that exam responses are not stored in a shared cache; a log-scrubbing test (SEC-LOG-3)
- **Compliance Tests / Evidence**: WCAG 2.2 AA — the exam surface is fully keyboard-operable and its questions respect the 72-character measure
- **Acceptance-Criteria Traceability**: AC-01 by the delivery payload test; AC-02 by the error-path sweep; AC-03 by the payload, state, cache and source-map inspections
- **Coverage Target**: Every response shape on the exam path, per role, covered for key absence — including error paths
- **Required Test Environment**: The `UT-10.1` fixture plus an exam with a known key, so the test can search for that exact value in every artifact

## Dependencies

- **Upstream Requirements**: REQ-EXAM-010, REQ-EXAM-020, REQ-AUTH-060, REQ-UIKIT-040
- **Downstream Requirements**: REQ-EXAM-040, REQ-EXAM-050
- **External Dependencies**: None
- **Dependency Assumptions**: N/A
- **Failure Impact**: N/A

## Implementation Notes

- **Constraints**: The exclusion is structural — REQ-EXAM-010 stores the key so the delivery query cannot select it. This issue relies on that and asserts it end to end.
- **Prohibited Approaches**: Filtering the key in a serializer, a view model or the client (SEC-BOUND-3, DR-8); shipping a source map that embeds server fixtures; caching exam responses in a shared cache
- **Implementation Guidance**: Search for the fixture's literal answer values in every artifact the test can reach — response bodies, client state dumps, bundles and source maps. A test that only checks the happy-path response shape will not catch the debug and cache paths SEC-RENDER-4 names.
- **AI Development Guidance**: `CLAUDE.md`; `.claude/agents/security-reviewer.md` before the pull request
- **Required Human Review**: Human security review before merge — trust boundary and data protection (`CLAUDE.md`)
- **Open Decisions**: `PQ-4` is recorded and blocks REQ-EXAM-040, not this issue: delivery must be key-free regardless of what the attempt policy turns out to be.
- **Estimated effort**: 1–1.5 engineer-days; 350–600 changed human-authored lines
- **Recommended model**: Claude Opus 5 (`claude-opus-5`) — NFR-9.7 admits no partial compliance and the leak paths named by SEC-RENDER-4 are ones a conventional implementation overlooks.
