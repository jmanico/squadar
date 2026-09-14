# [REQ-CHART-070] Equivalent score table rendered from the chart dataset

## Metadata

- **ID**: REQ-CHART-070
- **Title**: Equivalent score table rendered from the chart dataset
- **Version**: 1.0.0
- **Status**: Draft
- **Owner**: Squadar engineering — unassigned
- **Author**: Jim Manico
- **Last Updated**: 2026-09-14
- **Priority**: Critical
- **Requirement Type**: Functional
- **Source / Parent**: REQ-CHART-000; `REQUIREMENTS.md` FR-6.1, FR-6.2, FR-7.9, NFR-9.5; `ARCHITECTURE.md` DR-7

## Requirement

- **Statement**: Each team member's per-skill current score MUST be visible in a tabular form as well as within the radar chart, rendered from the same dataset as the chart, with higher scores denoting greater assessed skill and absent scores shown as absent; the table is the accessible route to the chart's data, not an afterthought.
- **Rationale**: FR-6.2 requires the tabular view and DR-7 requires it to come from the chart's dataset so the two can never disagree. `DESIGN.md` makes the table the chart's accessible equivalent and the fallback below 280 px, which means it must be as complete as the chart, not a summary of it.
- **Assumptions**: None.
- **Out of Scope**: The chart rendering (REQ-CHART-030, blocked); ranking by a chosen skill (REQ-CHART-080); the dataset itself (REQ-CHART-010).
- **Design Traceability**: `DESIGN.md` — Layout and Spacing (score tables are compact, 8–12 px cell padding, because comparison across rows is the point; the score table scrolls horizontally in its own container at mobile; below 280 px the tabular score view replaces the chart), Typography (the numeric and code family is used for 1–10 scores in tables so digits align in columns), Accessibility (Text and zoom: only tables and the chart may scroll inside their own container; Keyboard: paging score tables is keyboard-operable; Names and structure: the chart is backed by the equivalent score table, which is the accessible route to the same data).
- **Architecture Traceability**: `ARCHITECTURE.md` Chart Data Service — the same dataset backs the chart and its equivalent score table, so the two can never disagree; Assessment — produces ranked and tabular views; DR-7.
- **Security Traceability**: SEC-BIZ-4, SEC-AUTHZ-3, SEC-DATA-3, SEC-DATA-4, SEC-RENDER-1, SEC-HTTP-6.

## Scope

- **Applies To**: Web Client
- **Components**: Web Client; Chart Data Service as the dataset source
- **Interfaces / Operations**: The score table surface; its paging
- **Actors**: Administrator, Assessor, Team Member, Viewer — including keyboard-only and assistive-technology users
- **Preconditions**: REQ-CHART-010, REQ-UIKIT-020 and REQ-UIKIT-040 are Verified
- **Data Classification**: Restricted
- **Personal or Regulated Data**: Personal Data
- **Jurisdiction / Regulatory Scope**: TO BE DECIDED — `PQ-13`

## Security Context

- **Security Objectives**: Confidentiality, Integrity
- **Control Layers**: Output Encoding, Authorization, Data Protection
- **Threat References**: STRIDE — Information Disclosure, Tampering; OWASP Top 10:2025 Broken Access Control; CWE-79 Improper Neutralization of Input During Web Page Generation
- **Abuse / Misuse Case**: The table route treated as less sensitive than the chart route and returning members the caller may not see; a member or skill name containing markup rendered as HTML in a header or cell; an absent score rendered as an empty cell that a reader interprets as zero; a deleted member still present in the table.
- **Trust Boundary**: REST API → Web Client
- **Untrusted Inputs or Assertions**: Every member and skill name rendered into the table
- **Authoritative Enforcement Point**: The server — the table reads the same authorized dataset the chart does, so entitlement is decided once (DR-7, SEC-AUTHZ-3)
- **Independent Verification**: SEC-AUTHZ-3's test set names the table route explicitly alongside chart, export and ranked list
- **Zero Trust Relevance**: N/A — the client makes no access decision

## Standards Alignment

- **OWASP ASVS 5.0.0**: TO BE DECIDED — `PQ-17`
- **OWASP AISVS 1.0**: N/A
- **NIST SP 800-53 Rev. 5**: N/A
- **NIST SP 800-207**: N/A
- **Regulatory**: TO BE DECIDED — `PQ-13`
- **Other**: W3C WCAG 2.2 Level AA — 1.3.1 Info and Relationships (table headers and their associations), 1.4.10 Reflow, 2.1.1 Keyboard, 1.4.1 Use of Color
- **Mapping Basis**: `DESIGN.md` makes this table the accessible route to the chart's data; 1.3.1 is the criterion that makes a data table conveyable to assistive technology, and the others follow from the scroll, paging and absence rules it states.

