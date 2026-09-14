# [REQ-CHART-000] Chart dataset, radar chart, score table and ranking

## Metadata

- **ID**: REQ-CHART-000
- **Title**: Chart dataset, radar chart, score table and ranking
- **Version**: 1.0.0
- **Status**: Draft
- **Owner**: Squadar engineering — unassigned
- **Author**: Jim Manico
- **Last Updated**: 2026-09-14
- **Priority**: Critical
- **Requirement Type**: Functional
- **Source / Parent**: REQ-EPIC-001; `REQUIREMENTS.md` FR-6.1–FR-6.3, FR-7.1–FR-7.11, NFR-9.1, NFR-9.3, NFR-9.4; `ARCHITECTURE.md` Chart Data Service

## Requirement

- **Statement**: The system MUST assemble one chart dataset per member-and-skill selection and render from it both the shared radar chart and its equivalent score table, enforcing the axis and member limits server-side and marking absent scores as absent; delivery is the sum of its children.
- **Rationale**: The shared radar chart is the product's core artifact (FR-7.2). DR-7 requires the chart and its table to come from one dataset so they can never disagree, which is also what makes the table the accessible route to the same data.
- **Assumptions**: The limits in FR-7.6 (3–12 axes) and FR-7.7 (at least 6 members) are marked **(assumed)** and stand until `OQ-5` is answered. FR-7.5 and FR-7.11 are likewise **(assumed)**.
- **Out of Scope**: The chart rendering library and whether series geometry is computed client-side or server-side (`PQ-7`, blocking REQ-CHART-030); any read model, index or cache needed to hold NFR-9.1 at NFR-9.3 scale (`PQ-8`, `PQ-10`, blocking REQ-CHART-090).
- **Design Traceability**: `DESIGN.md` — Charts (one axis per selected skill labelled in Caption, rings at 2/4/6/8/10, distinct hue plus line pattern and vertex shape per series, legend entries toggle their series, broken polygon at an absent axis, empty state showing the bare grid and a sentence); Layout and Spacing (square chart, never below 280 px, tabular view below that; breakpoints); Accessibility (not colour alone, text alternative, equivalent score table). `style-guide.html` is the rendered reference.
- **Architecture Traceability**: `ARCHITECTURE.md` Chart Data Service; Web Client; Primary Flow 2; DR-1, DR-2, DR-7.
- **Security Traceability**: SEC-HTTP-6, SEC-BIZ-4, SEC-AUTHZ-3, SEC-DATA-3, SEC-DATA-4, SEC-RENDER-1, SEC-RENDER-2, SEC-INPUT-6, SEC-HTTP-5.

## Scope

- **Applies To**: Multiple
- **Components**: Chart Data Service; Assessment; Roster; Skill Catalog; REST API; Web Client
- **Interfaces / Operations**: Chart dataset request; radar chart surface; score table; ranked list by skill; selection and legend controls
- **Actors**: Administrator, Assessor, Team Member, Viewer
- **Preconditions**: The caller is authenticated and their authorization context is resolved
- **Data Classification**: Restricted
- **Personal or Regulated Data**: Personal Data
- **Jurisdiction / Regulatory Scope**: TO BE DECIDED — `PQ-13`

## Security Context

- **Security Objectives**: Multiple
- **Control Layers**: Authorization, Input Validation, Business-Rule Validation, Output Encoding, Availability
- **Threat References**: STRIDE — Information Disclosure, Denial of Service; OWASP Top 10:2025 Broken Access Control
- **Abuse / Misuse Case**: A Team Member charting a member they share no team with; a selection of 13 axes or an unbounded member list silently truncated instead of refused; a member or skill name carrying markup into an SVG axis label; a deleted member still plotted; an unassessed skill plotted as a value.
- **Trust Boundary**: Clients → REST API
- **Untrusted Inputs or Assertions**: The member and skill selection, sort and filter parameters on ranked lists, and every name that becomes a chart label
- **Authoritative Enforcement Point**: Chart Data Service behind the REST API — limits and entitlement are enforced there, not in the client (SEC-BOUND-1, SEC-HTTP-6)
- **Independent Verification**: The dataset is assembled from Assessment, Roster and Skill Catalog by identity; a client-supplied score or label is never trusted
- **Zero Trust Relevance**: NIST SP 800-207 §2.1 tenet 4 — chart entitlement is evaluated per request from shared-team membership

## Standards Alignment

- **OWASP ASVS 5.0.0**: TO BE DECIDED — `PQ-17`
- **OWASP AISVS 1.0**: N/A
- **NIST SP 800-53 Rev. 5**: N/A — no mapping verified against the catalog release
- **NIST SP 800-207**: §2.1 tenet 4
- **Regulatory**: TO BE DECIDED — `PQ-13`
- **Other**: W3C WCAG 2.2 Level AA, as `DESIGN.md` sets it, for every surface in this workstream
- **Mapping Basis**: WCAG 2.2 AA is cited because `DESIGN.md` names it as the conformance target and `CLAUDE.md` makes it a build requirement rather than a later pass.

## Acceptance Criteria

