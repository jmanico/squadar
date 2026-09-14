# [REQ-UIKIT-000] Design language implementation

## Metadata

- **ID**: REQ-UIKIT-000
- **Title**: Design language implementation
- **Version**: 1.0.0
- **Status**: Draft
- **Owner**: Squadar engineering — unassigned
- **Author**: Jim Manico
- **Last Updated**: 2026-09-14
- **Priority**: High
- **Requirement Type**: Functional
- **Source / Parent**: REQ-EPIC-001; `DESIGN.md` in full; `style-guide.html`; `REQUIREMENTS.md` NFR-9.4, NFR-9.5

## Requirement

- **Statement**: The Web Client MUST implement the design language defined in `DESIGN.md` — tokens, type scale, spacing, grid, components, focus and form-feedback behavior — at WCAG 2.2 AA in both light and dark modes; delivery is the sum of its children.
- **Rationale**: `DESIGN.md` is the sole source of these values and `style-guide.html` is its rendered reference. Building them once as shared primitives is what lets every screen inherit AA conformance rather than re-earn it.
- **Assumptions**: The system font stack is the provisional primary family; the broader typography direction is `TO BE DECIDED` in `DESIGN.md` and does not block this work.
- **Out of Scope**: The radar chart itself (REQ-CHART-000); the mobile realization of the same design obligations (REQ-MOBILE-000).
- **Design Traceability**: `DESIGN.md` — Color Palette (light, dark, contrast table), Typography (type scale and weights), Layout and Spacing (spacing scale, grid, breakpoints, elevation), Components (Buttons, Inputs, Links, Focus states, Form feedback and errors), Accessibility (all bullets). `style-guide.html` is the reference implementation and changes with `DESIGN.md` in the same commit.
- **Architecture Traceability**: `ARCHITECTURE.md` Web Client — implements the design language, responsive grid and WCAG 2.2 AA conformance defined in `DESIGN.md`; DR-1 (client validation is a courtesy layer only).
- **Security Traceability**: SEC-RENDER-1, SEC-RENDER-3, SEC-HTTP-7, SEC-SECRET-3, SEC-SESSION-4.

## Scope

- **Applies To**: Web Client
- **Components**: Web Client
- **Interfaces / Operations**: The shared component primitives every screen composes — buttons, inputs, links, focus treatment, form feedback, layout grid, theme tokens
- **Actors**: Administrator, Assessor, Team Member, Viewer — including keyboard-only users and users of assistive technology
- **Preconditions**: None
- **Data Classification**: Public — the design system itself carries no product data
- **Personal or Regulated Data**: None
- **Jurisdiction / Regulatory Scope**: N/A

## Security Context

- **Security Objectives**: Integrity, Confidentiality, Safety
- **Control Layers**: Output Encoding, Architecture
- **Threat References**: STRIDE — Tampering (injected script through a rendered name); OWASP Top 10:2025 Injection
- **Abuse / Misuse Case**: A member, team or skill name containing markup rendered as HTML; a `javascript:` or `data:` URL in a link-bearing field; a secret embedded in the client bundle; a session token written to `localStorage`.
- **Trust Boundary**: REST API → Web Client — every server-supplied string is untrusted at the point of rendering
- **Untrusted Inputs or Assertions**: All server- and user-supplied text: member names, team names, skill names, exam question text, import error messages, chart axis and legend labels
- **Authoritative Enforcement Point**: The server remains the enforcement point for every business rule (DR-1); this workstream's own control is contextual escaping at render time
- **Independent Verification**: A lint rule banning raw-HTML injection props, independent of any individual component's implementation (SEC-RENDER-1)
- **Zero Trust Relevance**: N/A — the client makes no access decision

## Standards Alignment

- **OWASP ASVS 5.0.0**: TO BE DECIDED — `PQ-17`
- **OWASP AISVS 1.0**: N/A
- **NIST SP 800-53 Rev. 5**: N/A
- **NIST SP 800-207**: N/A
- **Regulatory**: N/A
- **Other**: W3C WCAG 2.2 Level AA — the conformance target `DESIGN.md` sets, for every screen, on both platform targets, in both modes
- **Mapping Basis**: WCAG 2.2 AA is named directly by `DESIGN.md`; `CLAUDE.md` makes it a build requirement that lands with the screen.

## Acceptance Criteria

