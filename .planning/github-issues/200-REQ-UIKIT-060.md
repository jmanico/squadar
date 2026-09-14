# [REQ-UIKIT-060] Non-colour encoding and reduced-motion conformance

## Metadata

- **ID**: REQ-UIKIT-060
- **Title**: Non-colour encoding and reduced-motion conformance
- **Version**: 1.0.0
- **Status**: Draft
- **Owner**: Squadar engineering — unassigned
- **Author**: Jim Manico
- **Last Updated**: 2026-09-14
- **Priority**: High
- **Requirement Type**: Functional
- **Source / Parent**: REQ-UIKIT-000; `REQUIREMENTS.md` NFR-9.4; `DESIGN.md` Accessibility

## Requirement

- **Statement**: Score, state and chart series MUST be distinguishable without colour — a number, label, icon, line pattern or shape accompanying every hue — and under `prefers-reduced-motion: reduce` all non-essential animation and transition MUST be removed, with nothing flashing more than three times per second under any setting.
- **Rationale**: NFR-9.4 requires the radar chart to convey each series by a means other than colour alone. `DESIGN.md` generalizes that to score and state throughout, and adds the reduced-motion and flash obligations.
- **Assumptions**: NFR-9.4 is marked **(assumed)** in `REQUIREMENTS.md` and stands.
- **Out of Scope**: The chart's own series drawing, which REQ-CHART-030 implements using the shape and pattern vocabulary this issue defines; the legend, which REQ-CHART-050 owns.
- **Design Traceability**: `DESIGN.md` — Accessibility (Not colour alone; Reduced motion), Color Palette (chart series are distinguished by shape and line pattern in addition to hue, so the series palette carries no contrast obligation beyond 3:1 against the chart canvas), Charts (distinct hue plus a distinct line pattern and vertex shape per series).
- **Architecture Traceability**: `ARCHITECTURE.md` Web Client and Mobile Client — the same design and accessibility obligations on both platform targets.
- **Security Traceability**: N/A — this issue introduces no security control and crosses no trust boundary.

## Scope

- **Applies To**: Web Client
- **Components**: Web Client
- **Interfaces / Operations**: The shared series vocabulary (hue, line pattern, vertex shape) and the motion policy every animated surface obeys
- **Actors**: All four roles, in particular users who cannot discriminate colour and users sensitive to motion
- **Preconditions**: REQ-UIKIT-010 is Verified
- **Data Classification**: Public
- **Personal or Regulated Data**: None
- **Jurisdiction / Regulatory Scope**: N/A

## Security Context

- **Security Objectives**: Safety
- **Control Layers**: Other — presentation and interaction
- **Threat References**: N/A — no threat mapping applies to encoding and motion policy
- **Abuse / Misuse Case**: N/A
- **Trust Boundary**: N/A
- **Untrusted Inputs or Assertions**: N/A
- **Authoritative Enforcement Point**: N/A — the server enforces every business rule (DR-1)
- **Independent Verification**: N/A
- **Zero Trust Relevance**: N/A

## Standards Alignment

- **OWASP ASVS 5.0.0**: N/A — no verification requirement applies to visual encoding or motion
- **OWASP AISVS 1.0**: N/A
- **NIST SP 800-53 Rev. 5**: N/A
- **NIST SP 800-207**: N/A
- **Regulatory**: N/A
- **Other**: W3C WCAG 2.2 Level AA — 1.4.1 Use of Color, 1.4.11 Non-text Contrast, 2.2.2 Pause Stop Hide, 2.3.1 Three Flashes or Below Threshold, and 2.3.3 Animation from Interactions (AAA, which `DESIGN.md`'s reduced-motion rule exceeds AA to meet)
- **Mapping Basis**: 2.3.3 is listed explicitly as a AAA criterion the project chooses to meet, because `DESIGN.md` requires all non-essential animation to be removed under `prefers-reduced-motion` rather than merely offering a control.

## Acceptance Criteria

1. **AC-01 — Expected behavior**: Given a chart with six series, when it is rendered in greyscale, then each series remains identifiable by its line pattern and vertex shape alone, and each series line meets 3:1 against the chart canvas.
2. **AC-02 — Boundary or failure behavior**: Given a viewer with `prefers-reduced-motion: reduce`, when a chart renders or a state changes, then series appear at their final position without animating in, and no content moves, parallaxes or auto-advances.
3. **AC-03 — Prohibited behavior**: Given any score or state indicator, when it is rendered, then colour MUST NOT be its only distinguishing feature — a number, label, icon, pattern or shape accompanies every hue (NFR-9.4); and nothing MUST flash more than three times per second under any setting.

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

- **Unit Tests**: The series vocabulary assigns a distinct pattern and vertex shape per index up to the supported member count; the motion policy resolves to "no animation" under the reduced-motion preference
- **Integration Tests**: A rendered chart and a rendered state indicator asserted identifiable in a greyscale rendering
- **Security Tests**: N/A — this issue introduces no security-relevant behavior
- **Compliance Tests / Evidence**: Automated checks for 1.4.1, 1.4.11, 2.2.2 and 2.3.1; a reduced-motion profile pass; a manual greyscale review
- **Acceptance-Criteria Traceability**: AC-01 by the greyscale rendering test and the 3:1 assertion; AC-02 by the reduced-motion profile test; AC-03 by the indicator audit and the flash check
- **Coverage Target**: Every series index and every state indicator, in both modes and in greyscale
- **Required Test Environment**: A renderer supporting `prefers-reduced-motion` and greyscale simulation

## Dependencies

- **Upstream Requirements**: REQ-UIKIT-010
- **Downstream Requirements**: REQ-CHART-030, REQ-CHART-050, REQ-CHART-070
- **External Dependencies**: None
- **Dependency Assumptions**: N/A
- **Failure Impact**: N/A

## Implementation Notes

- **Constraints**: `DESIGN.md` states that the series palette carries no contrast obligation beyond 3:1 against the chart canvas precisely because shape and pattern carry the distinction — so the pattern and shape vocabulary is load-bearing, not decorative.
- **Prohibited Approaches**: Distinguishing series by hue alone; an animation that merely shortens rather than disappears under reduced motion; a score coloured to characterize it, which `DESIGN.md`'s brand direction forbids — nothing gamifies a low score
- **Implementation Guidance**: Define the vocabulary for at least the supported member count (FR-7.7, at least 6) so REQ-CHART-030 has a distinct pattern and shape available for every series it may draw.
- **AI Development Guidance**: `CLAUDE.md`; read `DESIGN.md` and `style-guide.html` together
- **Required Human Review**: Accessibility reviewer — the greyscale judgement is not fully automatable
- **Open Decisions**: None. If `OQ-5` raises the member limit, the vocabulary must extend to cover it.
- **Estimated effort**: 0.5–1 engineer-day; 200–350 changed human-authored lines
- **Recommended model**: Claude Sonnet 5 (`claude-sonnet-5`) — a bounded vocabulary and a motion policy, both stated in `DESIGN.md` and verified by automated checks plus one manual review.
