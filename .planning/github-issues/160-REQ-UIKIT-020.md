# [REQ-UIKIT-020] Responsive grid, breakpoints and zoom resilience

## Metadata

- **ID**: REQ-UIKIT-020
- **Title**: Responsive grid, breakpoints and zoom resilience
- **Version**: 1.0.0
- **Status**: Draft
- **Owner**: Squadar engineering — unassigned
- **Author**: Jim Manico
- **Last Updated**: 2026-09-14
- **Priority**: High
- **Requirement Type**: Functional
- **Source / Parent**: REQ-UIKIT-000; `DESIGN.md` Layout and Spacing, Accessibility; `style-guide.html`

## Requirement

- **Statement**: The Web Client MUST provide a 12-column desktop grid with a 24 px gutter, 8 columns at tablet and 4 at mobile, a 1200 px centred content column with a minimum 16 px page gutter at every width, a 72-character cap on long-form text, and layout that survives 200% zoom and a 320 px viewport without horizontal page scrolling.
- **Rationale**: `DESIGN.md` states each of these values and makes 200% zoom and 320 px width an accessibility obligation rather than a nicety, with only tables and the chart permitted to scroll inside their own container.
- **Assumptions**: None — every value is stated.
- **Out of Scope**: The chart's own square sizing and its 280 px floor, which REQ-CHART-030 owns; the score table's horizontal scroll container, which REQ-CHART-070 owns.
- **Design Traceability**: `DESIGN.md` — Layout and Spacing (Grid, Density, Breakpoints table, Elevation), Accessibility (Text and zoom).
- **Architecture Traceability**: `ARCHITECTURE.md` Web Client — responsive grid as defined in `DESIGN.md`.
- **Security Traceability**: N/A — this issue introduces no security control and crosses no trust boundary.

## Scope

- **Applies To**: Web Client
- **Components**: Web Client
- **Interfaces / Operations**: The layout primitives every screen composes into
- **Actors**: All four roles, including users at 200% zoom and on 320 px viewports
- **Preconditions**: REQ-UIKIT-010 is Verified
- **Data Classification**: Public
- **Personal or Regulated Data**: None
- **Jurisdiction / Regulatory Scope**: N/A

## Security Context

- **Security Objectives**: N/A
- **Control Layers**: Other — presentation layout only
- **Threat References**: N/A — no threat mapping applies to layout geometry
- **Abuse / Misuse Case**: N/A
- **Trust Boundary**: N/A — no untrusted data enters a more trusted component here
- **Untrusted Inputs or Assertions**: N/A
- **Authoritative Enforcement Point**: N/A — the server remains the enforcement point for every business rule (DR-1); layout enforces nothing
- **Independent Verification**: N/A
- **Zero Trust Relevance**: N/A

## Standards Alignment

- **OWASP ASVS 5.0.0**: N/A — no verification requirement applies to layout geometry
- **OWASP AISVS 1.0**: N/A
- **NIST SP 800-53 Rev. 5**: N/A
- **NIST SP 800-207**: N/A
- **Regulatory**: N/A
- **Other**: W3C WCAG 2.2 Level AA — success criterion 1.4.10 Reflow, which `DESIGN.md`'s 200% zoom and 320 px requirement is written against
- **Mapping Basis**: 1.4.10 Reflow is the criterion that states content must be presentable without two-dimensional scrolling at 320 px equivalent width; `DESIGN.md` restates it with the table and chart exception the criterion itself allows.

## Acceptance Criteria

1. **AC-01 — Expected behavior**: Given a desktop viewport at or above 1024 px, when a screen with a chart and a selection panel renders, then the two sit side by side within a 12-column grid, the content column is at most 1200 px and centred, and a page gutter of at least 16 px is present.
2. **AC-02 — Boundary or failure behavior**: Given a 320 px viewport, or a 1280 px viewport at 200% zoom, when any screen renders, then the layout reflows to a single column and the page MUST NOT scroll horizontally; only a table or the chart may scroll inside its own container.
3. **AC-03 — Prohibited behavior**: Given any component, when it is inspected, then it MUST NOT declare a minimum width wider than 320 px, and long-form text (requirements, help, exam questions) MUST NOT exceed 72 characters per line.

## Failure Behavior

- **On Invalid Input**: N/A
- **On Authentication Failure**: N/A
- **On Authorization Failure**: N/A
- **On Security-Decision Failure**: N/A
- **On External Dependency Failure**: N/A
- **On System Error**: N/A
- **Logging / Audit**: N/A
- **Alerting**: N/A

## Test Strategy

- **Unit Tests**: Column count and gutter resolution at each breakpoint; content-column max width and gutter; the 72-character measure on the long-form container
- **Integration Tests**: A representative screen rendered at 320 px, 599 px, 600 px, 1023 px, 1024 px and 1440 px, asserting the behavior stated in `DESIGN.md`'s breakpoints table at each
- **Security Tests**: N/A — this issue introduces no security-relevant behavior
- **Compliance Tests / Evidence**: Automated reflow check at 320 px and at 200% zoom, asserting no horizontal page scroll; manual confirmation on a real viewport
- **Acceptance-Criteria Traceability**: AC-01 by the desktop layout test; AC-02 by the reflow check; AC-03 by a lint rule on minimum widths and a measure assertion on the long-form container
- **Coverage Target**: Every breakpoint boundary tested on both sides
- **Required Test Environment**: A renderer supporting viewport resizing and page zoom

## Dependencies

- **Upstream Requirements**: REQ-UIKIT-010
- **Downstream Requirements**: REQ-CHART-030, REQ-CHART-040, REQ-CHART-070, REQ-PORT-030, and every screen
- **External Dependencies**: None
- **Dependency Assumptions**: N/A
- **Failure Impact**: N/A

## Implementation Notes

- **Constraints**: One elevation level — `surface` on `background` separated by a 1 px `border`, with a shadow only on transient overlays (`DESIGN.md` Elevation). Density differs by surface: comfortable for forms and detail views, compact for score tables.
- **Prohibited Approaches**: A fixed-width layout with a horizontal page scrollbar at small widths; a minimum width that defeats reflow; ad-hoc gutter values outside the spacing scale
- **Implementation Guidance**: `DESIGN.md`'s breakpoint table already states the behavior at each range — build the grid from that table rather than inventing intermediate steps.
- **AI Development Guidance**: `CLAUDE.md`; read `DESIGN.md` and `style-guide.html` together
- **Required Human Review**: Accessibility reviewer for the reflow result
- **Open Decisions**: None
- **Estimated effort**: 0.5–1 engineer-day; 200–400 changed human-authored lines
- **Recommended model**: Claude Sonnet 5 (`claude-sonnet-5`) — a stated breakpoint table rendered as a grid, verified mechanically at each boundary.