1. **AC-01 — Expected behavior**: Given a screen composed from these primitives, when it is rendered in light and dark mode, then every colour pairing meets the ratio recorded in `DESIGN.md`'s contrast table and every value comes from a token rather than an ad-hoc literal.
2. **AC-02 — Boundary or failure behavior**: Given a keyboard-only user at 200% zoom and 320 px width, when they traverse the screen, then focus is always visible at 2 px with a 2 px offset, focus order follows reading order, no keyboard trap exists, and the page does not scroll horizontally (NFR-9.5, `DESIGN.md` Accessibility).
3. **AC-03 — Prohibited behavior**: Given a member or skill name containing HTML markup, when it is rendered in any primitive, then it MUST be displayed literally and MUST NOT be interpreted as markup (SEC-RENDER-1).

## Failure Behavior

- **On Invalid Input**: The form-feedback contract in `DESIGN.md` — error border, an icon or symbol beside the message, and message text naming what is wrong and what to do, programmatically tied to its input; validation on submit, and on blur only for a field already completed
- **On Authentication Failure**: N/A — presented by the screen, not by the primitives
- **On Authorization Failure**: N/A
- **On Security-Decision Failure**: N/A — the client makes no security decision (DR-1)
- **On External Dependency Failure**: A blocked or failed font or asset load MUST NOT leave text invisible; the system stack is the first fallback
- **On System Error**: Present the server's product-term message; never a stack trace or internal identifier (SEC-ERR-1)
- **Logging / Audit**: N/A — the client logs no security event
- **Alerting**: N/A

## Test Strategy

- **Unit Tests**: Token resolution in both modes; component variants and states; focus-ring presence and geometry; error-summary construction and focus movement
- **Integration Tests**: A composed form exercising validate-on-submit and validate-on-blur-when-completed; theme switch preserving state
- **Security Tests**: Lint rule banning raw-HTML injection props plus a rendering test with markup and script payloads in every displayed name field (SEC-RENDER-1); `javascript:`, `data:` and app-scheme values in link-bearing fields (SEC-RENDER-3); automated scan of the built bundle for secret-shaped values (SEC-SECRET-3); automated check that no token value reaches web storage or a URL (SEC-SESSION-4)
- **Compliance Tests / Evidence**: Automated WCAG 2.2 AA checks per primitive plus manual keyboard and screen-reader passes; contrast assertions against `DESIGN.md`'s table
- **Acceptance-Criteria Traceability**: AC-01 by REQ-UIKIT-010; AC-02 by REQ-UIKIT-020 and REQ-UIKIT-040; AC-03 by REQ-UIKIT-030
- **Coverage Target**: Every component state — default, hover, active, disabled, focus, error — covered in both modes
- **Required Test Environment**: `style-guide.html` as the visual reference; light and dark rendering; a keyboard-only and a reduced-motion profile

## Dependencies

- **Upstream Requirements**: REQ-FOUND-010
- **Downstream Requirements**: REQ-CHART-000, REQ-PORT-000, REQ-AUTH-000 (sign-in surfaces), REQ-ROSTER-000, REQ-SKILL-000, REQ-EXAM-000
- **Child Requirements**:
  - [ ] {{ISSUE_URL:REQ-UIKIT-010}} — Design tokens for colour, type and spacing in light and dark mode
  - [ ] {{ISSUE_URL:REQ-UIKIT-020}} — Responsive grid, breakpoints and zoom resilience
  - [ ] {{ISSUE_URL:REQ-UIKIT-030}} — Button, input and link primitives
  - [ ] {{ISSUE_URL:REQ-UIKIT-040}} — Focus states and full keyboard operability
  - [ ] {{ISSUE_URL:REQ-UIKIT-050}} — Form feedback, error messaging and error summary
  - [ ] {{ISSUE_URL:REQ-UIKIT-060}} — Non-colour encoding and reduced-motion conformance
- **External Dependencies**: None — the system font stack needs no network request, which is `DESIGN.md`'s stated reason for choosing it
- **Dependency Assumptions**: N/A
- **Failure Impact**: N/A

## Implementation Notes

- **Constraints**: Every value comes from `DESIGN.md`; a change to `DESIGN.md` and the matching change to `style-guide.html` land in the same commit (`CLAUDE.md`). No ad-hoc spacing values; no weights beyond 400, 500 and 600; never body text below 14 px.
- **Prohibited Approaches**: Colour as the sole indicator of state; removing focus without an equivalent replacement; a disabled control as the only signal that an action is unavailable; raw-HTML injection interfaces
- **Implementation Guidance**: Treat `style-guide.html` as the acceptance reference — a primitive is done when it matches it in both modes.
- **AI Development Guidance**: `CLAUDE.md`; read `DESIGN.md` and `style-guide.html` together before any UI work
- **Required Human Review**: Accessibility reviewer before merge on each child
- **Open Decisions**: None blocking. `DESIGN.md`'s broader typography direction is `TO BE DECIDED` and does not gate this work.
