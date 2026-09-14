# [REQ-CHART-010] Assemble one chart dataset with a shared axis set and explicit absence markers

## Metadata

- **ID**: REQ-CHART-010
- **Title**: Assemble one chart dataset with a shared axis set and explicit absence markers
- **Version**: 1.0.0
- **Status**: Draft
- **Owner**: Squadar engineering — unassigned
- **Author**: Jim Manico
- **Last Updated**: 2026-09-14
- **Priority**: Critical
- **Requirement Type**: Functional
- **Source / Parent**: REQ-CHART-000; `REQUIREMENTS.md` FR-7.4, FR-7.9, FR-6.2; `ARCHITECTURE.md` Chart Data Service, DR-7

## Requirement

- **Statement**: The Chart Data Service MUST assemble, for a selection of members and skills, one dataset containing the same axis set for every series, each member's current score per axis, and an explicit absence marker where a member has no score for an axis; and the radar chart and its equivalent score table MUST both be rendered from that single dataset.
- **Rationale**: FR-7.4 makes the shared axis set what allows series to be compared. DR-7 requires the chart and the table to come from one dataset so the two can never disagree — which is also what makes the table a faithful accessible route to the chart.
- **Assumptions**: None.
- **Out of Scope**: The limits applied to a selection (REQ-CHART-020); the chart rendering itself (REQ-CHART-030, blocked); the table rendering (REQ-CHART-070); performance at NFR-9.3 scale (REQ-CHART-090, blocked).
- **Design Traceability**: `DESIGN.md` — Charts (one axis per selected skill labelled at its vertex in Caption; skills with no score break the polygon at that axis and are marked in the legend rather than plotted as a value), Accessibility (the chart is backed by the equivalent score table, which is the accessible route to the same data rather than an afterthought).
- **Architecture Traceability**: `ARCHITECTURE.md` Chart Data Service — assembles a chart dataset with one shared axis set, each member's current score per axis and explicit absence markers; the same dataset backs the chart and its equivalent score table; reads from Assessment, Roster and Skill Catalog and owns nothing; Primary Flow 2; DR-4, DR-7.
- **Security Traceability**: SEC-BIZ-4, SEC-AUTHZ-3, SEC-DATA-3, SEC-DATA-4, SEC-HTTP-6, SEC-INPUT-1.

## Scope

- **Applies To**: API
- **Components**: Chart Data Service; Assessment; Roster; Skill Catalog; REST API
- **Interfaces / Operations**: Chart dataset request and response
- **Actors**: Administrator, Assessor, Team Member, Viewer
- **Preconditions**: REQ-SCORE-030, REQ-SCORE-050, REQ-ROSTER-040 and REQ-SKILL-030 are Verified
- **Data Classification**: Restricted
- **Personal or Regulated Data**: Personal Data
- **Jurisdiction / Regulatory Scope**: TO BE DECIDED — `PQ-13`

## Security Context

- **Security Objectives**: Confidentiality, Integrity, Authorization
- **Control Layers**: Authorization, Business-Rule Validation, Data Protection
- **Threat References**: STRIDE — Information Disclosure, Tampering; OWASP Top 10:2025 Broken Access Control; CWE-639 Authorization Bypass Through User-Controlled Key; CWE-1188 Initialization of a Resource with an Insecure Default
- **Abuse / Misuse Case**: A Team Member obtaining another individual's scores through the chart route rather than the score-detail route; a deleted member still present in an assembled dataset; an unassessed skill defaulted to a number in the dataset and thereby in both the chart and the table at once.
- **Trust Boundary**: Clients → REST API
- **Untrusted Inputs or Assertions**: The member and skill selection
- **Authoritative Enforcement Point**: The REST API and Chart Data Service, authorizing the caller against Roster membership and role before any score is read (Primary Flow 2)
- **Independent Verification**: Tests per endpoint with a Team Member actor and another member's identifier, covering the chart and table routes specifically (SEC-AUTHZ-3); a post-deletion sweep including cached and derived views (SEC-DATA-3)
- **Zero Trust Relevance**: NIST SP 800-207 §2.1 tenet 4 — each member in the selection is a separate resource with its own access decision

## Standards Alignment

- **OWASP ASVS 5.0.0**: TO BE DECIDED — `PQ-17`
- **OWASP AISVS 1.0**: N/A
- **NIST SP 800-53 Rev. 5**: N/A
- **NIST SP 800-207**: §2.1 tenet 4
- **Regulatory**: TO BE DECIDED — `PQ-13`
- **Other**: N/A
- **Mapping Basis**: Tenet 4 is cited because SEC-AUTHZ-3 makes chart access depend on shared-team membership evaluated per request.

## Acceptance Criteria

