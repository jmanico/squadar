# [REQ-CHART-090] Meet the chart render budget at the supported member and skill scale

> **BLOCKED — do not implement.** Blocked on `PQ-8` and `PQ-10`. See **Open Decisions**.

## Metadata

- **ID**: REQ-CHART-090
- **Title**: Meet the chart render budget at the supported member and skill scale
- **Version**: 0.1.0
- **Status**: Draft
- **Owner**: Squadar engineering — unassigned
- **Author**: Jim Manico
- **Last Updated**: 2026-09-14
- **Priority**: High
- **Requirement Type**: Performance
- **Source / Parent**: REQ-CHART-000; `REQUIREMENTS.md` NFR-9.1, NFR-9.3; `ARCHITECTURE.md` Chart Data Service open decisions

## Requirement

- **Statement**: A radar chart for the maximum supported selection MUST render within 2 seconds of the selection being confirmed at the 95th percentile, and the system MUST sustain that with at least 1,000 team members and 100 skills.
- **Rationale**: NFR-9.1 and NFR-9.3 state the budget and the scale. `ARCHITECTURE.md` marks the Chart Data Service's Requirement Traceability entry for these as `PARTIALLY DEFINED` because no read model, indexing or caching decision has been made — and that decision depends on a database product that has not been chosen.
- **Assumptions**: None. NFR-9.1 and NFR-9.3 are both marked **(assumed)** in `REQUIREMENTS.md`, and the mechanism to meet them is unresolved.
- **Out of Scope**: The dataset's correctness (REQ-CHART-010); the selection limits (REQ-CHART-020); request-rate and request-size limits (SEC-HTTP-5, pending `PQ-10`).
- **Design Traceability**: `DESIGN.md` — Components (Buttons that start a slow action, including chart render, show a busy state and stay disabled until it resolves), Accessibility (Reduced motion: series appear at their final position rather than animating in, so perceived render time is not padded by animation).
- **Architecture Traceability**: `ARCHITECTURE.md` Chart Data Service — meets NFR-9.1 and NFR-9.3 for the maximum supported selection; whether any read model or caching is needed to hold NFR-9.1 at NFR-9.3 scale is `TO BE DECIDED`; Relational Data Store — schema, indexing and history-table shape `TO BE DECIDED`; Requirement Traceability marks NFR-9.1 and NFR-9.3 `PARTIALLY DEFINED`.
- **Security Traceability**: SEC-HTTP-5, SEC-HTTP-6, SEC-DATA-3, SEC-BIZ-2, SEC-DATA-1.

## Scope

- **Applies To**: Multiple
- **Components**: Chart Data Service; Assessment; Relational Data Store; REST API; Web Client
- **Interfaces / Operations**: Chart dataset assembly under load; any read model, index or cache introduced to support it
- **Actors**: All four roles
- **Preconditions**: A database product has been chosen and the resource limits are set
- **Data Classification**: Restricted
- **Personal or Regulated Data**: Personal Data — any cache or read model would hold it
- **Jurisdiction / Regulatory Scope**: TO BE DECIDED — `PQ-13`

## Security Context

- **Security Objectives**: Availability, Confidentiality, Integrity
- **Control Layers**: Availability, Data Protection
- **Threat References**: STRIDE — Denial of Service, Information Disclosure; OWASP Top 10:2025 Security Misconfiguration; CWE-770 Allocation of Resources Without Limits or Throttling; CWE-524 Use of Cache Containing Sensitive Information
- **Abuse / Misuse Case**: A cache introduced for performance serving a superseded score after reassessment, or a deleted member after erasure — the exact surfaces SEC-DATA-3 and FR-5.10 require to be current; an unencrypted read model holding personal performance data outside the protections SEC-DATA-1 places on the primary store; a request pattern that degrades the service rather than being refused.
- **Trust Boundary**: Clients → REST API; and, if introduced, the read model or cache as a second store of personal data
- **Untrusted Inputs or Assertions**: Request volume and selection size
- **Authoritative Enforcement Point**: The REST API for limits (SEC-HTTP-5, SEC-HTTP-6); Assessment remains the single source of the current score regardless of any derived store
- **Independent Verification**: A load test asserting a clean refusal with no partial write once limits are set (SEC-HTTP-5); the REQ-EXAM-060 and SEC-DATA-3 freshness tests must still pass after any cache is introduced
- **Zero Trust Relevance**: N/A — a performance and resource concern, though any derived store inherits the access rules of its source

## Standards Alignment

- **OWASP ASVS 5.0.0**: TO BE DECIDED — `PQ-17`
- **OWASP AISVS 1.0**: N/A
- **NIST SP 800-53 Rev. 5**: N/A
- **NIST SP 800-207**: N/A
- **Regulatory**: TO BE DECIDED — `PQ-13`
- **Other**: N/A
- **Mapping Basis**: CWE-524 is cited because the principal risk this issue introduces is a cache of personal performance data, not the latency target itself.

## Acceptance Criteria

The mechanism is `TO BE DECIDED` and depends on a database product that has not been chosen, and the
concrete resource limits are `TO BE DECIDED` in SEC-HTTP-5 pending `SQ-9`. A criterion naming an index,
a read model or a cache would invent a technology choice. The targets and the invariants that any
mechanism must preserve are stated.

