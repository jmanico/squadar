# [REQ-CHART-060] Chart empty state when no team member is selected

## Metadata

- **ID**: REQ-CHART-060
- **Title**: Chart empty state when no team member is selected
- **Version**: 1.0.0
- **Status**: Draft
- **Owner**: Squadar engineering — unassigned
- **Author**: Jim Manico
- **Last Updated**: 2026-09-14
- **Priority**: Medium
- **Requirement Type**: Functional
- **Source / Parent**: REQ-CHART-000; `REQUIREMENTS.md` FR-7.10; `DESIGN.md` Charts

## Requirement

- **Statement**: When no team member is selected, the system MUST NOT display a populated radar chart and MUST indicate that a selection is required, showing the bare grid and a sentence saying what to select.
- **Rationale**: FR-7.10 prevents an empty or stale chart being read as a result. `DESIGN.md` specifies the empty state's form — the bare grid plus a sentence — so the surface reads as "nothing chosen yet" rather than "nothing measured".
- **Assumptions**: None.
- **Out of Scope**: The selection controls (REQ-CHART-040); the populated chart (REQ-CHART-030, blocked); the score table's own empty state, which follows the same rule and is covered by REQ-CHART-070.
- **Design Traceability**: `DESIGN.md` — Charts (empty state shows the bare grid and a sentence saying what to select), Typography (Body for the sentence), Layout and Spacing (the chart area retains its square aspect in the empty state), Brand direction (calm, exact and unshowy — the empty state instructs, it does not apologize).
- **Architecture Traceability**: `ARCHITECTURE.md` Chart Data Service — returns an empty-state result when no member is selected (FR-7.10); DR-7.
- **Security Traceability**: SEC-DATA-4, SEC-ERR-1.

## Scope

- **Applies To**: Multiple
- **Components**: Chart Data Service; REST API; Web Client
- **Interfaces / Operations**: The chart surface with an empty selection; the empty-state dataset result
- **Actors**: Administrator, Assessor, Team Member, Viewer
- **Preconditions**: REQ-CHART-010 and REQ-UIKIT-010 are Verified
- **Data Classification**: Public — the empty state contains no product data
- **Personal or Regulated Data**: None
- **Jurisdiction / Regulatory Scope**: N/A

## Security Context

- **Security Objectives**: Integrity, Safety
- **Control Layers**: Data Protection, Other
- **Threat References**: STRIDE — Information Disclosure; CWE-524 Use of Cache Containing Sensitive Information
- **Abuse / Misuse Case**: A stale populated chart left on screen after the selection is cleared, so one user's session shows another selection's data; an empty state that leaks the names of selectable members it has no entitlement to show.
- **Trust Boundary**: REST API → Web Client
- **Untrusted Inputs or Assertions**: N/A — an empty selection carries no untrusted content
- **Authoritative Enforcement Point**: Chart Data Service, returning an empty-state result rather than an error or a stale dataset
- **Independent Verification**: A test that clearing a selection replaces a previously populated chart rather than leaving it rendered
- **Zero Trust Relevance**: N/A

## Standards Alignment

- **OWASP ASVS 5.0.0**: N/A — no verification requirement applies to an empty-state presentation
- **OWASP AISVS 1.0**: N/A
- **NIST SP 800-53 Rev. 5**: N/A
- **NIST SP 800-207**: N/A
- **Regulatory**: N/A
- **Other**: W3C WCAG 2.2 Level AA — 1.1.1 Non-text Content (the bare grid needs no alternative beyond the sentence, which must be real text), 4.1.3 Status Messages
- **Mapping Basis**: The instructive sentence is the accessible content of the empty state; 4.1.3 applies because it appears in response to the selection changing.

## Acceptance Criteria

1. **AC-01 — Expected behavior**: Given no team member selected, when the chart surface renders, then the bare grid is shown together with a sentence saying what to select, and no series is drawn (FR-7.10, `DESIGN.md` Charts).
2. **AC-02 — Boundary or failure behavior**: Given a populated chart, when the user clears the selection to none, then the populated chart is replaced by the empty state on the same render — a stale populated chart MUST NOT remain visible (FR-7.8, FR-7.10).
3. **AC-03 — Prohibited behavior**: Given the empty state, when it is rendered, then it MUST NOT display a populated chart, a zeroed chart, or any team member's data; and the instruction MUST be real text rather than an image or a decorative element alone (FR-7.10).

## Failure Behavior

- **On Invalid Input**: An empty selection is a valid state, not an invalid input — it produces the empty state, not an error (FR-7.10)
- **On Authentication Failure**: The surface shows nothing at all; the empty state is for authenticated callers with no selection (SEC-AUTHN-1)
- **On Authorization Failure**: Deny the request; the empty state MUST NOT be used to mask a refusal, which would misreport a denial as "nothing selected" (SEC-AUTHZ-7, SEC-ERR-1)
- **On Security-Decision Failure**: Deny by default
- **On External Dependency Failure**: An unreachable source is an error state, distinct from the empty state (SEC-ERR-1)
- **On System Error**: Show the error, not the empty state — the two must be visually and semantically distinct
- **Logging / Audit**: N/A
- **Alerting**: N/A

## Test Strategy

- **Unit Tests**: The empty-state predicate; the distinction between empty, error and denied states
- **Integration Tests**: A dataset request with an empty member selection returning the empty-state result; a populated-to-empty transition on the same surface
- **Security Tests**: A denied request asserted to render the refusal rather than the empty state (SEC-AUTHZ-7); a response-shape test asserting the empty-state result carries no member data (SEC-DATA-4)
- **Compliance Tests / Evidence**: WCAG 2.2 AA — the sentence is real text with sufficient contrast, and the state change is announced
- **Acceptance-Criteria Traceability**: AC-01 by the empty-state render test; AC-02 by the populated-to-empty transition test; AC-03 by the content assertions
- **Coverage Target**: Empty, populated-to-empty, error and denied states each covered and asserted distinct
- **Required Test Environment**: The `UT-10.1` fixture; a surface able to transition between states

## Dependencies

- **Upstream Requirements**: REQ-CHART-010, REQ-CHART-040, REQ-UIKIT-010
- **Downstream Requirements**: None
- **External Dependencies**: None
- **Dependency Assumptions**: N/A
- **Failure Impact**: N/A

## Implementation Notes

- **Constraints**: `DESIGN.md` specifies the bare grid plus a sentence — not a blank panel, not an illustration, not a zeroed chart.
- **Prohibited Approaches**: Plotting all axes at zero or at 1, which would read as a measurement and is exactly what FR-4.4 and SEC-BIZ-4 forbid elsewhere; leaving the previous chart on screen; using the empty state to present an authorization refusal
- **Implementation Guidance**: Keep empty, error and denied as three distinct states in the component's model. Collapsing any two of them is how a refusal ends up reported as "nothing selected".
- **AI Development Guidance**: `CLAUDE.md`; read `DESIGN.md` and `style-guide.html` together
- **Required Human Review**: Product review of the instruction's wording; accessibility reviewer for the announcement
- **Open Decisions**: None
- **Estimated effort**: 0.5 engineer-day; 120–250 changed human-authored lines
- **Recommended model**: Claude Sonnet 5 (`claude-sonnet-5`) — a small, fully specified state with one genuine subtlety, keeping empty distinct from error and denied, which is called out above.