1. **AC-01 — Expected behavior**: Given a selection of four members and six skills, when the dataset is requested by an entitled caller, then it contains exactly those six axes in the same order for every one of the four series, and each series carries that member's current score per axis (FR-7.4).
2. **AC-02 — Boundary or failure behavior**: Given a selected member with no score for one of the selected skills, when the dataset is assembled, then that axis carries an explicit absence marker distinguishable from any numeric value, and the marker is present in the single dataset both the chart and the table read (FR-7.9, SEC-BIZ-4, DR-7).
3. **AC-03 — Prohibited behavior**: Given a Team Member, when they request a dataset containing a member they share no team with, then no score for that member MUST be read or returned (FR-1.4, SEC-AUTHZ-3); and the chart and the table MUST NOT be produced from two independent computations (DR-7).

## Failure Behavior

- **On Invalid Input**: Reject the selection with the offending identifier or rule named; assemble no dataset (SEC-INPUT-1)
- **On Authentication Failure**: Refuse; return no chart data (SEC-AUTHN-1)
- **On Authorization Failure**: Deny the whole request without revealing which selected member the caller may not see (SEC-AUTHZ-3, SEC-AUTHZ-7)
- **On Security-Decision Failure**: Deny by default (SEC-AUTHZ-1)
- **On External Dependency Failure**: If Assessment, Roster or Skill Catalog cannot be reached, return an error — not a dataset with absence markers standing in for unreadable data, which would misreport people as unassessed (SEC-ERR-1)
- **On System Error**: No partial dataset (SEC-ERR-2)
- **Logging / Audit**: Authorization denials logged with actor, action and target (SEC-LOG-2); score values MUST NOT appear in logs (SEC-LOG-3)
- **Alerting**: N/A

## Test Strategy

- **Unit Tests**: Axis-set construction and ordering; per-series score resolution; absence-marker placement; the distinction between "absent score" and "unreadable source"
- **Integration Tests**: Primary Flow 2 end to end; the chart and the table asserted equal from one payload (DR-7); a reassessment reflected on the next read (FR-5.10)
- **Security Tests**: A Team Member requesting a dataset containing a non-shared member (SEC-AUTHZ-3); a mixed-entitlement selection asserting whole-request denial rather than silent filtering; a post-deletion sweep over the dataset route including any cached view (SEC-DATA-3); a response-shape test per role (SEC-DATA-4); an absence-marker survival test from store to payload (SEC-BIZ-4)
- **Compliance Tests / Evidence**: TO BE DECIDED — `PQ-13`
- **Acceptance-Criteria Traceability**: AC-01 by the shared-axis-set test; AC-02 by the absence-marker test; AC-03 by the SEC-AUTHZ-3 suite and a single-source assertion on the table route
- **Coverage Target**: Positive and negative coverage per role on entitlement, and full coverage of the absent case alongside the scored case
- **Required Test Environment**: The `UT-10.1` fixture — ten members across ten skill levels with unassessed skills present, spanning teams the test actors do and do not belong to

## Dependencies

- **Upstream Requirements**: REQ-SCORE-030, REQ-SCORE-050, REQ-ROSTER-030, REQ-ROSTER-040, REQ-SKILL-030, REQ-AUTH-060
- **Downstream Requirements**: REQ-CHART-020, REQ-CHART-030, REQ-CHART-050, REQ-CHART-060, REQ-CHART-070, REQ-CHART-090, REQ-EXAM-060
- **External Dependencies**: None
- **Dependency Assumptions**: N/A
- **Failure Impact**: N/A

## Implementation Notes

- **Constraints**: Chart Data Service reads from Assessment, Roster and Skill Catalog through their interfaces and owns nothing (DR-4). One dataset backs both surfaces (DR-7).
- **Prohibited Approaches**: A table endpoint that recomputes scores independently of the chart endpoint; silently dropping members the caller may not see; substituting an absence marker for data that could not be read; an axis set that differs between series
- **Implementation Guidance**: Make the dataset shape carry the axis set once, at the top level, rather than repeating it per series — then FR-7.4 holds structurally and cannot drift between series.
- **AI Development Guidance**: `CLAUDE.md`; `.claude/agents/security-reviewer.md` before the pull request
- **Required Human Review**: Human security review before merge — authorization and data protection (`CLAUDE.md`); architecture reviewer for the dataset contract
- **Open Decisions**: `PQ-7` is recorded — whether series geometry is computed client-side or returned by the API is `TO BE DECIDED` in `ARCHITECTURE.md`. This issue returns data values, not geometry, which is correct under either answer; `PQ-7` blocks REQ-CHART-030, not this issue.
- **Estimated effort**: 1.5–2 engineer-days; 500–800 changed human-authored lines
- **Recommended model**: Claude Opus 5 (`claude-opus-5`) — the dataset is the single source for every score surface, it crosses three owning components, and it is the route by which an unentitled read would be least conspicuous.