1. **AC-01 — Expected behavior**: Given a dataset of at least 1,000 team members and 100 skills, when the maximum supported selection is confirmed, then the chart renders within 2 seconds at the 95th percentile (NFR-9.1, NFR-9.3). The measurement harness and the mechanism to achieve it are BLOCKED on `PQ-8`.
2. **AC-02 — Boundary or failure behavior**: BLOCKED on `PQ-10` — the concrete request-rate and request-size limits are `TO BE DECIDED` in SEC-HTTP-5, and the required behavior is a clean refusal rather than degradation once they exist.
3. **AC-03 — Prohibited behavior**: Given any read model, index or cache introduced to meet AC-01, when a score is reassessed or a member's personal data is deleted, then the derived view MUST NOT serve the superseded score or the deleted member (FR-5.10, SEC-DATA-3); and any such store MUST NOT hold personal performance data outside the encryption SEC-DATA-1 requires. Both hold regardless of how `PQ-8` and `PQ-10` are answered.

## Failure Behavior

- **On Invalid Input**: Handled by REQ-CHART-020's limits
- **On Authentication Failure**: Refuse (SEC-AUTHN-1)
- **On Authorization Failure**: Deny; a derived store MUST NOT relax the entitlement rules of its source (SEC-AUTHZ-3)
- **On Security-Decision Failure**: Deny by default
- **On External Dependency Failure**: If a cache or read model is unavailable, fall back to the authoritative source rather than serving stale or partial data
- **On System Error**: Refuse rather than degrade when a limit is exceeded (SEC-HTTP-5)
- **Logging / Audit**: Latency and refusal metrics recorded without score values or member names (SEC-LOG-3)
- **Alerting**: TO BE DECIDED — the destination depends on `PQ-9`

## Test Strategy

- **Unit Tests**: BLOCKED on `PQ-8` — what to unit test depends on the mechanism
- **Integration Tests**: A 95th-percentile latency measurement at NFR-9.3 scale, once a product and mechanism exist
- **Security Tests**: A load test asserting a clean refusal with no partial write once limits are set (SEC-HTTP-5); the freshness tests from REQ-EXAM-060 and the post-deletion sweep from SEC-DATA-3 re-run against any cache or read model; an encryption-at-rest assertion on any derived store (SEC-DATA-1)
- **Compliance Tests / Evidence**: TO BE DECIDED — `PQ-13`
- **Acceptance-Criteria Traceability**: AC-03 by the freshness and encryption tests; AC-01's target by the latency harness once it exists; AC-02 deferred with the criterion
- **Coverage Target**: The latency target measured at the 95th percentile, not the mean; freshness covered on every derived view
- **Required Test Environment**: A fixture of at least 1,000 synthetic members and 100 skills, generated rather than imported (SEC-DATA-5), and a load harness

## Dependencies

- **Upstream Requirements**: REQ-CHART-010, REQ-CHART-020, REQ-CHART-030, REQ-SCORE-010, REQ-FOUND-030
- **Downstream Requirements**: None
- **External Dependencies**: The relational database product (`TO BE DECIDED`, `PQ-8`); any caching or read-model technology, which would itself need a DEP-1…DEP-8 review
- **Dependency Assumptions**: None can be made until the product is chosen. Any derived store inherits SEC-DATA-1's encryption obligation and SEC-DATA-3's deletion obligation.
- **Failure Impact**: Failing NFR-9.1 degrades the product's core interaction; failing to invalidate a cache correctly would breach FR-5.10 and SEC-DATA-3, which is the more serious of the two.

## Implementation Notes

- **Constraints**: Assessment remains the single source of the current score (DR-3, DR-7) regardless of what is derived from it. The fixture at NFR-9.3 scale must be generated, not imported from any production source (SEC-DATA-5).
- **Prohibited Approaches**: A cache without invalidation on reassessment and on deletion; an unencrypted derived store of personal performance data; degrading under load instead of refusing (SEC-HTTP-5); meeting the target by returning a truncated dataset (SEC-HTTP-6)
- **Implementation Guidance**: None on mechanism while blocked. Measure first once `PQ-8` is answered — `ARCHITECTURE.md` asks whether *any* read model or caching is needed, and the answer may be no, which would make the safest implementation the empty one.
- **AI Development Guidance**: `CLAUDE.md`; do not implement while BLOCKED
- **Required Human Review**: Architecture owner to answer `PQ-8`; security owner to answer `PQ-10`; security review of any derived store
- **Open Decisions**: **`PQ-8` (blocking)** — the database product, schema, indexing and history-table shape are `TO BE DECIDED` in `ARCHITECTURE.md`, and whether any read model or caching is needed to hold NFR-9.1 at NFR-9.3 scale is `TO BE DECIDED` for the Chart Data Service. **`PQ-10` (blocking)** — `SQ-9` in `SECURITY.md`: the abuse and resource limits behind SEC-HTTP-5 are undecided. `OQ-5` is also recorded, since a larger member limit would raise the maximum supported selection this issue is measured against.
- **Estimated effort**: Not estimated while blocked — the answer may range from adding indexes to building a read model.
- **Recommended model**: Claude Fable 5.1 (`claude-fable-5-1`) — if a read model or cache is required this becomes long-horizon work spanning the data store, Assessment, Chart Data Service and the freshness guarantees of every derived view, with invariants from three other issues that must continue to hold; to be confirmed once `PQ-8` fixes the mechanism.
