# [REQ-CHART-050] Legend that names every series and toggles its visibility

## Metadata

- **ID**: REQ-CHART-050
- **Title**: Legend that names every series and toggles its visibility
- **Version**: 1.0.0
- **Status**: Draft
- **Owner**: Squadar engineering — unassigned
- **Author**: Jim Manico
- **Last Updated**: 2026-09-14
- **Priority**: High
- **Requirement Type**: Functional
- **Source / Parent**: REQ-CHART-000; `REQUIREMENTS.md` FR-7.3, FR-7.9, FR-7.11, NFR-9.4, NFR-9.5; `DESIGN.md` Charts

## Requirement

- **Statement**: A legend MUST name every series on a shared chart and identify which series belongs to which team member; each legend entry MUST toggle its series' visibility without changing the underlying selection; and a member with no score for a shown skill MUST be marked in the legend rather than plotted as a value.
- **Rationale**: FR-7.3 requires each series to be identifiable by member. FR-7.11 makes visibility a view concern distinct from selection, so hiding a series does not remove that person from the comparison being built. `DESIGN.md` assigns the absence marking to the legend as well as to the polygon.
- **Assumptions**: FR-7.11 is marked **(assumed)** in `REQUIREMENTS.md` and stands.
- **Out of Scope**: The chart drawing itself (REQ-CHART-030, blocked); the selection controls (REQ-CHART-040); the series pattern and shape vocabulary (REQ-UIKIT-060).
- **Design Traceability**: `DESIGN.md` — Charts (a legend names every series, and each legend entry toggles its series; skills with no score for a member are marked in the legend rather than plotted as a value), Color Palette (chart series are distinguished by shape and line pattern in addition to hue), Accessibility (Not colour alone; Keyboard: toggling chart series is keyboard-operable), Layout and Spacing (Desktop: the chart and its selection/legend panel sit side by side).
- **Architecture Traceability**: `ARCHITECTURE.md` Web Client — series visibility per FR-7.11 is transient view state the client owns; DR-7 (the legend reads the same dataset as the chart and table).
- **Security Traceability**: SEC-RENDER-1, SEC-BIZ-4, SEC-DATA-4.

## Scope

- **Applies To**: Web Client
- **Components**: Web Client
- **Interfaces / Operations**: The chart legend; per-series visibility toggle
- **Actors**: Administrator, Assessor, Team Member, Viewer — including keyboard-only users and users who cannot discriminate colour
- **Preconditions**: REQ-CHART-010, REQ-UIKIT-040 and REQ-UIKIT-060 are Verified
- **Data Classification**: Restricted — the legend names individuals alongside their series
- **Personal or Regulated Data**: Personal Data
- **Jurisdiction / Regulatory Scope**: N/A

## Security Context

- **Security Objectives**: Confidentiality, Integrity
- **Control Layers**: Output Encoding
- **Threat References**: STRIDE — Tampering; OWASP Top 10:2025 Injection; CWE-79 Improper Neutralization of Input During Web Page Generation
- **Abuse / Misuse Case**: A member name containing markup rendered as HTML in a legend entry; a hidden series' data still present in the payload and recoverable, when the user believed hiding it removed it — though under FR-7.11 hiding is explicitly a view operation, so this is a user-expectation matter rather than an entitlement one.
- **Trust Boundary**: REST API → Web Client
- **Untrusted Inputs or Assertions**: Member names rendered into legend entries
- **Authoritative Enforcement Point**: The server scopes which members may appear at all (SEC-AUTHZ-3, REQ-CHART-010); visibility here is presentational
- **Independent Verification**: A rendering test with markup payloads in every displayed name field (SEC-RENDER-1)
- **Zero Trust Relevance**: N/A — the client makes no access decision

## Standards Alignment

- **OWASP ASVS 5.0.0**: TO BE DECIDED — `PQ-17`
- **OWASP AISVS 1.0**: N/A
- **NIST SP 800-53 Rev. 5**: N/A
- **NIST SP 800-207**: N/A
- **Regulatory**: N/A
- **Other**: W3C WCAG 2.2 Level AA — 1.4.1 Use of Color, 2.1.1 Keyboard, 4.1.2 Name Role Value, 1.4.11 Non-text Contrast
- **Mapping Basis**: `DESIGN.md` requires the legend to identify series without relying on colour and to be keyboard-operable; each maps to one criterion named.

