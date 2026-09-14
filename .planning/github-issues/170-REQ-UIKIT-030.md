# [REQ-UIKIT-030] Button, input and link primitives

## Metadata

- **ID**: REQ-UIKIT-030
- **Title**: Button, input and link primitives
- **Version**: 1.0.0
- **Status**: Draft
- **Owner**: Squadar engineering — unassigned
- **Author**: Jim Manico
- **Last Updated**: 2026-09-14
- **Priority**: High
- **Requirement Type**: Functional
- **Source / Parent**: REQ-UIKIT-000; `DESIGN.md` Components; `style-guide.html`

## Requirement

- **Statement**: The Web Client MUST provide button, input and link primitives matching `DESIGN.md` — three button variants with a 44×44 px minimum hit target and a busy state for slow actions, inputs with a persistent visible label and 16 px text, and links that never lose their underline in prose — and all of them MUST render server- and user-supplied text through contextual escaping.
- **Rationale**: These are the primitives every screen composes. `DESIGN.md` states each variant, state and dimension; SEC-RENDER-1 makes escaping at this layer the control that protects every name field in the product.
- **Assumptions**: None — every value is stated.
- **Out of Scope**: Focus ring geometry and keyboard traversal (REQ-UIKIT-040); error presentation and the error summary (REQ-UIKIT-050); the checkable selection list with its count, which REQ-CHART-040 builds on these primitives.
- **Design Traceability**: `DESIGN.md` — Components (Buttons: primary, secondary, destructive; hover, active, disabled; busy state; 44×44 minimum. Inputs: persistent visible label, 1 px border on surface, rounded 4 px, 16 px text, helper text in Small/`text-muted`, required marked in the label not by colour. Links: `secondary`, underlined in prose).
- **Architecture Traceability**: `ARCHITECTURE.md` Web Client — presents client-side validation as a courtesy layer only (DR-1).
- **Security Traceability**: SEC-RENDER-1, SEC-RENDER-3.

## Scope

- **Applies To**: Web Client
- **Components**: Web Client
- **Interfaces / Operations**: Every form, action and navigation surface in the product
- **Actors**: All four roles, including pointer, keyboard and assistive-technology users
- **Preconditions**: REQ-UIKIT-010 is Verified
- **Data Classification**: Internal — the primitives display product data supplied to them
- **Personal or Regulated Data**: Personal Data — member names pass through these primitives
- **Jurisdiction / Regulatory Scope**: N/A

## Security Context

- **Security Objectives**: Integrity, Confidentiality
- **Control Layers**: Output Encoding
- **Threat References**: STRIDE — Tampering; OWASP Top 10:2025 Injection
- **Abuse / Misuse Case**: An Administrator, or an imported row, supplying a member, team or skill name containing HTML or script, which a later screen renders as markup; a `javascript:` or `data:` URL reaching a link primitive.
- **Trust Boundary**: REST API → Web Client — every server-supplied string is untrusted at render time
- **Untrusted Inputs or Assertions**: Member names, team names, skill names, exam question text, import error messages, and any URL-bearing field
- **Authoritative Enforcement Point**: The server remains the enforcement point for business rules (DR-1); this issue's control is contextual escaping and scheme allow-listing at render time
- **Independent Verification**: A lint rule banning raw-HTML injection props, applied repository-wide rather than component by component (SEC-RENDER-1)
- **Zero Trust Relevance**: N/A

## Standards Alignment

- **OWASP ASVS 5.0.0**: TO BE DECIDED — `PQ-17`
- **OWASP AISVS 1.0**: N/A
- **NIST SP 800-53 Rev. 5**: N/A
- **NIST SP 800-207**: N/A
- **Regulatory**: N/A
- **Other**: W3C WCAG 2.2 Level AA — success criterion 2.5.8 Target Size (Minimum) and 3.3.2 Labels or Instructions, which `DESIGN.md`'s 44×44 target and persistent-label rules exceed and restate respectively
- **Mapping Basis**: Both criteria are named because `DESIGN.md` states concrete values (44×44 px; a persistent visible label, never a placeholder) that map directly onto them.