## Acceptance Criteria

1. **AC-01 — Expected behavior**: Given a chart dataset for four members and six skills, when the score table renders, then it shows every one of those members' current scores for every one of those skills, from that same dataset, with higher scores denoting greater assessed skill (FR-6.1, FR-6.2, DR-7).
2. **AC-02 — Boundary or failure behavior**: Given a viewport narrower than 280 px, when the surface renders, then the score table is shown in place of the chart and carries the same information; at mobile width the table scrolls horizontally within its own container and the page does not scroll horizontally (`DESIGN.md` Layout and Spacing, Accessibility).
3. **AC-03 — Prohibited behavior**: Given a member with no score for a skill, when the table renders, then that cell MUST show an explicit absence indication in text and MUST NOT be blank or zero (FR-7.9, SEC-BIZ-4); and the table MUST NOT be computed from a second, independent query (DR-7).

## Failure Behavior

- **On Invalid Input**: N/A — the table renders from the dataset, which REQ-CHART-010 validates
- **On Authentication Failure**: The surface shows nothing (SEC-AUTHN-1)
- **On Authorization Failure**: The refusal is presented without indicating which member was withheld (SEC-AUTHZ-3, SEC-AUTHZ-7)
- **On Security-Decision Failure**: N/A — the client makes no security decision (DR-1)
- **On External Dependency Failure**: N/A — this is the fallback surface when the chart cannot render
- **On System Error**: Present the server's product-term message; render no partial table (SEC-ERR-1)
- **Logging / Audit**: N/A
- **Alerting**: N/A

## Test Strategy

- **Unit Tests**: Row and column construction from the dataset; absence-cell rendering; paging state
- **Integration Tests**: The chart and the table asserted to show identical values from one dataset (DR-7); a reassessment reflected in both on the next read (FR-5.10)
- **Security Tests**: The SEC-AUTHZ-3 test set run against the table route with a Team Member actor and another member's identifier; markup payloads in member and skill names asserted to render literally in headers and cells (SEC-RENDER-1); a post-deletion sweep including the table route (SEC-DATA-3); bounded row and column counts asserted server-side (SEC-HTTP-6)
- **Compliance Tests / Evidence**: WCAG 2.2 AA — header associations announced by a screen reader, keyboard paging, reflow at 320 px and 200% zoom with only the table's own container scrolling, and absence conveyed in text rather than by an empty cell
- **Acceptance-Criteria Traceability**: AC-01 by the chart-table equality test; AC-02 by the narrow-viewport and reflow tests; AC-03 by the absence-cell test and the single-source assertion
- **Coverage Target**: Every dataset shape the chart supports, including the fully absent row, in both modes, by keyboard
- **Required Test Environment**: The `UT-10.1` fixture with unassessed skills present; viewports below 280 px and at 320 px; a screen reader for the manual pass

## Dependencies

- **Upstream Requirements**: REQ-CHART-010, REQ-CHART-020, REQ-UIKIT-010, REQ-UIKIT-020, REQ-UIKIT-040, REQ-UIKIT-060
- **Downstream Requirements**: REQ-EXAM-060
- **External Dependencies**: None
- **Dependency Assumptions**: N/A
- **Failure Impact**: N/A

## Implementation Notes

- **Constraints**: The table reads the chart's dataset (DR-7). `DESIGN.md` sets compact density, 8–12 px cell padding, and the monospace numeric family so digits align in columns.
- **Prohibited Approaches**: A separate table endpoint with its own query; a blank cell for an absent score; a table that summarizes rather than reproduces the chart's data, which would break FR-6.2's equivalence and with it the accessibility claim
- **Implementation Guidance**: Build this alongside REQ-CHART-010 and before `PQ-7` unblocks the chart. It is fully specified today, it is the accessible route to the same data, and it is the fallback the chart degrades to — so the product is usable before the chart exists.
- **AI Development Guidance**: `CLAUDE.md`; read `DESIGN.md` and `style-guide.html` together
- **Required Human Review**: Accessibility reviewer — the screen-reader pass on table semantics is not replaceable by automated checks
- **Open Decisions**: `PQ-6` is recorded — the pagination convention is `TO BE DECIDED` in `ARCHITECTURE.md`; adopt the project convention when it exists rather than inventing a second one.
- **Estimated effort**: 1–1.5 engineer-days; 350–600 changed human-authored lines
- **Recommended model**: Claude Sonnet 5 (`claude-sonnet-5`) — a well-specified data table; its exacting parts, the accessibility semantics and the absence rendering, are both stated explicitly.
