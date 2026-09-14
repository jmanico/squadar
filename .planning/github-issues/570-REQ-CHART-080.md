# [REQ-CHART-080] Rank team members by their score for a chosen skill

## Metadata

- **ID**: REQ-CHART-080
- **Title**: Rank team members by their score for a chosen skill
- **Version**: 1.0.0
- **Status**: Draft
- **Owner**: Squadar engineering — unassigned
- **Author**: Jim Manico
- **Last Updated**: 2026-09-14
- **Priority**: Medium
- **Requirement Type**: Functional
- **Source / Parent**: REQ-CHART-000; `REQUIREMENTS.md` FR-6.1, FR-6.3; `SECURITY.md` SEC-INPUT-6, SEC-HTTP-6

## Requirement

- **Statement**: The system MUST be able to list team members ordered by their score for a chosen skill, highest first, with the ordering and filtering parameters drawn from a server-side allow-list, the result bounded per request, and members the caller is not entitled to see excluded by the server.
- **Rationale**: FR-6.3 states the ranked list and FR-6.1 fixes its direction. SEC-INPUT-6 names ranked lists explicitly as the place sort and filter parameters reach the query layer, and SEC-HTTP-6 requires the result to be bounded.
- **Assumptions**: FR-6.3 is marked **(assumed)** in `REQUIREMENTS.md` and stands. Members with no score for the chosen skill are excluded from the ranking rather than ordered last, since FR-4.4 forbids treating unassessed as a value — this is recorded as an implementation decision in the notes below.
- **Out of Scope**: The chart dataset and its table (REQ-CHART-010, REQ-CHART-070); score history.
- **Design Traceability**: `DESIGN.md` — Layout and Spacing (score tables are compact because comparison across rows is the point), Typography (monospace numerics so scores align in columns), Brand direction (no visual device ranks a person as a whole — only skills, on their stated 1–10 scale), Accessibility (Keyboard: paging score tables is keyboard-operable).
- **Architecture Traceability**: `ARCHITECTURE.md` Assessment — produces ranked and tabular views (FR-6.1–FR-6.3); REST API — enforces request-level concerns including pagination and limits; DR-3.
- **Security Traceability**: SEC-INPUT-6, SEC-HTTP-6, SEC-AUTHZ-3, SEC-DATA-3, SEC-DATA-4, SEC-BIZ-4, SEC-RENDER-1.

## Scope

- **Applies To**: Multiple
- **Components**: Assessment; REST API; Web Client
- **Interfaces / Operations**: Ranked list by skill
- **Actors**: Administrator, Assessor, Team Member, Viewer
- **Preconditions**: REQ-SCORE-030, REQ-SCORE-050, REQ-SKILL-010 and REQ-AUTH-060 are Verified
- **Data Classification**: Restricted
- **Personal or Regulated Data**: Personal Data — a ranked list is a comparative statement about identified individuals
- **Jurisdiction / Regulatory Scope**: TO BE DECIDED — `PQ-13`

## Security Context

- **Security Objectives**: Confidentiality, Integrity, Availability
- **Control Layers**: Authorization, Input Validation, Availability
- **Threat References**: STRIDE — Information Disclosure, Denial of Service; OWASP Top 10:2025 Injection; CWE-89 Improper Neutralization of Special Elements used in an SQL Command; CWE-770 Allocation of Resources Without Limits or Throttling
- **Abuse / Misuse Case**: An injection payload in a sort or filter parameter reaching the query layer; a Team Member using the ranked list to read colleagues' individual scores, which FR-1.4 denies outside a shared chart; an unbounded ranked list at the NFR-9.3 scale of 1,000 members; a deleted member still appearing in a ranked view, which SEC-DATA-3 names explicitly.
- **Trust Boundary**: Clients → REST API
- **Untrusted Inputs or Assertions**: The chosen skill identifier and every sort, filter and pagination parameter
- **Authoritative Enforcement Point**: Assessment behind the REST API, with sortable and filterable fields from a server-side allow-list (SEC-INPUT-6)
- **Independent Verification**: Code review plus tests submitting injection payloads in sort and filter parameters (SEC-INPUT-6); SEC-AUTHZ-3's test set names the ranked-list route explicitly
- **Zero Trust Relevance**: NIST SP 800-207 §2.1 tenet 4 — each member in the result is a resource whose inclusion is decided by the caller's entitlement

## Standards Alignment

- **OWASP ASVS 5.0.0**: TO BE DECIDED — `PQ-17`
- **OWASP AISVS 1.0**: N/A
- **NIST SP 800-53 Rev. 5**: N/A
- **NIST SP 800-207**: §2.1 tenet 4
- **Regulatory**: TO BE DECIDED — `PQ-13`
- **Other**: N/A
- **Mapping Basis**: CWE-89 is cited because SEC-INPUT-6 names sort, filter and pagination parameters as the concatenation risk, and this is the endpoint where they are user-facing.

