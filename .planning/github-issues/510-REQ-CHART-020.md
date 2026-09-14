# [REQ-CHART-020] Enforce the axis and member selection limits server-side with a stated reason

## Metadata

- **ID**: REQ-CHART-020
- **Title**: Enforce the axis and member selection limits server-side with a stated reason
- **Version**: 1.0.0
- **Status**: Draft
- **Owner**: Squadar engineering — unassigned
- **Author**: Jim Manico
- **Last Updated**: 2026-09-14
- **Priority**: High
- **Requirement Type**: Functional
- **Source / Parent**: REQ-CHART-000; `REQUIREMENTS.md` FR-7.6, FR-7.7; `SECURITY.md` SEC-HTTP-6

## Requirement

- **Statement**: The system MUST support at least 3 and at most 12 skill axes and at least 6 team members on one radar chart, MUST report the limit when a selection falls outside it, and MUST enforce the bound server-side, refusing an out-of-range selection with a stated reason rather than truncating silently.
- **Rationale**: FR-7.6 and FR-7.7 set the limits and require them to be reported. SEC-HTTP-6 makes enforcement server-side and prohibits silent truncation, which would otherwise produce a chart that quietly omits a selected person.
- **Assumptions**: FR-7.6 and FR-7.7 are marked **(assumed)** in `REQUIREMENTS.md` and stand until `OQ-5` is answered. FR-7.7's "at least 6" is read as a minimum supported count; the concrete maximum is the documented bound this issue enforces and records.
- **Out of Scope**: The dataset assembly itself (REQ-CHART-010); the selection control's visible count (REQ-CHART-040); the empty-selection case (REQ-CHART-060).
- **Design Traceability**: `DESIGN.md` — Components (Inputs: selection of team members and skills for a chart uses checkable list items with a visible count of the current selection against its limit), Form feedback and errors (the message names what is wrong and what to do).
- **Architecture Traceability**: `ARCHITECTURE.md` Chart Data Service — enforcement of the 3–12 axis and ≥6 member limits with a reported reason when a selection falls outside them; REST API — enforces request-level concerns including limits; DR-1.
- **Security Traceability**: SEC-HTTP-6, SEC-HTTP-5, SEC-BOUND-1, SEC-INPUT-1, SEC-ERR-1.

## Scope

- **Applies To**: Multiple
- **Components**: Chart Data Service; REST API; Web Client
- **Interfaces / Operations**: Chart dataset request; ranked list and score table bounds
- **Actors**: Administrator, Assessor, Team Member, Viewer
- **Preconditions**: REQ-CHART-010 is Verified
- **Data Classification**: Restricted
- **Personal or Regulated Data**: Personal Data
- **Jurisdiction / Regulatory Scope**: N/A

## Security Context

- **Security Objectives**: Availability, Integrity
- **Control Layers**: Input Validation, Availability, Business-Rule Validation
- **Threat References**: STRIDE — Denial of Service, Tampering; OWASP Top 10:2025 Security Misconfiguration; CWE-770 Allocation of Resources Without Limits or Throttling; CWE-1284 Improper Validation of Specified Quantity in Input
- **Abuse / Misuse Case**: A request for hundreds of members and all 100 skills at NFR-9.3 scale, used to exhaust the dataset assembly path; a client-only limit bypassed by calling the API directly; a silently truncated selection producing a chart that omits a person the user believed was included.
- **Trust Boundary**: Clients → REST API
- **Untrusted Inputs or Assertions**: The lengths and contents of the member and skill selection
- **Authoritative Enforcement Point**: Chart Data Service behind the REST API (SEC-HTTP-6, SEC-BOUND-1)
- **Independent Verification**: A test requesting 13 axes and more than the supported member count directly against the API, with both clients bypassed (SEC-HTTP-6)
- **Zero Trust Relevance**: N/A — a resource bound, not a resource-access decision

## Standards Alignment

- **OWASP ASVS 5.0.0**: TO BE DECIDED — `PQ-17`
- **OWASP AISVS 1.0**: N/A
- **NIST SP 800-53 Rev. 5**: N/A
- **NIST SP 800-207**: N/A
- **Regulatory**: N/A
- **Other**: N/A
- **Mapping Basis**: CWE-770 is cited because SEC-HTTP-6's purpose is bounding the work a single request can demand.