## Acceptance Criteria

1. **AC-01 — Expected behavior**: Given a chart with four series, when the legend renders, then it contains four entries, each naming its team member and showing that series' hue, line pattern and vertex shape, so the series can be identified without colour (FR-7.3, NFR-9.4).
2. **AC-02 — Boundary or failure behavior**: Given a legend entry, when it is activated by pointer or by keyboard, then its series' visibility toggles, the underlying member selection is unchanged, and re-activating restores it (FR-7.11, NFR-9.5).
3. **AC-03 — Prohibited behavior**: Given a member with no score for a shown skill, when the legend renders, then that absence MUST be marked in the legend and MUST NOT be represented by plotting a value on the chart (FR-7.9, `DESIGN.md` Charts, SEC-BIZ-4); and a member name containing markup MUST NOT be rendered as markup (SEC-RENDER-1).

## Failure Behavior

- **On Invalid Input**: N/A — the legend renders from the dataset, which REQ-CHART-010 validates
- **On Authentication Failure**: The chart surface shows nothing (SEC-AUTHN-1)
- **On Authorization Failure**: Members the caller may not see never reach the dataset, so they never reach the legend (SEC-AUTHZ-3)
- **On Security-Decision Failure**: N/A — the client makes no security decision
- **On External Dependency Failure**: N/A
- **On System Error**: The legend renders from the last good dataset or not at all; it MUST NOT render entries for series the chart is not drawing
- **Logging / Audit**: N/A
- **Alerting**: N/A

## Test Strategy

- **Unit Tests**: Legend entry construction per series; the toggle's effect on visibility state and its non-effect on selection state; the absence marking
- **Integration Tests**: Toggling a series and asserting the selection sent on the next dataset request is unchanged (FR-7.11); the legend and chart reading the same dataset (DR-7)
- **Security Tests**: Markup payloads in every member name asserted to render literally in legend entries (SEC-RENDER-1)
- **Compliance Tests / Evidence**: WCAG 2.2 AA — greyscale identifiability of every legend entry, keyboard activation of each toggle, accessible name and pressed state on each entry, and 3:1 contrast on the pattern and shape swatches
- **Acceptance-Criteria Traceability**: AC-01 by the legend construction and greyscale tests; AC-02 by the toggle tests; AC-03 by the absence-marking test and the rendering test
- **Coverage Target**: Every series index up to the supported member count, in both modes, in greyscale, by pointer and by keyboard
- **Required Test Environment**: The `UT-10.1` fixture with a member having an unassessed skill among the selected axes; greyscale and keyboard-only profiles

## Dependencies

- **Upstream Requirements**: REQ-CHART-010, REQ-UIKIT-030, REQ-UIKIT-040, REQ-UIKIT-060
- **Downstream Requirements**: None
- **External Dependencies**: None
- **Dependency Assumptions**: N/A
- **Failure Impact**: N/A

## Implementation Notes

- **Constraints**: Visibility is transient view state the client owns (`ARCHITECTURE.md` Web Client); it is never persisted server-side and never alters the selection.
- **Prohibited Approaches**: A toggle that removes the member from the selection, which would change the dataset and defeat FR-7.11; a legend that distinguishes series by hue alone; representing an absent score as a plotted value anywhere
- **Implementation Guidance**: Build this before REQ-CHART-030 unblocks — the legend is fully specified by `DESIGN.md` and is testable against the dataset alone, and it carries the absence marking that the chart's broken polygon only complements.
- **AI Development Guidance**: `CLAUDE.md`; read `DESIGN.md` and `style-guide.html` together
- **Required Human Review**: Accessibility reviewer for the greyscale and keyboard behavior
- **Open Decisions**: None blocking. `PQ-7` blocks the chart drawing, not the legend.
- **Estimated effort**: 0.5–1 engineer-day; 250–450 changed human-authored lines
- **Recommended model**: Claude Sonnet 5 (`claude-sonnet-5`) — a small, fully specified control whose accessibility obligations are enumerated and mechanically checkable.