1. **AC-01 — Expected behavior**: Given a selection of 4 members and 6 skills, when the chart is requested, then one dataset returns the same 6 axes for every member, each member's current score per axis, and the chart and score table render from that single dataset (FR-7.4, FR-6.2, DR-7).
2. **AC-02 — Boundary or failure behavior**: Given a selection of 13 skills submitted directly to the API, when the dataset is requested, then the request is refused with the limit stated as the reason and no truncated dataset is returned (FR-7.6, SEC-HTTP-6).
3. **AC-03 — Prohibited behavior**: Given a selected member with no score for a shown skill, when the chart and the table are rendered, then that axis MUST NOT carry a plotted value — the absence is indicated instead (FR-7.9, SEC-BIZ-4).

## Failure Behavior

- **On Invalid Input**: Reject the selection with the offending limit or identifier named; return no partial dataset (SEC-INPUT-1, SEC-HTTP-6)
- **On Authentication Failure**: Refuse; return no chart data (SEC-AUTHN-1)
- **On Authorization Failure**: Deny without confirming which of the selected members the caller may not see (SEC-AUTHZ-3, SEC-AUTHZ-7)
- **On Security-Decision Failure**: Deny by default (SEC-AUTHZ-1)
- **On External Dependency Failure**: N/A
- **On System Error**: Return an error with no internal detail; render the empty state rather than a partial chart (SEC-ERR-1)
- **Logging / Audit**: Authorization denials logged with actor, action and target (SEC-LOG-2); score values MUST NOT appear in logs (SEC-LOG-3)
- **Alerting**: TO BE DECIDED — chart-request abuse thresholds depend on `PQ-10`

## Test Strategy

- **Unit Tests**: Axis-set construction; absence marker propagation; limit predicates at 2, 3, 12 and 13 axes and at the member bound; ranked-list ordering
- **Integration Tests**: Primary Flow 2 end to end; chart and table asserted equal from one payload (DR-7); a new exam score picked up by the next chart read (FR-5.10)
- **Security Tests**: Team Member charting a non-shared member (SEC-AUTHZ-3); direct API requests exceeding both limits (SEC-HTTP-6); markup payloads in member and skill names asserted to display literally in chart and table (SEC-RENDER-1, SEC-RENDER-2); injection payloads in ranked-list sort and filter parameters (SEC-INPUT-6); post-deletion sweep of chart, table, ranked list and export (SEC-DATA-3)
- **Compliance Tests / Evidence**: WCAG 2.2 AA verification per surface — keyboard operation of selection and legend, non-colour series encoding, text alternative, 200% zoom and 320 px width
- **Acceptance-Criteria Traceability**: AC-01 by REQ-CHART-010 and REQ-CHART-070; AC-02 by REQ-CHART-020; AC-03 by REQ-CHART-010 and REQ-CHART-070
- **Coverage Target**: Positive and negative coverage on every limit, authorization decision and absence path
- **Required Test Environment**: The `UT-10.1` fixture — ten members across ten skill levels, with unassessed skills present and at least one deactivated member

## Dependencies

- **Upstream Requirements**: REQ-SCORE-010, REQ-SCORE-030, REQ-SCORE-050, REQ-ROSTER-030, REQ-ROSTER-040, REQ-SKILL-030, REQ-AUTH-060, REQ-UIKIT-010, REQ-UIKIT-040, REQ-UIKIT-060
- **Downstream Requirements**: None
- **Child Requirements**:
  - [ ] {{ISSUE_URL:REQ-CHART-010}} — Assemble one chart dataset with a shared axis set and explicit absence markers
  - [ ] {{ISSUE_URL:REQ-CHART-020}} — Enforce the axis and member selection limits server-side with a stated reason
  - [ ] {{ISSUE_URL:REQ-CHART-030}} — Render the shared radar chart with distinguishable series
  - [ ] {{ISSUE_URL:REQ-CHART-040}} — Member and skill selection controls with a visible count against the limit
  - [ ] {{ISSUE_URL:REQ-CHART-050}} — Legend that names every series and toggles its visibility
  - [ ] {{ISSUE_URL:REQ-CHART-060}} — Chart empty state when no team member is selected
  - [ ] {{ISSUE_URL:REQ-CHART-070}} — Equivalent score table rendered from the chart dataset
  - [ ] {{ISSUE_URL:REQ-CHART-080}} — Rank team members by their score for a chosen skill
  - [ ] {{ISSUE_URL:REQ-CHART-090}} — Meet the chart render budget at the supported member and skill scale
- **External Dependencies**: A radar chart rendering library — TO BE DECIDED (`PQ-7`), to be evaluated under DEP-1…DEP-8 before it is added
- **Dependency Assumptions**: Any library chosen renders from structured values, never by interpolating a server-supplied string into SVG, canvas or style content (SEC-RENDER-2).
- **Failure Impact**: An unsuitable library blocks REQ-CHART-030 only; the dataset, table, ranking and limit enforcement stand without it.

## Implementation Notes

- **Constraints**: The chart and the table come from one dataset (DR-7). Limits are enforced server-side regardless of what the client offers (SEC-BOUND-1).
- **Prohibited Approaches**: A second, client-side computation of the table; silent truncation of an over-limit selection; distinguishing series by hue alone (NFR-9.4)
- **Implementation Guidance**: Build REQ-CHART-070 alongside REQ-CHART-010, before REQ-CHART-030 unblocks — the table is the accessible route to the same data and is fully buildable today.
- **AI Development Guidance**: `CLAUDE.md`; `DESIGN.md` and `style-guide.html` together for every UI child
- **Required Human Review**: Accessibility review per surface; security review for the dataset authorization path
- **Open Decisions**: `PQ-7` blocks REQ-CHART-030; `PQ-8` and `PQ-10` block REQ-CHART-090.
