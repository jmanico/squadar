# [REQ-UIKIT-010] Design tokens for colour, type and spacing in light and dark mode

## Metadata

- **ID**: REQ-UIKIT-010
- **Title**: Design tokens for colour, type and spacing in light and dark mode
- **Version**: 1.0.0
- **Status**: Draft
- **Owner**: Squadar engineering — unassigned
- **Author**: Jim Manico
- **Last Updated**: 2026-09-14
- **Priority**: High
- **Requirement Type**: Functional
- **Source / Parent**: REQ-UIKIT-000; `DESIGN.md` Color Palette, Typography, Layout and Spacing; `style-guide.html`

## Requirement

- **Statement**: The Web Client MUST expose the nine colour tokens in both their light and dark values, the seven-step type scale, the nine-step 4 px spacing scale and the two font stacks exactly as `DESIGN.md` defines them, and every screen MUST take these values from tokens rather than literals.
- **Rationale**: `DESIGN.md` is the sole source of these values and records a contrast ratio for each pairing. Defining them once is what makes the AA ratios hold everywhere instead of being re-checked per screen.
- **Assumptions**: The system font stack is the provisional primary family; `DESIGN.md`'s broader typography direction is `TO BE DECIDED` and does not gate this.
- **Out of Scope**: The components that consume the tokens (REQ-UIKIT-030); the chart series palette, which `DESIGN.md` gives its own rule.
- **Design Traceability**: `DESIGN.md` — Color Palette (light-mode table, dark-mode table, logo colours, contrast table), Typography (primary family, numeric and code family, type scale, weights), Layout and Spacing (spacing scale, elevation). `style-guide.html` is the rendered reference and changes with `DESIGN.md` in the same commit.
- **Architecture Traceability**: `ARCHITECTURE.md` Web Client — implements the design language defined in `DESIGN.md`, which is the sole source of those values.
- **Security Traceability**: SEC-HTTP-7 (the Content Security Policy under which the token stylesheet is delivered), SEC-SECRET-3.

## Scope

- **Applies To**: Web Client
- **Components**: Web Client
- **Interfaces / Operations**: The token layer every screen and component imports; the light/dark mode switch
- **Actors**: All four roles, including users who rely on high contrast or a specific colour scheme
- **Preconditions**: REQ-FOUND-010 is Verified
- **Data Classification**: Public
- **Personal or Regulated Data**: None
- **Jurisdiction / Regulatory Scope**: N/A

## Security Context

- **Security Objectives**: Integrity
- **Control Layers**: Output Encoding, Architecture
- **Threat References**: STRIDE — Tampering; OWASP Top 10:2025 Security Misconfiguration
- **Abuse / Misuse Case**: A style delivery mechanism that requires an unsafe-inline CSP relaxation, widening the injection surface for every later screen.
- **Trust Boundary**: Web Client delivery — the response headers under which the stylesheet is served
- **Untrusted Inputs or Assertions**: N/A — token values are authored constants
- **Authoritative Enforcement Point**: N/A — this issue makes no security decision; it must not force a CSP relaxation on those that do
- **Independent Verification**: A header assertion test once the CSP directives are chosen (SEC-HTTP-7)
- **Zero Trust Relevance**: N/A

## Standards Alignment

- **OWASP ASVS 5.0.0**: TO BE DECIDED — `PQ-17`
- **OWASP AISVS 1.0**: N/A
- **NIST SP 800-53 Rev. 5**: N/A
- **NIST SP 800-207**: N/A
- **Regulatory**: N/A
- **Other**: W3C WCAG 2.2 Level AA — success criterion 1.4.3 Contrast (Minimum) and 1.4.11 Non-text Contrast, which `DESIGN.md`'s contrast table is written against
- **Mapping Basis**: `DESIGN.md` states the ratios and the AA target explicitly; the two criteria named are the ones its table measures.

## Acceptance Criteria

1. **AC-01 — Expected behavior**: Given the token layer, when each pairing in `DESIGN.md`'s contrast table is measured in its stated mode, then the computed ratio meets or exceeds the recorded value.
2. **AC-02 — Boundary or failure behavior**: Given a viewer whose system requests dark mode, when a screen renders, then every token resolves to its dark-mode value and no light-mode literal remains visible.
3. **AC-03 — Prohibited behavior**: Given any stylesheet or component in `web/`, when it is linted, then it MUST NOT contain an ad-hoc spacing value outside the nine-step scale, a font weight other than 400, 500 or 600, or body text below 14 px (`DESIGN.md` Typography, Layout and Spacing).

## Failure Behavior

- **On Invalid Input**: N/A
- **On Authentication Failure**: N/A
- **On Authorization Failure**: N/A
- **On Security-Decision Failure**: N/A
- **On External Dependency Failure**: None exists — `DESIGN.md` chose the system font stack precisely so no network request, licence or font-loading fallback flash is involved
- **On System Error**: A failed stylesheet load MUST NOT leave text invisible; the system stack and the `text` token are the first fallback
- **Logging / Audit**: N/A
- **Alerting**: N/A

## Test Strategy

- **Unit Tests**: Token resolution in light and dark mode; the type scale's size, line height and weight per step
- **Integration Tests**: A rendered page compared against `style-guide.html` in both modes
- **Security Tests**: A check that the delivery mechanism does not require an `unsafe-inline` style relaxation once SEC-HTTP-7's directives are chosen
- **Compliance Tests / Evidence**: Automated contrast assertion over every pairing in `DESIGN.md`'s table, in both modes
- **Acceptance-Criteria Traceability**: AC-01 by the contrast assertion suite; AC-02 by a dark-mode rendering test; AC-03 by the lint rules
- **Coverage Target**: Every token, in both modes
- **Required Test Environment**: A renderer able to compute contrast ratios; light and dark scheme profiles

## Dependencies

- **Upstream Requirements**: REQ-FOUND-010
- **Downstream Requirements**: REQ-UIKIT-020, REQ-UIKIT-030, REQ-UIKIT-040, REQ-UIKIT-050, REQ-UIKIT-060, and every UI issue
- **External Dependencies**: None
- **Dependency Assumptions**: N/A
- **Failure Impact**: N/A

## Implementation Notes

- **Constraints**: A change to `DESIGN.md` and the matching change to `style-guide.html` land in the same commit (`CLAUDE.md`). This issue implements those files; it does not amend them.
- **Prohibited Approaches**: Hard-coded hex values in components; a dark mode built by filtering the light palette rather than from the stated dark values; using `error` or `success` to characterize a person's score, which `DESIGN.md` forbids
- **Implementation Guidance**: `DESIGN.md` records `border` on `surface` at 1.4:1 as decorative only — never let a component make a border its sole indicator of state.
- **AI Development Guidance**: `CLAUDE.md`; read `DESIGN.md` and `style-guide.html` together
- **Required Human Review**: Accessibility reviewer for the contrast results
- **Open Decisions**: None
- **Estimated effort**: 0.5–1 engineer-day; 250–450 changed human-authored lines
- **Recommended model**: Claude Sonnet 5 (`claude-sonnet-5`) — a transcription of an explicit, fully enumerated value table into a token layer, verified by an automated contrast check.