## Acceptance Criteria

1. **AC-01 — Expected behavior**: Given a chosen skill and a set of members the caller is entitled to see, when the ranked list is requested, then those members are returned ordered by their current score for that skill, highest first (FR-6.1, FR-6.3).
2. **AC-02 — Boundary or failure behavior**: Given a sort or filter parameter naming a field not on the server-side allow-list, or a request at the NFR-9.3 scale of 1,000 members with no pagination, when either is submitted, then the first is rejected without the value reaching the query layer and the second is bounded by the documented page size (SEC-INPUT-6, SEC-HTTP-6).
3. **AC-03 — Prohibited behavior**: Given a Team Member, when they request a ranked list, then it MUST NOT disclose another individual's score detail outside what FR-1.4 permits (SEC-AUTHZ-3); and a member with no score for the chosen skill MUST NOT be ordered as though scored (FR-4.4, SEC-BIZ-4).

## Failure Behavior

- **On Invalid Input**: Reject the parameter with the reason named; return no list (SEC-INPUT-1, SEC-INPUT-6)
- **On Authentication Failure**: Refuse; return no score data (SEC-AUTHN-1)
- **On Authorization Failure**: Deny without confirming which members exist (SEC-AUTHZ-3, SEC-AUTHZ-7)
- **On Security-Decision Failure**: Deny by default (SEC-AUTHZ-1)
- **On External Dependency Failure**: N/A
- **On System Error**: Return an error with no query text or internal identifier; return no partial list (SEC-ERR-1)
- **Logging / Audit**: Authorization denials logged with actor, action and target (SEC-LOG-2); score values MUST NOT appear in logs (SEC-LOG-3)
- **Alerting**: TO BE DECIDED — depends on `PQ-10`

## Test Strategy

- **Unit Tests**: Ordering by score descending, including ties; exclusion of unassessed members; the sort and filter allow-list; page bounding
- **Integration Tests**: A ranked list for a skill with known scores asserting the exact order; consistency with the current score shown in the score table
- **Security Tests**: Injection payloads in sort, filter and pagination parameters (SEC-INPUT-6); the SEC-AUTHZ-3 test set against the ranked-list route; a 1,000-member scale request asserting the documented bound (SEC-HTTP-6); a post-deletion sweep including the ranked view (SEC-DATA-3); markup payloads in member names asserted to render literally (SEC-RENDER-1)
- **Compliance Tests / Evidence**: WCAG 2.2 AA — the list is keyboard-pageable and its ordering is conveyed in text, not by position alone
- **Acceptance-Criteria Traceability**: AC-01 by the ordering test; AC-02 by the allow-list and scale tests; AC-03 by the SEC-AUTHZ-3 suite and the unassessed-exclusion test
- **Coverage Target**: Positive and negative coverage per role, plus every sort and filter parameter on both sides of the allow-list
- **Required Test Environment**: The `UT-10.1` fixture — ten members across ten skill levels, which gives an unambiguous expected order — plus a 1,000-member fixture for the scale case

## Dependencies

- **Upstream Requirements**: REQ-SCORE-030, REQ-SCORE-050, REQ-SKILL-010, REQ-AUTH-060, REQ-CHART-020
- **Downstream Requirements**: REQ-EXAM-060
- **External Dependencies**: None
- **Dependency Assumptions**: N/A
- **Failure Impact**: N/A

## Implementation Notes

- **Constraints**: `DESIGN.md`'s brand direction is explicit that no visual device ranks a person as a whole — this list ranks one skill, and its presentation must not read as an overall leaderboard.
- **Prohibited Approaches**: Concatenating a sort or filter value into query text (SEC-INPUT-6); an unbounded result; ordering unassessed members as though they scored a value (SEC-BIZ-4); filtering unentitled members in the client
- **Implementation Guidance**: Excluding unassessed members rather than ordering them last is the reading taken here because FR-4.4 forbids treating unassessed as a value and any ordinal position implies one. If the product wants them listed, they belong in a separate "not assessed" group, and that change belongs in `REQUIREMENTS.md`.
- **AI Development Guidance**: `CLAUDE.md`; `.claude/agents/security-reviewer.md` before the pull request
- **Required Human Review**: Human security review before merge — input handling and authorization (`CLAUDE.md`); product review of how unassessed members are presented
- **Open Decisions**: `PQ-6` (pagination convention) and `PQ-10` (`SQ-9`, resource limits) are recorded; neither blocks the behavior.
- **Estimated effort**: 0.5–1 engineer-day; 250–450 changed human-authored lines
- **Recommended model**: Claude Sonnet 5 (`claude-sonnet-5`) — a bounded, allow-listed query with a stated order; the security requirements are explicit and the tests are named.
