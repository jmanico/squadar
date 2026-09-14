# [REQ-UIKIT-040] Focus states and full keyboard operability

## Metadata

- **ID**: REQ-UIKIT-040
- **Title**: Focus states and full keyboard operability
- **Version**: 1.0.0
- **Status**: Draft
- **Owner**: Squadar engineering — unassigned
- **Author**: Jim Manico
- **Last Updated**: 2026-09-14
- **Priority**: High
- **Requirement Type**: Functional
- **Source / Parent**: REQ-UIKIT-000; `REQUIREMENTS.md` NFR-9.5; `DESIGN.md` Focus states, Accessibility

## Requirement

- **Statement**: Every interactive element MUST show a 2 px `secondary` focus outline with a 2 px offset on keyboard focus, visible against both `surface` and `background` and never clipped by an ancestor's overflow, and everything a pointer can do a keyboard MUST be able to do, with no keyboard trap, focus order following reading order, a skip link preceding the main content, and dialogs returning focus to the element that opened them.
- **Rationale**: NFR-9.5 requires every user-facing screen to be operable by keyboard alone, and `DESIGN.md` fixes the focus geometry and the traversal rules that make that real rather than nominal.
- **Assumptions**: NFR-9.5 is marked **(assumed)** in `REQUIREMENTS.md` and stands.
- **Out of Scope**: Chart-specific keyboard behavior — selecting members and skills and toggling series — which REQ-CHART-040 and REQ-CHART-050 implement against the primitives this issue provides.
- **Design Traceability**: `DESIGN.md` — Components (Focus states: 2 px `secondary` outline, 2 px offset, never removed without an equivalent replacement, not suppressed for subsequent keyboard use by mouse interaction), Accessibility (Visible focus, Keyboard, Names and structure).
- **Architecture Traceability**: `ARCHITECTURE.md` Web Client — WCAG 2.2 AA conformance defined in `DESIGN.md`.
- **Security Traceability**: N/A — this issue introduces no security control and crosses no trust boundary.

## Scope

- **Applies To**: Web Client
- **Components**: Web Client
- **Interfaces / Operations**: Focus treatment; tab order; skip link; dialog focus management
- **Actors**: All four roles, in particular keyboard-only and assistive-technology users
- **Preconditions**: REQ-UIKIT-010 and REQ-UIKIT-030 are Verified
- **Data Classification**: Public
- **Personal or Regulated Data**: None
- **Jurisdiction / Regulatory Scope**: N/A

## Security Context

- **Security Objectives**: Safety
- **Control Layers**: Other — interaction and presentation
- **Threat References**: N/A — no threat mapping applies to focus management
- **Abuse / Misuse Case**: N/A
- **Trust Boundary**: N/A
- **Untrusted Inputs or Assertions**: N/A
- **Authoritative Enforcement Point**: N/A — the server enforces every business rule (DR-1)
- **Independent Verification**: N/A
- **Zero Trust Relevance**: N/A

## Standards Alignment

- **OWASP ASVS 5.0.0**: N/A — no verification requirement applies to focus geometry
- **OWASP AISVS 1.0**: N/A
- **NIST SP 800-53 Rev. 5**: N/A
- **NIST SP 800-207**: N/A
- **Regulatory**: N/A
- **Other**: W3C WCAG 2.2 Level AA — 2.1.1 Keyboard, 2.1.2 No Keyboard Trap, 2.4.1 Bypass Blocks, 2.4.3 Focus Order, 2.4.7 Focus Visible, 2.4.11 Focus Not Obscured (Minimum), 2.4.13 Focus Appearance
- **Mapping Basis**: Each criterion is named because `DESIGN.md` states the corresponding behavior explicitly — keyboard parity, no trap, a skip link, reading-order focus, always-visible focus, focus never behind a sticky header or overlay, and a 2 px ring at 2 px offset meeting 3:1.

## Acceptance Criteria

1. **AC-01 — Expected behavior**: Given a keyboard-only user on any screen, when they traverse it with Tab and Shift+Tab, then every interactive element receives focus in reading order, the focus ring is 2 px at a 2 px offset and meets 3:1 against both the component and the background, and every action reachable by pointer is reachable and operable by keyboard (NFR-9.5).
2. **AC-02 — Boundary or failure behavior**: Given a dialog or overlay, when it opens and is then dismissed, then focus is confined to it while open, no keyboard trap exists, and on close focus returns to the element that opened it.
3. **AC-03 — Prohibited behavior**: Given any screen with a sticky header or overlay, when an element behind it receives focus, then the focus ring MUST NOT be clipped or obscured; and mouse interaction MUST NOT suppress focus visibility for subsequent keyboard use.

## Failure Behavior

- **On Invalid Input**: N/A
- **On Authentication Failure**: N/A
- **On Authorization Failure**: N/A
- **On Security-Decision Failure**: N/A
- **On External Dependency Failure**: N/A
- **On System Error**: If a dialog's opener has been removed from the document, focus returns to the nearest stable ancestor rather than to the document body without announcement
- **Logging / Audit**: N/A
- **Alerting**: N/A

## Test Strategy

- **Unit Tests**: Focus-ring geometry and contrast per primitive in both modes; skip-link presence and target; focus-return behavior on dialog close
- **Integration Tests**: A full keyboard traversal of a representative screen asserting order, reachability and absence of a trap
- **Security Tests**: N/A — this issue introduces no security-relevant behavior
- **Compliance Tests / Evidence**: Automated checks for 2.1.1, 2.1.2, 2.4.1, 2.4.3, 2.4.7 and 2.4.11, plus a manual keyboard-only pass and a screen-reader pass recording accessible names and heading nesting
- **Acceptance-Criteria Traceability**: AC-01 by the traversal test and the ring-contrast assertions; AC-02 by the dialog focus tests; AC-03 by an overflow-clipping test and a mouse-then-keyboard sequence test
- **Coverage Target**: Every interactive primitive covered for focus visibility and keyboard operation, in both modes
- **Required Test Environment**: A keyboard-only profile; a screen reader for the manual pass

## Dependencies

- **Upstream Requirements**: REQ-UIKIT-010, REQ-UIKIT-030
- **Downstream Requirements**: REQ-UIKIT-050, REQ-CHART-040, REQ-CHART-050, REQ-CHART-070, REQ-EXAM-030, and every screen
- **External Dependencies**: None
- **Dependency Assumptions**: N/A
- **Failure Impact**: N/A

## Implementation Notes

- **Constraints**: `CLAUDE.md` makes the accessibility conformance target a build requirement that lands with the screen, not a later pass — this issue is the shared mechanism that lets that hold.
- **Prohibited Approaches**: Removing focus without an equivalent replacement; a positive `tabindex` that decouples focus order from reading order; an ancestor `overflow: hidden` that clips the ring
- **Implementation Guidance**: Taking and submitting an exam and paging score tables are named explicitly in `DESIGN.md` as keyboard obligations — build the primitives so those screens inherit them rather than re-solving focus locally.
- **AI Development Guidance**: `CLAUDE.md`; read `DESIGN.md` and `style-guide.html` together
- **Required Human Review**: Accessibility reviewer — the manual keyboard and screen-reader passes are not replaceable by automated checks
- **Open Decisions**: None
- **Estimated effort**: 1–1.5 engineer-days; 300–500 changed human-authored lines
- **Recommended model**: Claude Sonnet 5 (`claude-sonnet-5`) — well-specified interaction behavior against named WCAG criteria, with the residual judgement handled by the required manual review.
