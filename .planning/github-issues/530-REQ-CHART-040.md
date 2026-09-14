# [REQ-CHART-040] Member and skill selection controls with a visible count against the limit

## Metadata

- **ID**: REQ-CHART-040
- **Title**: Member and skill selection controls with a visible count against the limit
- **Version**: 1.0.0
- **Status**: Draft
- **Owner**: Squadar engineering — unassigned
- **Author**: Jim Manico
- **Last Updated**: 2026-09-14
- **Priority**: High
- **Requirement Type**: Functional
- **Source / Parent**: REQ-CHART-000; `REQUIREMENTS.md` FR-7.5, FR-7.8, FR-2.6, NFR-9.5; `DESIGN.md` Components

## Requirement

- **Statement**: The user MUST be able to choose which team members and which skills from the catalog form the chart's series and axes, using checkable list items that show a visible count of the current selection against its limit, and the chart MUST update to reflect the current selection whenever that selection changes.
- **Rationale**: FR-7.5 gives the user control of the axes and FR-7.8 requires the chart to follow the selection. `DESIGN.md` specifies the control form exactly — checkable list items with a visible count against the limit — which is what makes FR-7.6 and FR-7.7's limits legible before the user hits them.
- **Assumptions**: FR-7.5 is marked **(assumed)** in `REQUIREMENTS.md` and stands.
- **Out of Scope**: Server-side limit enforcement (REQ-CHART-020), which this control mirrors as a courtesy layer; the legend's per-series toggle (REQ-CHART-050); the chart rendering (REQ-CHART-030, blocked).
- **Design Traceability**: `DESIGN.md` — Components (Inputs: selection of team members and skills for a chart uses checkable list items with a visible count of the current selection against its limit; Buttons; Focus states), Layout and Spacing (Desktop: chart and its selection/legend panel side by side; Tablet and Mobile: chart and controls stack), Accessibility (Keyboard: selecting team members and skills is fully keyboard-operable). `style-guide.html` is the rendered reference.
- **Architecture Traceability**: `ARCHITECTURE.md` Web Client — selection of members and skills; holds the current selection as transient view state; DR-1 (the client's limit display is a courtesy layer only).
- **Security Traceability**: SEC-BOUND-1, SEC-HTTP-6, SEC-RENDER-1, SEC-AUTHZ-3.

## Scope

- **Applies To**: Web Client
- **Components**: Web Client; Roster and Skill Catalog as the list sources
- **Interfaces / Operations**: Member selection list; skill selection list; the count indicator; selection change propagating to the chart
- **Actors**: Administrator, Assessor, Team Member, Viewer — including keyboard-only users
- **Preconditions**: REQ-CHART-020, REQ-ROSTER-040, REQ-SKILL-030 and REQ-UIKIT-030 are Verified
- **Data Classification**: Confidential — the member list names individuals
- **Personal or Regulated Data**: Personal Data
- **Jurisdiction / Regulatory Scope**: N/A

## Security Context

- **Security Objectives**: Confidentiality, Integrity
- **Control Layers**: Output Encoding, Input Validation
- **Threat References**: STRIDE — Information Disclosure, Tampering; OWASP Top 10:2025 Injection; CWE-79 Improper Neutralization of Input During Web Page Generation
- **Abuse / Misuse Case**: A member the caller is not entitled to see appearing in the selection list; a member or skill name containing markup rendered as HTML in a list item; the client's limit treated as the only enforcement, so a crafted request bypasses it.
- **Trust Boundary**: REST API → Web Client
- **Untrusted Inputs or Assertions**: Every member and skill name rendered into a list item
- **Authoritative Enforcement Point**: The server — the selection list is scoped by the caller's entitlement (SEC-AUTHZ-3) and the limit is enforced in REQ-CHART-020 (SEC-HTTP-6, SEC-BOUND-1)
- **Independent Verification**: The limit is tested server-side with the client bypassed; this issue's tests cover the courtesy layer only
- **Zero Trust Relevance**: N/A — the client makes no access decision

## Standards Alignment

- **OWASP ASVS 5.0.0**: TO BE DECIDED — `PQ-17`
- **OWASP AISVS 1.0**: N/A
- **NIST SP 800-53 Rev. 5**: N/A
- **NIST SP 800-207**: N/A
- **Regulatory**: N/A
- **Other**: W3C WCAG 2.2 Level AA — 2.1.1 Keyboard, 4.1.2 Name Role Value, 4.1.3 Status Messages (the count as a live status), 3.3.2 Labels or Instructions
- **Mapping Basis**: `DESIGN.md` requires the selection to be keyboard-operable and the count to be visible; the count changing as the user selects is a status message under 4.1.3.

## Acceptance Criteria

1. **AC-01 — Expected behavior**: Given the selection panel, when a user checks four members and six skills, then the count indicator reads the current selection against its limit for each list, and the chart and score table update to reflect the new selection (FR-7.5, FR-7.8).
2. **AC-02 — Boundary or failure behavior**: Given a selection already at the axis limit of 12 skills, when the user attempts to check a thirteenth, then the control states why it is unavailable in adjacent text rather than only disabling the item, and the selection is unchanged (`DESIGN.md` Components, FR-7.6).
3. **AC-03 — Prohibited behavior**: Given a keyboard-only user, when they operate the selection lists, then every item MUST be checkable and the count MUST be announced — the control MUST NOT be pointer-only (NFR-9.5); and a member or skill name containing markup MUST NOT be rendered as markup (SEC-RENDER-1).

## Failure Behavior

- **On Invalid Input**: A selection the server refuses is reported through the standard error contract, with the limit named (REQ-UIKIT-050, SEC-ERR-1)
- **On Authentication Failure**: The panel shows nothing; the server returns no member or skill list (SEC-AUTHN-1)
- **On Authorization Failure**: Members the caller may not see are absent from the list because the server scoped it, not because the client filtered it (SEC-AUTHZ-3, DR-1)
- **On Security-Decision Failure**: N/A — the client makes no security decision
- **On External Dependency Failure**: N/A
- **On System Error**: Present the server's product-term message; leave the prior selection intact rather than clearing it (SEC-ERR-1)
- **Logging / Audit**: N/A
- **Alerting**: N/A

## Test Strategy

- **Unit Tests**: Count computation and its rendering against each limit; selection state transitions; the at-limit behavior and its explanatory text
- **Integration Tests**: A selection change propagating to a dataset request and to both the chart and the table (FR-7.8, DR-7)
- **Security Tests**: Markup payloads in member and skill names asserted to render literally in list items (SEC-RENDER-1); a test confirming the member list is scoped server-side by asserting a non-entitled member never reaches the client (SEC-AUTHZ-3)
- **Compliance Tests / Evidence**: WCAG 2.2 AA — keyboard operation of both lists, accessible names on each item, the count announced as a status message, focus visibility, and layout at each breakpoint
- **Acceptance-Criteria Traceability**: AC-01 by the count and propagation tests; AC-02 by the at-limit test; AC-03 by the keyboard pass and the rendering test
- **Coverage Target**: Every selection state — empty, partial, at limit — in both modes, by pointer and by keyboard
- **Required Test Environment**: The `UT-10.1` fixture; a keyboard-only profile; viewports at each breakpoint

## Dependencies

- **Upstream Requirements**: REQ-CHART-020, REQ-ROSTER-040, REQ-SKILL-030, REQ-UIKIT-030, REQ-UIKIT-040, REQ-UIKIT-050
- **Downstream Requirements**: REQ-CHART-050, REQ-CHART-060
- **External Dependencies**: None
- **Dependency Assumptions**: N/A
- **Failure Impact**: N/A

## Implementation Notes

- **Constraints**: `DESIGN.md` specifies checkable list items with a visible count against the limit — not a multi-select dropdown or a tag input. The desktop layout places the panel beside the chart; tablet and mobile stack them.
- **Prohibited Approaches**: Enforcing the limit only here (DR-1, SEC-BOUND-1); disabling an at-limit item with no adjacent explanation, which `DESIGN.md` forbids; filtering the member list client-side rather than relying on the server's scoping
- **Implementation Guidance**: The count is the mechanism that makes FR-7.6 and FR-7.7 visible before the user is refused — build it as a live status region so it is announced as well as seen.
- **AI Development Guidance**: `CLAUDE.md`; read `DESIGN.md` and `style-guide.html` together
- **Required Human Review**: Accessibility reviewer for the keyboard and status-announcement behavior
- **Open Decisions**: None blocking. `OQ-5` would change the numbers the count is measured against, not the control.
- **Estimated effort**: 1–1.5 engineer-days; 350–600 changed human-authored lines
- **Recommended model**: Claude Sonnet 5 (`claude-sonnet-5`) — a fully specified control built from existing primitives, with the accessibility obligations named explicitly.