## Acceptance Criteria

1. **AC-01 — Expected behavior**: Given a selection of between 3 and 12 skills and up to the documented member bound, when the dataset is requested, then it is assembled and returned (FR-7.6, FR-7.7).
2. **AC-02 — Boundary or failure behavior**: Given a selection of 2 skills, of 13 skills, or of more members than the documented bound, submitted directly to the API with no client involved, when the dataset is requested, then each is refused with the applicable limit stated as the reason (FR-7.6, FR-7.7, SEC-HTTP-6).
3. **AC-03 — Prohibited behavior**: Given an out-of-range selection, when it is processed, then it MUST NOT be silently truncated to fit, and the limit MUST NOT be enforced only in the client (SEC-HTTP-6, DR-1).

## Failure Behavior

- **On Invalid Input**: Refuse with the applicable limit named in product terms; assemble no dataset (SEC-INPUT-1, SEC-ERR-1)
- **On Authentication Failure**: Refuse (SEC-AUTHN-1)
- **On Authorization Failure**: Deny (SEC-AUTHZ-1); the limit check does not disclose which members exist
- **On Security-Decision Failure**: Deny by default
- **On External Dependency Failure**: N/A
- **On System Error**: No partial dataset (SEC-ERR-2)
- **Logging / Audit**: Limit refusals may be logged with actor, action and the counts involved; member identifiers and score values MUST NOT appear in the log line (SEC-LOG-3)
- **Alerting**: TO BE DECIDED — rate-based alerting on repeated limit breaches depends on `PQ-10`

## Test Strategy

- **Unit Tests**: The axis-count predicate at 2, 3, 12 and 13; the member-count predicate at the bound and one above it; message construction naming the limit
- **Integration Tests**: A within-limits request succeeding and each out-of-limits request refused, through the REST API
- **Security Tests**: A request for 13 axes and one for more than the supported member count, both directly against the API (SEC-HTTP-6); a request at NFR-9.3 scale asserting refusal rather than degradation (SEC-HTTP-5); an assertion that no truncated dataset is ever returned
- **Compliance Tests / Evidence**: N/A
- **Acceptance-Criteria Traceability**: AC-01 by the within-limits test; AC-02 by the boundary suite; AC-03 by the no-truncation assertion and the direct-API tests
- **Coverage Target**: Both sides of every limit boundary
- **Required Test Environment**: The `UT-10.1` fixture plus a larger fixture able to exceed both bounds

## Dependencies

- **Upstream Requirements**: REQ-CHART-010, REQ-ROSTER-040, REQ-SKILL-030
- **Downstream Requirements**: REQ-CHART-040, REQ-CHART-070, REQ-CHART-080
- **External Dependencies**: None
- **Dependency Assumptions**: N/A
- **Failure Impact**: N/A

## Implementation Notes

- **Constraints**: FR-7.7 states a minimum ("at least 6") rather than a maximum. Choose the documented maximum, record it in `REQUIREMENTS.md` alongside FR-7.7, and enforce it — an unbounded member count would make SEC-HTTP-6 and NFR-9.1 unsatisfiable.
- **Prohibited Approaches**: Silent truncation; a client-only check (DR-1); degrading rather than refusing when the bound is exceeded (SEC-HTTP-5)
- **Implementation Guidance**: The client's visible count against the limit (REQ-CHART-040) is the courtesy layer; this issue is the rule it mirrors.
- **AI Development Guidance**: `CLAUDE.md`; `.claude/agents/spec-auditor.md` before the pull request
- **Required Human Review**: Product review of the chosen member maximum; security reviewer for the bound
- **Open Decisions**: `OQ-5` is recorded — whether 3–12 skills and 6 members are the right sizes. The limits as stated are testable now; a change would move the numbers, not the mechanism. `PQ-10` (`SQ-9`, abuse and resource limits) is recorded and bears on SEC-HTTP-5 rather than on this rule.
- **Estimated effort**: 0.5 engineer-day; 150–300 changed human-authored lines
- **Recommended model**: Claude Sonnet 5 (`claude-sonnet-5`) — two numeric bounds with stated messages and clearly enumerated boundary cases.