## Acceptance Criteria

1. **AC-01 — Expected behavior**: Given each button variant, when it is rendered, then its hit target is at least 44×44 px, hover darkens the fill or border by a perceptible step, active depresses it further, and disabled drops opacity and removes the pointer cursor.
2. **AC-02 — Boundary or failure behavior**: Given a button that starts a slow action, when it is activated, then it shows a busy state and stays disabled until the action resolves, so it cannot be clicked twice.
3. **AC-03 — Prohibited behavior**: Given a skill named `<img src=x onerror=alert(1)>`, when it is rendered in any of these primitives, then it MUST be displayed literally; and given a link field whose value is `javascript:alert(1)`, the primitive MUST NOT navigate to it (SEC-RENDER-1, SEC-RENDER-3).

## Failure Behavior

- **On Invalid Input**: The primitive surfaces the error contract REQ-UIKIT-050 defines; it does not invent its own
- **On Authentication Failure**: N/A
- **On Authorization Failure**: N/A
- **On Security-Decision Failure**: A URL whose scheme is not on the allow-list is not navigated to, embedded or opened (SEC-RENDER-3)
- **On External Dependency Failure**: N/A
- **On System Error**: A button whose action fails leaves the busy state and re-enables, rather than staying disabled with no explanation
- **Logging / Audit**: N/A
- **Alerting**: N/A

## Test Strategy

- **Unit Tests**: Each variant in each state — default, hover, active, disabled, busy; input label persistence; required-field marking in the label; helper-text placement and style
- **Integration Tests**: A composed form exercising a slow submit, asserting a single submission
- **Security Tests**: A rendering test with markup and script payloads in every displayed name field, plus the repository lint rule banning raw-HTML injection props (SEC-RENDER-1); `javascript:`, `data:` and app-scheme values in link-bearing fields (SEC-RENDER-3)
- **Compliance Tests / Evidence**: Target-size measurement per variant; accessible-name assertion per primitive; contrast assertion on every state in both modes
- **Acceptance-Criteria Traceability**: AC-01 by the variant-state suite; AC-02 by the slow-submit test; AC-03 by the escaping and scheme tests
- **Coverage Target**: Every variant × every state × both modes
- **Required Test Environment**: A renderer supporting hover, active and disabled simulation; light and dark profiles

## Dependencies

- **Upstream Requirements**: REQ-UIKIT-010
- **Downstream Requirements**: REQ-UIKIT-050, REQ-CHART-040, REQ-CHART-050, REQ-PORT-030, and every form surface
- **External Dependencies**: None
- **Dependency Assumptions**: N/A
- **Failure Impact**: N/A

## Implementation Notes

- **Constraints**: One primary action per view (`DESIGN.md` Buttons). The destructive variant is reserved for deletion and deactivation. Input text is 16 px so mobile browsers do not zoom on focus.
- **Prohibited Approaches**: A placeholder used as the label; a required field marked by colour alone; a disabled control as the only signal that an action is unavailable — `DESIGN.md` requires adjacent text saying why; raw-HTML injection interfaces
- **Implementation Guidance**: Score entry accepts only integers 1–10 and states that range in helper text before the user errs (`DESIGN.md` Inputs, FR-4.2) — build that as a variant here so REQ-SCORE-020's server rule has a matching courtesy layer (DR-1).
- **AI Development Guidance**: `CLAUDE.md`; read `DESIGN.md` and `style-guide.html` together
- **Required Human Review**: Accessibility reviewer; security reviewer for the escaping and scheme allow-list
- **Open Decisions**: None
- **Estimated effort**: 1–2 engineer-days; 500–800 changed human-authored lines
- **Recommended model**: Claude Sonnet 5 (`claude-sonnet-5`) — a fully specified component set; the one security-sensitive part, contextual escaping, is a framework default backed by a lint rule rather than hand-written logic.
