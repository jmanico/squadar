# [REQ-CHART-030] Render the shared radar chart with distinguishable series

> **BLOCKED — do not implement.** Blocked on `PQ-7`. See **Open Decisions**.

## Metadata

- **ID**: REQ-CHART-030
- **Title**: Render the shared radar chart with distinguishable series
- **Version**: 0.1.0
- **Status**: Draft
- **Owner**: Squadar engineering — unassigned
- **Author**: Jim Manico
- **Last Updated**: 2026-09-14
- **Priority**: Critical
- **Requirement Type**: Functional
- **Source / Parent**: REQ-CHART-000; `REQUIREMENTS.md` FR-7.1, FR-7.2, FR-7.3, FR-7.8, NFR-9.4; `ARCHITECTURE.md` Web Client open decisions

## Requirement

- **Statement**: The Web Client MUST display a selected team member's skills as a radar chart with one axis per skill scaled 1 to 10, MUST display multiple selected members on a single chart simultaneously, MUST visually distinguish each member's series and identify which series belongs to whom, and MUST update the chart whenever the selection changes.
- **Rationale**: This is the product's core artifact — `DESIGN.md` describes the logo itself as this chart drawn at logo scale. The requirement statement is determinate; what is not is the rendering approach, the library, and whether series geometry is computed client-side or returned by the API, all recorded as `TO BE DECIDED` in `ARCHITECTURE.md`.
- **Assumptions**: None — the rendering decisions are recorded as unresolved rather than assumed.
- **Out of Scope**: The dataset (REQ-CHART-010); the legend and its toggles (REQ-CHART-050); the empty state (REQ-CHART-060); the score table (REQ-CHART-070); performance at scale (REQ-CHART-090, blocked).
- **Design Traceability**: `DESIGN.md` — Charts (one axis per selected skill labelled at its vertex in Caption; rings at 2/4/6/8/10; each member's series drawn with a distinct hue plus a distinct line pattern and vertex shape; skills with no score break the polygon at that axis), Layout and Spacing (the radar chart is square and scales with its container, never below 280 px on a side; below that, show the tabular score view instead), Color Palette (`secondary` for plotted data; series lines meet 3:1 against the chart canvas), Accessibility (Not colour alone; Reduced motion; the chart carries a text alternative). `style-guide.html` is the rendered reference.
- **Architecture Traceability**: `ARCHITECTURE.md` Web Client — radar chart rendering approach and library `TO BE DECIDED`; whether chart series geometry is computed client-side or returned by the API `TO BE DECIDED`; Requirement Traceability marks FR-7.1–FR-7.11 `PARTIALLY DEFINED` for exactly this reason; DR-1, DR-7.
- **Security Traceability**: SEC-RENDER-2, SEC-RENDER-1, SEC-BIZ-4, SEC-HTTP-7, DEP-1…DEP-8.

## Scope

- **Applies To**: Web Client
- **Components**: Web Client; Chart Data Service (as the dataset source)
- **Interfaces / Operations**: The radar chart surface
- **Actors**: Administrator, Assessor, Team Member, Viewer — including users who cannot discriminate colour and users sensitive to motion
- **Preconditions**: REQ-CHART-010, REQ-CHART-020, REQ-UIKIT-020 and REQ-UIKIT-060 are Verified
- **Data Classification**: Restricted
- **Personal or Regulated Data**: Personal Data — the chart displays named individuals' performance
- **Jurisdiction / Regulatory Scope**: N/A

## Security Context

- **Security Objectives**: Integrity, Confidentiality, Safety
- **Control Layers**: Output Encoding, Supply Chain
- **Threat References**: STRIDE — Tampering; OWASP Top 10:2025 Injection; CWE-79 Improper Neutralization of Input During Web Page Generation; CWE-1104 Use of Unmaintained Third Party Components
- **Abuse / Misuse Case**: A member or skill name interpolated into SVG, canvas or style content in a way that becomes executable markup; a charting library with a large, opaque or unmaintained transitive tree pulled in to save a day's work; a library that requires an `unsafe-inline` CSP relaxation and thereby weakens SEC-HTTP-7 for the whole client.
- **Trust Boundary**: REST API → Web Client
- **Untrusted Inputs or Assertions**: Every member name, skill name and value in the dataset, at the point of rendering
- **Authoritative Enforcement Point**: The server remains the enforcement point for entitlement and limits (DR-1); this issue's own control is rendering from structured values rather than interpolated strings (SEC-RENDER-2)
- **Independent Verification**: A test rendering a chart whose member and skill names contain markup, asserting literal display (SEC-RENDER-2)
- **Zero Trust Relevance**: N/A — the client makes no access decision

## Standards Alignment

- **OWASP ASVS 5.0.0**: TO BE DECIDED — `PQ-17`
- **OWASP AISVS 1.0**: N/A
- **NIST SP 800-53 Rev. 5**: N/A
- **NIST SP 800-207**: N/A
- **Regulatory**: N/A
- **Other**: W3C WCAG 2.2 Level AA — 1.4.1 Use of Color, 1.4.11 Non-text Contrast, 1.1.1 Non-text Content (the chart's text alternative), 2.3.3 Animation from Interactions
- **Mapping Basis**: `DESIGN.md` states the chart must be distinguishable without colour, that series lines meet 3:1 against the canvas, that the chart carries a text alternative, and that series appear at their final position under reduced motion — each maps to one of the criteria named.

## Acceptance Criteria

Whether the API returns geometry or the client computes it changes what is rendered, what is tested,
and where SEC-RENDER-2's boundary falls. The library choice changes the accessibility and
reduced-motion story materially. Writing expected-behavior criteria now would resolve `PQ-7` by
implication. The criteria that hold under either answer are stated.

1. **AC-01 — Expected behavior**: BLOCKED on `PQ-7`.
2. **AC-02 — Boundary or failure behavior**: BLOCKED on `PQ-7` for rendering specifics. Independent of it: given a container narrower than 280 px, when the chart would render, then the tabular score view is shown instead (`DESIGN.md` Layout and Spacing).
3. **AC-03 — Prohibited behavior**: Given member and skill names containing HTML or SVG markup, when the chart renders, then they MUST be displayed literally and MUST NOT become executable markup (SEC-RENDER-2). Given six series, they MUST NOT be distinguishable by hue alone — each carries a distinct line pattern and vertex shape (NFR-9.4, `DESIGN.md` Charts). Given a member with no score for a shown axis, the polygon MUST break at that axis rather than plotting a value (FR-7.9, SEC-BIZ-4). All three hold regardless of how `PQ-7` is answered.

## Failure Behavior

- **On Invalid Input**: A malformed dataset is an error state, not a chart with gaps — the two must not be conflated (SEC-BIZ-4)
- **On Authentication Failure**: The chart surface shows nothing; the server returns no data (SEC-AUTHN-1)
- **On Authorization Failure**: The refusal is presented without indicating which member was withheld (SEC-AUTHZ-7)
- **On Security-Decision Failure**: N/A — the client makes no security decision (DR-1)
- **On External Dependency Failure**: If the charting library fails to load, fall back to the equivalent score table (REQ-CHART-070), which carries the same information (FR-6.2)
- **On System Error**: Present the server's product-term message; render no partial chart (SEC-ERR-1)
- **Logging / Audit**: N/A — the client logs no security event
- **Alerting**: N/A

## Test Strategy

- **Unit Tests**: BLOCKED on `PQ-7` for the geometry path; the series vocabulary assignment and the break-at-absent-axis rule are testable independently
- **Integration Tests**: BLOCKED on `PQ-7`
- **Security Tests**: A chart rendered with markup in every member and skill name, asserting literal display (SEC-RENDER-2, SEC-RENDER-1); a CSP compatibility check asserting the chosen approach needs no `unsafe-inline` relaxation (SEC-HTTP-7); a DEP-1…DEP-8 review of any library before it is added
- **Compliance Tests / Evidence**: WCAG 2.2 AA — greyscale identifiability of six series, 3:1 series-to-canvas contrast, the text alternative, keyboard reachability, and reduced-motion behavior
- **Acceptance-Criteria Traceability**: AC-02's 280 px clause and AC-03 by the rendering, greyscale and absence tests; AC-01 deferred with the criterion itself
- **Coverage Target**: Every series index up to the supported member count, in both modes and in greyscale; the absent-axis case on every series
- **Required Test Environment**: The `UT-10.1` fixture with unassessed skills present; greyscale and reduced-motion profiles; containers at and below 280 px

## Dependencies

- **Upstream Requirements**: REQ-CHART-010, REQ-CHART-020, REQ-UIKIT-010, REQ-UIKIT-020, REQ-UIKIT-060
- **Downstream Requirements**: REQ-CHART-050, REQ-CHART-060, REQ-CHART-090
- **External Dependencies**: A radar chart rendering library — `TO BE DECIDED` (`PQ-7`); `SECURITY.md` SEC-RENDER-2 directs that it be evaluated under DEP-1…DEP-8
- **Dependency Assumptions**: None may be made until the library is chosen. DEP-6 requires the complete transitive tree to be reviewed, and DEP-8 prefers the narrowest scope and smallest tree among suitable candidates.
- **Failure Impact**: The score table (REQ-CHART-070) carries the same information (FR-6.2), so a library failure degrades rather than blocks the product.

## Implementation Notes

- **Constraints**: The chart and the table read the same dataset (DR-7). The chart is square, scales with its container, and never renders below 280 px on a side.
- **Prohibited Approaches**: Interpolating a server-supplied string into SVG, canvas or style content (SEC-RENDER-2); hue-only series distinction (NFR-9.4); plotting a value for an unassessed skill (SEC-BIZ-4); adding a library without a DEP-1…DEP-8 justification in the pull request
- **Implementation Guidance**: None on the rendering approach while blocked. Note that `DESIGN.md` already specifies the visual result in full — rings at 2/4/6/8/10, Caption axis labels, distinct hue plus pattern plus vertex shape, broken polygon at an absent axis — so `PQ-7` is a question about mechanism, not appearance.
- **AI Development Guidance**: `CLAUDE.md`; read `DESIGN.md` and `style-guide.html` together; do not implement while BLOCKED
- **Required Human Review**: Architecture owner to answer `PQ-7`; security review of the library under DEP-1…DEP-8; accessibility review of the rendered result
- **Open Decisions**: **`PQ-7` (blocking)** — `ARCHITECTURE.md` Web Client: the radar chart rendering approach and library are `TO BE DECIDED`, and whether chart series geometry is computed client-side or returned by the API is `TO BE DECIDED`. `SECURITY.md` SEC-RENDER-2 records the same and requires the library to be evaluated under DEP-1…DEP-8. `PQ-8` is also recorded, since a server-side geometry choice would interact with the persistence and performance decisions.
- **Estimated effort**: Not estimated while blocked — client-side and server-side geometry differ materially in scope.
- **Recommended model**: Claude Opus 5 (`claude-opus-5`) — the product's core artifact, with an accessibility contract that is exacting and a rendering surface that is the client's main injection risk; to be confirmed once `PQ-7` fixes the approach.
